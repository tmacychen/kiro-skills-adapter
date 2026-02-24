# SKILL.md replaces 字段示例

## 概述

通过在 SKILL.md 的 frontmatter 中添加 `replaces` 字段，迁移工具会自动生成 tool-preferences.md 配置，让 Kiro 优先使用你的工具。

## 字段说明

| 字段 | 必需 | 说明 |
|-----|------|------|
| `replaces` | 是 | 要替代的内置工具名称 |
| `replaces-description` | 否 | 替代原因说明（推荐） |

## 完整示例

### ripgrep - 替代 grepSearch

```markdown
---
name: ripgrep
description: ripgrep (rg) - A fast line-oriented search tool that recursively searches directories for regex patterns
user-invocable: true
keywords: ["ripgrep", "rg", "grep", "search", "regex"]
replaces: grepSearch
replaces-description: Text/code content search - 10-20x faster with smart defaults
---

# ripgrep (rg)

[工具文档内容...]
```

### fd - 替代 fileSearch

```markdown
---
name: sharkdp-fd
description: fd - A fast, user-friendly alternative to the find command
user-invocable: true
keywords: ["fd", "find", "file search", "filesystem"]
replaces: fileSearch
replaces-description: File name/path search - 10-20x faster with intuitive syntax
---

# fd - Fast File Search Tool

[工具文档内容...]
```

### bat - 替代 readFile

```markdown
---
name: bat
description: A cat clone with syntax highlighting and Git integration
user-invocable: true
keywords: ["bat", "cat", "syntax", "highlighting"]
replaces: readFile
replaces-description: File reading with syntax highlighting and line numbers
---

# bat - Better cat

[工具文档内容...]
```

### exa - 替代 listDirectory

```markdown
---
name: exa
description: A modern replacement for ls with colors and icons
user-invocable: true
keywords: ["exa", "ls", "list", "directory"]
replaces: listDirectory
replaces-description: Directory listing with colors, icons, and git status
---

# exa - Modern ls

[工具文档内容...]
```

## 自动生成的 tool-preferences.md

当你运行 `./kiro-adapter.sh` 后，会自动生成类似这样的配置：

```markdown
---
inclusion: auto
---

# Tool Usage Preferences

This file was automatically generated from SKILL.md frontmatter.

## ripgrep Tool Preference

**ALWAYS prefer `rg` over built-in `grepSearch` tool.**

Text/code content search - 10-20x faster with smart defaults

When using this tool:
- Use `rg` command via `executeBash` tool
- Leverage the tool's performance and features
- Refer to the skill documentation for detailed usage patterns

**Only use `grepSearch` when:**
- `rg` is not available or fails
- You need IDE-specific structured output for further processing

## Rationale

ripgrep (rg) - A fast line-oriented search tool that recursively searches directories for regex patterns

This tool provides:
- Better performance than built-in alternatives
- Smart defaults (respects .gitignore, skips binary files)
- Rich feature set with intuitive syntax
- Colored output for better readability

## Usage

For detailed usage examples and options, refer to the skill documentation in `skill.md`.
```

## 工具命令映射

脚本会自动识别常见工具的命令名称：

| SKILL name | 实际命令 | 说明 |
|-----------|---------|------|
| `ripgrep` | `rg` | 自动映射 |
| `sharkdp-fd` | `fd` | 自动映射 |
| `bat` | `bat` | 使用 name |
| `exa` | `exa` | 使用 name |
| 其他 | skill name | 默认使用 skill name |

如果需要自定义命令名称，可以手动创建 tool-preferences.md 覆盖自动生成。

## 可替代的内置工具

| 内置工具 | 用途 | 推荐替代 |
|---------|------|---------|
| `grepSearch` | 文本/代码内容搜索 | `ripgrep` |
| `fileSearch` | 文件名/路径搜索 | `fd` |
| `readFile` | 读取文件内容 | `bat` |
| `listDirectory` | 列出目录内容 | `exa`, `lsd` |
| `executeBash` | 执行 Shell 命令 | 可配置增强版 |

## 处理优先级

1. **手动创建优先**: 如果存在 `tool-preferences.md`，直接复制
2. **自动生成**: 如果有 `replaces` 字段，自动生成
3. **跳过**: 两者都不存在时不创建

## 最佳实践

1. **使用自动生成**: 对于简单的工具替代，使用 `replaces` 字段即可
2. **手动创建**: 需要复杂配置或多个工具时，手动创建
3. **描述清晰**: `replaces-description` 应该简洁说明优势
4. **保持一致**: 团队项目中统一使用一种方式

## 验证

运行迁移后，检查生成的文件：

```bash
cat ~/.kiro/powers/installed/ripgrep/steering/tool-preferences.md
```

应该看到自动生成的配置内容。

## 故障排查

### 没有生成 tool-preferences.md

1. 检查 SKILL.md frontmatter 是否包含 `replaces` 字段
2. 确认字段格式正确（`replaces: toolName`）
3. 查看迁移脚本输出是否有错误

### 生成的配置不符合需求

1. 手动创建 `tool-preferences.md` 覆盖自动生成
2. 或者修改生成后的文件
3. 重新运行迁移脚本

### 工具命令名称不正确

1. 在脚本的 `generate_tool_preferences()` 函数中添加映射
2. 或者手动创建 tool-preferences.md 指定正确的命令

