# Kiro Adapter Templates

This directory contains template files used by `kiro-adapter.sh` to initialize Kiro steering configurations.

## Directory Structure

```
templates/
└── steering/           # Steering template files
    ├── product.md      # Product overview template
    ├── tech.md         # Tech stack template
    ├── structure.md    # Project structure template
    └── powers.md       # Kiro Powers system introduction
```

## Template Files

### steering/product.md
Template for documenting product overview, target users, key features, and business goals.

### steering/tech.md
Template for documenting tech stack, frameworks, libraries, and technical constraints.

### steering/structure.md
Template for documenting project structure, file organization, and naming conventions.

### steering/powers.md
Introduction to Kiro Powers system - helps AI discover and use installed powers.

## Usage

These templates are automatically copied to `~/.kiro/steering/` when running:

```bash
./kiro-adapter.sh
```

The script will:
1. Check if template files exist in `~/.kiro/steering/`
2. Copy missing templates from this directory
3. Skip existing files (no overwrite)

## Customization

You can customize these templates to match your project needs:

1. Edit the template files in this directory
2. Run `./kiro-adapter.sh --fix` to regenerate steering files
3. Existing files will be backed up with `.bak` extension

## Template Format

All steering templates follow this format:

```markdown
---
description: "Brief description of the file's purpose"
inclusion: always
---

# Title

[Content sections...]
```

The frontmatter is required for Kiro to properly load the steering files.

## See Also

- Main script: `../kiro-adapter.sh`
- Documentation: `../README.md`
- Quickstart: `../QUICKSTART.md`
