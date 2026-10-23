# Site Config Checklist

Collect these before writing any automation for a new site.

| Field | How to find it | Notes |
|---|---|---|
| `name` | User's choice, such as `chase-checking` | Becomes the slug, the profile dir, the CDP port key, and the keychain service |
| `login_url` | The page that shows the login form | Use the direct form URL, not the marketing homepage, if one exists |
| `verify_url` | A protected page, such as the account summary | Must redirect or deny when logged out |
| `logged_in(page)` | An element only signed-in users see | `page.locator("text=Sign out").count() > 0`; avoid URL tests at banks |
| `login_form.user` / `password` / `submit` | DevTools selectors | Prefer `id`/`name` over brittle CSS paths |
| `two_step` | Does the password field appear only after "Next"? | Common at large banks |
| `otp` / `otp_submit` | The selector for the one-time-code field | Only useful with an authenticator-app (TOTP) secret |
| `ready` | Optional selector to wait for before filling | For login forms injected late by JS or iframes |
| `browser` | Which browser passes the site's bot check | Brave often passes Cloudflare Turnstile cleanly |
| `challenge_timeout` | Seconds to wait out an interstitial | 120 is a sensible default |
| `manual_login_timeout` | Seconds a human gets for MFA | 300–600 for banks |
| `nav_timeout` | Per-navigation timeout | 30s default; raise for slow portals |
| legacy env-var names | If migrating an older `.env` setup | Keychain first, env vars as fallback |

## Gotchas seen in practice

- **Login inside an iframe.** Use `page.frame_locator(...)`. Selectors on `page` won't find it.
- **"Continue" instead of a form.** Some sites with a remembered device show only a continue button. Handle both branches.
- **"Keep me logged in" checkbox.** Tick it during the first login when it's present.
- **Session-expired HTML served with 200.** Never trust a status code alone. Check `logged_in` or validate the payload (see the financial-statement-collection skill).
- **Default URL heuristic.** "Not on a URL containing login/signin/auth" is fine for simple sites and wrong for most banks.
