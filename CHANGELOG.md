# 更新日志

## [3.3.0] - 2026-03-06

### 重大改进 - 移除 skills-index 自动生成

#### 🔥 移除功能

- **移除 skills-index 自动生成**: 不再自动创建 skills-index power
- **简化设计**: 专注于核心功能 - 技能安装和工具偏好管理
- **完全通用**: --fix 清理逻辑完全基于文件结构，无硬编码规则

#### ✨ 改进

- **清理逻辑优化**: 移除所有硬编码的跳过规则
- **完全通用设计**: 只基于 SKILL.md 和 skills/ 目录判断
- **文档清理**: 删除 8 个过时的文档文件
- **模板更新**: 更新 powers.md 模板，移除 skills-index 引用

#### 📝 文档更新

**删除的文档**:
- CURRENT-STATUS.md
- FINAL-SUMMARY.md
- FIX-FEATURE-UPDATE.md
- FUNCTION-CHECK-SUMMARY.md
- GENERIC-DESIGN.md
- UPDATE-NOTES.md
- VERIFICATION-REPORT.md
- SUMMARY.md

**更新的文档**:
- README.md - 移除 skills-index 相关内容
- QUICKSTART.md - 简化验证步骤
- CHANGELOG.md - 重写为简洁版本
- MIGRATION.md - 简化迁移指南

### 使用指南

```bash
# 正常安装
./kiro-adapter.sh

# 修复配置 + 清理多余 powers
./kiro-adapter.sh --fix

# 强制重装
./kiro-adapter.sh --force
```

---

## [3.2.0] - 2026-03-06

### 自动清理多余 Powers

- ✨ 在 `--fix` 模式下自动检测并清理多余的 powers
- ✨ 完全通用的清理逻辑，基于源目录结构
- ✨ 同时清理校验和记录

---

## [3.1.0] - 2026-03-06

### 模板外部化

- ✨ 将所有 Steering 模板移到 `templates/steering/` 目录
- ✨ 新增 `powers.md` 模板 - Powers 系统介绍
- ✨ 代码减少 20%，更易维护
- 📝 添加 `templates/README.md` 说明文档

---

## [3.0.0] - 2026-02-28

### 简化和自动化

- ✨ 自动初始化 Steering 模板（每次运行）
- ✨ 新增 `--fix` 选项 - 智能修复和验证配置
- 🔥 移除 `--init-steering` 选项（不再需要）
- 📝 简化用户体验

---

## [2.0.0] - 2024-02-28

### 符合 Kiro 规范

- ✨ 修正 Steering 的使用
- ✨ 修正 `inclusion` 模式（`auto` → `always`）
- ✨ 创建标准 Steering 文件模板

---

## [1.0.0] - 2024-02-27

### 初始版本 - 差异更新功能

- ✨ 差异检测：使用 MD5 校验和追踪文件变化
- ✨ 增量安装：只更新修改过的技能
- ✨ 命令行选项：`--force`, `--verbose`, `--help`
- ✨ 状态显示：`[NEW]`, `[UPDATE]`, `✓ Up to date`
- ⚡ 性能提升 5-10 倍（对于未更改的技能）

---

## 版本说明

### 语义化版本

本项目遵循 [语义化版本 2.0.0](https://semver.org/lang/zh-CN/)：

- **主版本号**：不兼容的 API 修改
- **次版本号**：向下兼容的功能性新增
- **修订号**：向下兼容的问题修正

### 版本标签

- ✨ 新增功能
- 🐛 Bug 修复
- 📚 文档更新
- ⚡ 性能优化
- 🗑️ 删除功能
- 🔥 移除功能
- 🔧 改进

---

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License
