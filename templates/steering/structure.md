---
description: "Project structure - file organization, naming conventions, import patterns, and architectural decisions"
inclusion: always
---

# Project Structure

## File Organization

[Describe how files are organized]

## AI 开发状态目录 (.ai/)

每个项目应包含以下"自描述"文件，用于 AI Agent 的状态管理：

### 核心状态文件

- **`.ai/feature_list.json`**：功能的单一事实来源
  - 记录所有功能、优先级、依赖、测试用例和完成状态
  - 每个功能包含：id, category, description, priority, status, dependencies, test_cases, passes 等
  - 定义验证要求和完成标准

- **`progress.log`**：进度日志
  - 面向人类/Agent 的自然语言进度总结
  - 采用增量追加模式，记录每个会话的成果
  - 包含"已完成"、"进行中"、"待办事项"及交接说明

- **`.ai/architecture.md`**：架构文档
  - 记录项目架构、技术栈选择和核心数据流
  - 记录关键设计决策和备选方案

- **`init.sh`**：环境初始化脚本
  - 自动化环境配置
  - 必须是幂等的（可安全多次运行）
  - 运行后任何 Agent 应能立即执行测试或启动开发

### 可选增强文件

- **`.ai/data_collection_config.json`**：数据收集配置
  - 定义如何捕获学习数据

- **`.ai/harness_config.json`**：Harness 模块化配置
  - 支持模块化架构和配置管理

- **`.ai/training_data/`**：训练数据目录
  - `failures.jsonl`：失败案例和解决方案
  - `successes.jsonl`：成功模式和效率指标
  - `performance.jsonl`：性能指标数据

## Naming Conventions

[File and directory naming rules]

## Import Patterns

[How imports should be structured]

## Architectural Decisions

[Key architectural choices and patterns]

## Module Structure

[How modules are organized]
