# Collector Contract

## Document

```python
@dataclass
class Document:
    account: str                 # stable label: "checking-1234", "visa-9876", "electric"
    date: date                   # statement period end / bill date / export range end
    kind: str = "statement"      # statement | transactions | bill | invoice | tax-form | notice
    id: str | None = None        # unique within the site; default f"{account}:{kind}:{date}"
    url: str | None = None       # direct link, if the listing exposes one
    title: str = ""              # human description for logs
    ext: str = "pdf"             # pdf | csv | ofx | qfx | qbo | xlsx | zip
    meta: dict = field(default_factory=dict)   # whatever fetch() needs: row index, doc ids, range

    def filename(self, site):    # 2026-09-30_mybank_checking-1234_statement.pdf
        return f"{self.date:%Y-%m-%d}_{site}_{safe(self.account)}_{safe(self.kind)}.{self.ext}"

    def relpath(self, site):     # mybank/checking-1234/2026/<filename>
        return Path(site) / safe(self.account) / f"{self.date:%Y}" / self.filename(site)
```

`safe()` lowercases and replaces every run of non-alphanumeric characters with `-`, so `"Checking ...1234"` becomes `checking-1234`.

## Collector

```python
class Collector(ABC):
    site: SiteConfig

    @abstractmethod
    def list_documents(self, s, since=None) -> Iterable[Document]:
        """Yield what's available. `s` is an authenticated session. Filtering by
        `since` here is optional (the runner filters too) but saves time."""

    def fetch(self, s, doc, dest) -> Path:
        """Save doc to dest. Default: download doc.url with the session's cookies."""
        if not doc.url:
            raise NotImplementedError("implement fetch() when documents have no url")
        return fetch_url(s.page, doc.url, dest, expect=doc.ext)
```

### Rules for `list_documents`

- Only read: no downloads, no state changes. Dry runs depend on this.
- Loop over every account (checking, savings, each card). Account switchers are often a dropdown or a separate URL per account id.
- Parse dates explicitly (`strptime` with the site's format). Never rely on locale.
- Put whatever `fetch` needs in `meta` (row index, internal doc id, form values). Row indexes are fragile if the list can reorder, so prefer ids.
- Yield newest first, and stop early once you're past `since` when the listing is sorted.

### Rules for `fetch`

- Pick the download strategy that matches how the site delivers the file (see `download-strategies.md`).
- Re-navigate to the listing if `fetch` may run after other navigation. Don't assume the page is still where `list_documents` left it.
- Always pass `expect=doc.ext` (or a custom validator for CSV/OFX).

## Runner responsibilities (not the collector's)

1. Open an authenticated session (interactive or unattended).
2. `docs = list(collector.list_documents(s, since))`, filter by `since`, and drop docs already in the manifest. Apply `--limit`.
3. For each new doc: fetch into staging → non-empty check → SHA-256 → duplicate check → move to `root / doc.relpath(site)` → record in the manifest.
4. Catch per-doc exceptions: screenshot, record the failure, continue.
5. Catch `LoginRequired` and mark the result `needs_login`.
6. Append a run summary to a rolling JSON history (keep the last ~200).

## Registration

A plug-in registry keeps sites decoupled. Each site module defines `SITE` (required) and `COLLECTOR` (optional). Auto-discover modules in a `sites/` package, skipping files that start with `_` (templates), and optionally load sites contributed by other packages through an entry-point group.

## Manifest schema

```sql
CREATE TABLE IF NOT EXISTS documents (
    site TEXT NOT NULL, doc_id TEXT NOT NULL, account TEXT, kind TEXT, doc_date TEXT,
    path TEXT NOT NULL,          -- relative to the output root, so the folder can move
    sha256 TEXT NOT NULL, bytes INTEGER, downloaded_at TEXT NOT NULL,
    PRIMARY KEY (site, doc_id)
);
CREATE INDEX IF NOT EXISTS idx_documents_sha ON documents(sha256);
```

Keep the manifest **inside** the output folder (`.<tool>-manifest.sqlite`) so syncing or moving the archive carries its history with it.
