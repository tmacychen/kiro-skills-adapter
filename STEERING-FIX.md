# Steering File Description Fix

## 问题描述

Kiro 显示警告：`Progressive steering file missing description`

这是因为 steering 文件的 YAML front-matter 中缺少 `description` 字段。

## 解决方案

### 1. 更新了 `kiro-adapter.sh` 脚本

在生成 `tool-preferences.md` 文件时，现在会自动添加 `description` 字段：

```yaml
---
description: "Tool usage preferences for [tool-name] - replaces [built-in-tool]"
inclusion: auto
---
```

### 2. 更新了 `tool-preferences-template.md` 模板

模板文件现在包含 `description` 字段示例，确保用户创建新的 tool-preferences 文件时包含此字段。

### 3. 重新生成了所有 powers

运行脚本后，所有已安装的 powers 的 `tool-preferences.md` 文件都包含了正确的 description 字段。

## 验证

检查生成的文件：

```bash
head -10 ~/.kiro/powers/installed/ripgrep/steering/tool-preferences.md
head -10 ~/.kiro/powers/installed/sharkdp-fd/steering/tool-preferences.md
```

两个文件都正确包含了 description 字段。

## 下一步

重启 Kiro 以加载更新后的 powers，警告应该消失。
