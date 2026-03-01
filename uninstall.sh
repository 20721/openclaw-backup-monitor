#!/bin/bash
# openclaw-backup-monitor 卸载脚本

SCRIPT_DIR="$HOME/Desktop/backup-openclaw"

echo "========== 卸载 OpenClaw 备份监控系统 =========="

# 1. 移除 cron 任务
crontab -l 2>/dev/null | grep -v "backup-openclaw/monitor" | crontab -
echo "✅ 已移除 cron 任务"

# 2. 删除备份目录
if [ -d "$SCRIPT_DIR" ]; then
    rm -rf "$SCRIPT_DIR"
    echo "✅ 已删除备份目录"
fi

# 3. 删除锁文件
rm -f /tmp/openclaw_restore.lock
echo "✅ 已清理锁文件"

echo ""
echo "========== 卸载完成 =========="
