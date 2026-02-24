# Kiro Adapter 迁移工具更新

## 新增功能：Tool Preferences 自动生成

### 概述

`kiro-adapter.sh` 现在支持从 SKILL.md 的 frontmatter 自动生成 `tool-preferences.md` 文件。只需在 SKILL.md 中添加 `replaces` 字段，迁移工具会自动生成工具优先级配置。

### 更新内容

1. **新增 frontmatter 字段**:
   - `replaces`: 指定要替代的内置工具名称（如 `grepSearch`, `fileSearch`）
   - `replaces-description`: 描述替代的原因和优势

2. **新增函数**: `generate_tool_preferences()`
   - 从 SKILL.md frontmatter 提取 `replaces` 字段
   - 自动生成 tool-preferences.md 配置
   - 包含工具使用说明和回退策略

3. **智能处理优先级**:
   - 优先复制已存在的 `tool-preferences.md`
   - 如果不存在，则从 SKILL.md 自动生成
   - 无需手动编写配置文件

### SKILL.md 配置示例

#### ripgrep (替代 grepSearch)

```markdown
---
name: ripgrep
description: ripgrep (rg) - A fast line-oriented search tool
keywords: ["ripgrep", "rg", "grep", "search"]
replaces: grepSearch
replaces-description: Text/code content search - 10-20x faster with smart defaults
---
```

#### fd (替代 fileSearch)

```markdown
---
name: sharkdp-fd
description: fd - A fast, user-friendly alternative to the find command
keywords: ["fd", "find", "file search"]
replaces: fileSearch
replaces-description: File name/path search - 10-20x faster with intuitive syntax
---
```

### 使用方法

1. **在 SKILL.md 中添加 replaces 字段**：
   ```markdown
   ---
   name: your-tool
   description: Your tool description
   replaces: builtInTool
   replaces-description: Why this tool is better
   ---
   ```

2. **运行迁移脚本**：
   ```bash
   ./kiro-adapter.sh
   ```

3. **脚本输出**：
   ```
   your-tool
     ✓ Generated POWER.md
     ✓ Created steering
     ✓ Generated tool-preferences.md from SKILL.md    # 自动生成
   ```

4. **重启 Kiro** 加载新配置

### 生成的 tool-preferences.md 示例

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
```

### 处理优先级

迁移脚本按以下优先级处理 tool-preferences：

1. **手动创建的文件优先**: 如果 skill 目录中已有 `tool-preferences.md`，直接复制
2. **自动生成**: 如果没有手动文件但 SKILL.md 有 `replaces` 字段，自动生成
3. **跳过**: 如果两者都不存在，不创建 tool-preferences.md

### 支持的内置工具

可以通过 `replaces` 字段替代的内置工具：

| 内置工具 | 用途 | 推荐替代工具 |
|---------|------|------------|
| `grepSearch` | 文本/代码搜索 | `ripgrep` (rg) |
| `fileSearch` | 文件名/路径搜索 | `fd` |
| `executeBash` | Shell 命令执行 | 可配置增强版 |
| `readFile` | 读取文件 | `bat`, `cat` |
| `listDirectory` | 列出目录 | `exa`, `lsd` |

### 工具命令映射

脚本会自动识别常见工具的命令名称：

| Skill Name | 命令名称 |
|-----------|---------|
| `ripgrep` | `rg` |
| `sharkdp-fd` | `fd` |
| 其他 | 使用 skill name |

### 文件结构

迁移前：
```
~/.kiro/skills/ripgrep/
└── SKILL.md (包含 replaces 字段)
```

迁移后：
```
~/.kiro/powers/installed/ripgrep/
├── POWER.md
└── steering/
    ├── skill.md
    └── tool-preferences.md    # 自动生成
```

### 优势

1. **零配置**: 只需在 SKILL.md 添加两个字段
2. **自动化**: 迁移时自动生成配置
3. **一致性**: 所有工具使用统一的配置格式
4. **可覆盖**: 可以手动创建 tool-preferences.md 覆盖自动生成
5. **向后兼容**: 没有 replaces 字段的 skill 正常工作

### 文档

- **完整指南**: `TOOL-PREFERENCES-GUIDE.md`
- **配置模板**: `tool-preferences-template.md`
- **实际示例**: 查看 `ripgrep/SKILL.md` 和 `sharkdp-fd/SKILL.md`

### 注意事项

- `replaces` 字段必须是有效的 Kiro 内置工具名称
- 生成的文件包含 `inclusion: auto` 自动加载
- 手动创建的 tool-preferences.md 优先级更高
- 修改后需要重启 Kiro 才能生效

### 兼容性

- 向后兼容：没有 `replaces` 字段的 skill 正常工作
- 自动检测：只在字段存在时才生成
- 优先级处理：手动文件 > 自动生成 > 不创建

