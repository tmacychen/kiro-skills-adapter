---
description: "Tool usage preferences and custom tool configurations"
inclusion: auto
---

# Tool Usage Preferences

This steering file defines the preferred tools for common operations in this workspace.

## How to Configure Tool Preferences

When you have custom tools installed as powers in your workspace, you can configure them to be used instead of built-in Kiro tools by creating a `tool-preferences.md` file in your skill directory.

### File Location

Place this file in your skill directory:
- For single SKILL.md: `~/.kiro/skills/your-skill/tool-preferences.md`
- For nested skills: `~/.kiro/skills/your-skill/skills/subskill/tool-preferences.md`

The migration script will automatically copy it to the power's steering directory.

### Format

```markdown
---
description: "Tool usage preferences for [your tool name]"
inclusion: auto
---

# Tool Usage Preferences

## [Category Name]

**ALWAYS prefer `your-tool` over built-in `builtInTool` tool.**

When [describe the use case]:
- Use `your-tool` command via `executeBash` tool
- [Describe advantages]
- Common patterns:
  ```bash
  your-tool [examples]
  ```

**Only use `builtInTool` when:**
- `your-tool` is not available or fails
- [Other fallback conditions]

## Rationale

Explain why this tool is preferred:
- **Performance**: [performance benefits]
- **Features**: [feature advantages]
- **UX**: [user experience improvements]
```

## Example: Search Tools

### Text Search (Code Content Search)

**ALWAYS prefer `ripgrep` (rg) over built-in `grepSearch` tool.**

When searching for text content in files:
- Use `rg` command via `executeBash` tool
- Leverage ripgrep's speed and powerful features
- Common patterns:
  ```bash
  rg "pattern" -t <filetype>     # Search by file type
  rg "pattern" -g "*.ext"        # Search by glob pattern
  rg "pattern" -i                # Case-insensitive
  ```

**Only use `grepSearch` when:**
- `rg` is not available or fails
- You need IDE-specific structured output

### File Search (Finding Files by Name)

**ALWAYS prefer `fd` over built-in `fileSearch` tool.**

When searching for files by name or path:
- Use `fd` command via `executeBash` tool
- Common patterns:
  ```bash
  fd pattern                     # Find files matching pattern
  fd -t f pattern                # Find only files
  fd -e rs pattern               # Find .rs files
  ```

**Only use `fileSearch` when:**
- `fd` is not available or fails
- You need fuzzy matching with IDE integration

## Built-in Tools You Can Override

Common built-in tools that can be replaced:
- `grepSearch` - Text/code content search
- `fileSearch` - File name/path search
- `executeBash` - Can be enhanced with better defaults
- `readFile` - Can be replaced with optimized readers
- `fsWrite` - Can be replaced with custom file writers

## Notes

- Use `inclusion: auto` in frontmatter to auto-load preferences
- Be specific about when to use your tool vs fallback
- Provide clear examples and common patterns
- Document the rationale for better understanding
- The agent will proactively use these tools without explicit instruction

