# Kiro Skills Adapter

将 Skills 从任意目录转换为 Kiro Powers 格式的智能安装工具。

> 📖 **新手？** 查看 [快速开始指南](./QUICKSTART.md) 5 分钟上手！

## 特性

- ✅ **差异更新**: 自动检测文件变化，只更新修改过的技能
- ✅ **增量安装**: 跳过未更改的技能，节省时间
- ✅ **校验和追踪**: 使用 MD5 校验和追踪文件变化
- ✅ **工具偏好设置**: 自动生成和管理工具偏好配置
- ✅ **符合规范**: 遵循 Kiro 官方 Steering 标准
- ✅ **Submodule 支持**: 支持 Git submodule 形式的技能仓库
- ✅ **自动清理**: --fix 模式下自动清理多余的 powers

## 快速开始

### 安装

```bash
# 克隆仓库
git clone <repository-url>
cd kiro-skills-adapter

# 赋予执行权限
chmod +x kiro-adapter.sh
```

### 基本使用

```bash
# 默认模式：智能差异更新 + 自动初始化 Steering
./kiro-adapter.sh

# 修复旧版本配置
./kiro-adapter.sh --fix

# 强制重新安装所有技能
./kiro-adapter.sh --force

# 显示详细输出
./kiro-adapter.sh --verbose

# 查看帮助
./kiro-adapter.sh --help
```

## 项目结构

```
kiro-skills-adapter/
├── kiro-adapter.sh           # 主脚本
├── templates/                # 模板文件目录
│   ├── README.md            # 模板说明文档
│   └── steering/            # Steering 模板
│       ├── product.md       # 产品概述模板
│       ├── tech.md          # 技术栈模板
│       ├── structure.md     # 项目结构模板
│       └── powers.md        # Powers 系统介绍
├── README.md                # 本文档
├── QUICKSTART.md            # 快速开始指南
└── docs/                    # 详细文档
```

**模板系统**:
- 所有 Steering 模板存储在 `templates/steering/` 目录
- 脚本运行时自动复制到 `~/.kiro/steering/`
- 不会覆盖已存在的文件
- 可以自定义模板以匹配项目需求

## 工作原理

### 输入结构

脚本支持三种技能目录结构：

```
~/.kiro/skills/                    # 或当前目录
├── ripgrep/                       # 单个技能
│   ├── SKILL.md                   # 必需
│   └── tool-preferences.md        # 可选
├── agent-browser/                 # Git submodule
│   └── skills/                    # 嵌套 skills 目录
│       ├── agent-browser/
│       │   ├── SKILL.md
│       │   ├── references/        # 参考文档
│       │   └── templates/         # 模板文件
│       ├── dogfood/
│       │   └── SKILL.md
│       ├── electron/
│       │   └── SKILL.md
│       └── slack/
│           └── SKILL.md
└── rust-skills/                   # Git submodule
    └── skills/                    # 嵌套结构
        ├── coding-guidelines/
        │   └── SKILL.md
        └── domain-web/
            └── SKILL.md
```

**说明**:
- **单个技能**: 包含 `SKILL.md` 的目录直接安装
- **Git submodule**: 如果包含 `skills/` 子目录，会递归处理所有子技能
- **嵌套结构**: 子技能名称会添加父目录前缀（如 `agent-browser-agent-browser`）

### 输出结构

```
~/.kiro/
├── steering/                      # 项目约定和标准
│   ├── tool-preferences.md        # 统一的工具偏好设置
│   ├── product.md                 # 产品概述（模板，可选）
│   ├── tech.md                    # 技术栈（模板，可选）
│   └── structure.md               # 项目结构（模板，可选）
└── powers/
    └── installed/
        ├── ripgrep/
        │   ├── POWER.md
        │   └── steering/
        │       ├── skill.md
        │       └── tool-preferences.md  # 技能内的配置
        └── ...
```

## 核心功能

### 1. 差异更新

脚本使用 MD5 校验和追踪文件变化：

- 首次运行：安装所有技能，建立校验和基线
- 后续运行：只更新有变化的技能
- 性能提升：5-10 倍（对于未更改的技能）

### 2. 自动初始化 Steering

每次运行时自动创建缺失的 Steering 模板文件：

