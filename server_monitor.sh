
#!/usr/bin/env bash

# ==================================================
# TELECOM OSS/BSS SERVER HEALTH MONITORING
# Linux Administration Training Project
# ==================================================

set -u

# Project directories
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$BASE_DIR/logs" "$BASE_DIR/reports"

LOG_FILE="$BASE_DIR/logs/monitoring.log"
REPORT_FILE="$BASE_DIR/reports/health_report.txt"

# Alert thresholds (can be overridden when running)
: "${CPU_LOAD_THRESHOLD:=80}"
: "${RAM_THRESHOLD:=80}"
: "${DISK_THRESHOLD:=80}"

# Prepare report
: > "$REPORT_FILE"

# Display output and save it to both files
exec > >(tee -a "$LOG_FILE" "$REPORT_FILE") 2>&1

ALERT_COUNT=0

echo "================================================"
echo "       TELECOM OSS/BSS SERVER HEALTH REPORT"
echo "================================================"

echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo "Linux User: $(whoami)"
echo "Operating System: $(. /etc/os-release && echo "$PRETTY_NAME")"

echo ""
echo "--------------- CPU MONITORING ----------------"

uptime

CORES=$(nproc)
LOAD=$(awk '{print $1}' /proc/loadavg)

echo "CPU Cores: $CORES"
echo "1-Minute Load Average: $LOAD"

LOAD_PERCENT=$(awk -v load="$LOAD" -v cores="$CORES" \
'BEGIN {printf "%.1f", (load/cores)*100}')

echo "Load per CPU Core: ${LOAD_PERCENT}%"

if awk -v value="$LOAD_PERCENT" -v limit="$CPU_LOAD_THRESHOLD" \
'BEGIN {exit !(value > limit)}'; then
    echo "WARNING: High CPU load detected!"
    ((ALERT_COUNT+=1))
else
    echo "CPU Load Status: NORMAL"
fi

echo ""
echo "--------------- MEMORY MONITORING --------------"

free -h

RAM_PERCENT=$(free | awk '/^Mem:/ {
    printf "%.0f", ($3/$2)*100
}')

echo "RAM Usage: ${RAM_PERCENT}%"

if [ "$RAM_PERCENT" -gt "$RAM_THRESHOLD" ]; then
    echo "WARNING: High RAM usage detected!"
    ((ALERT_COUNT+=1))
else
    echo "RAM Status: NORMAL"
fi

echo ""
echo "--------------- DISK MONITORING ----------------"

df -h

DISK_PERCENT=$(df -P / | awk 'NR==2 {
    gsub("%","",$5);
    print $5
}')

echo "Root Disk Usage: ${DISK_PERCENT}%"

if [ "$DISK_PERCENT" -gt "$DISK_THRESHOLD" ]; then
    echo "WARNING: High disk usage detected!"
    ((ALERT_COUNT+=1))
else
    echo "Disk Status: NORMAL"
fi

echo ""
echo "--------------- PROCESS MONITORING -------------"

echo "Top 10 CPU-consuming processes:"

ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -10

echo ""
echo "--------------- NETWORK MONITORING ------------"

ip -brief address

echo ""
echo "--------------- UPTIME MONITORING --------------"

uptime -p

echo ""
echo "--------------- HEALTH SUMMARY -----------------"

if [ "$ALERT_COUNT" -gt 0 ]; then
    echo "SERVER STATUS: WARNING"
    echo "Total Alerts: $ALERT_COUNT"
else
    echo "SERVER STATUS: HEALTHY"
    echo "Total Alerts: 0"
fi

echo ""
echo "Report saved to: $REPORT_FILE"
echo "Log saved to: $LOG_FILE"

echo "================================================"
echo "           MONITORING COMPLETED"
echo "================================================"
