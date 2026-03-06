# 迁移指南

## 从旧版本迁移

如果你之前使用过旧版本的 `kiro-adapter.sh`，建议运行修复命令以确保配置正确。

## 快速迁移

```bash
# 1. 更新代码
git pull

# 2. 运行修复（可选，推荐）
./kiro-adapter.sh --fix

# 3. 正常使用
./kiro-adapter.sh
```

## --fix 功能说明

`--fix` 选项会：

1. **修复 Steering 配置**
   - 对比文件内容与标准模板
   - 不一致则重新生成（创建 `.bak` 备份）
   - 一致则跳过，不修改
   - 修正 `inclusion: auto` → `inclusion: always`

2. **清理多余 Powers**
   - 扫描源目录，构建期望的 powers 列表
   - 对比已安装的 powers
   - 自动删除不在源目录中的 powers
   - 同时清理校验和记录

## 验证迁移

### 检查文件结构

```bash
# Steering 目录
ls ~/.kiro/steering/
# 应该看到：
# - tool-preferences.md
# - product.md, tech.md, structure.md, powers.md（模板）

# Powers 目录
ls ~/.kiro/powers/installed/
# 应该看到你的技能，如：
# - ripgrep
# - sharkdp-fd
# - rust-skills-*
# - 等等
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
```

## 常见问题

### Q: --fix 会覆盖我的自定义内容吗？

A: 不会。`--fix` 会对比文件内容：
- 如果内容一致，跳过
- 如果内容不同，重新生成并创建 `.bak` 备份
- 你可以从备份文件中恢复自定义内容

### Q: 我需要运行 --fix 吗？

A: 建议在以下情况下运行：
- 从旧版本升级
- 怀疑配置文件被修改
- 想验证配置是否正确
- 发现有多余的 powers

### Q: --fix 是否安全？

A: 是的，`--fix` 是安全的：
- 会创建备份文件（`.bak`）
- 只删除不在源目录中的 powers
- 不会影响源文件

### Q: 如何回滚？

A: 如果需要回滚：

```bash
# 恢复 Steering 文件
cp ~/.kiro/steering/product.md.bak ~/.kiro/steering/product.md

# 重新安装 powers（如果误删）
./kiro-adapter.sh --force
```

## 命令对照表

| 功能 | 命令 |
|------|------|
| 正常安装 | `./kiro-adapter.sh` |
| 修复配置 | `./kiro-adapter.sh --fix` |
| 强制重装 | `./kiro-adapter.sh --force` |
| 详细输出 | `./kiro-adapter.sh --verbose` |
| 查看帮助 | `./kiro-adapter.sh --help` |

## 获取帮助

如果迁移过程中遇到问题：

1. 查看 [README.md](./README.md)
2. 查看 [QUICKSTART.md](./QUICKSTART.md)
3. 查看 [CHANGELOG.md](./CHANGELOG.md)
4. 提交 Issue

## 相关文档

- [README.md](./README.md) - 完整文档
- [QUICKSTART.md](./QUICKSTART.md) - 快速开始指南
- [CHANGELOG.md](./CHANGELOG.md) - 更新日志
- [PROJECT-STRUCTURE.md](./PROJECT-STRUCTURE.md) - 项目结构
