# Kiro Skills 安装指南（中文版）

## 概述

`kiro-adapter.sh` 是一个智能安装脚本，支持差异更新和增量安装，避免重复安装未更改的技能。

## 核心特性

### 🚀 差异更新
- 自动检测文件变化
- 只更新修改过的技能
- 跳过未更改的技能

### 📊 智能追踪
- 使用 MD5 校验和追踪文件变化
- 记录每个技能的安装状态
- 支持增量更新

### ⚡ 性能优化
- 首次安装后，后续更新速度显著提升
- 适合频繁更新的开发场景
- 减少不必要的文件操作

## 使用方法

### 基本命令

```bash
# 默认模式：智能差异更新
./kiro-adapter.sh

# 强制重新安装所有技能
./kiro-adapter.sh --force

# 显示详细输出信息
./kiro-adapter.sh --verbose

# 组合使用多个选项
./kiro-adapter.sh -f -v

# 查看帮助信息
./kiro-adapter.sh --help
```

### 命令行选项说明

| 选项 | 简写 | 说明 |
|------|------|------|
| `--force` | `-f` | 强制重新安装所有技能，忽略校验和 |
| `--verbose` | `-v` | 显示详细的处理过程信息 |
| `--help` | `-h` | 显示帮助信息 |

## 工作原理

### 校验和机制

脚本为每个技能计算 MD5 校验和，包括：

1. **SKILL.md** - 技能定义文件
2. **tool-preferences.md** - 工具偏好设置（如果存在）

校验和存储位置：`~/.kiro/powers/.checksums`

### 差异检测算法

```
┌─────────────────┐
│  读取技能文件    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  计算 MD5 校验和 │
└────────┬────────┘
         │
         ▼
┌─────────────────┐      是      ┌──────────────┐
│ 校验和已存在？   │─────────────▶│ 比较校验和    │
└────────┬────────┘              └──────┬───────┘
         │ 否                           │
         │                              ▼
         │                    ┌─────────────────┐
         │                    │  校验和相同？    │
         │                    └────┬────────┬───┘
         │                         │ 是     │ 否
         │                         ▼        ▼
         │                    ┌────────┐ ┌────────┐
         └───────────────────▶│ 跳过   │ │ 更新   │
                              └────────┘ └────────┘
```

### 状态标识

| 标识 | 含义 | 说明 |
|------|------|------|
| `[NEW]` | 新安装 | 首次安装的技能 |
| `[UPDATE]` | 更新 | 文件有变化，需要更新 |
| `✓ Up to date` | 已是最新 | 跳过未更改的技能 |

## 输出示例

### 场景 1：首次安装

```
=== Kiro Skills Adapter ===
Source: /Users/username/kiro-skills
Target: /Users/username/.kiro/powers

ripgrep [NEW]
  ✓ Generated POWER.md
  ✓ Created steering
  ✓ Generated tool-preferences.md from SKILL.md
  ✓ Copied tool-preferences.md to global steering

rust-skills-coding-guidelines [NEW]
rust-skills-domain-web [NEW]

New: 3 | Updated: 0 | Skipped: 0
Total processed: 3

Updating default agent...
  ✓ Updated /Users/username/.kiro/agents/default.json

Powers are in: /Users/username/.kiro/powers/installed
Restart Kiro to load the powers
```

### 场景 2：差异更新（有变化）

```
=== Kiro Skills Adapter ===
Source: /Users/username/kiro-skills
Target: /Users/username/.kiro/powers

ripgrep [UPDATE]
rust-skills-coding-guidelines ✓ Up to date
rust-skills-domain-web ✓ Up to date

New: 0 | Updated: 1 | Skipped: 2
Total processed: 3
```

### 场景 3：无变化（全部跳过）

```
=== Kiro Skills Adapter ===
Source: /Users/username/kiro-skills
Target: /Users/username/.kiro/powers

ripgrep ✓ Up to date
rust-skills-coding-guidelines ✓ Up to date
rust-skills-domain-web ✓ Up to date

New: 0 | Updated: 0 | Skipped: 3
Total processed: 3
```

### 场景 4：强制重装

```
=== Kiro Skills Adapter ===
Source: /Users/username/kiro-skills
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

## 目录结构

### 输入结构

```
~/.kiro/skills/                    # 或当前目录
├── ripgrep/
│   ├── SKILL.md                   # 必需
│   └── tool-preferences.md        # 可选
├── rust-skills/
│   └── skills/                    # 嵌套结构
│       ├── coding-guidelines/
│       │   └── SKILL.md
│       └── domain-web/
│           └── SKILL.md
└── agent-browser/
    ├── SKILL.md
    ├── references/                # 参考文档
    └── templates/                 # 模板文件
