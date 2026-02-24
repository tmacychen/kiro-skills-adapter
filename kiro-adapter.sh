#!/bin/bash
# Kiro Skills Adapter
# Converts skills from ~/.kiro/skills to Kiro powers format in ~/.kiro/powers/installed/
# Supports both single SKILL.md and nested skills/ subdirectory structures

SKILLS_SRC="$HOME/.kiro/skills"
POWERS_DIR="$HOME/.kiro/powers"
INSTALLED_DIR="$POWERS_DIR/installed"
INSTALLED_JSON="$POWERS_DIR/installed.json"
REGISTRY_JSON="$POWERS_DIR/registry.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Kiro Skills Adapter ===${NC}"
echo "Source: $SKILLS_SRC"
echo "Target: $POWERS_DIR"
echo

mkdir -p "$POWERS_DIR" "$INSTALLED_DIR"

# Clean up old symlinks from previous migration
echo -e "${BLUE}Cleaning up old symlinks...${NC}"
for link in "$POWERS_DIR"/*; do
    if [ -L "$link" ]; then
        rm -f "$link"
        echo -e "  ${GREEN}✓${NC} Removed $(basename "$link")"
    fi
done

installed=0

# Extract YAML frontmatter from SKILL.md
# Returns lines between first --- and second ---
extract_frontmatter() {
    local skill_file="$1"
    if head -1 "$skill_file" | grep -q "^---$"; then
        sed -n '2,/^---$/p' "$skill_file" | grep -v "^---$"
    fi
}

# Generate POWER.md from SKILL.md frontmatter
generate_power_md() {
    local skill_dir="$1"
    local skill_name="$2"
    local power_md="$INSTALLED_DIR/$skill_name/POWER.md"
    
    local skill_file="$skill_dir/SKILL.md"
    [ -f "$skill_file" ] || return 1
    
    local frontmatter=$(extract_frontmatter "$skill_file")
    local name=$(echo "$frontmatter" | grep "^name:" | sed 's/name: *//' | tr -d '"')
    local desc=$(echo "$frontmatter" | grep "^description:" | sed 's/description: *//' | tr -d '"')
    local keywords=$(echo "$frontmatter" | grep "^keywords:" | sed 's/keywords: *//')
    
    [ -z "$name" ] && name="$skill_name"
    [ -z "$desc" ] && desc="A Kiro skill for $skill_name"
    
    # Convert YAML keywords array to JSON array
    local keywords_json="[]"
    if [ -n "$keywords" ] && [ "$keywords" != "[]" ]; then
        keywords_json=$(echo "$keywords" | sed 's/\[//;s/\]//;s/"//g' | tr ',' '\n' | \
            sed 's/^ *//;s/ *$//' | grep -v '^$' | sed 's/^/"/;s/$/"/' | tr '\n' ',' | \
            sed 's/,$//' | sed 's/^/[/;s/$/]/')
    fi
    
    cat > "$power_md" <<EOF
---
name: "$name"
displayName: "$name"
description: "$desc"
keywords: $keywords_json
---

# $name

$desc

## Overview

This power provides capabilities for $name.

## Usage

This skill is automatically available in Kiro.
Refer to the original SKILL.md file for detailed usage.

## Source

Original location: $skill_dir
EOF
}

# Copy SKILL.md to steering/skill.md
create_steering() {
    local skill_dir="$1"
    local skill_name="$2"
    local steering_dir="$INSTALLED_DIR/$skill_name/steering"
    
    mkdir -p "$steering_dir"
    
    if [ -f "$skill_dir/SKILL.md" ]; then
        cp "$skill_dir/SKILL.md" "$steering_dir/skill.md"
    fi
}

