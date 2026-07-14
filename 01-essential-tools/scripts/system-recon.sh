#!/bin/bash
#
# system-recon.sh
# Quick first-contact recon for an unfamiliar Linux box.
# Usage: ./system-recon.sh [output-file]
#   If no output file is given, prints to stdout only.

set -uo pipefail

OUTFILE="${1:-}"

log() {
  if [[ -n "$OUTFILE" ]]; then
    echo "$1" | tee -a "$OUTFILE"
  else
    echo "$1"
  fi
}

section() {
  log ""
  log "=== $1 ==="
}

if [[ -n "$OUTFILE" ]]; then
  : > "$OUTFILE"
fi

section "Host + Uptime"
log "$(hostname) - $(date)"
log "$(uptime)"

section "Logged in / recent logins"
log "$(who)"
log "--- last 5 logins ---"
log "$(last -n 5 2>/dev/null)"

section "Real user accounts (uid >= 1000)"
log "$(awk -F: '$3 >= 1000 && $3 < 65534 {print $1, $3, $6, $7}' /etc/passwd)"

section "Disk usage (mounted filesystems)"
log "$(df -h --output=target,pcent,avail,fstype 2>/dev/null)"

section "Top 5 largest dirs under /var (may skip dirs you can't read)"
log "$(du -sh /var/* 2>/dev/null | sort -rh | head -5)"

section "Top 5 CPU consumers"
log "$(ps aux --sort=-%cpu 2>/dev/null | head -6)"

section "Failed systemd units"
FAILED=$(systemctl list-units --failed --no-legend 2>/dev/null)
if [[ -z "$FAILED" ]]; then
  log "None"
else
  log "$FAILED"
fi

section "Files modified in the last 24h under /etc and /var/log"
log "$(find /etc /var/log -mtime -1 -type f 2>/dev/null | head -20)"

section "Listening ports"
log "$(ss -tulnp 2>/dev/null)"

section "Recon complete"
log "$(date)"
