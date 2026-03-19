#!/usr/bin/env bash
# setup-cron.sh — Install or update the keepalive cron job
#
# Reads KEEPALIVE_INTERVAL_DAYS and KEEPALIVE_TIME from rentec.conf and
# writes the appropriate cron entry. Safe to re-run — replaces the existing
# rentec-keepalive entry rather than adding duplicates.
#
# Usage:
#   ./setup-cron.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load rentec.conf
if [[ ! -f "$SCRIPT_DIR/rentec.conf" ]]; then
    echo "ERROR: rentec.conf not found at $SCRIPT_DIR/rentec.conf" >&2
    exit 1
fi
set -a; source "$SCRIPT_DIR/rentec.conf"; set +a

INTERVAL="${KEEPALIVE_INTERVAL_DAYS:-1}"
TIME="${KEEPALIVE_TIME:-03:00}"
KEEPALIVE_SCRIPT="$SCRIPT_DIR/rentec-keepalive.sh"

# Parse hour and minute from KEEPALIVE_TIME
HOUR=$(echo "$TIME" | cut -d: -f1)
MINUTE=$(echo "$TIME" | cut -d: -f2)

# Build cron schedule
if [[ "$INTERVAL" -eq 1 ]]; then
    SCHEDULE="$MINUTE $HOUR * * *"        # Every day
else
    SCHEDULE="$MINUTE $HOUR */$INTERVAL * *"  # Every N days
fi

CRON_MARKER="# rentec-keepalive"
CRON_ENTRY="$SCHEDULE $KEEPALIVE_SCRIPT >> $SCRIPT_DIR/keepalive.log 2>&1 $CRON_MARKER"

# Remove existing entry and add updated one
(crontab -l 2>/dev/null | grep -v "$CRON_MARKER"; echo "$CRON_ENTRY") | crontab -

echo "Cron job installed:"
echo "  Schedule : $SCHEDULE"
echo "  Interval : every $INTERVAL day(s) at $TIME (VPS local time)"
echo "  Script   : $KEEPALIVE_SCRIPT"
echo "  Log      : $SCRIPT_DIR/keepalive.log"
echo ""
echo "To verify: crontab -l"
echo "To change frequency: edit rentec.conf then re-run this script, or tell your agent."
