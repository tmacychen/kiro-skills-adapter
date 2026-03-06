# Kiro Skills Adapter

An intelligent installation tool that converts Skills from any directory to Kiro Powers format.

> 📖 **New user?** Check out the [Quick Start Guide](./QUICKSTART.md) to get started in 5 minutes!

## Features

- ✅ **Differential Updates**: Automatically detects file changes and only updates modified skills
- ✅ **Incremental Installation**: Skips unchanged skills to save time
- ✅ **Checksum Tracking**: Uses MD5 checksums to track file changes
- ✅ **Tool Preferences**: Automatically generates and manages tool preference configurations
- ✅ **Standard Compliance**: Follows Kiro official Steering standards
- ✅ **Submodule Support**: Supports skill repositories in Git submodule format
- ✅ **Auto Cleanup**: Automatically cleans up excess powers in --fix mode

## Quick Start

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd kiro-skills-adapter

# Make executable
chmod +x kiro-adapter.sh
```

### Basic Usage

```bash
# Default mode: Intelligent differential update + automatic Steering initialization
./kiro-adapter.sh

# Fix old version configuration
./kiro-adapter.sh --fix

# Force reinstall all skills
./kiro-adapter.sh --force

# Show detailed output
./kiro-adapter.sh --verbose

# View help
./kiro-adapter.sh --help
```

## Project Structure

```
kiro-skills-adapter/
├── kiro-adapter.sh           # Main script
├── templates/                # Template files directory
│   ├── README.md            # Template documentation
│   └── steering/            # Steering templates
│       ├── product.md       # Product overview template
│       ├── tech.md          # Technology stack template
│       ├── structure.md     # Project structure template
│       └── powers.md        # Powers system introduction
├── README.md                # This documentation
├── QUICKSTART.md            # Quick start guide
└── docs/                    # Detailed documentation
```

**Template System**:
- All Steering templates are stored in `templates/steering/` directory
- Script automatically copies them to `~/.kiro/steering/`
- Will not overwrite existing files
- Templates can be customized to match project requirements

## Working Principle

### Input Structure

The script supports three skill directory structures:

```
~/.kiro/skills/                    # Or current directory
├── ripgrep/                       # Single skill
│   ├── SKILL.md                   # Required
│   └── tool-preferences.md        # Optional
├── agent-browser/                 # Git submodule
│   └── skills/                    # Nested skills directory
│       ├── agent-browser/
│       │   ├── SKILL.md
│       │   ├── references/        # Reference documentation
│       │   └── templates/         # Template files
│       ├── dogfood/
│       │   └── SKILL.md
│       ├── electron/
│       │   └── SKILL.md
│       └── slack/
│           └── SKILL.md
└── rust-skills/                   # Git submodule
    └── skills/                    # Nested structure
        ├── coding-guidelines/
        │   └── SKILL.md
        └── domain-web/
            └── SKILL.md
```

**Explanation**:
- **Single Skill**: Directories containing `SKILL.md` are installed directly
- **Git Submodule**: If contains `skills/` subdirectory, recursively processes all sub-skills
- **Nested Structure**: Sub-skill names will have parent directory prefix (e.g., `agent-browser-agent-browser`)

### Output Structure

```
~/.kiro/
├── steering/                      # Project conventions and standards
│   ├── tool-preferences.md        # Unified tool preferences
│   ├── product.md                 # Product overview (template, optional)
│   ├── tech.md                    # Technology stack (template, optional)
│   └── structure.md               # Project structure (template, optional)
└── powers/
    └── installed/
        ├── ripgrep/
        │   ├── POWER.md
        │   └── steering/
        │       ├── skill.md
        │       └── tool-preferences.md  # Skill-specific configuration
        └── ...
```

## Core Features

### 1. Differential Updates

The script uses MD5 checksums to track file changes:

- First run: Installs all skills, establishes checksum baseline
- Subsequent runs: Only updates changed skills
- Performance improvement: 5-10x (for unchanged skills)

### 2. Automatic Steering Initialization

Automatically creates missing Steering template files on each run:

- `product.md` - Product overview
- `tech.md` - Technology stack
- `structure.md` - Project structure
- Skips existing files, won't overwrite

### 3. Tool Preferences

Automatically handles tool preference configurations:

- Automatically generates from `replaces` field in SKILL.md
- Generates unified tool preferences summary in `~/.kiro/steering/tool-preferences.md`

### 4. Fix Old Configuration

Use `--fix` option to fix and validate configurations:

- Compares file content, regenerates if inconsistent (creates `.bak` backup)
- Skips if consistent, no modification
- Detects extra documents and prompts for deletion
- Corrects `inclusion: auto` → `inclusion: always`
- **Automatically cleans up excess powers**

#### Clean Up Excess Powers

The `--fix` feature automatically detects and cleans up powers that no longer correspond to the current source directory structure:

```bash
$ ./kiro-adapter.sh --fix

