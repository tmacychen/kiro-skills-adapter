# Project Structure

```
kiro-skills-adapter/
├── kiro-adapter.sh              # Main installation script
├── fix-steering-skills.sh       # Fix script (corrects Steering/Skills specifications)
├── README.md                    # Project description
├── LICENSE                      # License
├── PROJECT-STRUCTURE.md         # This file
├── .gitmodules                  # Git submodule configuration
│
├── docs/                        # Documentation directory
│   ├── INSTALL-GUIDE-ZH.md      # Installation guide (Chinese)
│   ├── INSTALL-GUIDE.md         # Installation guide (English)
│   └── STEERING-SKILLS-ANALYSIS.md  # Steering and Skills analysis
│
└── [skill-directories]/         # Skill directories (examples)
    ├── ripgrep/
    ├── sharkdp-fd/
    ├── agent-browser/
    ├── dogfood/
    ├── rust-skills/
    └── Second-Me-Skills/
```

## Core File Explanation

### kiro-adapter.sh

Main installation script with features including:

- Differential updates and incremental installation
- Automatic POWER.md generation
- Steering file creation
- Tool preference generation
- Skill index Power creation
- Agent configuration update

### fix-steering-skills.sh

Fix script used for:

- Correcting `inclusion` mode (`auto` → `always`)
- Moving skill index to Powers system
- Organizing tool preferences
- Creating standard Steering file templates
- Registering skills-index power

### Documentation Directory

- **INSTALL-GUIDE-ZH.md**: Detailed Chinese installation and usage guide
- **INSTALL-GUIDE.md**: Detailed English installation and usage guide
- **STEERING-SKILLS-ANALYSIS.md**: Kiro official specification analysis and implementation comparison

## Generated File Structure

After running the script, the following structure will be generated in the user directory:

```
~/.kiro/
├── steering/                        # Project conventions and standards
│   ├── tool-preferences.md          # Unified tool preferences
│   ├── ripgrep-tool-preferences.md  # Individual tool configuration
│   ├── sharkdp-fd-tool-preferences.md
│   ├── product.md                   # Product overview (template)
│   ├── tech.md                      # Technology stack (template)
│   └── structure.md                 # Project structure (template)
│
├── powers/
│   ├── .checksums                   # Checksum records
│   ├── installed.json               # Installed list
│   ├── registry.json                # Registry
│   └── installed/
│       ├── skills-index/            # Skill index (automatically generated)
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
    └── default.json                 # Agent configuration
```

## Skill Directory Structure

### Single SKILL.md Structure

```
skill-name/
├── SKILL.md                         # Required
├── tool-preferences.md              # Optional
├── references/                      # Optional: Reference documentation
│   ├── guide1.md
│   └── guide2.md
└── templates/                       # Optional: Template files
    ├── template1.sh
    └── template2.md
```

### Nested skills/ Structure

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

## Usage Flow

1. **Prepare skill directories**
   - Place skills in `~/.kiro/skills/` or current directory
   - Ensure each skill has a `SKILL.md` file

2. **Run installation script**
   ```bash
   ./kiro-adapter.sh
   ```

3. **(Optional) Run fix script**
   ```bash
   ./fix-steering-skills.sh
   ```

4. **Restart Kiro**
   - Load newly installed Powers and Steering configurations

## Maintenance

### Update Skills

```bash
# Modify skill files
vim ~/.kiro/skills/my-skill/SKILL.md

# Run differential update
./kiro-adapter.sh
```

### Force Reinstall

```bash
./kiro-adapter.sh --force
```

### Cleanup

```bash
# Clear all installed skills
rm -rf ~/.kiro/powers/installed/*
rm ~/.kiro/powers/.checksums

# Reinstall
./kiro-adapter.sh
```

## Development

### Modifying Scripts

Main functions:

- `calculate_skill_checksum()`: Calculates checksum
- `needs_update()`: Checks if update is needed
- `process_skill()`: Processes individual skill
- `generate_power_md()`: Generates POWER.md
- `create_steering()`: Creates steering files
- `generate_tool_preferences()`: Generates tool preferences

### Testing

```bash
# Test in verbose mode
./kiro-adapter.sh --verbose

# Check generated files
ls -la ~/.kiro/powers/installed/
cat ~/.kiro/steering/tool-preferences.md
```

## Troubleshooting

Refer to the troubleshooting section in [INSTALL-GUIDE-ZH.md](./docs/INSTALL-GUIDE-ZH.md).