# Quick Start

## 5-Minute Quick Start Guide

### 1. Installation

```bash
# Clone the repository
git clone <repository-url>
cd kiro-skills-adapter

# Make executable
chmod +x kiro-adapter.sh
```

### 2. Prepare Skills

Place your skills in one of the following locations:

- `~/.kiro/skills/` (recommended)
- Current directory (containing SKILL.md files)

### 3. Run Installation

```bash
# First installation (automatically initializes Steering templates)
./kiro-adapter.sh

# If migrating from old version
./kiro-adapter.sh --fix
```

### 4. Restart Kiro

Restart Kiro IDE to load newly installed Powers and Steering configurations.

## Common Commands

```bash
# View help
./kiro-adapter.sh --help

# Fix old configuration
./kiro-adapter.sh --fix

# Detailed output
./kiro-adapter.sh --verbose

# Force reinstall
./kiro-adapter.sh --force
```

## Verify Installation

### Check Powers

```bash
ls ~/.kiro/powers/installed/
```

You should see:
- `ripgrep/` - if ripgrep is installed
- `sharkdp-fd/` - if fd is installed
- Other installed skills

### Check Steering

```bash
ls ~/.kiro/steering/
```

**After first run**, you should see:
- `tool-preferences.md` - unified tool preferences (contains all tool configurations)
- `product.md`, `tech.md`, `structure.md`, `powers.md` - automatically created standard templates

> 💡 **Note**: Steering templates will be automatically created on first run, you can edit them directly to customize project configuration.

### Test in Kiro

Open Kiro and try:

```
"Use rg to search for 'function' in this project"
```
Kiro will prefer `rg` command over built-in `grepSearch`.

```
"Use fd to find all .md files"
```
Kiro will prefer `fd` command over built-in `fileSearch`.

```
"Use rg to search for 'function' in this project"
```
Kiro will prefer `rg` command over built-in `grepSearch`.

```
"Use fd to find all .md files"
```
Kiro will prefer `fd` command over built-in `fileSearch`.

## Complete Setup

Steering templates will be automatically created on first run:

```bash
./kiro-adapter.sh
```

Created files:

### Default Files (Automatically Created)
- `product.md` - Product overview
- `tech.md` - Technology stack
- `structure.md` - Project structure
- `powers.md` - Powers system introduction

### Common Files (Optional, Manually Created)
- `api-standards.md` - API standards
- `testing-standards.md` - Testing methodology
- `code-conventions.md` - Code style
- `security-policies.md` - Security guidelines
- `deployment-workflow.md` - Deployment process

> 💡 **Tip**: Default templates contain placeholders, you need to fill in content according to your project's actual situation.

## Next Steps

- Read [Complete Documentation](./README.md)
- Learn about [Project Structure](./PROJECT-STRUCTURE.md)
- Check [Changelog](./CHANGELOG.md)

## Common Questions

### Q: Skill not updating?

```bash
./kiro-adapter.sh --force
```

### Q: Kiro not recognizing skills?

1. Check installation directory: `ls ~/.kiro/powers/installed/`
2. Restart Kiro
3. If migrating from old version: `./kiro-adapter.sh --fix`

### Q: How to add new skills?

```bash
# 1. Create skill directory
mkdir -p ~/.kiro/skills/my-skill

# 2. Create SKILL.md
cat > ~/.kiro/skills/my-skill/SKILL.md <<'EOF'
---
name: "my-skill"
description: "My awesome skill"
keywords: ["custom"]
---

# My Skill

Content here...
EOF

# 3. Install
./kiro-adapter.sh
```

## Get Help

- Check [Documentation Directory](./docs/)
- Submit an Issue
- Read [README](./README.md)