# Steering 文件指南

## 什么是 Steering？

Steering 通过 `.kiro/steering/` 目录中的 markdown 文件为 Kiro 提供持久的项目知识。这些文件确保 Kiro 始终遵循你建立的模式、库和标准。

## 标准 Steering 文件

### 默认文件（推荐）

这些文件在每次交互中自动加载，形成 Kiro 项目理解的基线：

#### 1. product.md - 产品概述

定义产品的目的、目标用户、关键功能和业务目标。

```yaml
---
description: "Product overview"
inclusion: always
---
```

**包含内容**：
- 产品目的和存在理由
- 目标用户群体
- 关键功能和能力
- 业务目标
- 技术约束

#### 2. tech.md - 技术栈

记录选择的框架、库、开发工具和技术约束。

```yaml
---
description: "Tech stack"
inclusion: always
---
```

**包含内容**：
- 主要框架
- 关键库和依赖
- 开发工具
- 技术限制
- 首选模式

#### 3. structure.md - 项目结构

概述文件组织、命名约定、导入模式和架构决策。

```yaml
---
description: "Project structure"
inclusion: always
---
```

**包含内容**：
- 文件组织方式
- 命名约定
- 导入模式
- 架构决策
- 模块结构

### 常用文件（可选）

这些文件根据需要加载，提供特定领域的指导：

#### 4. api-standards.md - API 规范

定义 REST 约定、错误响应格式、认证流程和版本策略。

```yaml
---
description: "API standards"
inclusion: fileMatch
fileMatchPattern: 'api/**/*'
---
```

**包含内容**：
- 端点命名模式
- HTTP 方法使用
- 错误响应格式
- 状态码使用
- 认证流程
- 版本策略
- 请求/响应示例

#### 5. testing-standards.md - 测试方法论

建立单元测试模式、集成测试策略、模拟方法和覆盖率期望。

```yaml
---
description: "Testing standards"
inclusion: fileMatch
fileMatchPattern: '**/*.test.*'
---
```

**包含内容**：
- 单元测试模式
- 集成测试策略
- 模拟方法
- 覆盖率期望
- 首选测试库
- 测试文件组织

#### 6. code-conventions.md - 代码风格

指定命名模式、文件组织、导入顺序和架构决策。

```yaml
---
description: "Code conventions"
inclusion: always
---
```

**包含内容**：
- 命名模式
- 文件组织
- 导入顺序
- 代码结构
- 反模式
- 示例

#### 7. security-policies.md - 安全指南

记录认证要求、数据验证规则、输入清理标准和漏洞预防措施。

```yaml
---
description: "Security policies"
inclusion: always
---
```

**包含内容**：
- 认证要求
- 数据验证
- 输入清理
- 漏洞预防
- 安全编码实践
- 合规要求

#### 8. deployment-workflow.md - 部署流程

概述构建过程、环境配置、部署步骤和回滚策略。

```yaml
---
description: "Deployment workflow"
inclusion: manual
---
```

**包含内容**：
- 构建过程
- 环境配置
- 部署步骤
- 回滚策略
- CI/CD 管道
- 环境特定要求

## Inclusion 模式

### Always Include（默认）

```yaml
---
inclusion: always
---
```

这些文件在每次 Kiro 交互中自动加载。

**适用于**：
- 项目范围的标准
- 技术偏好
- 安全策略
- 普遍适用的编码约定

### Conditional Include

```yaml
---
inclusion: fileMatch
fileMatchPattern: 'components/**/*.tsx'
---
```

仅在处理匹配指定模式的文件时自动包含。

**常用模式**：
- `"*.tsx"` - React 组件和 JSX 文件
- `"app/api/**/*"` - API 路由和后端逻辑
- `"**/*.test.*"` - 测试文件
- `"src/components/**/*"` - 组件特定指南
- `"*.md"` - 文档文件

**适用于**：
- 领域特定标准
- 组件模式
- API 设计规则
- 测试方法论

