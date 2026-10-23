---
name: financial-statement-collection
description: Automate downloading statements, transaction exports (CSV/OFX/QFX/QBO), bills, and tax forms from bank, credit card, brokerage, and utility web portals into a de-duplicated, consistently named local archive that runs on a schedule. Use when a user wants to stop logging in by hand to pull statements or transactions, add a new bank or card portal to an existing collector, debug a failing download, or design a personal finance document pipeline.
---

# Financial Statement Collection

Turn "log in to every bank and card portal each month and click download" into a scheduled job that brings in only what's new, files it predictably, never saves a "session expired" page as a statement, and tells the human exactly which site needs a login.

The work splits into layers, and each new site only touches the top one:

```
scheduler ─► runner ─► collector (per site: list_documents / fetch)
                │            ▲
                │            └─ authenticated page ◄─ session (authenticated-browser-session skill)
                ├─ manifest (SQLite: seen ids + SHA-256)
                └─ filing (<root>/<site>/<account>/<year>/<date>_<site>_<account>_<kind>.<ext>)
```

Related skills: `authenticated-browser-session` (getting and keeping the login) and `authenticated-page-recon` (mapping a portal before writing its collector).

## Workflow: adding a bank or card portal

Follow `templates/site-onboarding-checklist.md`. In short:

1. **Site config and credentials.** Define the site, store the login in the OS keychain, and do the first login by hand (MFA, "remember this device").
2. **Recon** the statements page, the activity or transactions page, and the export dialog. Find out whether documents come from a direct link, a JS-triggered download, a PDF in a new tab, or a JSON/AJAX endpoint.
3. **Write the collector** (`references/collector-contract.md`, `templates/collector_template.py`):
   - `list_documents(session, since)` yields `Document(account, date, kind, url?, meta)`. It does no downloading.
   - `fetch(session, doc, dest)` puts one document at `dest`, using one of the three download strategies in `references/download-strategies.md`.
4. **Dry run**: list what would be downloaded, and check the account labels, dates, and kinds.
5. **Real run** with `--limit 1`, then a full run. Open a few files and confirm the period and account match the filename.
6. **Schedule**: a daily fetch in unattended mode plus a keepalive, and alerts on "needs login" or failures.

## Non-negotiable behaviors

- **Validate bytes, not status codes.** Check magic bytes (`%PDF`, `PK\x03\x04`) or parse CSV/OFX headers before saving. Banks return a 200 HTML login page when the session lapses.
- **Write atomically**: write to `.part`, then rename. Stage in `<root>/.partial/` and move into place only after validation.
- **Idempotent runs.** Skip a `(site, doc_id)` that's already in the manifest. Discard a download whose SHA-256 matches a file on record (a re-issued statement under a new link), but still record the new id. On a name collision with different bytes, keep both (`_<sha8>` suffix).
- **Isolate failures.** One bad document doesn't stop the site, and one bad site doesn't stop the run. Screenshot and save HTML on each failure.
- **Unattended never hangs.** A site needing MFA is reported as `needs_login` with the exact command to fix it.
- **Exit codes**: `0` all good, `1` something failed, `2` a site needs a manual login. Append a JSON run summary (found, downloaded, skipped, duplicates, failed, needs_login) for dashboards and alerts.
- **Stable ids and labels.** Ids must stay the same across runs: default to `account:kind:date`, or use the portal's own document id when it exposes one. Use the last 4 digits for account labels (`checking-1234`, `visa-9876`), never full numbers.

## Statements vs transactions

- **Statement PDFs** are the authoritative monthly record: one document per account per period, `kind="statement"`.
- **Transaction exports** (CSV, OFX/QFX, QBO) are better for bookkeeping and categorization. They're usually produced by a form (account, date range, format) and arrive as a browser download. Model each export window as a document (`kind="transactions"`, `date` = range end, `meta={"start":…, "end":…, "format":"csv"}`), and use non-overlapping windows, such as calendar months, so ids stay stable. Validate CSVs by their header row and OFX by `OFXHEADER`/`<OFX>`, not by `%PDF`.
- Many portals cap export ranges (for example 90 days to 18 months back). Statements usually go back further. See `references/bank-portal-quirks.md`.

## Reference implementation

`webauto` (Python + Playwright, real browser over CDP, Windows Credential Manager via `keyring`) implements every layer above. It has a `fetch` / `login` / `keepalive` / `history` / `creds` / `recon` / `schedule` CLI and an end-to-end test suite against a local fake bank. When working in a repo that already uses it, write a site module (`SITE` plus `COLLECTOR`) and use its CLI instead of rebuilding the machinery. For transaction exports it provides an `ExportCollector` base (one export per account per completed calendar month) and CSV/OFX/QFX/QBO validation, so a site only implements `accounts()` and `export()`. Outside it, the references here hold enough to rebuild each layer in any language.

Read `references/troubleshooting.md` when a collector breaks.
