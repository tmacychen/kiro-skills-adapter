# 更新说明

## 最新更新 (v3.0.0) - 简化和自动化

### 🎯 主要变更：自动初始化 Steering

脚本现在会在每次运行时自动创建缺失的 Steering 模板文件，无需额外命令。

### 变更详情

#### 1. 自动初始化 Steering 模板

**之前**：
```bash
./kiro-adapter.sh              # 安装技能
./kiro-adapter.sh --init-steering  # 需要单独初始化
```

**现在**：
```bash
./kiro-adapter.sh              # 安装技能 + 自动初始化 Steering
```

**自动创建的文件**：
- ✅ `product.md` - 产品概述 (inclusion: always)
- ✅ `tech.md` - 技术栈 (inclusion: always)
- ✅ `structure.md` - 项目结构 (inclusion: always)

**特性**：
- 智能跳过已存在的文件，不会覆盖你的自定义内容
- 首次运行自动创建
- 无需记住额外命令

#### 2. 新增 `--fix` 选项

智能修复和验证配置：

```bash
./kiro-adapter.sh --fix
```

**功能**：
- ✅ 对比文件内容与标准模板
- ✅ 不一致则重新生成（创建 `.bak` 备份）
- ✅ 一致则跳过，不修改
- ✅ 检测额外的文档并提示删除
- ✅ 修正 `inclusion: auto` → `inclusion: always`

**示例输出**：
```
Fixing old configuration...
  ⟳ Regenerated product.md (backup: product.md.bak)
  ✓ tech.md is up to date
  ✓ structure.md is up to date

⚠ Extra files detected in steering directory:
  • old-config.md

These files are not part of the standard configuration.
If they are not needed, you can remove them:

  rm ~/.kiro/steering/old-config.md
```

#### 3. 移除 `--init-steering` 选项

不再需要单独的初始化命令，一切都是自动的。

### 如何更新

如果你已经克隆了仓库：

```bash
# 1. 拉取最新代码
git pull

# 2. 如果从旧版本迁移，修复配置（可选）
./kiro-adapter.sh --fix

# 3. 正常使用
./kiro-adapter.sh
```

### 命令对照表

| 旧命令 | 新命令 | 说明 |
|--------|--------|------|
| `./kiro-adapter.sh --init-steering` | `./kiro-adapter.sh` | 自动初始化，无需单独命令 |
| `./fix-steering-skills.sh` | `./kiro-adapter.sh --fix` | 修复旧配置 |
| `./kiro-adapter.sh` | `./kiro-adapter.sh` | 安装技能（不变） |
| `./kiro-adapter.sh -f` | `./kiro-adapter.sh --force` | 强制重装（不变） |
| `./kiro-adapter.sh -v` | `./kiro-adapter.sh --verbose` | 详细输出（不变） |

### 完整的工作流程

```bash
# 1. 首次运行（自动创建 Steering 模板）
./kiro-adapter.sh

# 2. 自定义模板内容（可选）
vim ~/.kiro/steering/product.md
vim ~/.kiro/steering/tech.md
vim ~/.kiro/steering/structure.md

# 3. 重启 Kiro
# 在 Kiro IDE 中重启
```

### 为什么做这个改变？

1. **更简单**：一个命令完成所有操作
2. **更智能**：自动检测和创建缺失的文件
3. **更安全**：不会覆盖已存在的文件
4. **更直观**：无需记住多个命令
5. **更自动化**：减少手动步骤

### 常见问题

**Q: Steering 模板会覆盖我的自定义内容吗？**

A: 不会。脚本会检测已存在的文件并跳过它们。只有缺失的文件才会被创建。

**Q: 我需要运行 `--fix` 吗？**

A: 在以下情况下运行：
- 从旧版本迁移
- 怀疑配置文件被修改
- 想验证配置是否正确
- 检测是否有额外的文件

