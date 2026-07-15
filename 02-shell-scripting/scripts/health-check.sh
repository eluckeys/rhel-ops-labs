#!/bin/bash
# health-check.sh - checks disk and memory, alerts if thresholds exceeded

DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
MEM_FREE=$(free -m | awk 'NR==2 {print $4}')

if [ $DISK_USAGE -gt 80 ]; then
  echo "WARNING: Disk usage is ${DISK_USAGE}%"
fi

if [ $MEM_FREE -lt 100 ]; then
  echo "WARNING: Free memory is ${MEM_FREE}MB"
fi

echo "Health check complete: disk=${DISK_USAGE}% mem_free=${MEM_FREE}MB"

if [ $DISK_USAGE -gt 10 ]; then
  /opt/scripts/notify-helper.sh "Disk usage high: ${DISK_USAGE}%"
fi
