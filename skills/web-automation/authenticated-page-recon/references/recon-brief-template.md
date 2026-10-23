# Recon Brief Template

Fill in `{…}` and hand the whole file to the model.

````markdown
# Automation brief for `{site_name}`

You are helping write **ONE function** that automates a task on an authenticated website.

Authentication is already solved. The caller provides an authenticated Playwright page:

```python
with Session({SITE}) as s:
    page = s.page          # a normal, authenticated Playwright page
    your_function(page)
```

`s.goto(url)` navigates and waits out bot challenges. To call a same-origin endpoint with the session's cookies, fetch from inside the page:

```python
data = page.evaluate('''async (u) => {
    const r = await fetch(u, {credentials: 'include',
                              headers: {'X-Requested-With': 'XMLHttpRequest'}});
    return {status: r.status, text: await r.text()};
}''', endpoint_url)
```

## Guidance
- Prefer the data endpoints flagged below over DOM scraping.
- Check endpoint query strings for hidden date ranges and paging.
- Repeated `data-*` attributes mark records and carry clean values.
- Write one focused function with a clear signature and docstring, returning structured data.

## Reconnaissance
{per-page findings: URL → final URL, title, flagged endpoints, other network calls, tables (headers + 2 rows), forms, frequent data-* attributes, iframes, notes}

## WHAT I WANT TO AUTOMATE
{one function, for example: "List every statement on <URL> as dicts {account, date, download_url}, newest first."}

## Output
Return one function plus any small helpers it needs. Prefer the endpoints identified above. State your assumptions.
````
