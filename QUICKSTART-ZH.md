# 快速开始

## 5 分钟上手指南

### 1. 安装

```bash
# 克隆仓库
git clone <repository-url>
cd kiro-skills-adapter

# 赋予执行权限
chmod +x kiro-adapter.sh
```

### 2. 准备技能

将你的技能放在以下位置之一：

- `~/.kiro/skills/` （推荐）
- 当前目录（包含 SKILL.md 文件）

### 3. 运行安装

```bash
# 首次安装（自动初始化 Steering 模板）
./kiro-adapter.sh

# 如果从旧版本迁移
./kiro-adapter.sh --fix
```

### 4. 重启 Kiro

重启 Kiro IDE 以加载新安装的 Powers 和 Steering 配置。

## 常用命令

```bash
# 查看帮助
./kiro-adapter.sh --help

# 修复旧配置
./kiro-adapter.sh --fix

# 详细输出
./kiro-adapter.sh --verbose

# 强制重装
./kiro-adapter.sh --force
```

## 验证安装

### 检查 Powers

```bash
ls ~/.kiro/powers/installed/
```

应该看到：
- `ripgrep/` - 如果安装了 ripgrep
- `sharkdp-fd/` - 如果安装了 fd
- 其他已安装的技能

### 检查 Steering

```bash
ls ~/.kiro/steering/
```

**首次运行后**，应该看到：
- `tool-preferences.md` - 统一的工具偏好设置（包含所有工具配置）
- `product.md`, `tech.md`, `structure.md`, `powers.md` - 自动创建的标准模板

> 💡 **注意**：Steering 模板会在首次运行时自动创建，你可以直接编辑它们来自定义项目配置。

### 在 Kiro 中测试

打开 Kiro，尝试：

```
"Use rg to search for 'function' in this project"
```
Kiro 会优先使用 `rg` 命令而不是内置的 `grepSearch`。

```
"Use fd to find all .md files"
```
Kiro 会优先使用 `fd` 命令而不是内置的 `fileSearch`。

```
"Use rg to search for 'function' in this project"
```
Kiro 会优先使用 `rg` 命令而不是内置的 `grepSearch`。

```
"Use fd to find all .md files"
```
Kiro 会优先使用 `fd` 命令而不是内置的 `fileSearch`。

## 完整设置

Steering 模板会在首次运行时自动创建：

```bash
./kiro-adapter.sh
```

创建的文件：

### 默认文件（自动创建）
- `product.md` - 产品概述
- `tech.md` - 技术栈
- `structure.md` - 项目结构
- `powers.md` - Powers 系统介绍

### 常用文件（可选，手动创建）
- `api-standards.md` - API 规范
- `testing-standards.md` - 测试方法论
- `code-conventions.md` - 代码风格
- `security-policies.md` - 安全指南
- `deployment-workflow.md` - 部署流程

> 💡 **提示**：默认模板包含占位符，你需要根据项目实际情况填写内容。

## 下一步

- 阅读 [完整文档](./README.md)
- 了解 [项目结构](./PROJECT-STRUCTURE.md)
- 查看 [更新日志](./CHANGELOG.md)

## 常见问题

### Q: 技能没有更新？

```bash
./kiro-adapter.sh --force
```

### Q: Kiro 没有识别技能？

1. 检查安装目录：`ls ~/.kiro/powers/installed/`
2. 重启 Kiro
3. 如果从旧版本迁移：`./kiro-adapter.sh --fix`

### Q: 如何添加新技能？

```bash
# 1. 创建技能目录
mkdir -p ~/.kiro/skills/my-skill

# 2. 创建 SKILL.md
cat > ~/.kiro/skills/my-skill/SKILL.md <<'EOF'
---
name: "my-skill"
description: "My awesome skill"
keywords: ["custom"]
---

# My Skill

Content here...
EOF

# 3. 安装
./kiro-adapter.sh
```

## 获取帮助

- 查看 [文档目录](./docs/)
- 提交 Issue
- 阅读 [README](./README.md)