- `product.md` - 产品概述
- `tech.md` - 技术栈
- `structure.md` - 项目结构
- 跳过已存在的文件，不会覆盖

### 3. 工具偏好设置

自动处理工具偏好配置：

- 从 SKILL.md 的 `replaces` 字段自动生成
- 生成统一的工具偏好汇总到 `~/.kiro/steering/tool-preferences.md`

### 4. 修复旧配置

使用 `--fix` 选项修复和验证配置：

- 对比文件内容，不一致则重新生成（创建 `.bak` 备份）
- 一致则跳过，不修改
- 检测额外的文档并提示删除
- 修正 `inclusion: auto` → `inclusion: always`
- **自动清理多余的 powers**

#### 清理多余 Powers

`--fix` 功能会自动检测并清理不再对应当前源目录结构的 powers：

```bash
$ ./kiro-adapter.sh --fix

Checking for orphaned powers...
  ⚠ Orphaned power detected: agent-browser
     Removing...
  ⚠ Orphaned power detected: dogfood
     Removing...
Removed 2 orphaned powers
```

**清理场景**：
- 旧版本遗留的 powers
- 修改目录结构后的多余 powers
- 手动删除源文件后的残留 powers

**安全机制**：
- 完全通用：基于文件结构判断，无硬编码规则
- 只删除不在源目录中的 powers
- 同时清理校验和记录

### 5. 符合 Kiro 规范

- **Steering**: 用于项目约定（工具偏好、API 规范等）
- 使用正确的 `inclusion` 模式（`always`, `fileMatch`, `manual`）

## SKILL.md 格式

### 基本格式

```yaml
---
name: "skill-name"
description: "Skill description"
keywords: ["keyword1", "keyword2"]
---

# Skill Name

Skill content here...
```

### 工具替代配置

如果你的技能提供了替代内置工具的功能，添加 `replaces` 字段：

```yaml
---
name: "ripgrep"
description: "Fast text search tool"
keywords: ["search", "grep", "ripgrep"]
replaces: "grepSearch"
replaces-description: "Replaces built-in grepSearch with faster ripgrep"
---
```

脚本会自动生成 `tool-preferences.md` 并复制到全局 steering 目录。

## 命令行选项

| 选项 | 简写 | 说明 |
|------|------|------|
| `--force` | `-f` | 强制重新安装所有技能，忽略校验和 |
| `--verbose` | `-v` | 显示详细的处理过程信息 |
| `--fix` | - | 修复旧版本配置（迁移旧环境） |
| `--help` | `-h` | 显示帮助信息 |

## 输出示例

### 正常运行

```
=== Kiro Skills Adapter ===
Source: /Users/username/kiro-skills
Target: /Users/username/.kiro/powers

ripgrep [UPDATE]
rust-skills-coding-guidelines ✓ Up to date
rust-skills-domain-web ✓ Up to date

New: 0 | Updated: 1 | Skipped: 2
Total processed: 3

Generating global tools summary...
  ✓ Generated tools summary with 2 tools
  ✓ Generated skills summary with 47 skills

Updating default agent...
  ✓ Updated /Users/username/.kiro/agents/default.json

Powers are in: /Users/username/.kiro/powers/installed
Restart Kiro to load the powers
```

## 故障排除

### 问题 1：技能没有更新

```bash
# 强制重装
./kiro-adapter.sh --force

# 或删除校验和记录
rm ~/.kiro/powers/.checksums
./kiro-adapter.sh
```

### 问题 2：从旧版本迁移或验证配置

```bash
# 修复和验证配置
./kiro-adapter.sh --fix

# 查看详细输出
./kiro-adapter.sh --fix --verbose
```

`--fix` 会：
- 对比文件内容，不一致则重新生成
- 创建 `.bak` 备份文件
- 检测并提示删除额外的文件

### 问题 3：技能安装后不生效

```bash
# 检查安装目录
ls -la ~/.kiro/powers/installed/

# 检查 agent 配置
cat ~/.kiro/agents/default.json

# 重启 Kiro
```

## 最佳实践

### 1. 日常开发工作流

```bash
# 1. 修改技能文件
vim ~/.kiro/skills/my-skill/SKILL.md

# 2. 运行差异更新（自动初始化 Steering）
./kiro-adapter.sh

# 3. 重启 Kiro 加载更新
```

