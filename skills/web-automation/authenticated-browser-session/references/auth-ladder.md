# Authentication Ladder — Algorithm and Reference Code

Examples use Playwright for Python (sync API). The same structure works in Node Playwright, Puppeteer, or any CDP client.

## Launch a real browser with a persistent profile

```python
import subprocess, socket

def port_open(port, host="127.0.0.1"):
    with socket.socket() as s:
        s.settimeout(1)
        return s.connect_ex((host, port)) == 0

def launch(binary, profile_dir, port, headless=False):
    args = [str(binary),
            f"--remote-debugging-port={port}",
            f"--user-data-dir={profile_dir}",
            "--no-first-run", "--no-default-browser-check",
            "--disable-backgrounding-occluded-windows",
            "--disable-renderer-backgrounding"]
    if headless:
        args.append("--headless=new")   # less trusted by bot protection; prefer headed
    return subprocess.Popen(args)
```

Browser discovery: check the usual install paths per OS in preference order (Brave, Chrome, Edge, Chromium) and allow an env-var override. You do not need `playwright install`, because the installed browser is used.

## Attach and get a page

```python
from playwright.sync_api import sync_playwright

pw = sync_playwright().start()
if not port_open(port):
    proc = launch(find_browser(), profile_dir, port)
    wait_until(lambda: port_open(port), timeout=20)
browser = pw.chromium.connect_over_cdp(f"http://localhost:{port}")
ctx = browser.contexts[0] if browser.contexts else browser.new_context()
page = ctx.pages[0] if ctx.pages else ctx.new_page()
```

On exit, call `browser.close()` (which closes the CDP connection, not the browser) and `pw.stop()`. Don't kill the process.

## The ladder

```python
def authenticate(page, site, interactive=True):
    if is_authenticated(page, site):              # rungs 1 and 2
        return
    goto(page, site.login_url)
    if try_form_login(page, site):                # rung 3
        if wait_for_auth(page, site, timeout=max(30, site.manual_login_timeout // 6)):
            return
    if not interactive:
        raise LoginRequired(f"{site.name} needs a human: run `<tool> login {site.slug}`")
    if wait_for_auth(page, site, site.manual_login_timeout):   # rung 4
        return
    raise AuthenticationError("browser left open; log in there and re-run")

def is_authenticated(page, site):
    try:
        page.goto(site.verify_url, wait_until="domcontentloaded")
        wait_out_challenge(page, site.challenge_timeout)
        return bool(site.logged_in(page))
    except Exception:
        return False

def wait_for_auth(page, site, timeout, poll=2.0):
    deadline = time.time() + timeout
    while time.time() < deadline:
        time.sleep(poll)
        wait_out_challenge(page, site.challenge_timeout)
        try:
            if site.logged_in(page):
                return True
        except Exception:
            pass
    return False
```

## Form login, including two-step and TOTP

```python
def try_form_login(page, site):
    form, creds = site.login_form, keychain_get(site.slug)
    if not form or not creds:
        return False
    try:
        page.locator(form.user).first.fill(creds.username)
        if form.two_step:                          # username screen, then password screen
            page.locator(form.submit).first.click()
            page.locator(form.password).first.wait_for(timeout=15000)
        page.locator(form.password).first.fill(creds.password)
        page.locator(form.submit).first.click()
    except Exception:
        return False
    if form.otp and creds.totp_secret:
        try:
            field = page.locator(form.otp).first
            field.wait_for(timeout=20000)
        except Exception:
            return True                            # no prompt: device remembered
        if totp_seconds_remaining() < 4:           # don't submit a code about to roll over
            time.sleep(totp_seconds_remaining() + 0.5)
        field.fill(totp_code(creds.totp_secret))
        field.press("Enter")
    return True
```

TOTP (RFC 6238) is about 10 lines of stdlib code: HMAC-SHA1 over `floor(time/30)`, dynamic truncation, then mod 10^6. SMS and push MFA can't be automated, so those sites rely on "remember this device" plus rung 4.

## Passive challenge handling

```python
CHALLENGE_TITLES = {
    "cloudflare": ("just a moment", "attention required", "verifying you are human",
                   "checking your browser", "ddos-guard"),
    "waf": ("access denied", "pardon our interruption", "one moment, please",
            "human verification"),
}

def detect_challenge(page):
    t = (page.title() or "").lower()
    return next((k for k, needles in CHALLENGE_TITLES.items()
                 if any(n in t for n in needles)), None)

def wait_out_challenge(page, timeout=120, poll=1.0):
    if not detect_challenge(page):
        return True
    deadline = time.time() + timeout
    while time.time() < deadline:
        time.sleep(poll)
        if not detect_challenge(page):
            return True
    return False   # caller falls back to a human, rather than failing hard
```

Call it after every navigation. A warm, trusted profile usually clears a managed challenge in a few seconds without any input.

## Keepalive

A scheduled job that runs the ladder in unattended mode and loads the verify page. Report "alive", "expired → needs login", or "error". Pair it with a notification (email, chat, push) on "needs login" so the human knows to do a manual login.

## Remote/headless servers

The trust has to be earned from the IP the automation will run from. On a VPS, do the first headed login there, displaying the window through X11 forwarding (`ssh -X`) or a VNC session, so the profile is created and trusted on the server itself.