Checking for orphaned powers...
  ⚠ Orphaned power detected: agent-browser
     Removing...
  ⚠ Orphaned power detected: dogfood
     Removing...
Removed 2 orphaned powers
```

**Cleanup Scenarios**:
- Powers left from old versions
- Excess powers after modifying directory structure
- Residual powers after manually deleting source files

**Safety Mechanisms**:
- Fully generic: Based on file structure judgment, no hardcoded rules
- Only deletes powers not in source directory
- Cleans up checksum records simultaneously

### 5. Kiro Compliance

- **Steering**: Used for project conventions (tool preferences, API standards, etc.)
- Uses correct `inclusion` modes (`always`, `fileMatch`, `manual`)

## SKILL.md Format

### Basic Format

```yaml
---
name: "skill-name"
description: "Skill description"
keywords: ["keyword1", "keyword2"]
---

# Skill Name

Skill content here...
```

### Tool Replacement Configuration

If your skill provides functionality that replaces built-in tools, add the `replaces` field:

```yaml
---
name: "ripgrep"
description: "Fast text search tool"
keywords: ["search", "grep", "ripgrep"]
replaces: "grepSearch"
replaces-description: "Replaces built-in grepSearch with faster ripgrep"
---
```

The script will automatically generate `tool-preferences.md` and copy it to the global steering directory.

## Command Line Options

| Option | Short | Description |
|--------|-------|-------------|
| `--force` | `-f` | Force reinstall all skills, ignore checksums |
| `--verbose` | `-v` | Show detailed processing information |
| `--fix` | - | Fix old version configuration (migrate old environment) |
| `--help` | `-h` | Show help information |

## Output Example

### Normal Run

```
=== Kiro Skills Adapter ===
Source: /Users/username/kiro-skills
Target: /Users/username/.kiro/powers

ripgrep [UPDATE]
rust-skills-coding-guidelines ✓ Up to date
rust-skills-domain-web ✓ Up to date

New: 0 | Updated: 1 | Skipped: 2
Total processed: 3

Generating global tools summary...
  ✓ Generated tools summary with 2 tools
  ✓ Generated skills summary with 47 skills

Updating default agent...
  ✓ Updated /Users/username/.kiro/agents/default.json

Powers are in: /Users/username/.kiro/powers/installed
Restart Kiro to load the powers
```

## Troubleshooting

### Issue 1: Skill Not Updating

```bash
# Force reinstall
./kiro-adapter.sh --force

# Or delete checksum records
rm ~/.kiro/powers/.checksums
./kiro-adapter.sh
```

### Issue 2: Migrating from Old Version or Validating Configuration

```bash
# Fix and validate configuration
./kiro-adapter.sh --fix

# View detailed output
./kiro-adapter.sh --fix --verbose
```

`--fix` will:
- Compare file content, regenerate if inconsistent
- Create `.bak` backup files
- Detect and prompt for deletion of extra files

### Issue 3: Skill Not Taking Effect After Installation

```bash
# Check installation directory
ls -la ~/.kiro/powers/installed/

# Check agent configuration
cat ~/.kiro/agents/default.json

# Restart Kiro
```

## Best Practices

### 1. Daily Development Workflow

```bash
# 1. Modify skill files
vim ~/.kiro/skills/my-skill/SKILL.md

# 2. Run differential update (automatically initializes Steering)
./kiro-adapter.sh

# 3. Restart Kiro to load updates
```

### 2. Creating New Skills

```bash
# 1. Create skill directory
mkdir -p ~/.kiro/skills/my-new-skill

# 2. Create SKILL.md
cat > ~/.kiro/skills/my-new-skill/SKILL.md <<'EOF'
---
name: "my-new-skill"
description: "My awesome skill"
keywords: ["custom", "tool"]
---

# My New Skill

Skill content here...
EOF

