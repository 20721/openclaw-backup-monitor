#!/bin/bash
# openclaw-backup-monitor 安装脚本

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========== OpenClaw 备份监控系统安装 =========="

# 检查配置文件
if [ ! -f "$SCRIPT_DIR/config.env" ]; then
    echo "❌ 错误: 找不到 config.env"
    exit 1
fi

# 检查是否需要用户配置
source "$SCRIPT_DIR/config.env"

if [ "$BOT_TOKEN" = "YOUR_BOT_TOKEN_HERE" ] || [ "$CHAT_ID" = "YOUR_CHAT_ID_HERE" ]; then
    echo ""
    echo "⚠️  请先配置 Telegram Bot Token 和 Chat ID"
    echo ""
    echo "编辑文件: $SCRIPT_DIR/config.env"
    echo ""
    echo "配置说明:"
    echo "  BOT_TOKEN - 你的 Telegram Bot Token"
    echo "  CHAT_ID  - 你的 Telegram Chat ID"
    echo ""
    echo "获取 Bot Token: @BotFather (Telegram)"
    echo "获取 Chat ID: @userinfobot 或 @getidsbot"
    echo ""
    read -p "按回车键打开配置文件..."
    nano "$SCRIPT_DIR/config.env"
fi

# 再次检查
source "$SCRIPT_DIR/config.env"
if [ "$BOT_TOKEN" = "YOUR_BOT_TOKEN_HERE" ] || [ "$CHAT_ID" = "YOUR_CHAT_ID_HERE" ]; then
    echo "❌ 配置未完成，取消安装"
    exit 1
fi

echo "✅ 配置检查通过"

# 创建备份目录
mkdir -p "$BACKUP_DIR"
echo "✅ 创建备份目录: $BACKUP_DIR"

# 添加 cron 任务
(crontab -l 2>/dev/null | grep -v "backup-openclaw/monitor"; 
echo "* * * * * $SCRIPT_DIR/monitor.sh >> $SCRIPT_DIR/monitor.log 2>&1") | crontab -
echo "✅ 添加 cron 监控任务"

# 首次备份
bash "$SCRIPT_DIR/backup.sh"
echo "✅ 完成首次备份"

echo ""
echo "========== 安装完成 =========="
echo "备份目录: $BACKUP_DIR"
echo "日志: $SCRIPT_DIR/backup.log, $SCRIPT_DIR/restore.log"
echo ""
echo "手动命令:"
echo "  备份: bash $SCRIPT_DIR/backup.sh"
echo "  恢复: bash $SCRIPT_DIR/restore.sh"
