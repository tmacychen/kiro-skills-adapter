# 项目结构

```
kiro-skills-adapter/
├── kiro-adapter.sh              # 主安装脚本
├── fix-steering-skills.sh       # 修复脚本（修正 Steering/Skills 规范）
├── README.md                    # 项目说明
├── LICENSE                      # 许可证
├── PROJECT-STRUCTURE.md         # 本文件
├── .gitmodules                  # Git 子模块配置
│
├── docs/                        # 文档目录
│   ├── INSTALL-GUIDE-ZH.md      # 安装指南（中文）
│   ├── INSTALL-GUIDE.md         # 安装指南（英文）
│   └── STEERING-SKILLS-ANALYSIS.md  # Steering 和 Skills 分析
│
└── [skill-directories]/         # 技能目录（示例）
    ├── ripgrep/
    ├── sharkdp-fd/
    ├── agent-browser/
    ├── dogfood/
    ├── rust-skills/
    └── Second-Me-Skills/
```

## 核心文件说明

### kiro-adapter.sh

主安装脚本，功能包括：

- 差异更新和增量安装
- 自动生成 POWER.md
- 创建 steering 文件
- 生成工具偏好设置
- 创建技能索引 Power
- 更新 agent 配置

### fix-steering-skills.sh

修复脚本，用于：

- 修正 `inclusion` 模式（`auto` → `always`）
- 将技能索引移到 Powers 系统
- 整理工具偏好设置
- 创建标准 Steering 文件模板
- 注册 skills-index power

### 文档目录

- **INSTALL-GUIDE-ZH.md**: 详细的中文安装和使用指南
- **INSTALL-GUIDE.md**: 详细的英文安装和使用指南
- **STEERING-SKILLS-ANALYSIS.md**: Kiro 官方规范分析和实现对比

## 生成的文件结构

运行脚本后，会在用户目录生成以下结构：

```
~/.kiro/
├── steering/                        # 项目约定和标准
│   ├── tool-preferences.md          # 统一的工具偏好设置
│   ├── ripgrep-tool-preferences.md  # 单独工具配置
│   ├── sharkdp-fd-tool-preferences.md
│   ├── product.md                   # 产品概述（模板）
│   ├── tech.md                      # 技术栈（模板）
│   └── structure.md                 # 项目结构（模板）
│
├── powers/
│   ├── .checksums                   # 校验和记录
│   ├── installed.json               # 已安装列表
│   ├── registry.json                # 注册表
│   └── installed/
│       ├── skills-index/            # 技能索引（自动生成）
│       │   ├── POWER.md
│       │   └── steering/
│       │       └── skill.md
│       ├── ripgrep/
│       │   ├── POWER.md
│       │   └── steering/
│       │       ├── skill.md
│       │       └── tool-preferences.md
│       └── [other-skills]/
│
└── agents/
    └── default.json                 # Agent 配置
```

## 技能目录结构

### 单个 SKILL.md 结构

```
skill-name/
├── SKILL.md                         # 必需
├── tool-preferences.md              # 可选
├── references/                      # 可选：参考文档
│   ├── guide1.md
│   └── guide2.md
└── templates/                       # 可选：模板文件
    ├── template1.sh
    └── template2.md
```

### 嵌套 skills/ 结构

```
parent-skill/
└── skills/
    ├── subskill1/
    │   ├── SKILL.md
    │   └── references/
    └── subskill2/
        ├── SKILL.md
        └── templates/
```

## 使用流程

1. **准备技能目录**
   - 将技能放在 `~/.kiro/skills/` 或当前目录
   - 确保每个技能有 `SKILL.md` 文件

2. **运行安装脚本**
   ```bash
   ./kiro-adapter.sh
   ```

3. **（可选）运行修复脚本**
   ```bash
   ./fix-steering-skills.sh
   ```

4. **重启 Kiro**
   - 加载新安装的 Powers 和 Steering 配置

## 维护

### 更新技能

```bash
# 修改技能文件
vim ~/.kiro/skills/my-skill/SKILL.md

# 运行差异更新
./kiro-adapter.sh
```

### 强制重装

```bash
./kiro-adapter.sh --force
```

### 清理

```bash
# 清除所有已安装的技能
rm -rf ~/.kiro/powers/installed/*
rm ~/.kiro/powers/.checksums

# 重新安装
./kiro-adapter.sh
```

## 开发

### 修改脚本

主要函数：

- `calculate_skill_checksum()`: 计算校验和
- `needs_update()`: 检查是否需要更新
- `process_skill()`: 处理单个技能
- `generate_power_md()`: 生成 POWER.md
- `create_steering()`: 创建 steering 文件
- `generate_tool_preferences()`: 生成工具偏好设置

### 测试

```bash
# 详细模式测试
./kiro-adapter.sh --verbose

# 检查生成的文件
ls -la ~/.kiro/powers/installed/
cat ~/.kiro/steering/tool-preferences.md
```

## 故障排除

参考 [INSTALL-GUIDE-ZH.md](./docs/INSTALL-GUIDE-ZH.md) 的故障排除章节。
