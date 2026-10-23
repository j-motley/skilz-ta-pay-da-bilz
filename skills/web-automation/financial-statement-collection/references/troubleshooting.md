# Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `Expected pdf but got html (session expired?)` | Session lapsed mid-run, or the URL needs in-page auth headers | Re-run (the ladder re-authenticates). If it persists, use in-page `fetch` or a click-based strategy |
| Site reported `needs_login` every night | Device trust lost, keepalive too infrequent, or profile deleted | Run an interactive `login <site>` and tick "remember device". Schedule the keepalive more often than the idle timeout |
| Challenge never clears | Headless mode, a fresh profile, a new IP, or the wrong browser | Run headed, do one human visit from the same machine/IP, and try Brave |
| `list_documents` finds 0 documents | Redesign, data loaded by XHR after DOM ready, or the wrong account selected | Check the failure screenshot and HTML, run recon again, and wait on a row selector, not `domcontentloaded` |
| `No download or document tab appeared` | The click hit an overlay, or the viewer is an iframe in the same tab | Dismiss modals first. Read the iframe `src` and fetch it with strategy 1 |
| Same statement downloaded twice with different names | Unstable ids (row index or a URL token in the id) | Build the id from account, kind, and date, or from the portal's permanent doc id |
| Files filed under the wrong year | Date parsed from the posting date, not the period end, or locale parsing | Use the statement period-end date and an explicit `strptime` format |
| A second browser window opens instead of reusing the first | The port changed or the profile is locked by a crashed process | Keep port assignments persistent per site, and close the stale process |
| Native DLL import errors on a managed Windows machine | Application Control blocks compiled extensions | Use pure-Python dependencies (such as `keyring` instead of `cryptography`) |

Debug loop: `fetch <site> --dry-run` → check the listed docs → `fetch <site> --limit 1` → open the file → full run. Keep failure artifacts private and delete them once you're done.
