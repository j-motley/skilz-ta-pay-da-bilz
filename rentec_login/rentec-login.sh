#!/usr/bin/env bash
# rentec-login.sh — First-time or manual login to RentecDirect
#
# Runs headed (browser visible) so Cloudflare challenges can be solved.
# Uses a persistent Chrome profile so Cloudflare state is preserved for
# all future headless keepalive runs.
#
# Usage:
#   RENTEC_USERNAME=user RENTEC_PASSWORD=pass ./rentec-login.sh
#
# Environment variables:
#   RENTEC_USERNAME         RentecDirect login username (required)
#   RENTEC_PASSWORD         RentecDirect login password (required)
#   RENTEC_PROFILE_DIR      Chrome profile path (default: ~/.agent-browser/profiles/rentec-agent)
#   AGENT_BROWSER_ENCRYPTION_KEY  Encrypts profile at rest (optional)

set -euo pipefail

# Load .env if present
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/.env" ]]; then
    set -a; source "$SCRIPT_DIR/.env"; set +a
fi

# Load rentec.conf if present
if [[ -f "$SCRIPT_DIR/rentec.conf" ]]; then
    set -a; source "$SCRIPT_DIR/rentec.conf"; set +a
fi

PROFILE_DIR="${RENTEC_PROFILE_DIR:-$HOME/.agent-browser/profiles/rentec-agent}"
LOGIN_URL="https://secure.rentecdirect.com/owners/login.php"
DASHBOARD_URL="https://secure.rentecdirect.com/owners"

if [[ -z "${RENTEC_USERNAME:-}" || -z "${RENTEC_PASSWORD:-}" ]]; then
    echo "ERROR: RENTEC_USERNAME and RENTEC_PASSWORD must be set" >&2
    exit 1
fi

# Ensure no stale daemon is running
pkill -f agent-browser 2>/dev/null || true
sleep 1

echo "[rentec-login] Using Chrome profile: $PROFILE_DIR"
echo "[rentec-login] Opening login page (headed mode for Cloudflare)..."

agent-browser --headed --profile "$PROFILE_DIR" open "$LOGIN_URL"
agent-browser --profile "$PROFILE_DIR" wait --load networkidle
agent-browser --profile "$PROFILE_DIR" wait 2000

# Check if already authenticated (profile may have valid session)
CURRENT_URL=$(agent-browser --profile "$PROFILE_DIR" get url)
if ! echo "$CURRENT_URL" | grep -q "login"; then
    echo "[rentec-login] Already authenticated via saved profile."
    agent-browser --profile "$PROFILE_DIR" open "$DASHBOARD_URL"
    agent-browser --profile "$PROFILE_DIR" wait --load networkidle
    echo "[rentec-login] Dashboard loaded. Profile updated."
    exit 0
fi

# Wait for Cloudflare to clear and login form to appear
echo "[rentec-login] Waiting for Cloudflare to clear (up to 60s). Solve any challenge in the browser window."
agent-browser --profile "$PROFILE_DIR" wait \
    --fn "() => document.getElementById('username') !== null || !window.location.href.includes('login.php')" \
    --timeout 60000

# Fill login form or click continue button depending on what Chrome shows
agent-browser --profile "$PROFILE_DIR" wait 1000
AFTER_CF_URL=$(agent-browser --profile "$PROFILE_DIR" get url)
if ! echo "$AFTER_CF_URL" | grep -q "login.php"; then
    echo "[rentec-login] Already past login page. Current URL: $AFTER_CF_URL"
elif agent-browser --profile "$PROFILE_DIR" is visible "#username" 2>/dev/null; then
    echo "[rentec-login] Login form detected — filling credentials."
    agent-browser --profile "$PROFILE_DIR" fill "#username" "$RENTEC_USERNAME"
    agent-browser --profile "$PROFILE_DIR" fill "#password" "$RENTEC_PASSWORD"
    agent-browser --profile "$PROFILE_DIR" find role checkbox check --name "Keep me logged in" 2>/dev/null || true
    agent-browser --profile "$PROFILE_DIR" find role button click --name "Sign In"
else
    echo "[rentec-login] Continue button detected — clicking to proceed."
    agent-browser --profile "$PROFILE_DIR" find role checkbox check --name "Keep me logged in" 2>/dev/null || true
    agent-browser --profile "$PROFILE_DIR" find role button click
fi

echo "[rentec-login] Complete any 2FA in the browser window."
echo "[rentec-login] The browser will stay open. Press Ctrl+C here when you reach the dashboard."
echo "[rentec-login] Waiting up to 5 minutes..."
agent-browser --profile "$PROFILE_DIR" wait \
    --fn "window.location.href.includes('/owners/') && !window.location.href.includes('login')" \
    --timeout 300000 || true

FINAL_URL=$(agent-browser --profile "$PROFILE_DIR" get url 2>/dev/null || echo "unknown")
if echo "$FINAL_URL" | grep -q "login"; then
    echo "[rentec-login] WARNING: Still on login/2FA page. Complete 2FA in the browser, then close it manually."
else
    echo "[rentec-login] Login successful. URL: $FINAL_URL"
    echo "[rentec-login] Chrome profile saved to: $PROFILE_DIR"
    echo "[rentec-login] Future keepalive runs will use this profile headlessly."
fi
