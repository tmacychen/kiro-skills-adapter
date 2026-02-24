# Kiro Skills Adapter

[中文](#中文) | [English](#english)

---

## 中文

将 Claude Desktop 格式的 skills 适配到 Kiro CLI，无需修改源代码。

## 快速开始

```bash
# 1. 克隆 skills 到 ~/.kiro/skills/
cd ~/.kiro/skills
git clone https://github.com/ZhangHanDong/rust-skills
git clone https://github.com/Mindverse/Second-Me-Skills

# 2. 运行适配器
chmod +x kiro-adapter.sh
./kiro-adapter.sh

# 3. 设置默认 agent 为 Default（重要！）
kiro-cli config set defaultAgent Default

# 4. 完成！Kiro 现在可以使用这些 skills
```

### 配置工具优先级（可选）

如果你有自定义工具（如 ripgrep、fd），可以在 SKILL.md 中添加 `replaces` 字段：

```bash
# 编辑 SKILL.md 添加以下内容
---
name: ripgrep
replaces: grepSearch
replaces-description: 10-20x faster with smart defaults
---

# 重新运行适配器
./kiro-adapter.sh

# 重启 Kiro 加载配置
```

## 重要配置

配置 skills 后，必须将 Kiro CLI 的默认 agent 设置为 `Default`，而不是 `chat`：

```bash
kiro-cli config set defaultAgent Default
```

这样 skills 才能被正确加载和使用。

## 工作原理

- **符号链接**：在 `~/.kiro/powers/` 创建指向 `~/.kiro/skills/` 的链接
- **零修改**：不改动源仓库任何文件
- **自动更新**：在源仓库 `git pull` 后重新运行适配器即可

## 新功能：Tool Preferences 自动生成

适配器现在支持从 SKILL.md 自动生成 `tool-preferences.md` 配置，让 Kiro 优先使用自定义工具。

### 使用方法

在 SKILL.md 中添加 `replaces` 字段：

```markdown
---
name: ripgrep
description: Fast search tool
replaces: grepSearch
replaces-description: 10-20x faster with smart defaults
---
```

运行适配器后会自动生成 tool-preferences.md，Kiro 会优先使用 `rg` 而不是内置的 `grepSearch`。

### 支持的替代工具

| 内置工具 | 用途 | 推荐替代 |
|---------|------|---------|
| `grepSearch` | 文本/代码搜索 | `ripgrep` (rg) |
| `fileSearch` | 文件名/路径搜索 | `fd` |
| `readFile` | 读取文件 | `bat` |
| `listDirectory` | 列出目录 | `exa`, `lsd` |

### 详细文档

- [工具偏好配置指南](TOOL-PREFERENCES-GUIDE.md) - 中文版
- [Tool Preferences Guide (English)](TOOL-PREFERENCES-GUIDE-EN.md) - 英文版
- [replaces 字段示例](REPLACES-FIELD-EXAMPLE.md) - 完整示例
- [迁移更新说明](MIGRATION-UPDATE.md) - 新功能说明
- [测试结果报告](TEST-RESULTS.md) - 功能验证

## 更新 Skills

```bash
cd ~/.kiro/skills/rust-skills
git pull
cd ~/.kiro/skills
./kiro-adapter.sh
```

## 目录结构

```
~/.kiro/skills/          # 源仓库（可 git pull）
├── kiro-adapter.sh      # 适配工具
├── rust-skills/         # Git 仓库
└── Second-Me-Skills/    # Git 仓库

~/.kiro/powers/          # Kiro 读取目录
├── rust-skills -> ../skills/rust-skills
└── Second-Me-Skills -> ../skills/Second-Me-Skills
```

## 新功能：Tool Preferences 自动生成

适配器现在支持从 SKILL.md 自动生成 `tool-preferences.md` 配置文件，让 Kiro 优先使用自定义工具。

### 主要特性

1. **自动生成配置**：在 SKILL.md 中添加 `replaces` 字段，适配器自动生成工具优先级配置
2. **智能命令映射**：自动识别工具命令（如 `ripgrep` → `rg`, `sharkdp-fd` → `fd`）
3. **向后兼容**：不影响现有功能，无 `replaces` 字段时正常处理
4. **优先级处理**：手动配置优先，自动生成作为后备

### 使用示例

在 SKILL.md 中添加：
```yaml
---
name: ripgrep
replaces: grepSearch
replaces-description: 10-20x faster with smart defaults
---
```

运行适配器后自动生成：
- `~/.kiro/powers/installed/ripgrep/steering/tool-preferences.md`
- 包含完整的工具优先级配置

### 支持的内置工具替换

| 内置工具 | 用途 | 推荐替代工具 |
|---------|------|------------|
| `grepSearch` | 文本/代码搜索 | `ripgrep` (rg) |
| `fileSearch` | 文件搜索 | `fd` |
| `readFile` | 文件读取 | `bat` |
| `listDirectory` | 目录列表 | `exa`, `lsd` |

### 相关文档

- [工具偏好配置指南](TOOL-PREFERENCES-GUIDE.md) - 完整使用指南
- [replaces 字段示例](REPLACES-FIELD-EXAMPLE.md) - 完整示例
- [迁移更新说明](MIGRATION-UPDATE.md) - 新功能详情
- [测试结果报告](TEST-RESULTS.md) - 功能验证

## 兼容性

支持的 skill 格式：
- Claude Desktop skills（包含 `skills/` 目录）
- 单文件 skills（包含 `SKILL.md`）
- Claude Plugin 格式（包含 `.claude-plugin/plugin.json`）

Kiro 会自动识别这些格式并加载。

---

## English

Convert Claude Desktop skills to Kiro CLI format without modifying source code.

## Quick Start

```bash
# 1. Clone skills to ~/.kiro/skills/
cd ~/.kiro/skills
git clone https://github.com/ZhangHanDong/rust-skills
git clone https://github.com/Mindverse/Second-Me-Skills

# 2. Run the adapter
chmod +x kiro-adapter.sh
./kiro-adapter.sh

# 3. Set default agent to Default (Important!)
kiro-cli config set defaultAgent Default

# 4. Done! Kiro can now use these skills
```

### Configure Tool Priorities (Optional)

If you have custom tools (like ripgrep, fd), add `replaces` field to SKILL.md:

```bash
# Edit SKILL.md to add:
---
name: ripgrep
replaces: grepSearch
replaces-description: 10-20x faster with smart defaults
---

# Re-run the adapter
./kiro-adapter.sh

# Restart Kiro to load configuration
```

## Important Configuration

After configuring skills, you must set Kiro CLI's default agent to `Default` instead of `chat`:

```bash
kiro-cli config set defaultAgent Default
```

This ensures skills are properly loaded and available.

## How It Works

- **Symbolic Links**: Creates links in `~/.kiro/powers/` pointing to `~/.kiro/skills/`
- **Zero Modification**: No changes to source repositories
- **Auto Update**: Re-run adapter after `git pull` in source repos

## New Feature: Tool Preferences Auto-generation

The adapter now supports automatic generation of `tool-preferences.md` from SKILL.md, allowing Kiro to prioritize custom tools.

### Usage

Add `replaces` field to SKILL.md:

```markdown
---
name: ripgrep
description: Fast search tool
replaces: grepSearch
replaces-description: 10-20x faster with smart defaults
---
```

After running the adapter, tool-preferences.md will be automatically generated, and Kiro will prioritize using `rg` over built-in `grepSearch`.

### Supported Tool Replacements

| Built-in Tool | Purpose | Recommended Alternative |
|--------------|---------|------------------------|
| `grepSearch` | Text/code content search | `ripgrep` (rg) |
| `fileSearch` | File name/path search | `fd` |
| `readFile` | Read file content | `bat` |
| `listDirectory` | List directory contents | `exa`, `lsd` |

### Documentation

- [Tool Preferences Guide (English)](TOOL-PREFERENCES-GUIDE-EN.md) - English version
- [工具偏好配置指南](TOOL-PREFERENCES-GUIDE.md) - Chinese version
- [replaces Field Examples](REPLACES-FIELD-EXAMPLE.md) - Complete examples
- [Migration Update Notes](MIGRATION-UPDATE.md) - New feature details
- [Test Results Report](TEST-RESULTS.md) - Feature verification

## Update Skills

```bash
cd ~/.kiro/skills/rust-skills
git pull
cd ~/.kiro/skills
./kiro-adapter.sh
```

## Directory Structure

```
~/.kiro/skills/          # Source repos (git pull enabled)
├── kiro-adapter.sh      # Adapter tool
├── rust-skills/         # Git repository
└── Second-Me-Skills/    # Git repository

~/.kiro/powers/          # Kiro reads from here
├── rust-skills -> ../skills/rust-skills
└── Second-Me-Skills -> ../skills/Second-Me-Skills
```

## New Feature: Tool Preferences Auto-generation

The adapter now supports automatic generation of `tool-preferences.md` from SKILL.md, allowing Kiro to prioritize custom tools.

### Key Features

1. **Auto-generated Configuration**: Add `replaces` field to SKILL.md, adapter auto-generates tool priority config
2. **Smart Command Mapping**: Automatically recognizes tool commands (e.g., `ripgrep` → `rg`, `sharkdp-fd` → `fd`)
3. **Backward Compatible**: No impact on existing functionality, works normally without `replaces` field
4. **Priority Handling**: Manual configuration takes precedence, auto-generation as fallback

### Usage Example

Add to SKILL.md:
```yaml
---
name: ripgrep
replaces: grepSearch
replaces-description: 10-20x faster with smart defaults
---
```

After running adapter, automatically generates:
- `~/.kiro/powers/installed/ripgrep/steering/tool-preferences.md`
- Complete tool priority configuration

### Supported Built-in Tool Replacements

| Built-in Tool | Purpose | Recommended Alternative |
|--------------|---------|------------------------|
| `grepSearch` | Text/code content search | `ripgrep` (rg) |
| `fileSearch` | File name/path search | `fd` |
| `readFile` | Read file content | `bat` |
| `listDirectory` | List directory contents | `exa`, `lsd` |

### Related Documentation

- [Tool Preferences Guide (English)](TOOL-PREFERENCES-GUIDE-EN.md) - Complete usage guide
- [replaces Field Examples](REPLACES-FIELD-EXAMPLE.md) - Complete examples
- [Migration Update Notes](MIGRATION-UPDATE.md) - New feature details
- [Test Results Report](TEST-RESULTS.md) - Feature verification

## Compatibility

Supported skill formats:
- Claude Desktop skills (with `skills/` directory)
- Single-file skills (with `SKILL.md`)
- Claude Plugin format (with `.claude-plugin/plugin.json`)

Kiro automatically recognizes and loads these formats.
