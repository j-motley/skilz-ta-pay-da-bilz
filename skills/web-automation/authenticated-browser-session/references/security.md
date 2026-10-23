# Security Rules

- **Credentials**: store them in the OS keychain (Windows Credential Manager, macOS Keychain, or Secret Service on Linux). The Python `keyring` package is pure Python and covers all three. Use one service per site (`<tool>:<slug>`) with entries `username`, `password`, and optionally `totp_secret`. Collect them interactively (`getpass`) and never as CLI arguments, which leak into shell history.
- **`.env` files** are a legacy fallback only: `chmod 600`, gitignored, never committed.
- **Browser profiles are secrets.** They hold session cookies equivalent to a logged-in device. Keep them outside any repo, and consider OS-level disk encryption.
- **Artifacts** (failure screenshots, rendered HTML, recon dumps) contain real account data. Write them to a private folder (such as `~/.<tool>/artifacts/<site>/`), never into a repo, and delete them when you're done.
- **Logs**: redact credential objects (override `__repr__`), and never log OTP codes, cookies, or full account numbers.
- **TOTP secrets**: only the user's own authenticator enrollment, stored at the user's explicit request. Storing a TOTP secret with the password collapses two factors into one device, so tell the user about that trade-off.
- **Scope**: automate only accounts the user owns or is authorized to access, and respect the site's terms. Never bypass CAPTCHAs or bot protection by solving or spoofing them. Wait passively, and hand off to a human.
- **Native dependency restrictions**: some managed machines (such as Windows Application Control) block native extension DLLs. Prefer pure-Python dependencies where possible.
