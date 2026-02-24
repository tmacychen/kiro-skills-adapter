# Kiro Skills Adapter

将 Claude Desktop 格式的 skills 适配到 Kiro CLI，无需修改源代码。

Convert Claude Desktop skills to Kiro CLI format without modifying source code.

## 快速开始 / Quick Start

```bash
# 1. 克隆 skills 到 ~/.kiro/skills/
# Clone skills to ~/.kiro/skills/
cd ~/.kiro/skills
git clone https://github.com/ZhangHanDong/rust-skills
git clone https://github.com/Mindverse/Second-Me-Skills

# 2. 运行适配器
# Run the adapter
chmod +x kiro-adapter.sh
./kiro-adapter.sh

# 3. 设置默认 agent 为 Default（重要！）
# Set default agent to Default (Important!)
kiro-cli config set defaultAgent Default

# 4. 完成！Kiro 现在可以使用这些 skills
# Done! Kiro can now use these skills
```

## 重要配置 / Important Configuration

配置 skills 后，必须将 Kiro CLI 的默认 agent 设置为 `Default`，而不是 `chat`：

After configuring skills, you must set Kiro CLI's default agent to `Default` instead of `chat`:

```bash
kiro-cli config set defaultAgent Default
```

这样 skills 才能被正确加载和使用。

This ensures skills are properly loaded and available.

## 工作原理 / How It Works

- **符号链接 / Symbolic Links**：在 `~/.kiro/powers/` 创建指向 `~/.kiro/skills/` 的链接 / Creates links in `~/.kiro/powers/` pointing to `~/.kiro/skills/`
- **零修改 / Zero Modification**：不改动源仓库任何文件 / No changes to source repositories
- **自动更新 / Auto Update**：在源仓库 `git pull` 后重新运行适配器即可 / Re-run adapter after `git pull` in source repos

## 更新 Skills / Update Skills

```bash
cd ~/.kiro/skills/rust-skills
git pull
cd ~/.kiro/skills
./kiro-adapter.sh
```

## 目录结构 / Directory Structure

```
~/.kiro/skills/          # 源仓库（可 git pull）/ Source repos (git pull enabled)
├── kiro-adapter.sh      # 适配工具 / Adapter tool
├── rust-skills/         # Git 仓库 / Git repository
└── Second-Me-Skills/    # Git 仓库 / Git repository

~/.kiro/powers/          # Kiro 读取目录 / Kiro reads from here
├── rust-skills -> ../skills/rust-skills
└── Second-Me-Skills -> ../skills/Second-Me-Skills
```

## 兼容性 / Compatibility

支持的 skill 格式 / Supported skill formats:
- Claude Desktop skills（包含 `skills/` 目录 / with `skills/` directory）
- 单文件 skills（包含 `SKILL.md` / with `SKILL.md`）
- Claude Plugin 格式（包含 `.claude-plugin/plugin.json` / with `.claude-plugin/plugin.json`）

Kiro 会自动识别这些格式并加载。

Kiro automatically recognizes and loads these formats.
