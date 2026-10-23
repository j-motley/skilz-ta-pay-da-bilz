# Download Strategies

Portals hand over files in one of three ways. Use the matching helper, and validate in all of them.

## 1. You have a URL: fetch it with the session's cookies

The URL can come from an `href`, a JSON endpoint, or a recon finding.

```python
def fetch_bytes(page, url, method="GET", data=None, headers=None, timeout=60):
    # a) the context's request API: fast and shares the cookie jar
    if not url.startswith("blob:"):
        try:
            r = page.context.request.fetch(url, method=method, data=data,
                                           headers=headers, timeout=timeout * 1000)
            if r.ok and r.body():
                return r.body()
        except Exception:
            pass
    # b) fetch() inside the page carries what the cookie jar can't:
    #    SameSite-only cookies, auth headers the app's JS sets in memory, blob: URLs
    res = page.evaluate("""async ({url, method, body, headers}) => {
        const r = await fetch(url, {method, body, headers, credentials: 'include'});
        const buf = new Uint8Array(await r.arrayBuffer());
        let bin = ''; for (let i = 0; i < buf.length; i += 0x8000)
            bin += String.fromCharCode.apply(null, buf.subarray(i, i + 0x8000));
        return {status: r.status, b64: btoa(bin)};
    }""", {"url": url, "method": method, "body": data, "headers": headers or {}})
    body = base64.b64decode(res["b64"])
    if 200 <= res["status"] < 300 and body:
        return body
    raise DownloadError(f"could not fetch {url}")
```

## 2. The click fires a real browser download

```python
with page.expect_download(timeout=60_000) as info:
    trigger()                                  # e.g. click "Download" or submit the export form
d = info.value
if d.failure(): raise DownloadError(d.failure())
d.save_as(tmp); validate(tmp); tmp.rename(dest)
```

Typical for CSV/OFX exports and `Content-Disposition: attachment` links.

## 3. You don't know in advance: a download OR a PDF in a new tab

This is common at banks. Listen for both `page.on("download")` and `context.on("page")` (popups also get a download listener), then run the trigger. If a popup appears, wait for `domcontentloaded` plus about 1.5s, since it may still turn into a download. Otherwise fetch the popup's URL with strategy 1 and close the popup. Clean up listeners and tabs in `finally`.

## Validation

```python
MAGIC = {"pdf": b"%PDF", "zip": b"PK\x03\x04", "xlsx": b"PK\x03\x04", "png": b"\x89PNG"}

def check(data, expect):
    if not data: raise DownloadError("empty response")
    if expect in MAGIC and not data.lstrip().startswith(MAGIC[expect]):
        got = "html" if b"<html" in data[:300].lower() else "unknown"
        raise DownloadError(f"expected {expect}, got {got}"
                            + (" (login/error page: session expired?)" if got == "html" else ""))
```

Extra checks for transaction formats, which have no magic bytes:

- **CSV**: decode (try `utf-8-sig`, then `cp1252`), make sure it doesn't start with `<`, and check that the first row contains the expected headers (such as `Date`, `Description`, `Amount`). Treat a header-only file as "no transactions", not an error, and decide per site whether to keep it.
- **OFX/QFX/QBO**: starts with `OFXHEADER:` (v1, SGML) or `<?xml` followed by `<OFX>` (v2). Check that `<STMTRS>` or `<CCSTMTRS>` is present.

Always write to `<dest>.part`, then `replace()`, so a crash never leaves a truncated file under the final name.
