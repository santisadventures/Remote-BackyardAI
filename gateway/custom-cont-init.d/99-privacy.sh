#!/bin/sh
set -eu

# Runs at container startup (linuxserver custom-init).
# Goal: keep users/keys, but purge interaction traces (logs) after 24h.

RETENTION_MINUTES="${RETENTION_MINUTES:-1440}"
SLEEP_SECONDS="${PRIVACY_SWEEP_SECONDS:-3600}"

case "$RETENTION_MINUTES" in
  ''|*[!0-9]*) RETENTION_MINUTES=1440 ;;
esac
case "$SLEEP_SECONDS" in
  ''|*[!0-9]*) SLEEP_SECONDS=3600 ;;
esac

SSHD_CFG="/config/sshd/sshd_config"
if [ -f "$SSHD_CFG" ]; then
  if ! grep -q '^LogLevel ' "$SSHD_CFG"; then
    echo "LogLevel QUIET" >>"$SSHD_CFG"
  fi
fi

privacy_sweep() {
  if [ -d /config/logs ]; then
    find /config/logs -type f -mmin +"$RETENTION_MINUTES" -print -delete 2>/dev/null || true
  fi
  find /tmp -type f -name 'santisplayground-*' -mmin +"$RETENTION_MINUTES" -print -delete 2>/dev/null || true
}

privacy_sweep >/dev/null 2>&1 || true

(
  while :; do
    sleep "$SLEEP_SECONDS" || true
    privacy_sweep >/dev/null 2>&1 || true
  done
) &