```

### 输出结构

```
~/.kiro/powers/
├── .checksums                     # 校验和记录文件
├── installed.json                 # 已安装列表
├── registry.json                  # 注册表
└── installed/
    ├── ripgrep/
    │   ├── POWER.md              # 自动生成
    │   └── steering/
    │       ├── skill.md          # 从 SKILL.md 复制
    │       └── tool-preferences.md
    └── rust-skills-coding-guidelines/
        ├── POWER.md
        └── steering/
            └── skill.md

~/.kiro/steering/                  # 全局工具偏好设置
├── ripgrep-tool-preferences.md
├── sharkdp-fd-tool-preferences.md
├── installed-tools-summary.md    # 自动生成的工具汇总
└── installed-skills-summary.md   # 自动生成的技能汇总（包含 references 和 templates）
```

## 高级功能

### 自动生成工具偏好设置

如果 `SKILL.md` 的 frontmatter 包含 `replaces` 字段，脚本会自动生成 `tool-preferences.md`。

#### 示例 SKILL.md

```yaml
---
name: "ripgrep"
description: "超快的文本搜索工具"
keywords: ["search", "grep", "ripgrep"]
replaces: "grepSearch"
replaces-description: "使用更快的 ripgrep 替代内置的 grepSearch"
---

# Ripgrep

ripgrep 是一个面向行的搜索工具...
```

#### 自动生成的 tool-preferences.md

```markdown
---
description: "Tool usage preferences for ripgrep - replaces grepSearch"
inclusion: auto
---

# Tool Usage Preferences

**ALWAYS prefer `rg` over built-in `grepSearch` tool.**

使用更快的 ripgrep 替代内置的 grepSearch

When using this tool:
- Use `rg` command via `executeBash` tool
- Leverage the tool's performance and features
- Refer to the skill documentation for detailed usage patterns

**Only use `grepSearch` when:**
- `rg` is not available or fails
- You need IDE-specific structured output for further processing
```

### 全局工具偏好设置

脚本会自动将 `tool-preferences.md` 复制到全局 steering 目录，使其对所有项目生效：

```bash
~/.kiro/steering/
├── ripgrep-tool-preferences.md
├── sharkdp-fd-tool-preferences.md
└── installed-tools-summary.md      # 自动生成的工具汇总
```

这样 Kiro 在任何项目中都会优先使用这些工具。

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

### 自动生成技能资源汇总

脚本还会生成 `installed-skills-summary.md`，包含所有技能及其资源（references 和 templates）：

```markdown
# Installed Skills Summary

## Installed Skills

### 1. agent-browser
- Description: Browser automation for agents
- Skill File: `~/.kiro/powers/installed/agent-browser/steering/skill.md`
- References: 7 files in `~/.kiro/skills/agent-browser/references/`
- Templates: 3 files in `~/.kiro/skills/agent-browser/templates/`

  Reference Files:
  - `authentication.md`
  - `commands.md`
  - `profiling.md`
  - `proxy-support.md`
  - `session-management.md`
  - `snapshot-refs.md`
  - `video-recording.md`

  Template Files:
  - `authenticated-session.sh`
  - `capture-workflow.sh`
  - `form-automation.sh`

### 2. dogfood
- Description: Dogfooding and testing utilities
- Skill File: `~/.kiro/powers/installed/dogfood/steering/skill.md`
- References: 1 files in `~/.kiro/skills/dogfood/references/`
- Templates: 1 files in `~/.kiro/skills/dogfood/templates/`
```

这个汇总让 Kiro 能够：
- 了解每个技能包含哪些参考文档
- 知道有哪些模板可以使用
- 快速定位技能资源的位置

## 实用技巧

### 日常开发工作流

```bash
# 1. 修改技能文件
vim ~/.kiro/skills/my-skill/SKILL.md

# 2. 运行差异更新（只更新修改的技能）
./kiro-adapter.sh

# 3. 重启 Kiro 加载更新
```

### 调试技能

```bash
# 使用详细模式查看处理过程
./kiro-adapter.sh -v

# 查看校验和记录
cat ~/.kiro/powers/.checksums

# 查看已安装的技能
ls -la ~/.kiro/powers/installed/

# 查看全局工具汇总
cat ~/.kiro/steering/installed-tools-summary.md

