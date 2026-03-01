#!/bin/bash
# restore.sh - 配置文件恢复脚本 (带锁机制和多级修复)

BACKUP_DIR="$HOME/Desktop/backup-openclaw/backups"
CONFIG_DIR="$HOME/.openclaw"
LOCK_FILE="/tmp/openclaw_restore.lock"
LOG_FILE="$HOME/Desktop/backup-openclaw/restore.log"

# Telegram 配置
BOT_TOKEN="8423301827:AAG13bhK41bJINB4iaE-xQWMqYWODdb6XRw"
CHAT_ID="533614609"

# 记录日志
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 发送通知
notify() {
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" \
        -d "text=$1" >/dev/null 2>&1
}

# 检查锁
check_lock() {
    if [ -f "$LOCK_FILE" ]; then
        lock_time=$(stat -c %Y "$LOCK_FILE" 2>/dev/null)
        now=$(date +%s)
        if [ $((now - lock_time)) -lt 120 ]; then
            log "检测到锁，跳过恢复"
            return 1
        fi
    fi
    return 0
}

# 修复尝试
try_fix() {
    local method=$1
    log "尝试修复方法 $method..."
    
    case $method in
        1)
            # 方法1: restart 命令
            openclaw gateway restart 2>/dev/null
            ;;
        2)
            # 方法2: 杀死进程后重新启动
            pkill -f openclaw-gateway 2>/dev/null
            sleep 2
            nohup openclaw gateway > "$CONFIG_DIR/logs/gateway.log" 2>&1 &
            ;;
        3)
            # 方法3: 杀死占用端口的进程
            fuser -k 18789/tcp 2>/dev/null
            sleep 2
            nohup openclaw gateway > "$CONFIG_DIR/logs/gateway.log" 2>&1 &
            ;;
        4)
            # 方法4: 检查配置语法
            python3 -c "import json; json.load(open('$CONFIG_DIR/openclaw.json'))" 2>/dev/null
            if [ $? -eq 0 ]; then
                log "配置语法正确"
                nohup openclaw gateway > "$CONFIG_DIR/logs/gateway.log" 2>&1 &
            else
                log "配置有误，尝试修复..."
                openclaw doctor --fix 2>/dev/null
            fi
            ;;
    esac
    
    sleep 5
    if ss -tlnp | grep -q ":18789 "; then
        return 0
    fi
    return 1
}

# 主恢复逻辑
main() {
    if ! check_lock; then
        exit 0
    fi
    
    touch "$LOCK_FILE"
    log "========== 开始恢复 =========="
    notify "⚠️ Gateway 异常，正在恢复..."
    
    # 查找最新备份
    latest_backup=$(ls -t "$BACKUP_DIR"/openclaw-*.json 2>/dev/null | head -1)
    
    if [ -z "$latest_backup" ]; then
        log "没有备份文件，尝试使用 doctor 修复"
        notify "⚠️ 无备份文件，尝试自动修复..."
        
        # 尝试修复
        for i in 1 2 3 4; do
            if try_fix $i; then
                break
            fi
        done
    else
        log "使用备份: $latest_backup"
        
        # 停止 Gateway
        openclaw gateway stop 2>/dev/null
        sleep 2
        
        # 恢复配置
        cp "$latest_backup" "$CONFIG_DIR/openclaw.json"
        latest_node=$(ls -t "$BACKUP_DIR"/node-*.json 2>/dev/null | head -1)
        [ -n "$latest_node" ] && cp "$latest_node" "$CONFIG_DIR/node.json"
        
        # 尝试多种修复方法
        success=false
        for i in 1 2 3 4; do
            if try_fix $i; then
                success=true
                break
            fi
        done
        
        if $success; then
            log "✅ 恢复成功"
            notify "✅ 已恢复，Gateway 运行正常"
        else
            log "❌ 恢复失败"
            notify "❌ 恢复失败，请手动检查"
        fi
    fi
    
    rm -f "$LOCK_FILE"
    log "========== 恢复结束 =========="
}

main "$@"
