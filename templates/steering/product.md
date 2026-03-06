---
description: "Product overview - purpose, target users, key features, and business goals"
inclusion: always
---

# Product Overview

## Purpose

[Describe what your product does and why it exists]

## Target Users

[Who is this product for?]

## Key Features

[List the main features and capabilities]

## Business Goals

[What are the business objectives?]

## Technical Constraints

[Any important technical limitations or requirements]

## AI 开发协作

### 开发流程

本项目采用 AI Agent 辅助开发，遵循以下原则：

**增量开发**：
- 每个功能独立开发、测试和提交
- 每个功能 1-4 小时完成粒度
- 遵循功能清单中的优先级和依赖关系

**质量保证**：
- 所有功能必须有测试覆盖
- 必须提供工具执行证据（测试日志、截图等）
- 通过代码审查清单验证

**状态跟踪**：
- 通过 `.ai/feature_list.json` 跟踪功能进度
- 通过 `progress.log` 记录会话成果
- 通过 `.ai/architecture.md` 记录架构决策

### 验收标准

每个功能完成时必须满足：
- [ ] 所有测试用例通过
- [ ] 提供工具执行证据
- [ ] 代码通过 lint 检查
- [ ] 安全检查通过
- [ ] 文档已更新
- [ ] Git 提交已完成
