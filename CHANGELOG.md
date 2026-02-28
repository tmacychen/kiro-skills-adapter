# 更新日志

## [3.0.0] - 2026-02-28

### 重大变更 - 简化和自动化

#### ✨ 自动初始化 Steering

**变更**：每次运行 `kiro-adapter.sh` 时自动创建缺失的 Steering 模板文件。

**创建的文件**：
- `product.md` - 产品概述 (inclusion: always)
- `tech.md` - 技术栈 (inclusion: always)
- `structure.md` - 项目结构 (inclusion: always)

**特性**：
- 智能跳过已存在的文件，不会覆盖
- 首次运行自动创建
- 无需额外命令

#### 🔥 移除 `--init-steering` 选项

**原因**：不再需要单独初始化，自动完成。

**之前**：
```bash
./kiro-adapter.sh              # 安装技能
./kiro-adapter.sh --init-steering  # 初始化 Steering
```

**现在**：
```bash
./kiro-adapter.sh              # 安装技能 + 自动初始化 Steering
```

#### ✨ 新增 `--fix` 选项

**功能**：智能修复和验证配置。

```bash
./kiro-adapter.sh --fix
```

**特性**：
- 对比文件内容与标准模板
- 不一致则重新生成（创建 `.bak` 备份）
- 一致则跳过，不修改
- 检测额外的文档并提示删除
- 修正 `inclusion: auto` → `inclusion: always`

**使用场景**：
- 从旧版本迁移
- 验证配置是否正确
- 检测意外修改的文件
- 清理额外的配置文件

### 改进

- 🎯 **简化用户体验**：一个命令完成所有操作
- 🚀 **自动化**：无需手动初始化配置
- 🔧 **智能检测**：自动跳过已存在的文件
- 📝 **清晰输出**：显示创建/跳过状态

### 文档更新

- 更新 README.md - 反映自动初始化特性
- 更新 QUICKSTART.md - 简化安装步骤
- 更新 CHANGELOG.md - 记录所有变更
- 更新 UPDATE-NOTES.md - 详细说明

### 迁移指南

如果你从旧版本升级：

```bash
# 1. 拉取最新代码
git pull

# 2. 修复旧配置（可选，如果有问题）
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

## [3.0.0-beta] - 2026-02-28 (已废弃)

## [2.0.0] - 2024-02-28

### 重大变更 - 符合 Kiro 官方规范

#### 🔧 修正 Steering 和 Skills 的实现

**问题**：之前的实现将技能索引错误地放在了 Steering 目录中。

**修正**：
- ✅ 将技能索引移到 Powers 系统（`~/.kiro/powers/installed/skills-index/`）
- ✅ 将工具汇总重命名为 `tool-preferences.md`（更准确的名称）
- ✅ 修正所有 `inclusion: auto` → `inclusion: always`
- ✅ 自动注册 `skills-index` Power

**文件变更**：

| 旧位置 | 新位置 | 类型 |
|--------|--------|------|
| `~/.kiro/steering/installed-tools-summary.md` | `~/.kiro/steering/tool-preferences.md` | Steering |
| `~/.kiro/steering/installed-skills-summary.md` | `~/.kiro/powers/installed/skills-index/steering/skill.md` | Power/Skill |

#### 修正概念混淆

- **修正概念混淆**：明确区分 Steering（项目约定）和 Skills（大型文档集）
- **修正 inclusion 模式**：将所有 `inclusion: auto` 改为 `inclusion: always`
- **重构文件组织**：将技能索引从 Steering 移到 Powers 系统

#### 新增功能

- ✨ 创建 `skills-index` Power：技能索引作为独立的 Power/Skill
- ✨ 添加 `fix-steering-skills.sh`：自动修复现有安装以符合规范
- ✨ 生成标准 Steering 文件模板：`product.md`, `tech.md`, `structure.md`
- ✨ 统一工具偏好设置：`tool-preferences.md` 作为主配置文件

#### 文件结构变更

**之前（不符合规范）：**
```
~/.kiro/steering/
├── installed-tools-summary.md      # ❌ 应该是 skill
└── installed-skills-summary.md     # ❌ 应该是 skill
```

**现在（符合规范）：**
```
~/.kiro/
├── steering/                        # 项目约定
│   ├── tool-preferences.md          # ✅ 工具偏好
│   ├── product.md                   # ✅ 产品概述
│   ├── tech.md                      # ✅ 技术栈
│   └── structure.md                 # ✅ 项目结构
└── powers/installed/
    └── skills-index/                # ✅ 技能索引（作为 Power）
        ├── POWER.md
        └── steering/skill.md
