# Steering 和 Skills 处理分析报告

## 官方文档要点

### Steering 的定义和用途

根据 [Kiro 官方文档](https://kiro-community.github.io/book-of-kiro/en/features/steering/)：

1. **Steering 是什么**：
   - 通过 `.kiro/steering/` 目录中的 markdown 文件提供持久的项目知识
   - 确保 Kiro 始终遵循你建立的模式、库和标准
   - 不需要在每次对话中重复解释项目约定

2. **Steering 的三种包含模式**：
   ```yaml
   # 1. Always Include (默认)
   ---
   inclusion: always
   ---
   
   # 2. Conditional Include (条件包含)
   ---
   inclusion: fileMatch
   fileMatchPattern: 'components/**/*.tsx'
   ---
   
   # 3. Manual Include (手动包含)
   ---
   inclusion: manual
   ---
   ```

3. **Steering 的用途**：
   - 项目范围的标准和约定
   - 技术偏好和架构原则
   - API 设计规范
   - 测试方法论
   - 部署流程

### Skills 的定义和用途

根据 [Kiro Changelog 1.24](https://kiro.dev/changelog/cli/1-24)：

1. **Skills 是什么**：
   - 为大型文档集设计的新资源类型
   - 只在启动时加载元数据（name 和 description）
   - 完整内容按需加载（当 agent 需要时）
   - 需要 YAML frontmatter 和描述性元数据

2. **Skills 的特点**：
   - **渐进式上下文加载**：避免一次性加载所有内容
   - **按需激活**：根据任务相关性自动激活
   - **可移植**：可以跨项目共享或从社区导入

3. **Skills 的激活方式**：
   - 自动激活：当请求匹配 skill 的 description 时
   - 手动激活：通过 `/` 斜杠命令

## 当前实现的问题

### 问题 1：混淆了 Steering 和 Skills 的概念

**当前做法**：
```bash
~/.kiro/steering/
├── installed-tools-summary.md      # ❌ 这应该是 skill，不是 steering
└── installed-skills-summary.md     # ❌ 这应该是 skill，不是 steering
```

**问题分析**：
- `installed-tools-summary.md` 和 `installed-skills-summary.md` 是**大型文档集的索引**
- 它们应该作为 **Skills** 存在，而不是 Steering
- Steering 应该用于**项目约定和标准**，不是技能索引

### 问题 2：Steering 的 inclusion 模式使用不当

**当前做法**：
```yaml
---
description: "Summary of all installed skills with their resources"
inclusion: auto    # ❌ 'auto' 不是有效的 inclusion 模式
---
```

**正确做法**：
```yaml
---
description: "Summary of all installed skills with their resources"
inclusion: always  # ✅ 或 fileMatch 或 manual
---
```

### 问题 3：Skills 应该在 Powers 系统中，不是 Steering

**当前架构**：
```
~/.kiro/
├── steering/                        # 项目约定和标准
│   ├── installed-tools-summary.md   # ❌ 应该是 skill
│   └── installed-skills-summary.md  # ❌ 应该是 skill
└── powers/
    └── installed/
        ├── ripgrep/
        │   └── steering/
        │       └── skill.md         # ✅ 这是正确的
        └── ...
```

**正确架构**：
```
~/.kiro/
├── steering/                        # 项目约定和标准
│   ├── product.md                   # ✅ 产品概述
│   ├── tech.md                      # ✅ 技术栈
│   ├── structure.md                 # ✅ 项目结构
│   ├── api-standards.md             # ✅ API 规范
│   └── tool-preferences.md          # ✅ 工具偏好（这个是合理的）
└── powers/
    └── installed/
        ├── skills-index/            # ✅ 技能索引作为 power
        │   ├── POWER.md
        │   └── steering/
        │       └── skill.md         # 包含所有技能的索引
        ├── ripgrep/
        │   └── steering/
        │       └── skill.md
        └── ...
```

### 问题 4：Tool Preferences 的位置

**当前做法**：
```bash
~/.kiro/steering/
├── ripgrep-tool-preferences.md      # ✅ 这个位置是合理的
└── sharkdp-fd-tool-preferences.md   # ✅ 这个位置是合理的
```

**分析**：
- Tool preferences 作为 Steering 是**合理的**
- 它们定义了项目范围的工具使用约定
- 应该使用 `inclusion: always` 确保始终生效

## 改进方案

### 方案 1：将技能索引移到 Powers 系统

创建一个专门的 power 来管理技能索引：

```bash
~/.kiro/powers/installed/skills-index/
├── POWER.md
└── steering/
    └── skill.md    # 包含所有技能的索引和资源列表
```

**skill.md 的 frontmatter**：
```yaml
---
name: "skills-index"
description: "Index of all installed skills with their references and templates. Use when you need to discover available skills, find reference documentation, or locate template files."
keywords: ["skills", "index", "references", "templates", "documentation"]
---
```

### 方案 2：保留 Steering 用于工具偏好设置

```bash
~/.kiro/steering/
├── tool-preferences.md              # 统一的工具偏好设置
├── ripgrep-tool-preferences.md      # 或单独的工具配置
└── sharkdp-fd-tool-preferences.md
```

**frontmatter**：
```yaml
---
description: "Tool usage preferences for the project"
inclusion: always    # 始终包含
---
```

### 方案 3：创建项目标准 Steering 文件

根据官方建议，创建标准的 Steering 文件：

```bash
~/.kiro/steering/
├── product.md           # 产品概述
├── tech.md              # 技术栈
├── structure.md         # 项目结构
├── api-standards.md     # API 规范
├── testing-standards.md # 测试规范
└── tool-preferences.md  # 工具偏好
```

## 推荐的实现方案

### 步骤 1：修改脚本，创建 Skills Index Power

```bash
# 在 kiro-adapter.sh 中添加
create_skills_index_power() {
    local power_dir="$INSTALLED_DIR/skills-index"
    mkdir -p "$power_dir/steering"
    
    # 生成 POWER.md
    cat > "$power_dir/POWER.md" <<'EOF'
---
name: "skills-index"
displayName: "Skills Index"
description: "Index of all installed skills with their references and templates"
keywords: ["skills", "index", "references", "templates", "documentation", "discover"]
---

# Skills Index

This power provides a comprehensive index of all installed skills.

## Usage

Ask Kiro about:
- "What skills are available?"
- "Show me skills with references"
- "Which skills have templates?"
- "Find documentation for [skill-name]"

## Features

- Complete list of installed skills
- Reference documentation index
- Template file locations
- Resource discovery
EOF
    
    # 生成 skill.md（包含完整的技能索引）
    generate_skills_index_content > "$power_dir/steering/skill.md"
}
```

### 步骤 2：简化 Steering 目录

只保留真正的项目约定和标准：

```bash
# 在 kiro-adapter.sh 中
create_tool_preferences_steering() {
    local global_steering_dir="$HOME/.kiro/steering"
    mkdir -p "$global_steering_dir"
    
    # 生成统一的工具偏好设置文件
    cat > "$global_steering_dir/tool-preferences.md" <<'EOF'
---
description: "Tool usage preferences for the project"
inclusion: always
---

# Tool Usage Preferences

This file defines which tools to prefer for common operations.

## Tool Replacements

[列出所有工具替代关系]
EOF
}
```

### 步骤 3：修正 inclusion 模式

将所有 `inclusion: auto` 改为 `inclusion: always`：

```yaml
---
description: "Tool usage preferences"
inclusion: always    # ✅ 正确
---
```

## 具体改进建议

### 1. 立即修复

```bash
# 修改所有 steering 文件的 frontmatter
sed -i '' 's/inclusion: auto/inclusion: always/g' ~/.kiro/steering/*.md
```

### 2. 重构脚本

修改 `kiro-adapter.sh`：

1. **移除** `installed-skills-summary.md` 从 steering
2. **创建** `skills-index` power
3. **保留** `tool-preferences.md` 在 steering（但修正格式）
4. **添加** 生成标准 steering 文件的功能

### 3. 文件组织

```
~/.kiro/
├── steering/                        # 项目约定（Steering）
│   ├── tool-preferences.md          # ✅ 工具偏好
│   ├── api-standards.md             # ✅ API 规范（可选）
│   └── testing-standards.md         # ✅ 测试规范（可选）
└── powers/
    └── installed/
        ├── skills-index/            # ✅ 技能索引（Power/Skill）
        │   ├── POWER.md
        │   └── steering/
        │       └── skill.md
        ├── ripgrep/
        │   ├── POWER.md
        │   └── steering/
        │       ├── skill.md
        │       └── tool-preferences.md
        └── ...
```

## 总结

### 当前问题

1. ❌ 混淆了 Steering 和 Skills 的概念
2. ❌ 使用了无效的 `inclusion: auto` 模式
3. ❌ 将技能索引放在了 Steering 目录
4. ✅ Tool preferences 的位置是合理的（但需要修正格式）

### 改进方向

1. ✅ 将技能索引移到 Powers 系统作为独立的 skill
2. ✅ 修正 inclusion 模式为 `always`
3. ✅ 保留工具偏好设置在 Steering（作为项目约定）
4. ✅ 添加标准的 Steering 文件（product.md, tech.md, structure.md）

### 优先级

1. **高优先级**：修正 `inclusion: auto` → `inclusion: always`
2. **中优先级**：将技能索引移到 Powers 系统
3. **低优先级**：添加标准 Steering 文件

## 参考资料

- [Kiro Steering 官方文档](https://kiro-community.github.io/book-of-kiro/en/features/steering/)
- [Kiro Skills 更新日志](https://kiro.dev/changelog/cli/1-24)
- [Steering 最佳实践](https://kiro.directory/tips/steering-setup/)
