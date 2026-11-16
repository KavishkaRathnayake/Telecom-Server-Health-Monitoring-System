#!/bin/bash

# OSS/BSS Server Health Monitoring
# Training project for Linux administration

echo "======================================"
echo "     TELECOM SERVER HEALTH REPORT"
echo "======================================"

echo ""
echo "1. SERVER INFORMATION"
echo "Hostname: $(hostname)"
echo "Date: $(date)"
echo "Logged-in User: $(whoami)"

echo ""
echo "2. CPU LOAD"
uptime

echo ""
echo "3. MEMORY USAGE"
free -h

echo ""
echo "4. DISK SPACE"
df -h

echo ""
echo "5. TOP RUNNING PROCESSES"
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -10

echo ""
echo "6. NETWORK INFORMATION"
ip -brief address

echo ""
echo "7. SYSTEM UPTIME"
uptime -p

echo ""
echo "======================================"
echo "      MONITORING COMPLETED"
echo "======================================"
