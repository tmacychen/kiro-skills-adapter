---
description: "Tech stack - frameworks, libraries, development tools, and technical constraints"
inclusion: always
---

# Tech Stack

## Frameworks

[List main frameworks used]

## Libraries

[Key libraries and dependencies]

## Development Tools

[Tools used for development]

### AI 开发工具

**代码质量工具**：
- Lint 工具：`eslint`, `flake8`, `gofmt`, `rustfmt` 等
- 类型检查：`tsc`, `mypy` 等
- 格式化：`prettier`, `black` 等

**测试工具**：
- 单元测试：`jest`, `pytest`, `cargo test` 等
- E2E 测试：`playwright`, `cypress` (Web 项目)
- API 测试：`pytest`, `newman` 等

**版本控制**：
- Git：所有版本控制操作
- 提交规范：`<type>(<scope>): <description> [Closes #feature-id]`

**安全工具**：
- 依赖审计：`npm audit`, `safety` 等
- 密钥扫描：`git-secrets`, `trufflehog` 等

## Technical Constraints

[Any technical limitations or requirements]

### AI 开发约束

**命令白名单**：
- ✅ 允许：文件操作、包管理、编译、测试、Git 等开发命令
- ❌ 禁止：`sudo`, `su`, `rm -rf /`, `curl | bash` 等危险命令

**安全检查要求**：
- 用户输入验证和清理
- 无硬编码的秘密或凭据
- 敏感数据不以明文记录
- 认证/授权检查已到位

**测试覆盖要求**：
- Web 项目：必须使用 E2E 测试工具
- API 项目：验证响应状态码、数据格式
- 通用：测试覆盖率 ≥ 70%

## Preferred Patterns

[Coding patterns and architectural decisions]

### AI 开发模式

**双 Agent 模式**：
- 初始化 Agent：项目启动，拆解功能清单，搭建基础结构
- 编码 Agent：增量迭代，每次完成一个功能

**增量开发原则**：
- 每次只开发一个功能
- 原子提交：一个功能一个 commit
- 证据驱动：必须提供工具执行结果作为完成证据

**状态管理模式**：
- 功能清单作为单一事实来源
- 进度日志增量记录
- 架构文档同步更新