# 查看全局技能资源汇总
cat ~/.kiro/steering/installed-skills-summary.md
```

### 清理和重装

```bash
# 清除所有已安装的技能
rm -rf ~/.kiro/powers/installed/*
rm ~/.kiro/powers/.checksums

# 重新安装
./kiro-adapter.sh
```

### 强制更新特定技能

```bash
# 删除特定技能的校验和记录
sed -i '' '/^my-skill:/d' ~/.kiro/powers/.checksums

# 运行更新（只会更新该技能）
./kiro-adapter.sh
```

## 故障排除

### 问题 1：技能没有更新

**症状**：修改了 SKILL.md，但运行脚本后显示 "Up to date"

**解决方案**：
```bash
# 方法 1：强制重装
./kiro-adapter.sh --force

# 方法 2：删除校验和记录
rm ~/.kiro/powers/.checksums
./kiro-adapter.sh
```

### 问题 2：校验和文件损坏

**症状**：脚本报错或行为异常

**解决方案**：
```bash
# 删除校验和文件，重新建立基线
rm ~/.kiro/powers/.checksums
./kiro-adapter.sh
```

### 问题 3：技能安装后不生效

**症状**：技能已安装但 Kiro 中无法使用

**解决方案**：
```bash
# 1. 检查安装目录
ls -la ~/.kiro/powers/installed/

# 2. 检查 agent 配置
cat ~/.kiro/agents/default.json

# 3. 重启 Kiro
```

### 问题 4：权限错误

**症状**：脚本无法写入文件

**解决方案**：
```bash
# 检查目录权限
ls -la ~/.kiro/powers/

# 修复权限
chmod -R u+w ~/.kiro/powers/
```

## 性能对比

### 首次安装（10 个技能）

```
传统方式：每次都重新安装所有技能
时间：~5-10 秒

差异更新：建立校验和基线
时间：~5-10 秒
```

### 后续更新（修改 1 个技能）

```
传统方式：重新安装所有 10 个技能
时间：~5-10 秒

差异更新：只更新 1 个技能
时间：~1-2 秒
性能提升：5-10 倍
```

### 后续更新（无修改）

```
传统方式：重新安装所有 10 个技能
时间：~5-10 秒

差异更新：跳过所有技能
时间：<1 秒
性能提升：10+ 倍
```

## 系统要求

### 必需工具

- **bash**: Shell 脚本解释器
- **jq**: JSON 处理工具
- **md5** (macOS) 或 **md5sum** (Linux): 计算校验和

### 安装依赖

```bash
# macOS (使用 Homebrew)
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# CentOS/RHEL
sudo yum install jq
```

### 兼容性

| 系统 | 支持状态 | 校验和工具 |
|------|---------|-----------|
| macOS | ✅ 完全支持 | `md5` |
| Linux | ✅ 完全支持 | `md5sum` |
| Windows (WSL) | ✅ 支持 | `md5sum` |
| Windows (原生) | ❌ 不支持 | - |

## 最佳实践

### 1. 使用版本控制

```bash
# 将技能目录加入 Git
cd ~/.kiro/skills
git init
git add .
git commit -m "Initial skills"

# 每次修改后提交
git commit -am "Update ripgrep skill"
```

### 2. 定期备份

```bash
# 备份技能和配置
tar -czf kiro-backup-$(date +%Y%m%d).tar.gz \
    ~/.kiro/skills \
    ~/.kiro/powers \
    ~/.kiro/agents
```

### 3. 团队协作

```bash
# 共享技能仓库
git clone https://github.com/team/kiro-skills.git ~/.kiro/skills

# 更新团队技能
cd ~/.kiro/skills
git pull
cd -
./kiro-adapter.sh
```

### 4. 开发新技能

```bash
# 1. 创建技能目录
mkdir -p ~/.kiro/skills/my-new-skill

# 2. 创建 SKILL.md
cat > ~/.kiro/skills/my-new-skill/SKILL.md <<'EOF'
---
name: "my-new-skill"
description: "My awesome skill"
keywords: ["custom", "tool"]
---

# My New Skill

Skill content here...
EOF

# 3. 安装（会自动检测为新技能）
./kiro-adapter.sh

# 4. 测试和迭代
# 修改 SKILL.md
# 运行 ./kiro-adapter.sh（只更新这个技能）
# 在 Kiro 中测试
```

## 相关文档

- [SKILL.md 格式规范](./SKILL-FORMAT.md)
- [Tool Preferences 配置指南](./TOOL-PREFERENCES-GUIDE.md)
- [Kiro Powers 官方文档](https://kiro.ai/docs/powers)
- [示例技能集合](./examples/)

## 更新日志

### v2.0.0 - 差异更新版本

- ✨ 新增差异检测功能
- ✨ 新增 MD5 校验和追踪
- ✨ 新增 `--force` 强制重装选项
- ✨ 新增 `--verbose` 详细输出选项
- ✨ 改进状态显示（NEW/UPDATE/Up to date）
- ✨ 优化性能，跳过未更改的技能
- 📝 完善文档和使用说明

### v1.0.0 - 初始版本

- 基本的技能安装功能
- 支持单个 SKILL.md 和嵌套 skills/ 结构
- 自动生成 POWER.md
- 工具偏好设置支持

## 贡献

欢迎提交问题和改进建议！

## 许可证

MIT License
