---
name: authenticated-page-recon
description: Inspect pages behind a login before writing a scraper or downloader: capture the XHR/fetch endpoints, tables, forms, repeated data-* attributes, and the rendered HTML, then produce an LLM brief for writing one focused extraction function. Use when automating a bank, credit card, utility, or any authenticated web app whose data structure is unknown, when a DOM scraper finds nothing, or before writing a statement or transaction collector.
---

# Authenticated Page Recon

**Look before you scrape.** Modern portals rarely render plain `<table>` markup. They fetch JSON or HTML fragments from an endpoint, often with the date range and paging hidden in the query string, and build the DOM in the browser. A scraper written blind targets the wrong layer. Recon captures how each page actually loads its data and puts that in front of the model, so the first function it writes aims at the right target.

This skill assumes an authenticated page is available (see the `authenticated-browser-session` skill).

## Workflow

1. **List the URLs**, all behind the same login, in a text file. Blank lines and `#` comments are ignored. Include the statements list, the transaction or activity view, and the download/export page.
2. **Probe each URL** in the authenticated page. Capture the items in `references/recon-capture-checklist.md`, and save the rendered HTML per page.
3. **Write a brief** from `references/recon-brief-template.md`: how to get the authenticated page, the in-page `fetch` pattern, the guidance, per-page findings, and a placeholder for **one** function.
4. **Fill in "WHAT I WANT TO AUTOMATE"** with a single, specific function: its inputs, the exact data, and the return shape.
5. **Generate, run, and verify** that function, then run recon again for the next one. Compose verified functions into the larger automation.

## Decision rules for the function that follows

- An endpoint under `/api/`, `/ajax/`, or one returning JSON beats DOM parsing every time. Call it from inside the page with `credentials: 'include'` so it carries the session.
- Look in endpoint query strings for `start`/`end`/`from`/`to`, `page`, `offset`, `limit`, and `sort`. The real range control is often there, not in the visible form.
- An attribute that repeats across many elements (`data-id`, `data-date`, `data-amount`) usually marks one record with clean, unformatted values.
- Forms (action, method, field names) are the surface for anything you *submit*, such as export requests or date filters.
- Content inside an iframe needs its own frame locator. Record iframe `src` values.
- If `networkidle` never arrives, the page polls continuously. Wait on a specific selector instead.

## Output rules

- One function per brief: a clear signature, a docstring, and structured return data (a list of dicts), not prints.
- The brief and dumps contain real account data. Write them to a gitignored, private folder and delete them when you're done.