# Process a single skill directory and register it
process_skill() {
    local skill_dir="$1"
    local skill_name="$2"
    
    echo -e "${YELLOW}$skill_name${NC}"
    
    local power_dir="$INSTALLED_DIR/$skill_name"
    rm -rf "$power_dir"
    mkdir -p "$power_dir"
    
    # Generate POWER.md
    if generate_power_md "$skill_dir" "$skill_name"; then
        echo -e "  ${GREEN}✓${NC} Generated POWER.md"
    else
        echo -e "  ${YELLOW}⚠${NC} Failed to generate POWER.md"
        return 1
    fi
    
    # Create steering
    create_steering "$skill_dir" "$skill_name"
    echo -e "  ${GREEN}✓${NC} Created steering"
    
    # Get description from frontmatter
    local frontmatter=$(extract_frontmatter "$skill_dir/SKILL.md")
    local desc=$(echo "$frontmatter" | grep "^description:" | sed 's/description: *//' | tr -d '"')
    [ -z "$desc" ] && desc="A Kiro skill for $skill_name"
    
    # Register in registry.json
    if [ -f "$REGISTRY_JSON" ]; then
        tmp=$(mktemp)
        jq --arg n "$skill_name" \
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
    
    # Update installed.json
    if [ -f "$INSTALLED_JSON" ]; then
        if ! grep -q "$skill_name" "$INSTALLED_JSON"; then
            tmp=$(mktemp)
            jq --arg n "$skill_name" '.installedPowers += [{"name": $n, "registryId": "local-skills"}]' \
               "$INSTALLED_JSON" > "$tmp" && mv "$tmp" "$INSTALLED_JSON" || true
        fi
    else
        cat > "$INSTALLED_JSON" <<EOF
{
  "version": "1.0.0",
  "installedPowers": [{"name": "$skill_name", "registryId": "local-skills"}],
  "dismissedAutoInstalls": []
}
EOF
    fi
    
    return 0
}

# Main loop: process all skill directories
for skill_dir in "$SKILLS_SRC"/*; do
    [ -d "$skill_dir" ] || continue
    name=$(basename "$skill_dir")
    
    # Skip adapter and non-skill files
    [[ "$name" == "kiro-adapter.sh" ]] && continue
    [[ "$name" == "power-promot.txt" ]] && continue
    
    # Case 1: Single SKILL.md at root
    if [ -f "$skill_dir/SKILL.md" ]; then
        process_skill "$skill_dir" "$name" && ((installed++))
        continue
    fi
    
    # Case 2: Nested skills/ subdirectory
    if [ -d "$skill_dir/skills" ]; then
        echo -e "${BLUE}Processing $name with skills subdirectory...${NC}"
        
        for subskill in "$skill_dir/skills"/*; do
            [ -d "$subskill" ] || continue
            subskill_name=$(basename "$subskill")
            
            [ -f "$subskill/SKILL.md" ] || continue
            
            # Generate power name with parent prefix: parent-child
            power_name="${name}-${subskill_name}"
            
            process_skill "$subskill" "$power_name" && ((installed++))
        done
    fi
done

echo
echo -e "${GREEN}Installed: $installed powers${NC}"
echo

# Update default agent to include all installed powers
echo -e "${BLUE}Updating default agent...${NC}"
default_agent="$HOME/.kiro/agents/default.json"
if [ -f "$default_agent" ]; then
    # Update resources path to match new structure
    sed -i '' 's|"skill://.*"|"skill://~/.kiro/powers/installed/*/steering/skill.md"|g' "$default_agent"
    echo -e "  ${GREEN}✓${NC} Updated $default_agent"
else
    # Create default agent config
    mkdir -p "$HOME/.kiro/agents"
    cat > "$default_agent" <<EOF
{
  "name": "default",
  "description": "Default agent with all tools and imported skills",
  "tools": ["*"],
  "resources": [
    "skill://~/.kiro/powers/installed/*/steering/skill.md"
  ]
}
EOF
    echo -e "  ${GREEN}✓${NC} Created $default_agent"
fi

echo
echo "Powers are in: $INSTALLED_DIR"
echo "Restart Kiro to load the powers"
