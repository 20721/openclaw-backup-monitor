#!/bin/bash
# monitor.sh - 主监控脚本

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.env"

LOG_FILE="$SCRIPT_DIR/monitor.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

notify() {
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" -d "text=$1" >/dev/null 2>&1
}

check_gateway() {
    ss -tlnp | grep -q ":18789 " && pgrep -f "openclaw-gateway" >/dev/null
}

check_change() {
    current=$(md5sum "$CONFIG_DIR/openclaw.json" 2>/dev/null | cut -d' ' -f1)
    latest=$(ls -t "$BACKUP_DIR"/openclaw-*.json 2>/dev/null | head -1)
    [ -n "$latest" ] && [ "$current" != "$(md5sum "$latest" 2>/dev/null | cut -d' ' -f1)" ]
}

main() {
    log "开始监控..."
    
    if ! check_gateway; then
        log "Gateway 异常"
        bash "$SCRIPT_DIR/restore.sh"
        exit 0
    fi
    
    if check_change; then
        log "配置变化，备份"
        bash "$SCRIPT_DIR/backup.sh"
    else
        log "配置无变化"
    fi
}

main "$@"