`--fix` 是安全的，它会：
- 对比文件内容，只在不一致时重新生成
- 创建备份文件（`.bak`）
- 提示但不自动删除额外的文件

**Q: 如何查看所有可用选项？**

A: 运行 `./kiro-adapter.sh --help`

```bash
$ ./kiro-adapter.sh --help
Usage: ./kiro-adapter.sh [OPTIONS]
Options:
  -f, --force     Force reinstall all skills (ignore checksums)
  -v, --verbose   Show detailed output
  --fix           Fix old configuration (migrate from old versions)
  -h, --help      Show this help message
```

**Q: 我可以自定义创建哪些 Steering 文件吗？**

A: 默认只创建 3 个基础文件（product.md, tech.md, structure.md）。如果需要更多文件（如 api-standards.md, testing-standards.md 等），可以手动创建或参考 [Steering 文件指南](./docs/STEERING-FILES-GUIDE.md)。

**Q: 脚本运行时会显示创建了哪些文件吗？**

A: 使用 `--verbose` 选项可以看到详细的创建过程：

```bash
./kiro-adapter.sh --verbose
```

---

## 之前的更新 (v2.0.0) - 符合 Kiro 官方规范

### 问题

之前的 `kiro-adapter.sh` 脚本将技能索引生成到了 `~/.kiro/steering/` 目录：

```bash
~/.kiro/steering/
├── installed-tools-summary.md      # ❌ 应该是 Power/Skill
└── installed-skills-summary.md     # ❌ 应该是 Power/Skill
```

这不符合 Kiro 官方规范：
- **Steering**: 用于项目约定和标准（如工具偏好、API 规范）
- **Skills**: 用于大型文档集，按需加载（如技能索引）

### 解决方案

#### 1. 修改 `kiro-adapter.sh`

- ✅ 将技能索引移到 Powers 系统（`~/.kiro/powers/installed/skills-index/`）
- ✅ 将 `installed-tools-summary.md` 重命名为 `tool-preferences.md`
- ✅ 修正所有 `inclusion: auto` → `inclusion: always`
- ✅ 自动注册 `skills-index` Power

#### 2. 创建 `fix-steering-skills.sh`

提供修复脚本，用于迁移现有安装：
- 修正 inclusion 模式
- 移动技能索引到 Powers 系统
- 整合工具偏好设置
- 创建标准 Steering 模板

#### 3. 更新文档

- 创建 [MIGRATION.md](./MIGRATION.md) - 迁移指南
- 创建 [docs/STEERING-SKILLS-ANALYSIS.md](./docs/STEERING-SKILLS-ANALYSIS.md) - 官方规范分析
- 更新 README.md 和 QUICKSTART.md

### 文件结构变更

**之前**：
```
~/.kiro/steering/
├── installed-tools-summary.md      # ❌ 错误位置
└── installed-skills-summary.md     # ❌ 错误位置
```

**现在**：
```
~/.kiro/steering/
└── tool-preferences.md             # ✅ 正确：Steering

~/.kiro/powers/installed/skills-index/
├── POWER.md
└── steering/
    └── skill.md                    # ✅ 正确：Power/Skill
```

### 迁移步骤

```bash
# 1. 运行修复脚本
./fix-steering-skills.sh

# 2. 重新运行安装脚本
./kiro-adapter.sh

# 3. 重启 Kiro
```

详见 [MIGRATION.md](./MIGRATION.md)。

---

## 参考文档

- [README.md](./README.md) - 主文档
- [QUICKSTART.md](./QUICKSTART.md) - 快速开始
- [MIGRATION.md](./MIGRATION.md) - 迁移指南
- [CHANGELOG.md](./CHANGELOG.md) - 完整更新日志
- [docs/STEERING-FILES-GUIDE.md](./docs/STEERING-FILES-GUIDE.md) - Steering 文件指南
- [docs/STEERING-SKILLS-ANALYSIS.md](./docs/STEERING-SKILLS-ANALYSIS.md) - 官方规范分析
