# RentecDirect Login — Implementation Guide

Complete setup instructions. Follow each section in order.

---

## Overview

```
┌─────────────────────────────────────────────────────────┐
│                        VPS                              │
│                                                         │
│  rentec-login.sh     ← first-time / manual recovery    │
│  rentec-keepalive.sh ← runs daily via cron             │
│  rentec.conf         ← agent-editable config           │
│  .env                ← credentials (never commit)      │
│                                                         │
│  Chrome profile → persists Cloudflare session state    │
└─────────────────────────────────────────────────────────┘
         ↑                          ↓
  SSH -X (Linux)            Telegram alert
  bat script (Windows)      if challenge detected
```

**Normal flow:** cron → headless keepalive → dashboard → done
**Recovery flow:** Telegram alert → you → SSH + headed login → challenge solved → done

---

## Part 1 — VPS Setup

### 1.1 Copy project files to VPS

From your Linux machine or any machine with the repo:

```bash
scp -r /path/to/rentec_login user@your-vps:~/rentec_login
```

Or clone if you have it in a git repo:

```bash
ssh user@your-vps
git clone <your-repo-url> ~/rentec_login
```

### 1.2 Install Node.js on the VPS (if not already installed)

```bash
# Using nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.bashrc
nvm install --lts
```

### 1.3 Install agent-browser on the VPS

```bash
npm install -g agent-browser
agent-browser install   # Downloads Chromium — takes a minute
agent-browser --version # Verify install
```

### 1.4 Create your .env file on the VPS

```bash
cd ~/rentec_login
cp .env.example .env
nano .env   # or vim, or any editor
```

Fill in all four values:

```ini
RENTEC_USERNAME=your_rentec_username
RENTEC_PASSWORD=your_rentec_password
TELEGRAM_BOT_TOKEN=your_bot_token
TELEGRAM_CHAT_ID=your_chat_id
```

**To find your Telegram chat ID:**
1. Send any message to your Telegram bot
2. Run this from the VPS (replace with your token):
   ```bash
   curl -s "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates" | grep -o '"id":[0-9]*' | head -1
   ```
3. The number after `"id":` is your chat ID

Secure the .env file:
```bash
chmod 600 .env
```

### 1.5 Make scripts executable

```bash
cd ~/rentec_login
chmod +x rentec-login.sh rentec-keepalive.sh setup-cron.sh
```

### 1.6 Review rentec.conf

```bash
cat rentec.conf
```

Defaults are fine for now:
- `KEEPALIVE_INTERVAL_DAYS=1` — runs daily
- `KEEPALIVE_TIME=03:00` — runs at 3am VPS time
- `RENTEC_PROFILE_DIR` — where Chrome profile is stored

---

## Part 2 — One-Time Login from Linux Machine

This establishes the Chrome profile and solves any Cloudflare challenge. **Must be done from the VPS's IP**, using your Linux machine only to display the browser window.

### 2.1 Connect with X11 forwarding

From your Linux machine:

```bash
ssh -X user@your-vps
```

Verify X11 forwarding is working:

```bash
echo $DISPLAY   # Should print something like "localhost:10.0" — not empty
```