# 3. Install
./kiro-adapter.sh
```

### 3. Customizing Steering Configuration

```bash
# Steering templates are automatically created, just edit them directly
vim ~/.kiro/steering/product.md
vim ~/.kiro/steering/tech.md
vim ~/.kiro/steering/structure.md

# Restart Kiro to load configuration
```

### 3. Adding Reference Documentation and Templates

```bash
# Create directories
mkdir -p ~/.kiro/skills/my-skill/references
mkdir -p ~/.kiro/skills/my-skill/templates

# Add files
echo "# Reference" > ~/.kiro/skills/my-skill/references/guide.md
echo "# Template" > ~/.kiro/skills/my-skill/templates/example.sh

# Reinstall to update index
./kiro-adapter.sh
```

### 4. Migrating from Old Version

```bash
# Fix old configuration
./kiro-adapter.sh --fix

# Normal installation
./kiro-adapter.sh
```

- **bash**: Shell script interpreter
- **jq**: JSON processing tool
- **md5** (macOS) or **md5sum** (Linux): Checksum calculation

### Installing Dependencies

```bash
# macOS (using Homebrew)
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# CentOS/RHEL
sudo yum install jq
```

## Documentation

- 📚 [Quick Start](./QUICKSTART.md) - 5-minute quick start guide
- 🔄 [Migration Guide](./MIGRATION.md) - Migrating from old versions
- 📝 [Update Notes](./UPDATE-NOTES.md) - Latest change details
- 📖 [Installation Guide (Chinese)](./docs/INSTALL-GUIDE-ZH.md) - Detailed Chinese documentation
- 📖 [Installation Guide (English)](./docs/INSTALL-GUIDE.md) - Detailed English documentation
- 📋 [Steering Files Guide](./docs/STEERING-FILES-GUIDE.md) - Complete guide for Steering files
- 🔍 [Steering and Skills Analysis](./docs/STEERING-SKILLS-ANALYSIS.md) - Official specification analysis
- 📁 [Project Structure](./PROJECT-STRUCTURE.md) - Project organization explanation

## Changelog

### v3.2.0 - Auto Cleanup of Excess Powers

- ✨ **Auto cleanup of excess powers**: `--fix` mode automatically detects and cleans up
- ✨ **Smart identification**: Builds expected list based on source directory structure
- ✨ **Safety mechanism**: Whitelist protection, only deletes excess items
- ✨ **Clear feedback**: Shows cleanup progress and statistics
- 🔧 Enhanced `--fix` functionality: Not only fixes configuration but also cleans up excess powers
- 📝 Added `FIX-FEATURE-UPDATE.md` documentation

### v3.1.0 - Template Externalization

- ✨ **Template externalization**: Moved all Steering templates to `templates/steering/` directory
- ✨ **Improved maintainability**: No longer embedding large text in scripts
- ✨ **Easy customization**: Can directly edit template files
- ✨ **Added powers.md template**: Introduces Kiro Powers system
- 📝 Added `templates/README.md` documentation
- 🔧 Optimized `initialize_steering_templates()` function
- 🔧 Optimized `fix_old_configuration()` function

### v3.0.0 - Simplification and Automation

- ✨ **Automatic Steering initialization**: Automatically creates missing templates on each run
- ✨ **New `--fix` option**: Fixes old version configuration
- 🔥 **Removed `--init-steering`**: No longer needed for separate initialization
- ✨ Smartly skips existing files
- ✨ Automatically corrects inclusion mode
- 📝 Simplified user experience

### v2.0.0 - Kiro Compliance

- ✨ Corrected use of Steering
- ✨ Corrected `inclusion` mode (`auto` → `always`)
- ✨ Created standard Steering file templates

### v1.0.0 - Differential Update Version

- ✨ Added differential detection functionality
- ✨ Added MD5 checksum tracking
- ✨ Added `--force` option for forced reinstallation
- ✨ Added `--verbose` option for detailed output
- ✨ Improved status display (NEW/UPDATE/Up to date)
- ✨ Optimized performance, skips unchanged skills

## Contribution

Welcome to submit issues and improvement suggestions!

## License

GNU General Public License v3

## Related Links

- [Kiro Official Documentation](https://kiro.dev/docs/)
- [Kiro Steering Documentation](https://kiro-community.github.io/book-of-kiro/en/features/steering/)
- [Kiro Skills Changelog](https://kiro.dev/changelog/cli/1-24)