# What to Capture Per Page

| Signal | How (Playwright) | Why it matters |
|---|---|---|
| Network calls | `page.on("response")`, keeping `resource_type in (xhr, fetch)` or JSON content types; record method, status, content-type, URL; dedupe on (method, path, status) | The real data source; flag `/api/`, `/ajax/`, and JSON as preferred targets |
| Final URL and title | `page.url`, `page.title()` | Detects redirects to login or challenge pages |
| Tables | Count; per table, header count plus the first **two** rows' cell text (truncated) | Headers often live in `<td>`, so show both rows |
| Forms | `action`, `method`, field `name`s and types | Export, date-range, and search submission |
| Repeated `data-*` attributes | Count attribute names across all elements and keep the frequent ones | Record markers with clean values |
| Grid containers | Elements with role `grid`/`table`/`row`, and common grid library classes | Virtualized lists that aren't `<table>` |
| Iframes | `src` of each | Statement viewers and login forms often live in iframes |
| Element counts and a text sample | Rough DOM size, plus the first ~500 characters of body text | A quick sanity check that you're on the right page |
| Rendered HTML | `page.content()` saved to `page_NN_<slug>.html` | Deep inspection afterwards |

Procedure per URL: attach the response listener → `goto(url, wait_until="domcontentloaded")` → try `wait_for_load_state("networkidle", timeout=15s)`, and on timeout note "page may poll" → settle about 2.5s → run the DOM inventory in `page.evaluate` → save the HTML and a `recon_NN_<slug>.json` → remove the listener.
