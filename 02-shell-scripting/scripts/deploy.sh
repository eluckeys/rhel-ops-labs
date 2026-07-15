#!/bin/bash
# deploy.sh - copies config and restarts service, fails loudly on any error

set -e  # optional safety net, but we still check explicitly for clear messages

SOURCE_CONF="/opt/scripts/app-config-source.conf"
DEST_CONF="/etc/app-config.conf"
SERVICE="sshd"

cp "$SOURCE_CONF" "$DEST_CONF"
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to copy config from $SOURCE_CONF to $DEST_CONF" >&2
  exit 1
fi

systemctl restart "$SERVICE"
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to restart service $SERVICE" >&2
  exit 2
fi

echo "Deployment successful"
exit 0
