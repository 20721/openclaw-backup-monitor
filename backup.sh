#!/bin/bash
# backup.sh - 配置文件备份脚本
# 只在文件变化时备份，保留最近3次

BACKUP_DIR="$HOME/Desktop/backup-openclaw/backups"
CONFIG_DIR="$HOME/.openclaw"
LOG_FILE="$HOME/Desktop/backup-openclaw/backup.log"

# 生成时间戳
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 记录日志
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 计算 MD5 哈希
calculate_hash() {
    md5sum "$1" 2>/dev/null | cut -d' ' -f1
}

# 获取最新备份哈希
get_latest_hash() {
    latest=$(ls -t "$BACKUP_DIR"/openclaw-*.json 2>/dev/null | head -1)
    if [ -n "$latest" ]; then
        calculate_hash "$latest"
    else
        echo "none"
    fi
}

# 主备份逻辑
main() {
    # 确保备份目录存在
    mkdir -p "$BACKUP_DIR"
    
    # 检查配置文件是否有变化
    current_hash=$(calculate_hash "$CONFIG_DIR/openclaw.json")
    latest_hash=$(get_latest_hash)
    
    if [ "$current_hash" = "$latest_hash" ] && [ "$current_hash" != "none" ]; then
        log "配置无变化，跳过备份"
        exit 0
    fi
    
    log "检测到配置变化，开始备份..."
    
    # 备份配置文件
    backup_file="$BACKUP_DIR/openclaw-$TIMESTAMP.json"
    cp "$CONFIG_DIR/openclaw.json" "$backup_file"
    
    # 备份 node.json
    cp "$CONFIG_DIR/node.json" "$BACKUP_DIR/node-$TIMESTAMP.json" 2>/dev/null
    
    # 保留最近3次备份
    cd "$BACKUP_DIR"
    ls -t openclaw-*.json | tail -n +4 | xargs -r rm -f
    ls -t node-*.json | tail -n +4 | xargs -r rm -f
    
    log "备份完成: $backup_file"
}

main "$@"
