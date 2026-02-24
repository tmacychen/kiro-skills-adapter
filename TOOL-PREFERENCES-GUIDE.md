# Tool Preferences Guide

## 目录

- [概述](#概述)
- [工作原理](#工作原理)
- [文件位置](#文件位置)
- [配置格式](#配置格式)
  - [方式一：自动生成（推荐）](#方式一自动生成推荐)
  - [方式二：手动创建](#方式二手动创建)
- [实际示例](#实际示例)
  - [示例 1: 搜索工具优先级](#示例-1-搜索工具优先级)
  - [示例 2: 构建工具优先级](#示例-2-构建工具优先级)
- [可以覆盖的内置工具](#可以覆盖的内置工具)
- [使用流程](#使用流程)
  - [方式一：自动生成](#方式一自动生成)
  - [方式二：手动创建](#方式二手动创建-1)
- [最佳实践](#最佳实践)
- [注意事项](#注意事项)
- [故障排查](#故障排查)
  - [工具偏好未生效](#工具偏好未生效)
  - [迁移时未复制 tool-preferences.md](#迁移时未复制-tool-preferencesmd)
  - [Agent 仍使用内置工具](#agent-仍使用内置工具)
- [参考](#参考)

## 概述

当你在项目中配置了自定义工具（如 ripgrep、fd 等）后，可以通过 `tool-preferences.md` 文档来设置 Kiro 优先使用你的工具，而不是内置工具。

## 工作原理

1. 在你的 skill 目录中创建 `tool-preferences.md` 文件
2. 运行 `kiro-adapter.sh` 迁移脚本
3. 脚本会自动将 `tool-preferences.md` 复制到 power 的 steering 目录
4. Kiro 会自动加载这些偏好设置（通过 `inclusion: auto` frontmatter）
5. Agent 在执行任务时会优先使用你配置的工具

## 文件位置

### 单个 SKILL.md 结构
```
~/.kiro/skills/your-skill/
├── SKILL.md
└── tool-preferences.md          # 在这里创建
```

迁移后：
```
~/.kiro/powers/installed/your-skill/
├── POWER.md
└── steering/
    ├── skill.md
    └── tool-preferences.md      # 自动复制到这里
```

### 嵌套 skills 结构
```
~/.kiro/skills/your-skill/
└── skills/
    └── subskill/
        ├── SKILL.md
        └── tool-preferences.md  # 在这里创建
```

迁移后：
```
~/.kiro/powers/installed/your-skill-subskill/
├── POWER.md
└── steering/
    ├── skill.md
    └── tool-preferences.md      # 自动复制到这里
```

## 配置格式

### 方式一：自动生成（推荐）

在 SKILL.md 的 frontmatter 中添加 `replaces` 字段，迁移工具会自动生成 tool-preferences.md：

```markdown
---
name: your-tool
description: Your tool description
keywords: ["tool", "search"]
replaces: builtInTool
replaces-description: Why this tool is better
---
```

运行 `./kiro-adapter.sh` 后会自动生成 tool-preferences.md。

### 方式二：手动创建

如果需要更精细的控制，可以手动创建 tool-preferences.md：

### 基本结构

```markdown
---
inclusion: auto
---

# Tool Usage Preferences

## [工具类别]

**ALWAYS prefer `your-tool` over built-in `builtInTool` tool.**

When [使用场景描述]:
- Use `your-tool` command via `executeBash` tool
- [优势说明]
- Common patterns:
  ```bash
  your-tool [示例命令]
  ```

**Only use `builtInTool` when:**
- `your-tool` is not available or fails
- [其他回退条件]
```

### 关键要素

1. **Frontmatter**: 必须包含 `inclusion: auto` 以自动加载
2. **明确的优先级**: 使用 "ALWAYS prefer X over Y" 明确指定
3. **使用场景**: 清楚说明何时使用该工具
4. **示例命令**: 提供常用的命令模式
5. **回退条件**: 说明何时使用内置工具

## 实际示例

### 示例 1: 搜索工具优先级

```markdown
---
inclusion: auto
---

# Tool Usage Preferences

## Search and Find Tool Preferences

### Text Search (Code Content Search)

**ALWAYS prefer `ripgrep` (rg) over built-in `grepSearch` tool.**

When searching for text content in files:
- Use `rg` command via `executeBash` tool
- Leverage ripgrep's speed (10-20x faster)
- Common patterns:
  ```bash
  rg "pattern" -t rust           # Search in Rust files
  rg "pattern" -i                # Case-insensitive
  rg "pattern" -C 3              # Show 3 lines context
  ```

**Only use `grepSearch` when:**
- `rg` is not available or fails
- You need IDE-specific structured output

### File Search (Finding Files by Name)

**ALWAYS prefer `fd` over built-in `fileSearch` tool.**

When searching for files by name or path:
- Use `fd` command via `executeBash` tool
- Faster and more intuitive than find
- Common patterns:
  ```bash
  fd pattern                     # Find files
  fd -e rs pattern               # Find .rs files
  fd -t d pattern                # Find directories only
  ```

**Only use `fileSearch` when:**
- `fd` is not available or fails
```

### 示例 2: 构建工具优先级

```markdown
---
inclusion: auto
---

# Tool Usage Preferences

## Build Tool Preferences

**ALWAYS prefer `cargo-make` over direct `cargo` commands.**

When building or running tasks:
- Use `cargo make <task>` via `executeBash` tool
- Provides consistent task definitions across team
- Common patterns:
  ```bash
  cargo make build               # Build project
  cargo make test                # Run tests
  cargo make check               # Run checks
  ```

**Only use direct `cargo` commands when:**
- `cargo-make` is not available
- Running one-off commands not in Makefile.toml
```

## 可以覆盖的内置工具

常见的可以被替换的内置工具：

| 内置工具 | 用途 | 常见替代工具 |
|---------|------|------------|
| `grepSearch` | 文本/代码搜索 | `ripgrep` (rg) |
| `fileSearch` | 文件名/路径搜索 | `fd` |
| `executeBash` | Shell 命令执行 | 可以配置默认参数 |
| `readFile` | 读取文件 | `bat`, `cat` with plugins |
| `listDirectory` | 列出目录 | `exa`, `lsd` |

## 使用流程

### 方式一：自动生成（推荐）

1. **在 SKILL.md 中添加 replaces 字段**
   ```markdown
   ---
   name: ripgrep
   description: Fast search tool
   replaces: grepSearch
   replaces-description: 10-20x faster with smart defaults
   ---
   ```

2. **运行迁移脚本**
   ```bash
   ./kiro-adapter.sh
   ```
   
   脚本会：
   - 检测 `replaces` 字段
   - 自动生成 tool-preferences.md
   - 显示 "✓ Generated tool-preferences.md from SKILL.md"

3. **重启 Kiro** 加载配置

### 方式二：手动创建

1. **安装自定义工具**
   ```bash
   # 例如安装 ripgrep 和 fd
   brew install ripgrep fd
   # 或
   cargo install ripgrep fd-find
   ```

2. **创建 tool-preferences.md**
   - 在你的 skill 目录中创建文件
   - 参考 `tool-preferences-template.md` 模板
   - 明确指定工具优先级

3. **运行迁移脚本**
   ```bash
   ./kiro-adapter.sh
   ```
   
   脚本会：
   - 检测 `tool-preferences.md` 文件
   - 自动复制到 power 的 steering 目录
   - 显示 "✓ Copied tool-preferences.md" 确认信息

4. **重启 Kiro**
   - 重启后 Kiro 会自动加载工具偏好设置
   - Agent 会优先使用你配置的工具

5. **验证**
   - 让 Agent 执行搜索或其他操作
   - 观察是否使用了你配置的工具
   - 检查执行日志确认工具调用

## 最佳实践

1. **明确性**: 使用 "ALWAYS prefer" 和 "Only use when" 明确指定优先级
2. **文档化**: 提供清晰的示例和使用场景
3. **回退策略**: 始终提供内置工具作为回退选项
4. **性能说明**: 解释为什么优先使用某个工具（性能、功能等）
5. **团队一致性**: 在团队项目中统一工具偏好设置

## 注意事项

- `inclusion: auto` 是必需的，否则不会自动加载
- 工具必须在系统中已安装，否则会回退到内置工具
- 迁移脚本会覆盖已存在的 tool-preferences.md
- 修改后需要重启 Kiro 才能生效
- Agent 会自动遵循这些偏好，无需用户明确指示

## 故障排查

### 工具偏好未生效

1. 检查 frontmatter 是否包含 `inclusion: auto`
2. 确认文件已复制到 `~/.kiro/powers/installed/*/steering/`
3. 重启 Kiro
4. 检查工具是否已安装在系统中

### 迁移时未复制 tool-preferences.md

1. 确认文件名正确：`tool-preferences.md`
2. 确认文件位置在 skill 目录根目录
3. 检查迁移脚本输出是否有错误信息
4. 手动运行脚本查看详细日志

### Agent 仍使用内置工具

1. 检查工具是否在 PATH 中可用
2. 确认 tool-preferences.md 语法正确
3. 查看 Agent 执行日志了解原因
4. 可能是回退条件被触发（工具不可用等）

## 参考

- 模板文件: `tool-preferences-template.md`
- 示例文件: `tool-preferences.md`
- 迁移脚本: `kiro-adapter.sh`