### Manual Include

```yaml
---
inclusion: manual
---
```

通过在聊天消息中引用 `#steering-file-name` 按需提供。

**使用方法**：
在聊天中输入 `#troubleshooting-guide` 或 `#performance-optimization`

**适用于**：
- 专门的工作流程
- 故障排除指南
- 迁移过程
- 偶尔需要的上下文丰富文档

## 最佳实践

### 1. 保持文件专注

每个文件一个领域 - API 设计、测试或部署过程。

### 2. 使用清晰的名称

- `api-standards.md` - REST API 标准
- `testing-unit-patterns.md` - 单元测试方法论
- `components-form-validation.md` - 表单组件标准

### 3. 包含上下文

解释为什么做出决策，而不仅仅是标准是什么。

### 4. 提供示例

使用代码片段和前后对比来演示标准。

### 5. 安全第一

永远不要包含 API 密钥、密码或敏感数据。Steering 文件是代码库的一部分。

### 6. 定期维护

- 随着项目发展更新 Steering 文件
- 删除过时的约定
- 添加新的模式和决策

## 文件引用

链接到实时项目文件以保持 Steering 最新：

```markdown
#[[file:<relative_file_name>]]
```

**示例**：
- API 规范：`#[[file:api/openapi.yaml]]`
- 组件模式：`#[[file:components/ui/button.tsx]]`
- 配置模板：`#[[file:.env.example]]`

## 使用 fix-steering-skills.sh 创建模板

运行修复脚本会自动创建所有推荐的 Steering 文件模板：

```bash
./fix-steering-skills.sh
```

创建的文件：
- ✅ `product.md`
- ✅ `tech.md`
- ✅ `structure.md`
- ✅ `api-standards.md`
- ✅ `testing-standards.md`
- ✅ `code-conventions.md`
- ✅ `security-policies.md`
- ✅ `deployment-workflow.md`

## 自定义 Steering 文件

你可以创建任何自定义 Steering 文件来满足项目的独特需求：

1. 在 `.kiro/steering/` 目录中创建新的 `.md` 文件
2. 添加 YAML frontmatter 指定 inclusion 模式
3. 使用标准 markdown 语法编写指导
4. Kiro 会立即识别并使用新文件

## 示例场景

### 场景 1：React 项目

```
.kiro/steering/
├── product.md              (always)
├── tech.md                 (always)
├── structure.md            (always)
├── component-patterns.md   (fileMatch: '**/*.tsx')
├── state-management.md     (fileMatch: 'src/store/**/*')
└── testing-standards.md    (fileMatch: '**/*.test.*')
```

### 场景 2：API 项目

```
.kiro/steering/
├── product.md              (always)
├── tech.md                 (always)
├── structure.md            (always)
├── api-standards.md        (fileMatch: 'api/**/*')
├── security-policies.md    (always)
└── deployment-workflow.md  (manual)
```

### 场景 3：全栈项目

```
.kiro/steering/
├── product.md              (always)
├── tech.md                 (always)
├── structure.md            (always)
├── api-standards.md        (fileMatch: 'api/**/*')
├── component-patterns.md   (fileMatch: 'components/**/*')
├── testing-standards.md    (fileMatch: '**/*.test.*')
├── security-policies.md    (always)
└── deployment-workflow.md  (manual)
```

## 相关资源

- [Kiro 官方 Steering 文档](https://kiro-community.github.io/book-of-kiro/en/features/steering/)
- [快速开始指南](../QUICKSTART.md)
- [Steering 和 Skills 分析](./STEERING-SKILLS-ANALYSIS.md)

## 总结

Steering 文件是 Kiro 理解你项目的关键。通过创建和维护这些文件，你可以：

- ✅ 确保一致的代码生成
- ✅ 减少重复解释
- ✅ 团队对齐
- ✅ 可扩展的项目知识

从默认的三个文件（product.md、tech.md、structure.md）开始，然后根据需要添加更多专门的 Steering 文件。
