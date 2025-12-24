#!/bin/bash

################################################################################
# System Health Monitoring Script
# Monitors CPU, memory, disk usage, and top processes.
# Alerts when thresholds are exceeded and logs to system_health.log.
################################################################################

# Configuration
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80
LOG_FILE="system_health.log"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

check_cpu() {
    echo -e "\n${GREEN}=== CPU Usage ===${NC}"
    if command -v mpstat &> /dev/null; then
        cpu_idle=$(mpstat 1 1 | tail -1 | awk '{print $NF}')
        cpu_usage=$(echo "100 - $cpu_idle" | bc)
    else
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    fi
    echo "CPU Usage: ${cpu_usage}%"
    if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
        echo -e "${RED}⚠️  ALERT: CPU usage above $CPU_THRESHOLD%${NC}"
        log_message "ALERT" "CPU usage $cpu_usage% exceeds threshold $CPU_THRESHOLD%"
    else
        echo -e "${GREEN}✓ CPU usage normal${NC}"
        log_message "INFO" "CPU usage $cpu_usage%"
    fi
}

check_memory() {
    echo -e "\n${GREEN}=== Memory Usage ===${NC}"
    if command -v free &> /dev/null; then
        mem_used=$(free | grep Mem | awk '{print $3}')
        mem_total=$(free | grep Mem | awk '{print $2}')
        mem_usage=$(echo "scale=2; $mem_used/$mem_total*100" | bc)
        echo "Memory Usage: ${mem_usage}%"
        if (( $(echo "$mem_usage > $MEMORY_THRESHOLD" | bc -l) )); then
            echo -e "${RED}⚠️  ALERT: Memory usage above $MEMORY_THRESHOLD%${NC}"
            log_message "ALERT" "Memory usage $mem_usage% exceeds threshold $MEMORY_THRESHOLD%"
        else
            echo -e "${GREEN}✓ Memory usage normal${NC}"
            log_message "INFO" "Memory usage $mem_usage%"
        fi
    else
        echo -e "${YELLOW}⚠️  'free' command not found${NC}"
    fi
}

check_disk() {
    echo -e "\n${GREEN}=== Disk Usage ===${NC}"
    df -h | grep -vE '^Filesystem|tmpfs|cdrom|loop' | while read line; do
        usage=$(echo $line | awk '{print $5}' | sed 's/%//')
        mount=$(echo $line | awk '{print $6}')
        echo "Partition $mount: ${usage}%"
        if [ $usage -gt $DISK_THRESHOLD ]; then
            echo -e "${RED}⚠️  ALERT: Disk usage on $mount above $DISK_THRESHOLD%${NC}"
            log_message "ALERT" "Disk usage $usage% on $mount exceeds $DISK_THRESHOLD%"
        fi
    done
}

check_processes() {
    echo -e "\n${GREEN}=== Top 10 CPU Processes ===${NC}"
    ps aux --sort=-%cpu | head -11 | tail -10
    echo -e "\n${GREEN}=== Top 10 Memory Processes ===${NC}"
    ps aux --sort=-%mem | head -11 | tail -10
    log_message "INFO" "Process snapshot taken"
}

main() {
    echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     System Health Monitoring Script               ║${NC}"
    echo -e "${GREEN}║     $(date '+%Y-%m-%d %H:%M:%S')                          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
    log_message "INFO" "=== System health check started ==="
    check_cpu
    check_memory
    check_disk
    check_processes
    echo -e "\n${GREEN}✓ All checks completed${NC}"
    log_message "INFO" "=== System health check completed ==="
}

main
