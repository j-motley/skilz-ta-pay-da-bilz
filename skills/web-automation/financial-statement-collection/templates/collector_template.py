"""
collector_template.py — Starting point for a bank / credit card collector.

Written against the `webauto` reference implementation (drop it into
src/webauto/sites/<name>.py, or register it from another project). The
structure carries over to any implementation of the collector contract in
references/collector-contract.md.

Replace every EXAMPLE selector/URL with what recon found for the real portal.
"""

from datetime import date, datetime, timedelta
from urllib.parse import urljoin

from webauto.collector import Collector, Document
from webauto.config import LoginForm, SiteConfig
from webauto.downloads import DownloadError, click_to_file, save_download

BASE = "https://www.example-bank.com"          # EXAMPLE
STATEMENTS = f"{BASE}/documents/statements"     # EXAMPLE
ACTIVITY = f"{BASE}/accounts/activity"          # EXAMPLE


def _logged_in(page) -> bool:
    # Bank URLs often contain "auth"/"login" even when signed in — test an element.
    return page.locator("text=Sign out").count() > 0


SITE = SiteConfig(
    name="example-bank",
    login_url=f"{BASE}/login",
    verify_url=f"{BASE}/accounts/summary",
    login_form=LoginForm(
        user="#userId",
        password="#password",
        submit="button[type=submit]",
        two_step=True,                    # username screen, then password screen
        # otp="input[name=otpCode]",      # only if the bank accepts authenticator codes
    ),
    logged_in=_logged_in,
    manual_login_timeout=600,             # time for SMS/push MFA on first login
)


def _accounts(page):
    """(label, value) for each account in the selector, e.g. ('checking-1234', '8f3a…')."""
    opts = page.locator("select#account option")
    out = []
    for i in range(opts.count()):
        text = opts.nth(i).inner_text().strip()          # "Checking ...1234"
        last4 = "".join(ch for ch in text if ch.isdigit())[-4:]
        kind = "visa" if "visa" in text.lower() else text.split()[0].lower()
        out.append((f"{kind}-{last4}", opts.nth(i).get_attribute("value")))
    return out


def _month_windows(months_back: int, since=None):
    """Non-overlapping calendar-month windows ending with last full month."""
    end = date.today().replace(day=1) - timedelta(days=1)
    for _ in range(months_back):
        start = end.replace(day=1)
        if since and end < since:
            return
        yield start, end
        end = start - timedelta(days=1)


class ExampleBankCollector(Collector):
    site = SITE
    export_months = 3                     # portal's export range limit, in months

    def list_documents(self, s, since=None):
        s.goto(STATEMENTS)
        for label, value in _accounts(s.page):
            s.page.select_option("select#account", value)
            s.page.locator("table.statements tbody tr").first.wait_for()
            rows = s.page.locator("table.statements tbody tr")
            for i in range(rows.count()):
                row = rows.nth(i)
                when = datetime.strptime(row.locator("td").nth(0).inner_text().strip(),
                                         "%m/%d/%Y").date()
                if since and when < since:
                    break                             # newest-first listing
                href = row.locator("a").first.get_attribute("href")
                yield Document(
                    account=label, date=when, kind="statement",
                    url=urljoin(s.page.url, href) if href and href.startswith(("/", "http")) else None,
                    title=f"{label} statement {when}",
                    meta={"account_value": value, "row": i},
                )

            # Transaction exports: one document per settled calendar month.
            for start, end in _month_windows(self.export_months, since):
                yield Document(
                    account=label, date=end, kind="transactions", ext="csv",
                    title=f"{label} transactions {start}..{end}",
                    meta={"account_value": value, "start": start.isoformat(),
                          "end": end.isoformat()},
                )

    def fetch(self, s, doc, dest):
        if doc.kind == "transactions":
            return self._export_csv(s, doc, dest)
        if doc.url:
            return super().fetch(s, doc, dest)        # direct link, session cookies
        s.goto(STATEMENTS)
        s.page.select_option("select#account", doc.meta["account_value"])
        row = s.page.locator("table.statements tbody tr").nth(doc.meta["row"])
        # Download OR a PDF opened in a new tab — whichever the bank does.
        return click_to_file(s.page, lambda: row.locator("a").first.click(), dest)

    def _export_csv(self, s, doc, dest):
        s.goto(ACTIVITY)
        p = s.page
        p.select_option("select#account", doc.meta["account_value"])
        p.locator("text=Download").click()
        p.fill("input[name=fromDate]", _mdY(doc.meta["start"]))
        p.fill("input[name=toDate]", _mdY(doc.meta["end"]))
        p.select_option("select[name=format]", "CSV")
        path = save_download(p, lambda: p.locator("button:has-text('Export')").click(),
                             dest, expect=None)       # CSV has no magic bytes
        _check_csv(path)
        return path


def _mdY(iso: str) -> str:
    return datetime.fromisoformat(iso).strftime("%m/%d/%Y")


def _check_csv(path, required=("date", "amount")):
    raw = path.read_bytes()
    text = raw.decode("utf-8-sig", errors="replace").lstrip()
    if not text or text.startswith("<"):
        path.unlink(missing_ok=True)
        raise DownloadError("Expected CSV but got HTML/empty (session expired?)")
    header = text.splitlines()[0].lower()
    if not all(col in header for col in required):
        path.unlink(missing_ok=True)
        raise DownloadError(f"Unexpected CSV header: {header[:120]}")


COLLECTOR = ExampleBankCollector