If `$DISPLAY` is empty, X11 forwarding didn't activate. Check that:
- Your Linux machine has an X server running (it will if you're in a desktop session)
- `/etc/ssh/sshd_config` on the VPS has `X11Forwarding yes` (see note below)

**If X11Forwarding is not enabled on the VPS:**

```bash
# On the VPS (as root or with sudo)
sudo sed -i 's/#X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config
sudo sed -i 's/X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

Then reconnect with `ssh -X`.

### 2.2 Run the first-time login

```bash
cd ~/rentec_login
./rentec-login.sh
```

A Chrome browser window will appear on your Linux desktop.

- The page loads and Cloudflare evaluates the browser automatically
- If a **Turnstile CAPTCHA** appears, click it to solve it in the window
- The script fills your credentials and submits automatically
- On success you will see: `Login successful` and `Chrome profile saved`

### 2.3 Verify the profile was created

```bash
ls ~/.agent-browser/profiles/rentec-agent/
# Should show Chrome profile directories (Default, etc.)
```

---

## Part 3 — Set Up the Daily Keepalive

### 3.1 Test the keepalive headlessly first

Still on the VPS (via SSH), run:

```bash
cd ~/rentec_login
./rentec-keepalive.sh
```

Expected output:
```
[2026-xx-xx] Starting keepalive...
[2026-xx-xx] Already authenticated. Loading dashboard...
[2026-xx-xx] Keepalive complete. Dashboard loaded successfully.
```

If it fails with a Cloudflare error on the first headless run, go back to Part 2 and re-run the headed login — the profile may not have been fully saved.

### 3.2 Install the cron job

```bash
cd ~/rentec_login
./setup-cron.sh
```

Verify it was installed:

```bash
crontab -l
# Should show a line containing "rentec-keepalive"
```

### 3.3 Test the Telegram alert (optional but recommended)

Temporarily break the login to confirm alerts work:

```bash
# Temporarily rename the profile to simulate a missing profile
mv ~/.agent-browser/profiles/rentec-agent ~/.agent-browser/profiles/rentec-agent-backup
./rentec-keepalive.sh
# You should receive a Telegram message
# Restore the profile
mv ~/.agent-browser/profiles/rentec-agent-backup ~/.agent-browser/profiles/rentec-agent
```

---

## Part 4 — Windows Setup (for manual recovery from Windows)

Do this so you can solve a Cloudflare challenge from your Windows machine if you're away from your Linux machine.

### 4.1 Install required software

- **VcXsrv**: https://sourceforge.net/projects/vcxsrv/ (install to default path)
- **PuTTY**: https://www.putty.org/ (install to default path)

### 4.2 Configure the batch script

On your Windows machine, copy the `windows/` folder from the project. Then:

```
Copy windows\config.ini.example  →  windows\config.ini
Copy windows\.env.example        →  windows\.env
```

Edit `config.ini`:
```ini
VPS_HOST=your-vps-ip-or-hostname
VPS_USER=your_ssh_username
VPS_SCRIPT_PATH=/home/your_username/rentec_login/rentec-login.sh
```

Edit `.env`:
```ini
VPS_PASSWORD=your_ssh_password
RENTEC_USERNAME=your_rentec_username
RENTEC_PASSWORD=your_rentec_password
```

### 4.3 Accept the VPS host key (one-time only)

Open Command Prompt and run:

```
"C:\Program Files\PuTTY\plink.exe" -ssh your_user@your_vps_host
```

Type `y` when asked to store the key, then `Ctrl+C` to exit. This only needs to be done once.

### 4.4 Test the batch script

Double-click `windows\rentec-login.bat`

A Chrome window should appear on your Windows desktop. Solve any challenge, and the session will be saved on the VPS.

---

## Part 5 — Ongoing Operations

### Changing the keepalive frequency

Tell your Open Claw agent:
> "Change the rentec keepalive to run every 2 days"

The agent will edit `KEEPALIVE_INTERVAL_DAYS` in `rentec.conf` and re-run `setup-cron.sh`.

Or do it manually:
```bash
nano ~/rentec_login/rentec.conf   # Change KEEPALIVE_INTERVAL_DAYS
cd ~/rentec_login && ./setup-cron.sh
```

### Responding to a Telegram alert

When you receive a Cloudflare challenge alert:

**From Linux:**
```bash
ssh -X user@your-vps
cd ~/rentec_login && ./rentec-login.sh
```

**From Windows:**
Double-click `windows\rentec-login.bat`

### Checking the keepalive log

```bash
tail -50 ~/rentec_login/keepalive.log
```

### Manually refreshing the session at any time

```bash
ssh user@your-vps
cd ~/rentec_login && ./rentec-keepalive.sh
```

---

## File Reference

| File | Location | Purpose |
|------|----------|---------|
| `rentec-login.sh` | VPS | First-time and manual recovery login (headed) |
| `rentec-keepalive.sh` | VPS | Scheduled headless session maintenance |
| `setup-cron.sh` | VPS | Installs/updates the cron job from rentec.conf |
| `rentec.conf` | VPS | Agent-editable config (interval, time, profile path) |
| `.env` | VPS | Credentials and Telegram config (never commit) |
| `keepalive.log` | VPS | Auto-generated log of all keepalive runs |
| `windows/rentec-login.bat` | Windows machine | Double-click to run headed login from Windows |
| `windows/config.ini` | Windows machine | VPS connection details |
| `windows/.env` | Windows machine | Credentials for Windows-side script |

---

## Security Notes

- `.env` files contain plaintext credentials — never commit them to git
- The Chrome profile directory contains session tokens — treat it like a password
- To encrypt the profile at rest, set `AGENT_BROWSER_ENCRYPTION_KEY` in `.env`:
  ```bash
  AGENT_BROWSER_ENCRYPTION_KEY=your_32_byte_hex_key
  # Generate one with: openssl rand -hex 32
  # Store this key separately — losing it means re-running the first-time login
  ```
- The VPS SSH password is stored in `windows/.env` — ensure that machine is trusted
