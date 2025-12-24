#!/bin/bash

################################################################################
# Application Health Checker Script
# Checks HTTP status of given URLs and reports UP/DOWN status.
# Supports single URL or list via configuration array.
################################################################################

# Configuration
LOG_FILE="app_health.log"
TIMEOUT=10

# List of endpoints (NAME|URL)
declare -a ENDPOINTS=(
    "Wisecow|http://localhost:4499"
    "Google|https://www.google.com"
    "GitHub|https://github.com"
)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_message() {
    local level=$1
    local msg=$2
    local ts=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$ts] [$level] $msg" | tee -a "$LOG_FILE"
}

check_endpoint() {
    local name=$1
    local url=$2
    echo -e "\n${YELLOW}Checking $name...${NC}"
    http_code=$(curl -o /dev/null -s -w "%{http_code}" --connect-timeout $TIMEOUT "$url")
    curl_exit=$?
    if [ $curl_exit -ne 0 ]; then
        echo -e "${RED}DOWN (curl error $curl_exit)${NC}"
        log_message "ERROR" "$name is DOWN (curl error $curl_exit)"
        return 1
    fi
    if [ $http_code -ge 200 ] && [ $http_code -lt 300 ]; then
        echo -e "${GREEN}UP (HTTP $http_code)${NC}"
        log_message "INFO" "$name is UP (HTTP $http_code)"
        return 0
    else
        echo -e "${RED}DOWN (HTTP $http_code)${NC}"
        log_message "ERROR" "$name is DOWN (HTTP $http_code)"
        return 1
    fi
}

main() {
    echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Application Health Checker                     ║${NC}"
    echo -e "${GREEN}║     $(date '+%Y-%m-%d %H:%M:%S')                          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
    log_message "INFO" "=== Health check started ==="
    for ep in "${ENDPOINTS[@]}"; do
        IFS='|' read -r name url <<< "$ep"
        check_endpoint "$name" "$url"
    done
    log_message "INFO" "=== Health check completed ==="
    echo -e "\nLog file: $LOG_FILE"
}

main "$@"