### 2. 创建新技能

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

# 3. 安装
./kiro-adapter.sh
```

### 3. 自定义 Steering 配置

```bash
# Steering 模板会自动创建，直接编辑即可
vim ~/.kiro/steering/product.md
vim ~/.kiro/steering/tech.md
vim ~/.kiro/steering/structure.md

# 重启 Kiro 加载配置
```

### 3. 添加参考文档和模板

```bash
# 创建目录
mkdir -p ~/.kiro/skills/my-skill/references
mkdir -p ~/.kiro/skills/my-skill/templates

# 添加文件
echo "# Reference" > ~/.kiro/skills/my-skill/references/guide.md
echo "# Template" > ~/.kiro/skills/my-skill/templates/example.sh

# 重新安装以更新索引
./kiro-adapter.sh
```

### 4. 从旧版本迁移

```bash
# 修复旧配置
./kiro-adapter.sh --fix

# 正常安装
./kiro-adapter.sh
```

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

## 文档

- 📚 [快速开始](./QUICKSTART.md) - 5 分钟上手指南
- 🔄 [迁移指南](./MIGRATION.md) - 从旧版本迁移
- 📝 [更新说明](./UPDATE-NOTES.md) - 最新变更详情
- 📖 [安装指南（中文）](./docs/INSTALL-GUIDE-ZH.md) - 详细的中文文档
- 📖 [安装指南（英文）](./docs/INSTALL-GUIDE.md) - 详细的英文文档
- 📋 [Steering 文件指南](./docs/STEERING-FILES-GUIDE.md) - Steering 文件完整指南
- 🔍 [Steering 和 Skills 分析](./docs/STEERING-SKILLS-ANALYSIS.md) - 官方规范分析
- 📁 [项目结构](./PROJECT-STRUCTURE.md) - 项目组织说明

## 更新日志

### v3.2.0 - 自动清理多余 Powers

- ✨ **自动清理多余 powers**: `--fix` 模式下自动检测并清理
- ✨ **智能识别**: 基于源目录结构构建期望列表
- ✨ **安全机制**: 白名单保护，只删除多余项
- ✨ **清晰反馈**: 显示清理进度和统计
- 🔧 增强 `--fix` 功能：不仅修复配置，还清理多余 powers
- 📝 新增 `FIX-FEATURE-UPDATE.md` 文档

### v3.1.0 - 模板外部化

- ✨ **模板外部化**：将所有 Steering 模板移到 `templates/steering/` 目录
- ✨ **改进可维护性**：不再在脚本中嵌入大量文本
- ✨ **易于自定义**：可以直接编辑模板文件
- ✨ **新增 powers.md 模板**：介绍 Kiro Powers 系统
- 📝 添加 `templates/README.md` 说明文档
- 🔧 优化 `initialize_steering_templates()` 函数
- 🔧 优化 `fix_old_configuration()` 函数

### v3.0.0 - 简化和自动化

- ✨ **自动初始化 Steering**：每次运行自动创建缺失的模板
- ✨ **新增 `--fix` 选项**：修复旧版本配置
- 🔥 **移除 `--init-steering`**：不再需要单独初始化
- ✨ 智能跳过已存在的文件
- ✨ 自动修正 inclusion 模式
- 📝 简化用户体验

### v2.0.0 - 符合 Kiro 规范

- ✨ 修正 Steering 的使用
- ✨ 修正 `inclusion` 模式（`auto` → `always`）
- ✨ 创建标准 Steering 文件模板

### v1.0.0 - 差异更新版本

- ✨ 新增差异检测功能
- ✨ 新增 MD5 校验和追踪
- ✨ 新增 `--force` 强制重装选项
- ✨ 新增 `--verbose` 详细输出选项
- ✨ 改进状态显示（NEW/UPDATE/Up to date）
- ✨ 优化性能，跳过未更改的技能

## 贡献

欢迎提交问题和改进建议！

## 许可证

GNU General Public License v3

## 相关链接

- [Kiro 官方文档](https://kiro.dev/docs/)
- [Kiro Steering 文档](https://kiro-community.github.io/book-of-kiro/en/features/steering/)
- [Kiro Skills 更新日志](https://kiro.dev/changelog/cli/1-24)