```

#### 文档改进

- 📚 创建 `QUICKSTART.md`：5 分钟快速上手指南
- 📚 创建 `PROJECT-STRUCTURE.md`：项目组织说明
- 📚 创建 `docs/STEERING-SKILLS-ANALYSIS.md`：官方规范分析
- 📚 重写 `README.md`：更清晰的项目说明
- 📚 整合所有文档到 `docs/` 目录

#### 清理

- 🗑️ 删除过程文件：`MIGRATION-UPDATE.md`, `TEST-RESULTS.md` 等
- 🗑️ 删除示例文件：`examples/` 目录
- 🗑️ 删除临时文档：`GLOBAL-TOOLS-SUMMARY.md`, `SKILLS-RESOURCES-SUMMARY.md` 等
- 📁 整理文档到 `docs/` 目录

### 参考

- [Kiro Steering 官方文档](https://kiro-community.github.io/book-of-kiro/en/features/steering/)
- [Kiro Skills 更新日志](https://kiro.dev/changelog/cli/1-24)

---

## [1.0.0] - 2024-02-27

### 初始版本 - 差异更新功能

#### 核心功能

- ✨ 差异检测：使用 MD5 校验和追踪文件变化
- ✨ 增量安装：只更新修改过的技能
- ✨ 命令行选项：`--force`, `--verbose`, `--help`
- ✨ 状态显示：`[NEW]`, `[UPDATE]`, `✓ Up to date`

#### 技能处理

- ✨ 支持单个 `SKILL.md` 结构
- ✨ 支持嵌套 `skills/` 子目录结构
- ✨ 自动生成 `POWER.md`
- ✨ 创建 steering 文件

#### 工具偏好设置

- ✨ 从 `SKILL.md` 的 `replaces` 字段自动生成
- ✨ 复制到全局 `~/.kiro/steering/` 目录
- ✨ 生成工具偏好汇总文件

#### 性能优化

- ⚡ 首次安装后建立校验和基线
- ⚡ 后续只处理有变化的文件
- ⚡ 性能提升 5-10 倍（对于未更改的技能）

#### 文档

- 📚 详细的中文安装指南
- 📚 详细的英文安装指南
- 📚 工具偏好设置指南

---

## 版本说明

### 语义化版本

本项目遵循 [语义化版本 2.0.0](https://semver.org/lang/zh-CN/)：

- **主版本号**：不兼容的 API 修改
- **次版本号**：向下兼容的功能性新增
- **修订号**：向下兼容的问题修正

### 版本标签

- `[Major.Minor.Patch]` - 版本号
- `YYYY-MM-DD` - 发布日期
- ✨ 新增功能
- 🐛 Bug 修复
- 📚 文档更新
- ⚡ 性能优化
- 🗑️ 删除功能
- 📁 文件组织
- ❌ 不符合规范
- ✅ 符合规范

---

## 升级指南

### 从 1.x 升级到 2.0

如果你已经使用了 1.x 版本，需要运行修复脚本：

```bash
# 1. 更新代码
git pull

# 2. 运行修复脚本
./fix-steering-skills.sh

# 3. 重启 Kiro
```

修复脚本会：
- 修正 `inclusion` 模式
- 将技能索引移到 Powers 系统
- 整理工具偏好设置
- 创建标准 Steering 文件模板

### 全新安装

```bash
# 1. 克隆仓库
git clone <repository-url>
cd kiro-skills-adapter

# 2. 赋予执行权限
chmod +x kiro-adapter.sh fix-steering-skills.sh

# 3. 运行安装
./kiro-adapter.sh

# 4. 重启 Kiro
```

---

## 未来计划

### v2.1.0

- [ ] 支持子目录分类（如 `references/api/`, `references/guides/`）
- [ ] 添加文件大小和修改时间信息
- [ ] 生成交互式 HTML 索引
- [ ] 支持搜索功能

### v2.2.0

- [ ] 添加资源使用统计
- [ ] 支持多语言资源
- [ ] 自动检测和修复常见问题
- [ ] 集成测试套件

### v3.0.0

- [ ] 支持远程技能仓库
- [ ] 技能版本管理
- [ ] 依赖关系处理
- [ ] 插件系统

---

## 贡献

欢迎提交 Issue 和 Pull Request！

### 报告问题

在提交 Issue 时，请包含：

- 操作系统和版本
- Kiro 版本
- 完整的错误信息
- 重现步骤

### 提交代码

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 许可证

MIT License - 详见 [LICENSE](./LICENSE) 文件
