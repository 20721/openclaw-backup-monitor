#!/bin/bash
# monitor.sh - 主监控脚本
# 每分钟运行，检测 Gateway 状态和配置变化

BACKUP_DIR="$HOME/Desktop/backup-openclaw/backups"
CONFIG_DIR="$HOME/.openclaw"
SCRIPT_DIR="$HOME/Desktop/backup-openclaw"

# Telegram 配置
BOT_TOKEN="8423301827:AAG13bhK41bJINB4iaE-xQWMqYWODdb6XRw"
CHAT_ID="533614609"

# 发送 Telegram 通知
send_notification() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" \
        -d "text=$message" \
        >/dev/null 2>&1
}

# 检查 Gateway 状态
check_gateway() {
    # 检查端口
    if ! ss -tlnp | grep -q ":18789 "; then
        return 1
    fi
    
    # 检查进程
    if ! pgrep -f "openclaw-gateway" > /dev/null; then
        return 1
    fi
    
    return 0
}

# 检查配置文件是否有变化
check_config_change() {
    # 计算当前哈希
    current_hash=$(md5sum "$CONFIG_DIR/openclaw.json" 2>/dev/null | cut -d' ' -f1)
    
    # 获取最新备份哈希
    latest=$(ls -t "$BACKUP_DIR"/openclaw-*.json 2>/dev/null | head -1)
    if [ -n "$latest" ]; then
        latest_hash=$(md5sum "$latest" 2>/dev/null | cut -d' ' -f1)
    else
        latest_hash="none"
    fi
    
    if [ "$current_hash" != "$latest_hash" ]; then
        return 0  # 有变化
    else
        return 1  # 无变化
    fi
}

# 主逻辑
main() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始监控..."
    
    # 1. 检查 Gateway 状态
    if ! check_gateway; then
        echo "⚠️ 检测到 Gateway 异常，正在恢复..."
        send_notification "⚠️ Gateway 异常，正在恢复配置..."
        
        # 执行恢复
        bash "$SCRIPT_DIR/restore.sh"
        
        if [ $? -eq 0 ]; then
            echo "✅ 恢复完成"
        else
            echo "❌ 恢复失败"
        fi
        
        exit 0
    fi
    
    # 2. 检查配置文件变化
    if check_config_change; then
        echo "📝 检测到配置变化，开始备份..."
        bash "$SCRIPT_DIR/backup.sh"
    else
        echo "✅ 配置无变化"
    fi
}

main "$@"
