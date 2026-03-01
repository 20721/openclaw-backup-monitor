#!/bin/bash
# restore.sh - 配置文件恢复脚本

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.env"

LOCK_FILE="/tmp/openclaw_restore.lock"
LOG_FILE="$SCRIPT_DIR/restore.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

notify() {
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" -d "text=$1" >/dev/null 2>&1
}

check_lock() {
    [ -f "$LOCK_FILE" ] && {
        lock_time=$(stat -c %Y "$LOCK_FILE" 2>/dev/null)
        [ $(($(date +%s) - lock_time)) -lt 120 ] && return 1
    }
    return 0
}

try_fix() {
    log "尝试修复方法 $1..."
    case $1 in
        1) openclaw gateway restart 2>/dev/null ;;
        2) pkill -f openclaw-gateway; sleep 2; nohup openclaw gateway > "$CONFIG_DIR/logs/gateway.log" 2>&1 & ;;
        3) fuser -k 18789/tcp 2>/dev/null; sleep 2; nohup openclaw gateway > "$CONFIG_DIR/logs/gateway.log" 2>&1 & ;;
        4) python3 -c "import json; json.load(open('$CONFIG_DIR/openclaw.json'))" 2>/dev/null || openclaw doctor --fix 2>/dev/null; nohup openclaw gateway > "$CONFIG_DIR/logs/gateway.log" 2>&1 & ;;
    esac
    sleep 5
    ss -tlnp | grep -q ":18789 " && return 0 || return 1
}

main() {
    check_lock || { log "检测到锁，跳过"; exit 0; }
    touch "$LOCK_FILE"
    log "========== 开始恢复 =========="
    notify "⚠️ Gateway 异常，正在恢复..."
    
    latest=$(ls -t "$BACKUP_DIR"/openclaw-*.json 2>/dev/null | head -1)
    
    if [ -z "$latest" ]; then
        log "无备份，尝试修复"
        notify "⚠️ 无备份文件，尝试自动修复..."
        for i in 1 2 3 4; do try_fix $i && break; done
    else
        log "使用备份: $latest"
        openclaw gateway stop 2>/dev/null; sleep 2
        cp "$latest" "$CONFIG_DIR/openclaw.json"
        [ -n "$(ls -t "$BACKUP_DIR"/node-*.json 2>/dev/null | head -1)" ] && cp "$(ls -t "$BACKUP_DIR"/node-*.json | head -1)" "$CONFIG_DIR/node.json"
        
        success=false
        for i in 1 2 3 4; do try_fix $i && success=true && break; done
        
        $success && log "✅ 恢复成功" && notify "✅ 已恢复，Gateway 运行正常" || log "❌ 恢复失败" && notify "❌ 恢复失败，请手动检查"
    fi
    
    rm -f "$LOCK_FILE"
    log "========== 恢复结束 =========="
}

main "$@"
