#!/bin/bash
# openclaw-backup-monitor 安装脚本

SCRIPT_DIR="$HOME/Desktop/backup-openclaw"
SKILL_DIR="$HOME/.agents/skills/openclaw-backup-monitor"

# Telegram 配置 (从当前配置读取)
CONFIG_FILE="$HOME/.openclaw/openclaw.json"
BOT_TOKEN=$(grep -o '"botToken": "[^"]*"' "$CONFIG_FILE" 2>/dev/null | cut -d'"' -f4)
CHAT_ID="533614609"

echo "========== OpenClaw 备份监控系统安装 =========="

# 1. 创建备份目录
mkdir -p "$SCRIPT_DIR/backups"
echo "✅ 创建备份目录: $SCRIPT_DIR"

# 2. 复制脚本
cp "$SKILL_DIR/backup.sh" "$SCRIPT_DIR/"
cp "$SKILL_DIR/restore.sh" "$SCRIPT_DIR/"
cp "$SKILL_DIR/monitor.sh" "$SCRIPT_DIR/"
chmod +x "$SCRIPT_DIR"/*.sh
echo "✅ 复制脚本完成"

# 3. 配置 Telegram Token
sed -i "s/BOT_TOKEN=\"[^\"]*\"/BOT_TOKEN=\"$BOT_TOKEN\"/" "$SCRIPT_DIR/backup.sh"
sed -i "s/BOT_TOKEN=\"[^\"]*\"/BOT_TOKEN=\"$BOT_TOKEN\"/" "$SCRIPT_DIR/restore.sh"
echo "✅ 配置 Telegram Token"

# 4. 添加 cron 任务
(crontab -l 2>/dev/null | grep -v "backup-openclaw/monitor"; 
echo "* * * * * $SCRIPT_DIR/monitor.sh >> $SCRIPT_DIR/monitor.log 2>&1") | crontab -
echo "✅ 添加 cron 监控任务"

# 5. 首次备份
bash "$SCRIPT_DIR/backup.sh"
echo "✅ 完成首次备份"

echo ""
echo "========== 安装完成 =========="
echo "备份目录: $SCRIPT_DIR"
echo "监控频率: 每分钟"
echo "日志文件:"
echo "  - $SCRIPT_DIR/backup.log"
echo "  - $SCRIPT_DIR/restore.log"
echo "  - $SCRIPT_DIR/monitor.log"
