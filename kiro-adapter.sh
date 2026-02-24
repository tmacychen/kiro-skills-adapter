#!/bin/bash
# Kiro Skills Adapter - Convert Claude skills to Kiro powers format
set -e

SKILLS_SRC="$HOME/.kiro/skills"
POWERS_DIR="$HOME/.kiro/powers"
INSTALLED_DIR="$POWERS_DIR/installed"
INSTALLED_JSON="$POWERS_DIR/installed.json"
REGISTRY_JSON="$POWERS_DIR/registry.json"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Kiro Skills Adapter ===${NC}"
echo "Source: $SKILLS_SRC"
echo "Target: $POWERS_DIR"
echo

mkdir -p "$POWERS_DIR" "$INSTALLED_DIR"

installed=0

# Generate POWER.md from skills
generate_power_md() {
    local repo_path="$1"
    local name="$2"
    local power_md="$INSTALLED_DIR/$name/POWER.md"
    
    cat > "$power_md" <<EOF
# $name

> Imported from Claude Desktop skills format

## Overview

This power contains skills from the $name repository.

## Skills

EOF
    
    # List all skills
    if [ -d "$repo_path/skills" ]; then
        for skill in "$repo_path/skills"/*; do
            [ -d "$skill" ] || continue
            skill_name=$(basename "$skill")
            if [ -f "$skill/SKILL.md" ]; then
                # Extract description from frontmatter
                desc=$(grep "^description:" "$skill/SKILL.md" | sed 's/description: *//' | tr -d '"')
                echo "- **$skill_name**: $desc" >> "$power_md"
            fi
        done
    fi
    
    cat >> "$power_md" <<EOF

## Source

Original repository: $repo_path

This power is automatically generated from Claude Desktop skills format.
Skills are loaded from the \`skills/\` directory.

## Usage

Skills from this power are automatically available in Kiro.
Refer to individual SKILL.md files for detailed usage.
EOF
}

# Convert skills to steering files
convert_to_steering() {
    local repo_path="$1"
    local name="$2"
    local steering_dir="$INSTALLED_DIR/$name/steering"
    
    mkdir -p "$steering_dir"
    
    # Link skills directory
    if [ -d "$repo_path/skills" ]; then
        ln -sf "$repo_path/skills" "$steering_dir/skills"
    fi
    
    # Link other relevant directories
    for dir in agents commands templates docs; do
        if [ -d "$repo_path/$dir" ]; then
            ln -sf "$repo_path/$dir" "$steering_dir/$dir"
        fi
    done
}

# Register in registry.json
register_power() {
    local name="$1"
    local desc="$2"
    
    if [ -f "$REGISTRY_JSON" ]; then
        tmp=$(mktemp)
        jq --arg n "$name" \
           --arg d "$desc" \
           '.powers[$n] = {
               "name": $n,
               "description": $d,
               "author": "Community",
               "license": "MIT",
               "keywords": [],
               "displayName": $n,
               "iconUrl": "",
               "repositoryUrl": "",
               "repositoryCloneUrl": "",
               "pathInRepo": "",
               "repositoryBranch": "main",
               "installed": true,
               "source": {"type": "local"}
           }' "$REGISTRY_JSON" > "$tmp" && mv "$tmp" "$REGISTRY_JSON"
    fi
}

for repo in "$SKILLS_SRC"/*; do
    [ -d "$repo" ] || continue
    name=$(basename "$repo")
    [[ "$name" == *.sh ]] || [[ "$name" == *.md ]] && continue
    
    # Validate skill repo
    if [ ! -d "$repo/skills" ] && [ ! -f "$repo/SKILL.md" ]; then
        continue
    fi
    
    echo -e "${YELLOW}$name${NC}"
    
    # Create installed power structure
    power_dir="$INSTALLED_DIR/$name"
    rm -rf "$power_dir"
    mkdir -p "$power_dir"
    
    # Generate POWER.md
    generate_power_md "$repo" "$name"
    echo -e "  ${GREEN}✓${NC} Generated POWER.md"
    
    # Convert to steering format
    convert_to_steering "$repo" "$name"
    echo -e "  ${GREEN}✓${NC} Created steering links"
    
    # Get description
    desc="Imported Claude skills"
    if [ -f "$repo/README.md" ]; then
        desc=$(head -5 "$repo/README.md" | grep -v "^#" | grep -v "^$" | head -1 || echo "Imported Claude skills")
    fi
    
    # Register in registry.json
    register_power "$name" "$desc"
    echo -e "  ${GREEN}✓${NC} Registered in registry"
    
    # Update installed.json
    if [ -f "$INSTALLED_JSON" ]; then
        if ! grep -q "\"$name\"" "$INSTALLED_JSON"; then
            tmp=$(mktemp)
            jq --arg n "$name" '.installedPowers += [{"name": $n, "registryId": "local-skills"}]' \
               "$INSTALLED_JSON" > "$tmp" && mv "$tmp" "$INSTALLED_JSON"
        fi
    else
        cat > "$INSTALLED_JSON" <<EOF
{
  "version": "1.0.0",
  "installedPowers": [{"name": "$name", "registryId": "local-skills"}],
  "dismissedAutoInstalls": []
}
EOF
    fi
    
    ((installed++))
done

echo
echo -e "${GREEN}Installed: $installed powers${NC}"
echo

# Configure default agent
echo -e "${BLUE}Configuring default agent...${NC}"
if command -v kiro-cli &> /dev/null; then
    kiro-cli config set defaultAgent Default 2>/dev/null && \
        echo -e "${GREEN}✓${NC} Default agent set to 'Default'" || \
        echo -e "${YELLOW}⚠${NC} Please manually run: kiro-cli config set defaultAgent Default"
else
    echo -e "${YELLOW}⚠${NC} Please manually run: kiro-cli config set defaultAgent Default"
fi

echo
echo "Powers are in: $INSTALLED_DIR"
echo "Restart Kiro to load the powers"
