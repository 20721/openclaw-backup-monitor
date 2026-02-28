# OpenClaw Backup Monitor

English | [中文](./README_ZH.md)

Automatic backup and recovery system for OpenClaw Gateway.

## Features

- 📝 Automatic configuration backup on change (keep 3 latest)
- ⚠️ Gateway anomaly detection and auto-recovery
- 🔔 Telegram notifications on recovery
- 🚀 Auto-start on boot

## Quick Start

### Install

```bash
# Extract and install
tar -xzvf openclaw-backup-monitor.tar.gz
bash ~/.agents/skills/openclaw-backup-monitor/install.sh
```

### Usage

```bash
# Manual backup
bash ~/Desktop/backup-openclaw/backup.sh

# Manual restore
bash ~/Desktop/backup-openclaw/restore.sh
```

## Files

```
openclaw-backup-monitor/
├── backup.sh       # Backup script
├── restore.sh     # Recovery script
├── monitor.sh     # Monitoring script
├── install.sh     # Installation script
└── uninstall.sh   # Uninstall script
```

## Configuration

- Backup location: `~/Desktop/backup-openclaw/`
- Keep: 3 latest backups
- Check frequency: every minute (cron)
- Recovery lock: 2 minutes cooldown

## Telegram Notifications

| Event | Message |
|-------|---------|
| Recovery started | ⚠️ Gateway 异常，正在恢复... |
| Recovery success | ✅ 已恢复，Gateway 运行正常 |
| Recovery failed | ❌ 恢复失败，请手动检查 |

## License

MIT
