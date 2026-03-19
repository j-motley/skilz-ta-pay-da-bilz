#!/usr/bin/env bash
# rentec-keepalive.sh — Headless session keepalive for RentecDirect
#
# Runs on a schedule (via cron). Loads the Chrome profile, logs in if
# needed, navigates to the dashboard, and exits. Sends a Telegram alert
# if a Cloudflare challenge is detected (requires manual login).
#
# Usage:
#   ./rentec-keepalive.sh
#
# Environment variables (or set in .env):
#   RENTEC_USERNAME       RentecDirect login username
#   RENTEC_PASSWORD       RentecDirect login password
#   RENTEC_PROFILE_DIR    Chrome profile path
#   TELEGRAM_BOT_TOKEN    Telegram bot token for alerts
#   TELEGRAM_CHAT_ID      Telegram chat ID for alerts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/keepalive.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Load .env if present
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

# ── Telegram alert helper ────────────────────────────────────────────────────
send_alert() {
    local message="$1"
    if [[ -n "${TELEGRAM_BOT_TOKEN:-}" && -n "${TELEGRAM_CHAT_ID:-}" ]]; then
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -d chat_id="${TELEGRAM_CHAT_ID}" \
            -d text="$message" \
            -d parse_mode="Markdown" > /dev/null
        log "Telegram alert sent."
    else
        log "WARNING: Telegram not configured — alert not sent."
    fi
}

cleanup() {
    agent-browser --profile "$PROFILE_DIR" close 2>/dev/null || true
}
trap cleanup EXIT

log "Starting keepalive..."

# ── Validate requirements ────────────────────────────────────────────────────
if [[ -z "${RENTEC_USERNAME:-}" || -z "${RENTEC_PASSWORD:-}" ]]; then
    log "ERROR: RENTEC_USERNAME and RENTEC_PASSWORD must be set."
    send_alert "⚠️ *RentecDirect Keepalive Error*: Credentials not configured on VPS. Check \`.env\` file."
    exit 1
fi

if [[ ! -d "$PROFILE_DIR" ]]; then
    log "ERROR: Chrome profile not found at $PROFILE_DIR"
    send_alert "⚠️ *RentecDirect Keepalive Error*: Chrome profile missing. Run the first-time login from your Linux or Windows machine."
    exit 1
fi

# ── Open site with persistent profile (headless) ────────────────────────────
log "Opening $LOGIN_URL with profile $PROFILE_DIR..."
agent-browser --profile "$PROFILE_DIR" open "$LOGIN_URL"
agent-browser --profile "$PROFILE_DIR" wait --load networkidle
agent-browser --profile "$PROFILE_DIR" wait 3000

CURRENT_URL=$(agent-browser --profile "$PROFILE_DIR" get url)

# ── Already authenticated — go straight to dashboard ────────────────────────
if ! echo "$CURRENT_URL" | grep -q "login"; then
    log "Already authenticated. Loading dashboard..."
    agent-browser --profile "$PROFILE_DIR" open "$DASHBOARD_URL"
    agent-browser --profile "$PROFILE_DIR" wait --load networkidle
    log "Keepalive complete. Dashboard loaded successfully."
    exit 0
fi

# ── Need to log in ───────────────────────────────────────────────────────────
log "Session expired — attempting headless login..."
agent-browser --profile "$PROFILE_DIR" snapshot -i

agent-browser --profile "$PROFILE_DIR" fill @e1 "$RENTEC_USERNAME"
agent-browser --profile "$PROFILE_DIR" fill @e2 "$RENTEC_PASSWORD"
agent-browser --profile "$PROFILE_DIR" click @e3

agent-browser --profile "$PROFILE_DIR" wait --load networkidle
agent-browser --profile "$PROFILE_DIR" wait 5000

FINAL_URL=$(agent-browser --profile "$PROFILE_DIR" get url)

# ── Login succeeded headlessly ───────────────────────────────────────────────
if ! echo "$FINAL_URL" | grep -q "login"; then
    log "Headless login succeeded. URL: $FINAL_URL"
    agent-browser --profile "$PROFILE_DIR" open "$DASHBOARD_URL"
    agent-browser --profile "$PROFILE_DIR" wait --load networkidle
    log "Keepalive complete."
    exit 0
fi

# ── Still on login page — Cloudflare challenge required ─────────────────────
log "ERROR: Still on login page after credentials. Cloudflare challenge likely."
send_alert "⚠️ *RentecDirect Keepalive Failed*

Cloudflare is blocking the headless login. Manual intervention needed.

*Action required:* Run the login script from your Linux or Windows machine to solve the challenge and refresh the session.

\`ssh -X user@your-vps && ~/rentec_login/rentec-login.sh\`"

exit 1
