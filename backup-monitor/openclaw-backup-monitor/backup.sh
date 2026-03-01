#!/bin/bash
# backup.sh - 配置文件备份脚本

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.env"

LOG_FILE="$SCRIPT_DIR/backup.log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

calculate_hash() {
    md5sum "$1" 2>/dev/null | cut -d' ' -f1
}

get_latest_hash() {
    latest=$(ls -t "$BACKUP_DIR"/openclaw-*.json 2>/dev/null | head -1)
    [ -n "$latest" ] && calculate_hash "$latest" || echo "none"
}

main() {
    mkdir -p "$BACKUP_DIR"
    
    current_hash=$(calculate_hash "$CONFIG_DIR/openclaw.json")
    latest_hash=$(get_latest_hash)
    
    if [ "$current_hash" = "$latest_hash" ] && [ "$current_hash" != "none" ]; then
        log "配置无变化，跳过备份"
        exit 0
    fi
    
    log "检测到配置变化，开始备份..."
    
    backup_file="$BACKUP_DIR/openclaw-$TIMESTAMP.json"
    cp "$CONFIG_DIR/openclaw.json" "$backup_file"
    cp "$CONFIG_DIR/node.json" "$BACKUP_DIR/node-$TIMESTAMP.json" 2>/dev/null
    
    cd "$BACKUP_DIR"
    ls -t openclaw-*.json | tail -n +4 | xargs -r rm -f
    ls -t node-*.json | tail -n +4 | xargs -r rm -f
    
    log "备份完成: $backup_file"
}

main "$@"
