# Kiro Skills 安装指南

## 概述

`kiro-adapter.sh` 是一个智能安装脚本，支持差异更新和增量安装，避免重复安装未更改的技能。

## 功能特性

- ✅ **差异检测**: 自动检测文件变化，只更新修改过的技能
- ✅ **增量安装**: 跳过未更改的技能，节省时间
- ✅ **校验和追踪**: 使用 MD5 校验和追踪文件变化
- ✅ **强制重装**: 支持强制重新安装所有技能
- ✅ **详细输出**: 可选的详细模式显示更多信息
- ✅ **状态标识**: 清晰显示新安装、更新和跳过的技能

## 使用方法

### 基本用法

```bash
# 默认模式：只安装/更新有变化的技能
./kiro-adapter.sh
```

### 命令行选项

```bash
# 强制重新安装所有技能（忽略校验和）
./kiro-adapter.sh --force
./kiro-adapter.sh -f

# 显示详细输出
./kiro-adapter.sh --verbose
./kiro-adapter.sh -v

# 组合使用
./kiro-adapter.sh -f -v

# 显示帮助信息
./kiro-adapter.sh --help
./kiro-adapter.sh -h
```

## 工作原理

### 校验和机制

脚本会为每个技能计算 MD5 校验和，包括：
- `SKILL.md` 文件
- `tool-preferences.md` 文件（如果存在）

校验和存储在 `~/.kiro/powers/.checksums` 文件中。

### 差异检测流程

1. **首次安装**: 没有校验和记录，安装所有技能
2. **后续运行**: 
   - 比较当前文件的校验和与记录的校验和
   - 只处理有变化的技能
   - 跳过未更改的技能

### 状态标识

- `[NEW]` - 新安装的技能
- `[UPDATE]` - 更新的技能
- `✓ Up to date` - 跳过未更改的技能

## 输出示例

### 正常模式

```
=== Kiro Skills Adapter ===
Source: /path/to/skills
Target: /Users/username/.kiro/powers

ripgrep [UPDATE]
rust-skills-coding-guidelines ✓ Up to date
rust-skills-domain-web [NEW]

New: 1 | Updated: 1 | Skipped: 1
Total processed: 3
```

### 强制重装模式

```
=== Kiro Skills Adapter ===
Source: /path/to/skills
Target: /Users/username/.kiro/powers
Mode: Force reinstall

Cleaning up old symlinks...
Cleared checksums for force reinstall

ripgrep [NEW]
rust-skills-coding-guidelines [NEW]
rust-skills-domain-web [NEW]

New: 3 | Updated: 0 | Skipped: 0
Total processed: 3
```

### 详细模式

```
=== Kiro Skills Adapter ===
Source: /path/to/skills
Target: /Users/username/.kiro/powers
Verbose mode enabled

ripgrep [UPDATE]
  Checksum changed
  ✓ Generated POWER.md
  ✓ Created steering
  ✓ Generated tool-preferences.md from SKILL.md
  ✓ Copied tool-preferences.md to global steering
```

## 文件结构

### 输入

```
~/.kiro/skills/
├── ripgrep/
│   ├── SKILL.md
│   └── tool-preferences.md (可选)
└── rust-skills/
    └── skills/
        ├── coding-guidelines/
        │   └── SKILL.md
        └── domain-web/
            └── SKILL.md
```

### 输出

```
~/.kiro/powers/
├── .checksums                    # 校验和记录
├── installed.json
├── registry.json
└── installed/
    ├── ripgrep/
    │   ├── POWER.md
    │   └── steering/
    │       ├── skill.md
    │       └── tool-preferences.md
    └── rust-skills-coding-guidelines/
        ├── POWER.md
        └── steering/
            └── skill.md
```

## 高级功能

### 自动生成 tool-preferences.md

如果 SKILL.md 的 frontmatter 包含 `replaces` 字段，脚本会自动生成 `tool-preferences.md`：

```yaml
---
name: "ripgrep"
description: "Fast text search tool"
replaces: "grepSearch"
replaces-description: "Replaces built-in grepSearch with faster ripgrep"
---
```

### 全局工具偏好设置

脚本会自动将 `tool-preferences.md` 复制到全局 steering 目录：

```
~/.kiro/steering/
├── ripgrep-tool-preferences.md
├── sharkdp-fd-tool-preferences.md
└── installed-tools-summary.md      # 自动生成的工具汇总
```

### 自动生成工具汇总

脚本会自动生成 `installed-tools-summary.md`，包含所有已安装工具的信息：

```markdown
# Installed Tools Summary

## Tool Replacements

### 1. ripgrep
- Tool Command: `rg`
- Replaces: `grepSearch`
- Description: Tool usage preferences for ripgrep - replaces grepSearch
- Config File: `~/.kiro/steering/ripgrep-tool-preferences.md`

### 2. sharkdp-fd
- Tool Command: `fd`
- Replaces: `fileSearch`
- Description: Tool usage preferences for sharkdp-fd - replaces fileSearch
- Config File: `~/.kiro/steering/sharkdp-fd-tool-preferences.md`
```

这个汇总文件会在每次运行脚本时自动更新，方便查看所有可用的工具。

## 故障排除

### 校验和不准确

如果怀疑校验和记录不准确，使用强制重装：

```bash
./kiro-adapter.sh --force
```

### 清除所有安装

```bash
rm -rf ~/.kiro/powers/installed/*
rm ~/.kiro/powers/.checksums
./kiro-adapter.sh
```

### 查看校验和记录

```bash
cat ~/.kiro/powers/.checksums
```

格式：`skill-name:md5hash[:optional-tool-preferences-hash]`

## 性能优化

### 首次安装

- 所有技能都会被安装
- 建立校验和基线

### 后续更新

- 只处理有变化的文件
- 大幅减少处理时间
- 适合频繁更新的开发场景

### 建议

- 日常使用默认模式（差异更新）
- 遇到问题时使用 `--force` 重装
- 开发调试时使用 `--verbose` 查看详情

## 兼容性

- macOS: 使用 `md5` 命令
- Linux: 使用 `md5sum` 命令
- 需要 `jq` 处理 JSON 文件

## 相关文档

- [SKILL.md 格式说明](./SKILL-FORMAT.md)
- [Tool Preferences 指南](./TOOL-PREFERENCES-GUIDE.md)
- [Kiro Powers 文档](https://kiro.ai/docs/powers)
