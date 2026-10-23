# Bank and Card Portal Quirks

These are patterns that recur across financial portals. Confirm each one with recon for the specific site.

## Authentication
- Two-step login (username, then password) and logins inside iframes are common.
- MFA is usually SMS or push, which can't be automated. Rely on "remember this device" in a persistent profile, plus a scheduled keepalive. A few portals accept authenticator-app (TOTP) codes.
- Bot-protection vendors and device fingerprinting are common. A real browser with a warm profile matters more here than anywhere else. Prefer headed runs, because headless gets challenged more.
- Signed-in URLs often contain `auth`/`login`, so URL-based logged-in checks give false negatives. Test for "Sign out" or the account menu instead.
- Idle sessions expire fast (minutes), but device trust lasts weeks to months if the session is touched regularly.

## Statements
- Statements usually live in a "Statements & Documents" area with an account selector and a year filter. Loop over both.
- The PDF often opens in a new tab or a viewer iframe rather than downloading (strategy 3). The PDF URL inside the viewer can be fetched directly with the session's cookies.
- Links may be `javascript:` handlers with an internal document id. Capture the id in `meta`, or capture the XHR that returns the PDF URL.
- Banks sometimes re-issue corrected statements under new links. SHA-256 dedupe catches identical bytes, while different bytes with the same name are kept with a hash suffix.
- Tax forms (1099-INT/DIV/B, 1098) appear seasonally, often in a separate "Tax documents" section. Use `kind="tax-form"` and the tax-year end date.

## Transactions
- Export dialogs offer CSV, QFX (Quicken), QBO (QuickBooks), and sometimes OFX or XLSX. They typically take account, date range, and format, and produce a browser download (strategy 2).
- Range limits are common, typically somewhere between 90 days and 2 years back. Pull older history from statement PDFs.
- Pending transactions may be in the activity view but missing from exports, or the reverse. Decide which source is authoritative, and only export settled periods (for example, through the last full month).
- Card exports flip signs relative to bank exports (charges positive or negative depending on the portal). Normalize downstream, not in the collector, and record the source format in `meta`.
- Activity views are often virtualized or infinite-scroll grids backed by a paged JSON endpoint. Calling the endpoint directly (found with recon) is more reliable than scrolling.

## Operations
- Run the scheduler as the logged-in OS user, because headed browsers need a desktop session.
- Portals change layouts. A collector failing with "no rows found" on a site that used to work usually means a redesign. Check the failure screenshot first.
- Some institutions offer official alternatives (email statements, aggregator access, or an export API for business accounts). Mention them when they'd remove the need for automation.
