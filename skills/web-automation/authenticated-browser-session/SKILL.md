---
name: authenticated-browser-session
description: Establish and keep a durable, authenticated browser session on a website that has no API and sits behind a login, MFA, or bot protection (Cloudflare, Imperva, DataDome) — banks, credit card portals, utilities, property-management portals. Use when an agent must automate anything behind a login, needs a session that survives for weeks, must run unattended on a schedule, or keeps getting blocked, logged out, or asked for MFA.
---

# Authenticated Browser Session

Hand every downstream automation an already-authenticated page, however that happens. Downstream code (scrapers, downloaders, form fillers) should never deal with login.

The approach: drive the user's **real installed browser** with a **persistent profile per site**, attach to it over the Chrome DevTools Protocol (CDP), and climb an **authentication ladder** that gets cheaper on every later run. The trust a site gives a remembered device lives in the profile, so the human does MFA or a challenge once and the profile does the rest.

Read `references/auth-ladder.md` for the full algorithm and code. Read `references/site-config-checklist.md` when onboarding a new site. Read `references/security.md` before storing any credential.

## When this applies

- The site has no usable API or export feed.
- Login involves MFA, "remember this device", SSO redirects, or bot-protection interstitials.
- The automation must run repeatedly or unattended, not just once.

If the site offers an official API, an aggregator the user already uses, or a scheduled email/export, prefer that and say so.

## Operating principles

- **Real browser, not bundled automation Chromium.** Brave → Chrome → Edge, launched with `--user-data-dir=<profile>` and `--remote-debugging-port=<port>`, then attached with `connect_over_cdp`. A normal fingerprint plus accumulated profile trust is what makes sessions last.
- **One profile and one stable CDP port per site.** A browser process holds one profile. Separate profiles isolate trust (logging out of A can't break B), allow parallel runs, and a stable port lets later runs find and reuse a running browser.
- **Leave the browser running** after a run. Detach from CDP instead of closing; the next run reattaches instantly.
- **Handle challenges passively.** Detect an interstitial by title/URL and wait for it to clear. Never try to solve a CAPTCHA programmatically or use solver services. If it doesn't clear, a human looks at the window once.
- **Interactive vs unattended.** Interactive runs may wait for a human to finish MFA. Unattended (scheduled) runs must never hang: raise a distinct "needs login" result and move on.
- **A real logged-in check.** Test for something only a signed-in user sees ("Sign out", account menu). URL heuristics fail at banks, whose signed-in URLs often contain `auth` or `login`.
- **Secrets stay out of files and logs.** Use the OS keychain. Redact credentials in `repr`, logs, and tracebacks.

## Workflow

1. **Define the site config**: name (→ slug, profile dir, port, keychain entry), login URL, verify URL (a protected page), login-form selectors (optional, including two-step and OTP fields), `logged_in` predicate, preferred browser, timeouts. See `references/site-config-checklist.md`.
2. **Store credentials** in the OS keychain under a per-site service name (`<tool>:<slug>`). Store a TOTP secret only if it's the user's own authenticator enrollment and the user explicitly chooses to.
3. **First login is interactive.** Open the window, auto-fill if possible, then wait while the human completes MFA or a challenge and ticks "remember this device".
4. **Verify** by loading the verify URL in a fresh run and checking `logged_in`. It should reach rung 1 or 2 of the ladder without a human.
5. **Keep it warm.** Schedule a keepalive (load the verify page) more often than the site's idle timeout. Sessions that sit idle for weeks expire.
6. **On failure**, capture a screenshot and rendered HTML to a private artifacts folder outside any repo, and report which rung failed.

## The ladder (summary)

| Rung | What happens | Cost |
|---|---|---|
| 1. Reuse | A browser is already on the site's port and the session is valid | none |
| 2. Profile | Launch against the saved profile; cookies still authenticate | a launch |
| 3. Auto-login | Fill the form from the keychain, plus a TOTP code if stored | seconds |
| 4. Manual | Wait for a human (skipped when unattended → "needs login") | one human visit |

## Output rules

- Expose one contract: `with Session(site) as s: s.page` is authenticated.
- Give a navigation helper that waits out challenges after every `goto`.
- Use distinct errors: `LoginRequired` (needs a human, unattended) vs `AuthenticationError` (everything failed).
- Report outcomes plainly: which rung succeeded, or what the human needs to do next (for example `run: <tool> login <site>`).
