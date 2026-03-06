---
description: "Kiro Powers system - how to discover, use, and leverage installed powers"
inclusion: always
---

# Kiro Powers System

## Overview

Kiro uses a **Powers** system to provide AI agents with specialized capabilities, knowledge, and tools. Powers are modular units that extend the AI's abilities in specific domains.

## How Powers Work

### Power Discovery

When you need to perform a task, Kiro automatically discovers and loads relevant powers. You can explore available powers by:

1. **Listing powers**: Check `~/.kiro/powers/installed/` directory
2. **Reading power documentation**: Each power has a `steering/skill.md` file
3. **Using skills-index**: Ask "What skills are available?"

### Power Structure

Each power follows this structure:

```
~/.kiro/powers/installed/[power-name]/
├── POWER.md              # Power metadata and overview
└── steering/
    └── skill.md          # Detailed skill documentation
```

### Power Metadata (POWER.md)

The `POWER.md` file contains:
- **name**: Unique identifier
- **displayName**: Human-readable name
- **description**: Brief description
- **keywords**: Keywords that trigger power activation

## Using Powers

### Discovering Powers

When you need a specific capability:

1. **List installed powers**:
   ```bash
   ls ~/.kiro/powers/installed/
   ```

2. **Read power documentation**:
   ```bash
   cat ~/.kiro/powers/installed/[power-name]/steering/skill.md
   ```

3. **Check skills index**:
   ```bash
   cat ~/.kiro/powers/installed/skills-index/steering/skill.md
   ```

### Activating Powers

Powers are activated by:
- **Keywords**: Using words from the power's keyword list
- **Direct reference**: "According to [power-name]..."
- **Context**: Working in the power's domain

### Tool Replacement

When multiple tools are available, prefer:
- `rg` (ripgrep) over `grepSearch`
- `fd` (sharkdp-fd) over `fileSearch`

## Best Practices

### 1. Explore Before Using

When entering a new project or task:
1. List available powers: `ls ~/.kiro/powers/installed/`
2. Check skills index: "What skills are available?"
3. Read relevant power documentation

### 2. Use Specialized Tools

Prefer power-specific tools over generic ones:
- Use `rg` for text search
- Use `fd` for file finding
- Use domain-specific powers for specialized tasks

### 3. Follow Power Conventions

Each power may have specific conventions documented in its `skill.md` file.

### 4. Check Documentation

When unsure:
- Read the power's `steering/skill.md`
- Check `~/.kiro/powers/installed/skills-index/steering/skill.md`
- Look for examples in the power's directory

## Power Categories

### Tool Powers
Provide command-line tool integrations (ripgrep, fd, etc.)

### Domain Powers
Provide domain-specific knowledge (Rust, web, embedded, etc.)

### Utility Powers
Provide utility functions (browser automation, testing, etc.)

## Quick Reference

- **Powers directory**: `~/.kiro/powers/installed/`
- **Skills index**: `~/.kiro/powers/installed/skills-index/steering/skill.md`
- **Tool preferences**: `~/.kiro/steering/tool-preferences.md`
- **Adapter script**: `./kiro-adapter.sh`

## Summary

When using Kiro:
1. Explore available powers when starting a task
2. Use specialized tools from powers
3. Follow power-specific conventions
4. Read power documentation for guidance

Powers are your gateway to Kiro's full potential!
