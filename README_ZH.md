---
name: openclaw-backup-monitor
description: OpenClaw 网关备份监控系统 - 自动监控配置变化、异常自动恢复、开机启动
triggers:
  - 备份监控
  - 网关监控
  - 备份恢复
  - backup monitor
---

# OpenClaw 备份监控系统

## 功能

- 📝 配置文件变更自动备份（保留最近3份）
- ⚠️ Gateway 异常自动检测与恢复
- 🔔 恢复成功/失败 Telegram 通知
- 🚀 开机自动启动监控

## 安装

```bash
# 一键安装
bash ~/.agents/skills/openclaw-backup-monitor/install.sh
```

## 卸载

```bash
bash ~/.agents/skills/openclaw-backup-monitor/uninstall.sh
```

## 手动命令

| 功能 | 命令 |
|------|------|
| 手动备份 | `bash ~/Desktop/backup-openclaw/backup.sh` |
| 手动恢复 | `bash ~/Desktop/backup-openclaw/restore.sh` |
| 查看备份日志 | `tail -f ~/Desktop/backup-openclaw/backup.log` |
| 查看恢复日志 | `tail -f ~/Desktop/backup-openclaw/restore.log` |

## 文件结构

```
~/Desktop/backup-openclaw/
├── backup.sh       # 备份脚本
├── restore.sh     # 恢复脚本
├── monitor.sh     # 监控脚本
├── backup.log     # 备份日志
├── restore.log    # 恢复日志
└── backups/       # 备份存储
```

## 监控配置

- 监控文件: openclaw.json, node.json, credentials/, identity/
- 备份保留: 最近3份
- 检查频率: 每分钟 (cron)
- 恢复锁: 2分钟内不重复恢复

## Telegram 通知

- 异常开始: ⚠️ Gateway 异常，正在恢复...
- 恢复成功: ✅ 已恢复，Gateway 运行正常
- 恢复失败: ❌ 恢复失败，请手动检查
