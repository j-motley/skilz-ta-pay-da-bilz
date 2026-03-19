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

cleanup() {
    agent-browser --profile "$PROFILE_DIR" close 2>/dev/null || true
}
trap cleanup EXIT

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

# Discover form elements and fill credentials
agent-browser --profile "$PROFILE_DIR" snapshot -i

agent-browser --profile "$PROFILE_DIR" fill @e1 "$RENTEC_USERNAME"
agent-browser --profile "$PROFILE_DIR" fill @e2 "$RENTEC_PASSWORD"
agent-browser --profile "$PROFILE_DIR" click @e3

echo "[rentec-login] Credentials submitted. Waiting for redirect (up to 60s)..."
echo "[rentec-login] If a Cloudflare challenge appears, solve it in the browser window."

agent-browser --profile "$PROFILE_DIR" wait \
    --fn "!window.location.href.includes('login.php')" \
    --timeout 60000 || {
    echo "ERROR: Timed out — check browser window for Cloudflare challenge." >&2
    exit 1
}

agent-browser --profile "$PROFILE_DIR" wait --load networkidle

FINAL_URL=$(agent-browser --profile "$PROFILE_DIR" get url)
if echo "$FINAL_URL" | grep -q "login"; then
    echo "ERROR: Login failed — still on login page. Verify credentials." >&2
    exit 1
fi

echo "[rentec-login] Login successful. URL: $FINAL_URL"
echo "[rentec-login] Chrome profile saved to: $PROFILE_DIR"
echo "[rentec-login] Future keepalive runs will use this profile headlessly."
