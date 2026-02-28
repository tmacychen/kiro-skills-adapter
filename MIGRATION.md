# 迁移指南

## 从旧版本迁移到新版本

如果你之前运行过旧版本的 `kiro-adapter.sh`，需要进行迁移以符合 Kiro 官方规范。

## 快速迁移（推荐）

```bash
# 1. 更新代码
git pull

# 2. 运行修复脚本
./fix-steering-skills.sh

# 3. 重启 Kiro
```

就这么简单！修复脚本会自动处理所有迁移工作。

## 手动迁移

如果你想手动迁移，按照以下步骤：

### 步骤 1：备份现有文件

```bash
cp ~/.kiro/steering/installed-tools-summary.md ~/.kiro/steering/installed-tools-summary.md.bak
cp ~/.kiro/steering/installed-skills-summary.md ~/.kiro/steering/installed-skills-summary.md.bak
```

### 步骤 2：修正 Steering 文件的 inclusion 模式

```bash
# 修改所有 steering 文件
sed -i '' 's/inclusion: auto/inclusion: always/g' ~/.kiro/steering/*.md
```

### 步骤 3：创建 skills-index Power

```bash
# 创建目录
mkdir -p ~/.kiro/powers/installed/skills-index/steering

# 移动技能索引
mv ~/.kiro/steering/installed-skills-summary.md ~/.kiro/powers/installed/skills-index/steering/skill.md

# 修改 frontmatter
# 手动编辑文件，将 frontmatter 改为：
# ---
# name: "skills-index"
# description: "Comprehensive index of all installed skills..."
# keywords: ["skills", "index", "references", "templates"]
# ---
```

### 步骤 4：重命名工具偏好设置

```bash
# 重命名文件
mv ~/.kiro/steering/installed-tools-summary.md ~/.kiro/steering/tool-preferences.md

# 修改 frontmatter
# 手动编辑文件，将 frontmatter 改为：
# ---
# description: "Tool usage preferences for the project..."
# inclusion: always
# ---
```

### 步骤 5：创建 POWER.md

创建 `~/.kiro/powers/installed/skills-index/POWER.md`：

```yaml
---
name: "skills-index"
displayName: "Skills Index"
description: "Index of all installed skills with their references and templates"
keywords: ["skills", "index", "references", "templates"]
---

# Skills Index

This power provides a comprehensive index of all installed skills.
```

### 步骤 6：注册 Power

编辑 `~/.kiro/powers/registry.json`，添加：

```json
{
  "powers": {
    "skills-index": {
      "name": "skills-index",
      "description": "Index of all installed skills",
      "installed": true,
      "source": {"type": "local"}
    }
  }
}
```

编辑 `~/.kiro/powers/installed.json`，添加：

```json
{
  "installedPowers": [
    {"name": "skills-index", "registryId": "local-skills"}
  ]
}
```

### 步骤 7：重启 Kiro

重启 Kiro IDE 以加载新配置。

## 验证迁移

### 检查文件结构

```bash
# Steering 目录
ls ~/.kiro/steering/
# 应该看到：
# - tool-preferences.md
# - ripgrep-tool-preferences.md
# - sharkdp-fd-tool-preferences.md

# Powers 目录
ls ~/.kiro/powers/installed/skills-index/
# 应该看到：
# - POWER.md
# - steering/skill.md
```

### 检查 Frontmatter

```bash
# 检查 Steering 文件
head -5 ~/.kiro/steering/tool-preferences.md
# 应该看到：
# ---
# description: "..."
# inclusion: always
# ---

# 检查 Skill 文件
head -5 ~/.kiro/powers/installed/skills-index/steering/skill.md
# 应该看到：
# ---
# name: "skills-index"
# description: "..."
# keywords: [...]
# ---
```

### 在 Kiro 中测试

打开 Kiro，尝试：

```
"What skills are available?"
"Show me the skills index"
```

Kiro 应该能够找到并使用 skills-index Power。

## 回滚

如果迁移出现问题，可以回滚：

```bash
# 恢复备份
cp ~/.kiro/steering/installed-tools-summary.md.bak ~/.kiro/steering/installed-tools-summary.md
cp ~/.kiro/steering/installed-skills-summary.md.bak ~/.kiro/steering/installed-skills-summary.md

# 删除新文件
rm -rf ~/.kiro/powers/installed/skills-index/
rm ~/.kiro/steering/tool-preferences.md

# 重启 Kiro
```

## 常见问题

### Q: 为什么要迁移？

A: 旧版本不符合 Kiro 官方规范：
- 混淆了 Steering（项目约定）和 Skills（大型文档集）的概念
- 使用了无效的 `inclusion: auto` 模式
- 文件放置位置不当

### Q: 迁移会影响现有功能吗？

A: 不会。迁移只是重新组织文件，功能保持不变。实际上，迁移后性能会更好，因为技能索引会按需加载。

### Q: 必须迁移吗？

A: 强烈建议迁移。虽然旧版本可能仍然工作，但不符合官方规范，可能在未来的 Kiro 版本中出现问题。

### Q: 迁移需要多长时间？

A: 使用自动修复脚本，整个过程不到 1 分钟。

### Q: 迁移后需要重新安装技能吗？

A: 不需要。迁移只是重新组织现有文件，不影响已安装的技能。

## 获取帮助

如果迁移过程中遇到问题：

1. 查看 [UPDATE-NOTES.md](./UPDATE-NOTES.md)
2. 查看 [docs/STEERING-SKILLS-ANALYSIS.md](./docs/STEERING-SKILLS-ANALYSIS.md)
3. 提交 Issue

## 相关文档

- [UPDATE-NOTES.md](./UPDATE-NOTES.md) - 详细的更新说明
- [QUICKSTART.md](./QUICKSTART.md) - 快速开始指南
- [docs/STEERING-SKILLS-ANALYSIS.md](./docs/STEERING-SKILLS-ANALYSIS.md) - 官方规范分析
