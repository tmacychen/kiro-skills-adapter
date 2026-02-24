# Kiro Skills Adapter

[中文](#中文) | [English](#english)

---

## 中文

将 Claude Desktop 格式的 skills 适配到 Kiro CLI，无需修改源代码。

## 快速开始

```bash
# 1. 克隆 skills 到 ~/.kiro/skills/
cd ~/.kiro/skills
git clone https://github.com/ZhangHanDong/rust-skills
git clone https://github.com/Mindverse/Second-Me-Skills

# 2. 运行适配器
chmod +x kiro-adapter.sh
./kiro-adapter.sh

# 3. 设置默认 agent 为 Default（重要！）
kiro-cli config set defaultAgent Default

# 4. 完成！Kiro 现在可以使用这些 skills
```

## 重要配置

配置 skills 后，必须将 Kiro CLI 的默认 agent 设置为 `Default`，而不是 `chat`：

```bash
kiro-cli config set defaultAgent Default
```

这样 skills 才能被正确加载和使用。

## 工作原理

- **符号链接**：在 `~/.kiro/powers/` 创建指向 `~/.kiro/skills/` 的链接
- **零修改**：不改动源仓库任何文件
- **自动更新**：在源仓库 `git pull` 后重新运行适配器即可

## 更新 Skills

```bash
cd ~/.kiro/skills/rust-skills
git pull
cd ~/.kiro/skills
./kiro-adapter.sh
```

## 目录结构

```
~/.kiro/skills/          # 源仓库（可 git pull）
├── kiro-adapter.sh      # 适配工具
├── rust-skills/         # Git 仓库
└── Second-Me-Skills/    # Git 仓库

~/.kiro/powers/          # Kiro 读取目录
├── rust-skills -> ../skills/rust-skills
└── Second-Me-Skills -> ../skills/Second-Me-Skills
```

## 兼容性

支持的 skill 格式：
- Claude Desktop skills（包含 `skills/` 目录）
- 单文件 skills（包含 `SKILL.md`）
- Claude Plugin 格式（包含 `.claude-plugin/plugin.json`）

Kiro 会自动识别这些格式并加载。

---

## English

Convert Claude Desktop skills to Kiro CLI format without modifying source code.

## Quick Start

```bash
# 1. Clone skills to ~/.kiro/skills/
cd ~/.kiro/skills
git clone https://github.com/ZhangHanDong/rust-skills
git clone https://github.com/Mindverse/Second-Me-Skills

# 2. Run the adapter
chmod +x kiro-adapter.sh
./kiro-adapter.sh

# 3. Set default agent to Default (Important!)
kiro-cli config set defaultAgent Default

# 4. Done! Kiro can now use these skills
```

## Important Configuration

After configuring skills, you must set Kiro CLI's default agent to `Default` instead of `chat`:

```bash
kiro-cli config set defaultAgent Default
```

This ensures skills are properly loaded and available.

## How It Works

- **Symbolic Links**: Creates links in `~/.kiro/powers/` pointing to `~/.kiro/skills/`
- **Zero Modification**: No changes to source repositories
- **Auto Update**: Re-run adapter after `git pull` in source repos

## Update Skills

```bash
cd ~/.kiro/skills/rust-skills
git pull
cd ~/.kiro/skills
./kiro-adapter.sh
```

## Directory Structure

```
~/.kiro/skills/          # Source repos (git pull enabled)
├── kiro-adapter.sh      # Adapter tool
├── rust-skills/         # Git repository
└── Second-Me-Skills/    # Git repository

~/.kiro/powers/          # Kiro reads from here
├── rust-skills -> ../skills/rust-skills
└── Second-Me-Skills -> ../skills/Second-Me-Skills
```

## Compatibility

Supported skill formats:
- Claude Desktop skills (with `skills/` directory)
- Single-file skills (with `SKILL.md`)
- Claude Plugin format (with `.claude-plugin/plugin.json`)

Kiro automatically recognizes and loads these formats.
