# Tool Preferences Guide (English Version)

## Table of Contents

- [Overview](#overview)
- [How It Works](#how-it-works)
- [File Locations](#file-locations)
- [Configuration Format](#configuration-format)
  - [Method 1: Auto-generation (Recommended)](#method-1-auto-generation-recommended)
  - [Method 2: Manual Creation](#method-2-manual-creation)
- [Practical Examples](#practical-examples)
  - [Example 1: Search Tool Preferences](#example-1-search-tool-preferences)
  - [Example 2: Build Tool Preferences](#example-2-build-tool-preferences)
- [Built-in Tools You Can Override](#built-in-tools-you-can-override)
- [Usage Workflow](#usage-workflow)
  - [Method 1: Auto-generation](#method-1-auto-generation)
  - [Method 2: Manual Creation](#method-2-manual-creation-1)
- [Best Practices](#best-practices)
- [Important Notes](#important-notes)
- [Troubleshooting](#troubleshooting)
  - [Tool Preferences Not Working](#tool-preferences-not-working)
  - [tool-preferences.md Not Copied During Migration](#tool-preferencesmd-not-copied-during-migration)
  - [Agent Still Using Built-in Tools](#agent-still-using-built-in-tools)
- [References](#references)

## Overview

When you configure custom tools (like ripgrep, fd, etc.) in your project, you can use the `tool-preferences.md` document to configure Kiro to prioritize using your tools over built-in tools.

## How It Works

1. Create a `tool-preferences.md` file in your skill directory
2. Run the `kiro-adapter.sh` migration script
3. The script automatically copies `tool-preferences.md` to the power's steering directory
4. Kiro automatically loads these preferences (via `inclusion: auto` frontmatter)
5. The Agent will prioritize using your configured tools when executing tasks

## File Locations

### Single SKILL.md Structure
```
~/.kiro/skills/your-skill/
├── SKILL.md
└── tool-preferences.md          # Create here
```

After migration:
```
~/.kiro/powers/installed/your-skill/
├── POWER.md
└── steering/
    ├── skill.md
    └── tool-preferences.md      # Automatically copied here
```

### Nested Skills Structure
```
~/.kiro/skills/your-skill/
└── skills/
    └── subskill/
        ├── SKILL.md
        └── tool-preferences.md  # Create here
```

After migration:
```
~/.kiro/powers/installed/your-skill-subskill/
├── POWER.md
└── steering/
    ├── skill.md
    └── tool-preferences.md      # Automatically copied here
```

## Configuration Format

### Method 1: Auto-generation (Recommended)

Add a `replaces` field to the SKILL.md frontmatter, and the migration tool will automatically generate tool-preferences.md:

```markdown
---
name: your-tool
description: Your tool description
keywords: ["tool", "search"]
replaces: builtInTool
replaces-description: Why this tool is better
---
```

Run `./kiro-adapter.sh` and tool-preferences.md will be automatically generated.

### Method 2: Manual Creation

If you need more fine-grained control, you can manually create tool-preferences.md:

#### Basic Structure

```markdown
---
inclusion: auto
---

# Tool Usage Preferences

## [Tool Category]

**ALWAYS prefer `your-tool` over built-in `builtInTool` tool.**

When [usage scenario description]:
- Use `your-tool` command via `executeBash` tool
- [Advantages description]
- Common patterns:
  ```bash
  your-tool [example commands]
  ```

**Only use `builtInTool` when:**
- `your-tool` is not available or fails
- [Other fallback conditions]
```

#### Key Elements

1. **Frontmatter**: Must include `inclusion: auto` for auto-loading
2. **Clear Priority**: Use "ALWAYS prefer X over Y" to explicitly specify
3. **Usage Scenarios**: Clearly describe when to use the tool
4. **Example Commands**: Provide commonly used command patterns
5. **Fallback Conditions**: Specify when to use built-in tools

## Practical Examples

### Example 1: Search Tool Preferences

```markdown
---
inclusion: auto
---

# Tool Usage Preferences

## Search and Find Tool Preferences

### Text Search (Code Content Search)

**ALWAYS prefer `ripgrep` (rg) over built-in `grepSearch` tool.**

When searching for text content in files:
- Use `rg` command via `executeBash` tool
- Leverage ripgrep's speed (10-20x faster)
- Common patterns:
  ```bash
  rg "pattern" -t rust           # Search in Rust files
  rg "pattern" -i                # Case-insensitive
  rg "pattern" -C 3              # Show 3 lines context
  ```

**Only use `grepSearch` when:**
- `rg` is not available or fails
- You need IDE-specific structured output

### File Search (Finding Files by Name)

**ALWAYS prefer `fd` over built-in `fileSearch` tool.**

When searching for files by name or path:
- Use `fd` command via `executeBash` tool
- Faster and more intuitive than find
- Common patterns:
  ```bash
  fd pattern                     # Find files
  fd -e rs pattern               # Find .rs files
  fd -t d pattern                # Find directories only
  ```

**Only use `fileSearch` when:**
- `fd` is not available or fails
```

### Example 2: Build Tool Preferences

```markdown
---
inclusion: auto
---

# Tool Usage Preferences

## Build Tool Preferences

**ALWAYS prefer `cargo-make` over direct `cargo` commands.**

When building or running tasks:
- Use `cargo make <task>` via `executeBash` tool
- Provides consistent task definitions across team
- Common patterns:
  ```bash
  cargo make build               # Build project
  cargo make test                # Run tests
  cargo make check               # Run checks
  ```

**Only use direct `cargo` commands when:**
- `cargo-make` is not available
- Running one-off commands not in Makefile.toml
```

## Built-in Tools You Can Override

Common built-in tools that can be replaced:

| Built-in Tool | Purpose | Common Alternatives |
|--------------|---------|-------------------|
| `grepSearch` | Text/code content search | `ripgrep` (rg) |
| `fileSearch` | File name/path search | `fd` |
| `executeBash` | Shell command execution | Can configure default parameters |
| `readFile` | Read file content | `bat`, `cat` with plugins |
| `listDirectory` | List directory contents | `exa`, `lsd` |

## Usage Workflow

### Method 1: Auto-generation

1. **Add replaces field to SKILL.md**
   ```markdown
   ---
   name: ripgrep
   description: Fast search tool
   replaces: grepSearch
   replaces-description: 10-20x faster with smart defaults
   ---
   ```

2. **Run migration script**
   ```bash
   ./kiro-adapter.sh
   ```
   
   The script will:
   - Detect the `replaces` field
   - Automatically generate tool-preferences.md
   - Display "✓ Generated tool-preferences.md from SKILL.md"

3. **Restart Kiro** to load the configuration

### Method 2: Manual Creation

1. **Install custom tools**
   ```bash
   # For example, install ripgrep and fd
   brew install ripgrep fd
   # or
   cargo install ripgrep fd-find
   ```

2. **Create tool-preferences.md**
   - Create the file in your skill directory
   - Refer to the `tool-preferences-template.md` template
   - Explicitly specify tool priorities

3. **Run migration script**
   ```bash
   ./kiro-adapter.sh
   ```
   
   The script will:
   - Detect the `tool-preferences.md` file
   - Automatically copy it to the power's steering directory
   - Display "✓ Copied tool-preferences.md" confirmation

4. **Restart Kiro**
   - Kiro will automatically load tool preferences after restart
   - The Agent will prioritize using your configured tools

5. **Verify**
   - Have the Agent perform search or other operations
   - Observe if your configured tools are being used
   - Check execution logs to confirm tool calls

## Best Practices

1. **Clarity**: Use "ALWAYS prefer" and "Only use when" to explicitly specify priorities
2. **Documentation**: Provide clear examples and usage scenarios
3. **Fallback Strategy**: Always provide built-in tools as fallback options
4. **Performance Explanation**: Explain why a tool is preferred (performance, features, etc.)
5. **Team Consistency**: Use uniform tool preferences across team projects

## Important Notes

- `inclusion: auto` is required, otherwise preferences won't auto-load
- Tools must be installed on the system, otherwise fallback to built-in tools
- Migration script will overwrite existing tool-preferences.md files
- Changes require Kiro restart to take effect
- The Agent will automatically follow these preferences without explicit user instruction

## Troubleshooting

### Tool Preferences Not Working

1. Check if frontmatter contains `inclusion: auto`
2. Confirm the file is copied to `~/.kiro/powers/installed/*/steering/`
3. Restart Kiro
4. Check if the tool is installed on the system

### tool-preferences.md Not Copied During Migration

1. Confirm the filename is correct: `tool-preferences.md`
2. Confirm the file is in the skill directory root
3. Check migration script output for error messages
4. Run the script manually to see detailed logs

### Agent Still Using Built-in Tools

1. Check if the tool is available in PATH
2. Confirm tool-preferences.md syntax is correct
3. Check Agent execution logs to understand why
4. Fallback conditions may be triggered (tool unavailable, etc.)

## References

- Template file: `tool-preferences-template.md`
- Example file: `tool-preferences.md`
- Migration script: `kiro-adapter.sh`
- Examples: `REPLACES-FIELD-EXAMPLE.md`
- Test results: `TEST-RESULTS.md`
