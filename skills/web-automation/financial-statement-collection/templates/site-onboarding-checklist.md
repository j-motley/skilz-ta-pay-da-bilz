# Site Onboarding Checklist

Copy this list for each new bank or card portal and tick items off.

## 1. Decide
- [ ] Confirm there's no better source: an official API, aggregator access, emailed statements, or a scheduled export.
- [ ] Decide what to collect: statement PDFs, transaction exports (CSV/OFX/QFX/QBO), tax forms, notices.
- [ ] List the accounts in scope and pick a label for each (`checking-1234`, `visa-9876`).

## 2. Authenticate (authenticated-browser-session skill)
- [ ] Fill in the site config: name, login URL, verify URL, selectors, a `logged_in` element check, browser, and timeouts.
- [ ] Store credentials in the OS keychain (`<tool> creds set <site>`). Add a TOTP secret only if the user chooses to.
- [ ] Do the first login by hand: complete MFA and tick "remember this device".
- [ ] Re-run with no human involved and confirm it reaches the verify page.

## 3. Recon (authenticated-page-recon skill)
- [ ] Probe the statements list, the account switcher, the activity view, and the export dialog.
- [ ] Note the delivery method per document type: direct link, download, new-tab PDF, or JSON endpoint.
- [ ] Note the date formats, the history depth, and the export range limits.

## 4. Collector
- [ ] `list_documents` covers every account, parses dates explicitly, uses stable ids, and is read-only.
- [ ] `fetch` uses the matching download strategy and validates the type (`expect="pdf"` or a CSV/OFX check).
- [ ] Run `fetch <site> --dry-run` and confirm labels, dates, and counts are right.
- [ ] Run `fetch <site> --limit 1` and open the file to confirm the account and period match the filename.
- [ ] Do a full run, then run it again immediately: the second run should download 0 and skip everything.

## 5. Operate
- [ ] Schedule a daily `fetch --all --unattended` plus a `keepalive`.
- [ ] Set up alerts on exit code 2 (needs login) and 1 (failures).
- [ ] Keep failure artifacts and recon output outside any repo, and delete them once you're done.
