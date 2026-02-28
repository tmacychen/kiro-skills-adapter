#!/bin/bash
# Kiro Skills Adapter
# Converts skills from current directory or ~/.kiro/skills to Kiro powers format in ~/.kiro/powers/installed/
# Supports both single SKILL.md and nested skills/ subdirectory structures
# Features: Differential updates, skip unchanged files, force reinstall option

# Use current directory if it contains SKILL.md files, otherwise use ~/.kiro/skills
CURRENT_DIR="$(pwd)"
SKILLS_SRC="$HOME/.kiro/skills"

# Check if current directory has any SKILL.md files
if find "$CURRENT_DIR" -maxdepth 3 -name "SKILL.md" -type f 2>/dev/null | grep -q .; then
    SKILLS_SRC="$CURRENT_DIR"
fi

POWERS_DIR="$HOME/.kiro/powers"
INSTALLED_DIR="$POWERS_DIR/installed"
INSTALLED_JSON="$POWERS_DIR/installed.json"
REGISTRY_JSON="$POWERS_DIR/registry.json"
CHECKSUM_FILE="$POWERS_DIR/.checksums"

# Parse command line arguments
FORCE_REINSTALL=false
VERBOSE=false
FIX_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE_REINSTALL=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --fix)
            FIX_MODE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -f, --force     Force reinstall all skills (ignore checksums)"
            echo "  -v, --verbose   Show detailed output"
            echo "  --fix           Fix old configuration (migrate from old versions)"
            echo "  -h, --help      Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m'

echo -e "${BLUE}=== Kiro Skills Adapter ===${NC}"
echo "Source: $SKILLS_SRC"
echo "Target: $POWERS_DIR"
[ "$FORCE_REINSTALL" = true ] && echo -e "${YELLOW}Mode: Force reinstall${NC}"
[ "$VERBOSE" = true ] && echo -e "${GRAY}Verbose mode enabled${NC}"
[ "$FIX_MODE" = true ] && echo -e "${YELLOW}Mode: Fix old configuration${NC}"
echo

mkdir -p "$POWERS_DIR" "$INSTALLED_DIR"

# Function to fix old configuration
fix_old_configuration() {
    local steering_dir="$HOME/.kiro/steering"
    local fixed_count=0
    local regenerated_count=0
    
    echo -e "${BLUE}Fixing old configuration...${NC}"
    
    # Function to generate template content
    generate_template_content() {
        local template_type="$1"
        case "$template_type" in
            "product")
                cat <<'EOF'
---
description: "Product overview - purpose, target users, key features, and business goals"
inclusion: always
---

# Product Overview

## Purpose

[Describe what your product does and why it exists]

## Target Users

[Who is this product for?]

## Key Features

[List the main features and capabilities]

## Business Goals

[What are the business objectives?]

## Technical Constraints

[Any important technical limitations or requirements]
EOF
                ;;
            "tech")
                cat <<'EOF'
---
description: "Tech stack - frameworks, libraries, development tools, and technical constraints"
inclusion: always
---

# Tech Stack

## Frameworks

[List main frameworks used]

## Libraries

[Key libraries and dependencies]

## Development Tools

[Tools used for development]

## Technical Constraints

[Any technical limitations or requirements]

## Preferred Patterns

[Coding patterns and architectural decisions]
EOF
                ;;
            "structure")
                cat <<'EOF'
---
description: "Project structure - file organization, naming conventions, import patterns, and architectural decisions"
inclusion: always
---

# Project Structure

## File Organization

[Describe how files are organized]

## Naming Conventions

[File and directory naming rules]

## Import Patterns

[How imports should be structured]

## Architectural Decisions

[Key architectural choices and patterns]

## Module Structure

[How modules are organized]
EOF
                ;;
        esac
    }
    
    # Check if file is expected
    is_expected_file() {
        local filename="$1"
        case "$filename" in
            "product.md"|"tech.md"|"structure.md"|"tool-preferences.md")
                return 0
                ;;
            *)
                return 1
                ;;
        esac
    }
    
    # Check and fix expected files
    for filename in "product.md" "tech.md" "structure.md"; do
        local filepath="$steering_dir/$filename"
        local template_type="${filename%.md}"
        
        if [ -f "$filepath" ]; then
            # File exists, compare content
            local expected_content=$(generate_template_content "$template_type")
            local actual_content=$(cat "$filepath")
            
            if [ "$expected_content" != "$actual_content" ]; then
                # Content differs, backup and regenerate
                cp "$filepath" "$filepath.bak"
                echo "$expected_content" > "$filepath"
                echo -e "  ${YELLOW}⟳${NC} Regenerated $filename (backup: $filename.bak)"
                ((regenerated_count++))
            else
                echo -e "  ${GREEN}✓${NC} $filename is up to date"
            fi
        else
            # File doesn't exist, create it
            mkdir -p "$steering_dir"
            local content=$(generate_template_content "$template_type")
            echo "$content" > "$filepath"
            echo -e "  ${GREEN}✓${NC} Created $filename"
            ((fixed_count++))
        fi
    done
    
    # Check for extra files
    local extra_files=""
    if [ -d "$steering_dir" ]; then
        for file in "$steering_dir"/*.md; do
            [ -f "$file" ] || continue
            local basename=$(basename "$file")
            
            # Skip backup files
            [[ "$basename" == *.bak ]] && continue
            
            # Check if this is an expected file
            if ! is_expected_file "$basename"; then
                extra_files="$extra_files$basename "
            fi
        done
    fi
    
    # Fix inclusion modes in existing files
    if [ -d "$steering_dir" ]; then
        for file in "$steering_dir"/*.md; do
            [ -f "$file" ] || continue
            if grep -q "inclusion: auto" "$file"; then
                sed -i '' 's/inclusion: auto/inclusion: always/g' "$file"
                echo -e "  ${GREEN}✓${NC} Fixed inclusion mode in $(basename "$file")"
                ((fixed_count++))
            fi
        done
    fi
    
    # Report results
    echo
    if [ $fixed_count -eq 0 ] && [ $regenerated_count -eq 0 ] && [ -z "$extra_files" ]; then
        echo -e "${GREEN}✓ Configuration is up to date${NC}"
    else
        [ $fixed_count -gt 0 ] && echo -e "${GREEN}Created $fixed_count files${NC}"
        [ $regenerated_count -gt 0 ] && echo -e "${YELLOW}Regenerated $regenerated_count files${NC}"
        
        if [ -n "$extra_files" ]; then
            echo
            echo -e "${YELLOW}⚠ Extra files detected in steering directory:${NC}"
            for extra_file in $extra_files; do
                echo -e "  ${YELLOW}•${NC} $extra_file"
            done
            echo
            echo -e "${YELLOW}These files are not part of the standard configuration.${NC}"
            echo -e "${YELLOW}If they are not needed, you can remove them:${NC}"
            echo
            for extra_file in $extra_files; do
                echo -e "  rm ~/.kiro/steering/$extra_file"
            done
            echo
        fi
    fi
    echo
}

# Function to initialize steering template files (always run, skip existing)
initialize_steering_templates() {
    local steering_dir="$HOME/.kiro/steering"
    mkdir -p "$steering_dir"
    
    local created_count=0
    local skipped_count=0
    
    [ "$VERBOSE" = true ] && echo -e "${BLUE}Initializing steering templates...${NC}"
    
    # Create product.md if it doesn't exist
    if [ ! -f "$steering_dir/product.md" ]; then
        cat > "$steering_dir/product.md" <<'EOF'
---
description: "Product overview - purpose, target users, key features, and business goals"
inclusion: always
---

# Product Overview

## Purpose

[Describe what your product does and why it exists]

## Target Users

[Who is this product for?]

## Key Features

[List the main features and capabilities]

## Business Goals

[What are the business objectives?]

## Technical Constraints

[Any important technical limitations or requirements]
EOF
        [ "$VERBOSE" = true ] && echo -e "  ${GREEN}✓${NC} Created product.md"
        ((created_count++))
    else
        ((skipped_count++))
    fi
    
    # Create tech.md if it doesn't exist
    if [ ! -f "$steering_dir/tech.md" ]; then
        cat > "$steering_dir/tech.md" <<'EOF'
---
description: "Tech stack - frameworks, libraries, development tools, and technical constraints"
inclusion: always
---

# Tech Stack

## Frameworks

[List main frameworks used]

## Libraries

[Key libraries and dependencies]

## Development Tools

[Tools used for development]

## Technical Constraints

[Any technical limitations or requirements]

## Preferred Patterns

[Coding patterns and architectural decisions]
EOF
        [ "$VERBOSE" = true ] && echo -e "  ${GREEN}✓${NC} Created tech.md"
        ((created_count++))
    else
        ((skipped_count++))
    fi
    
    # Create structure.md if it doesn't exist
    if [ ! -f "$steering_dir/structure.md" ]; then
        cat > "$steering_dir/structure.md" <<'EOF'
---
description: "Project structure - file organization, naming conventions, import patterns, and architectural decisions"
inclusion: always
---

# Project Structure

## File Organization

[Describe how files are organized]

## Naming Conventions

[File and directory naming rules]

## Import Patterns

[How imports should be structured]

## Architectural Decisions

[Key architectural choices and patterns]

## Module Structure

[How modules are organized]
EOF
        [ "$VERBOSE" = true ] && echo -e "  ${GREEN}✓${NC} Created structure.md"
        ((created_count++))
    else
        ((skipped_count++))
    fi
    
    if [ $created_count -gt 0 ]; then
        echo -e "${GREEN}Created $created_count steering templates${NC}"
    fi
    
    [ "$VERBOSE" = true ] && [ $skipped_count -gt 0 ] && echo -e "${GRAY}Skipped $skipped_count existing files${NC}"
}

# If --fix flag is set, run fix and then continue with normal installation
if [ "$FIX_MODE" = true ]; then
    fix_old_configuration
fi

# Always initialize steering templates (skip existing files)
initialize_steering_templates

# Initialize checksum file if it doesn't exist
[ -f "$CHECKSUM_FILE" ] || touch "$CHECKSUM_FILE"

# Clean up old symlinks from previous migration
if [ "$FORCE_REINSTALL" = true ]; then
    echo -e "${BLUE}Cleaning up old symlinks...${NC}"
    for link in "$POWERS_DIR"/*; do
        if [ -L "$link" ]; then
            rm -f "$link"
            echo -e "  ${GREEN}✓${NC} Removed $(basename "$link")"
        fi
    done
    # Clear checksum file on force reinstall
    > "$CHECKSUM_FILE"
    echo -e "${YELLOW}Cleared checksums for force reinstall${NC}"
fi

installed=0
updated=0
skipped=0

# Calculate checksum for a skill directory
# Returns MD5 hash of SKILL.md and tool-preferences.md (if exists)
calculate_skill_checksum() {
    local skill_dir="$1"
    local checksum=""
    
    if [ -f "$skill_dir/SKILL.md" ]; then
        if command -v md5sum &> /dev/null; then
            checksum=$(md5sum "$skill_dir/SKILL.md" | awk '{print $1}')
        elif command -v md5 &> /dev/null; then
            checksum=$(md5 -q "$skill_dir/SKILL.md")
        fi
    fi
    
    # Include tool-preferences.md in checksum if it exists
    if [ -f "$skill_dir/tool-preferences.md" ]; then
        if command -v md5sum &> /dev/null; then
            local tp_checksum=$(md5sum "$skill_dir/tool-preferences.md" | awk '{print $1}')
        elif command -v md5 &> /dev/null; then
            local tp_checksum=$(md5 -q "$skill_dir/tool-preferences.md")
        fi
        checksum="${checksum}:${tp_checksum}"
    fi
    
    echo "$checksum"
}

# Check if skill needs update by comparing checksums
needs_update() {
    local skill_name="$1"
    local new_checksum="$2"
    
    [ "$FORCE_REINSTALL" = true ] && return 0
    
    local old_checksum=$(grep "^$skill_name:" "$CHECKSUM_FILE" 2>/dev/null | cut -d: -f2-)
    
    if [ -z "$old_checksum" ]; then
        [ "$VERBOSE" = true ] && echo -e "  ${GRAY}New skill detected${NC}"
        return 0
    fi
    
    if [ "$old_checksum" != "$new_checksum" ]; then
        [ "$VERBOSE" = true ] && echo -e "  ${GRAY}Checksum changed${NC}"
        return 0
    fi
    
    return 1
}

# Update checksum record
update_checksum() {
    local skill_name="$1"
    local checksum="$2"
    
    # Remove old entry if exists
    grep -v "^$skill_name:" "$CHECKSUM_FILE" > "$CHECKSUM_FILE.tmp" 2>/dev/null || true
    mv "$CHECKSUM_FILE.tmp" "$CHECKSUM_FILE"
    
    # Add new entry
    echo "$skill_name:$checksum" >> "$CHECKSUM_FILE"
}

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

# Copy tool-preferences.md if it exists in the skill directory
copy_tool_preferences() {
    local skill_dir="$1"
    local skill_name="$2"
    local steering_dir="$INSTALLED_DIR/$skill_name/steering"

    if [ -f "$skill_dir/tool-preferences.md" ]; then
        cp "$skill_dir/tool-preferences.md" "$steering_dir/tool-preferences.md"
        echo -e "  ${GREEN}✓${NC} Copied tool-preferences.md"
        return 0
    fi
    return 1
}

# Copy tool-preferences.md to global ~/.kiro/steering/ directory
copy_tool_preferences_to_global() {
    local skill_name="$1"
    local steering_dir="$INSTALLED_DIR/$skill_name/steering"
    local global_steering_dir="$HOME/.kiro/steering"

    if [ -f "$steering_dir/tool-preferences.md" ]; then
        mkdir -p "$global_steering_dir"
        cp "$steering_dir/tool-preferences.md" "$global_steering_dir/${skill_name}-tool-preferences.md"
        echo -e "  ${GREEN}✓${NC} Copied tool-preferences.md to global steering"
        return 0
    fi
    return 1
}

# Generate tool-preferences.md from SKILL.md frontmatter if 'replaces' field exists
generate_tool_preferences() {
    local skill_dir="$1"
    local skill_name="$2"
    local steering_dir="$INSTALLED_DIR/$skill_name/steering"
    
    local skill_file="$skill_dir/SKILL.md"
    [ -f "$skill_file" ] || return 1
    
    local frontmatter=$(extract_frontmatter "$skill_file")
    local replaces=$(echo "$frontmatter" | grep "^replaces:" | sed 's/replaces: *//' | tr -d '"')
    local replaces_desc=$(echo "$frontmatter" | grep "^replaces-description:" | sed 's/replaces-description: *//' | tr -d '"')
    local name=$(echo "$frontmatter" | grep "^name:" | sed 's/name: *//' | tr -d '"')
    local desc=$(echo "$frontmatter" | grep "^description:" | sed 's/description: *//' | tr -d '"')
    
    # Only generate if replaces field exists
    [ -z "$replaces" ] && return 1
    [ -z "$name" ] && name="$skill_name"
    [ -z "$desc" ] && desc="A tool for $skill_name"
    [ -z "$replaces_desc" ] && replaces_desc="Replaces built-in $replaces tool"
    
    # Determine tool command based on skill name
    local tool_cmd="$name"
    case "$name" in
        ripgrep) tool_cmd="rg" ;;
        sharkdp-fd) tool_cmd="fd" ;;
    esac
    
    # Generate tool-preferences.md
    cat > "$steering_dir/tool-preferences.md" <<EOF
---
description: "Tool usage preferences for $name - replaces $replaces"
inclusion: auto
---

# Tool Usage Preferences

This file was automatically generated from SKILL.md frontmatter.

## $name Tool Preference

**ALWAYS prefer \`$tool_cmd\` over built-in \`$replaces\` tool.**

$replaces_desc

When using this tool:
- Use \`$tool_cmd\` command via \`executeBash\` tool
- Leverage the tool's performance and features
- Refer to the skill documentation for detailed usage patterns

**Only use \`$replaces\` when:**
- \`$tool_cmd\` is not available or fails
- You need IDE-specific structured output for further processing

## Rationale

$desc

This tool provides:
- Better performance than built-in alternatives
- Smart defaults (respects .gitignore, skips binary files)
- Rich feature set with intuitive syntax
- Colored output for better readability

## Usage

For detailed usage examples and options, refer to the skill documentation in \`skill.md\`.

EOF
    
    echo -e "  ${GREEN}✓${NC} Generated tool-preferences.md from SKILL.md"
    return 0
}

# Process a single skill directory and register it
process_skill() {
    local skill_dir="$1"
    local skill_name="$2"
    
    # Calculate checksum
    local checksum=$(calculate_skill_checksum "$skill_dir")
    
    # Check if update is needed
    if ! needs_update "$skill_name" "$checksum"; then
        echo -e "${GRAY}$skill_name${NC} ${GREEN}✓${NC} Up to date"
        ((skipped++))
        return 0
    fi
    
    # Determine if this is new or update
    local is_new=false
    [ ! -d "$INSTALLED_DIR/$skill_name" ] && is_new=true
    
    if [ "$is_new" = true ]; then
        echo -e "${YELLOW}$skill_name${NC} ${BLUE}[NEW]${NC}"
    else
        echo -e "${YELLOW}$skill_name${NC} ${BLUE}[UPDATE]${NC}"
    fi
    
    local power_dir="$INSTALLED_DIR/$skill_name"
    rm -rf "$power_dir"
    mkdir -p "$power_dir"
    
    # Generate POWER.md
    if generate_power_md "$skill_dir" "$skill_name"; then
        [ "$VERBOSE" = true ] && echo -e "  ${GREEN}✓${NC} Generated POWER.md"
    else
        echo -e "  ${RED}✗${NC} Failed to generate POWER.md"
        return 1
    fi
    
    # Create steering
    create_steering "$skill_dir" "$skill_name"
    [ "$VERBOSE" = true ] && echo -e "  ${GREEN}✓${NC} Created steering"
    
    # Copy or generate tool-preferences
    # Priority: 1. Copy existing file, 2. Generate from SKILL.md frontmatter
    if ! copy_tool_preferences "$skill_dir" "$skill_name"; then
        generate_tool_preferences "$skill_dir" "$skill_name"
    fi
    
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
    
    # Update checksum
    update_checksum "$skill_name" "$checksum"
    
    if [ "$is_new" = true ]; then
        ((installed++))
    else
        ((updated++))
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
echo -e "${GREEN}New: $installed | Updated: $updated | Skipped: $skipped${NC}"
echo -e "${BLUE}Total processed: $((installed + updated + skipped))${NC}"
echo

# Generate global tool preferences and skills index
echo -e "${BLUE}Generating tool preferences and skills index...${NC}"
global_steering_dir="$HOME/.kiro/steering"
mkdir -p "$global_steering_dir"
tool_preferences="$global_steering_dir/tool-preferences.md"

# Create skills-index power
skills_index_dir="$INSTALLED_DIR/skills-index"
mkdir -p "$skills_index_dir/steering"

# Generate POWER.md for skills-index
cat > "$skills_index_dir/POWER.md" <<'EOF'
---
name: "skills-index"
displayName: "Skills Index"
description: "Index of all installed skills with their references and templates. Use when discovering available skills, finding reference documentation, or locating template files."
keywords: ["skills", "index", "references", "templates", "documentation", "discover", "what skills", "available skills"]
---

# Skills Index

This power provides a comprehensive index of all installed skills and their resources.

## Overview

The Skills Index helps you discover and utilize all available skills in your Kiro environment.

## Usage

Ask Kiro about:
- "What skills are available?"
- "Show me skills with references"
- "Which skills have templates?"
- "Find documentation for [skill-name]"
- "List all Rust skills"
- "What agent-browser references exist?"

## Features

- Complete list of installed skills
- Reference documentation index
- Template file locations
- Resource discovery
- Skill categorization

## Source

This index is automatically generated by kiro-adapter.sh and updated whenever skills are installed or modified.
EOF

# Generate tool preferences summary (in steering)
cat > "$tool_preferences" <<'HEADER'
---
description: "Tool usage preferences for the project - defines which tools to prefer for common operations"
inclusion: always
---

# Tool Preferences Summary

This file is automatically generated by kiro-adapter.sh.
Last updated: TIMESTAMP

## Overview

This document defines which tools to prefer for common operations in this project.

## Tool Replacements

The following custom tools are available as replacements for built-in Kiro tools:

HEADER

# Replace timestamp
sed -i '' "s/TIMESTAMP/$(date '+%Y-%m-%d %H:%M:%S')/" "$tool_preferences"

# Collect tool information from all installed skills
tool_count=0
for power_dir in "$INSTALLED_DIR"/*; do
    [ -d "$power_dir" ] || continue
    skill_name=$(basename "$power_dir")
    steering_dir="$power_dir/steering"
    
    # Check if tool-preferences exists
    if [ -f "$steering_dir/tool-preferences.md" ]; then
        # Extract information from tool-preferences
        local_tp="$steering_dir/tool-preferences.md"
        
        # Extract description from frontmatter
        desc=$(sed -n '2,/^---$/p' "$local_tp" | grep "^description:" | sed 's/description: *//' | tr -d '"')
        
        # Try to extract tool command and replaces info
        tool_cmd=$(grep -o '`[a-z0-9-]*`' "$local_tp" | head -1 | tr -d '`')
        replaces=$(echo "$desc" | grep -o "replaces [a-zA-Z]*" | sed 's/replaces //')
        
        if [ -n "$tool_cmd" ] && [ -n "$replaces" ]; then
            ((tool_count++))
            cat >> "$tool_preferences" <<EOF

### $tool_count. $skill_name

- **Tool Command**: \`$tool_cmd\`
- **Replaces**: \`$replaces\`
- **Description**: $desc
- **Skill Location**: \`~/.kiro/powers/installed/${skill_name}/steering/tool-preferences.md\`

EOF
        fi
    fi
done

# Add usage section to tool preferences
cat >> "$tool_preferences" <<'FOOTER'

## Usage Guidelines

### Priority Order

When multiple tools are available for the same task, Kiro will prefer:

1. **Custom tools** (defined in this file)
2. **Built-in tools** (fallback when custom tools fail)

### Best Practices

- Always check tool availability before use
- Use \`executeBash\` to invoke custom command-line tools
- Refer to individual skill documentation for detailed usage
- Fall back to built-in tools only when custom tools are unavailable

## Tool Configuration

All tool configurations are defined in this file. Individual skills may have additional tool-specific documentation in their respective directories:

\`~/.kiro/powers/installed/[skill-name]/steering/tool-preferences.md\`

## Updating Tools

To update tool preferences:

\`\`\`bash
# Run the adapter script
./kiro-adapter.sh

# Force reinstall all tools
./kiro-adapter.sh --force
\`\`\`

## See Also

- Skills index: \`~/.kiro/powers/installed/skills-index/steering/skill.md\`
- Individual skill documentation: \`~/.kiro/powers/installed/*/steering/skill.md\`
- [Kiro Documentation](https://kiro.ai/docs)

---

*This file is automatically regenerated each time kiro-adapter.sh runs.*
FOOTER

if [ $tool_count -gt 0 ]; then
    echo -e "  ${GREEN}✓${NC} Generated tool preferences with $tool_count tools"
else
    echo -e "  ${YELLOW}⚠${NC} No tool preferences found"
fi

# Generate skills index (in skills-index power)
cat > "$skills_index_dir/steering/skill.md" <<'HEADER'
---
name: "skills-index"
description: "Comprehensive index of all installed skills with their references and templates. Use when you need to discover available skills, find reference documentation, or locate template files."
keywords: ["skills", "index", "references", "templates", "documentation", "discover"]
---

# Installed Skills Index

This file is automatically generated by kiro-adapter.sh.
Last updated: TIMESTAMP

## Overview

This document provides a comprehensive index of all installed skills, including their references and templates.

## Installed Skills

HEADER

# Replace timestamp
sed -i '' "s/TIMESTAMP/$(date '+%Y-%m-%d %H:%M:%S')/" "$skills_index_dir/steering/skill.md"

# Collect skill information
skill_count=0
for power_dir in "$INSTALLED_DIR"/*; do
    [ -d "$power_dir" ] || continue
    skill_name=$(basename "$power_dir")
    steering_dir="$power_dir/steering"
    skill_file="$steering_dir/skill.md"
    
    [ -f "$skill_file" ] || continue
    
    ((skill_count++))
    
    # Extract description from SKILL.md frontmatter
    desc=$(sed -n '2,/^---$/p' "$skill_file" 2>/dev/null | grep "^description:" | sed 's/description: *//' | tr -d '"')
    [ -z "$desc" ] && desc="No description available"
    
    # Check for references and templates in the original skill directory
    # Find the original skill directory by searching in SKILLS_SRC
    original_skill_dir=""
    for src_dir in "$SKILLS_SRC"/*; do
        [ -d "$src_dir" ] || continue
        src_name=$(basename "$src_dir")
        
        # Check direct match
        if [ -f "$src_dir/SKILL.md" ] && [ "$src_name" = "$skill_name" ]; then
            original_skill_dir="$src_dir"
            break
        fi
        
        # Check nested skills
        if [ -d "$src_dir/skills" ]; then
            for subskill in "$src_dir/skills"/*; do
                [ -d "$subskill" ] || continue
                subskill_name=$(basename "$subskill")
                power_name="${src_name}-${subskill_name}"
                if [ "$power_name" = "$skill_name" ]; then
                    original_skill_dir="$subskill"
                    break 2
                fi
            done
        fi
    done
    
    # Count references and templates
    ref_count=0
    template_count=0
    has_resources=false
    
    if [ -n "$original_skill_dir" ]; then
        if [ -d "$original_skill_dir/references" ]; then
            ref_count=$(find "$original_skill_dir/references" -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
            [ $ref_count -gt 0 ] && has_resources=true
        fi
        
        if [ -d "$original_skill_dir/templates" ]; then
            template_count=$(find "$original_skill_dir/templates" -type f 2>/dev/null | wc -l | tr -d ' ')
            [ $template_count -gt 0 ] && has_resources=true
        fi
    fi
    
    # Write skill entry
    cat >> "$skills_index_dir/steering/skill.md" <<EOF

### $skill_count. $skill_name

- **Description**: $desc
- **Skill File**: \`~/.kiro/powers/installed/$skill_name/steering/skill.md\`
EOF
    
    if [ $ref_count -gt 0 ]; then
        cat >> "$skills_index_dir/steering/skill.md" <<EOF
- **References**: $ref_count files in \`$original_skill_dir/references/\`
EOF
    fi
    
    if [ $template_count -gt 0 ]; then
        cat >> "$skills_index_dir/steering/skill.md" <<EOF
- **Templates**: $template_count files in \`$original_skill_dir/templates/\`
EOF
    fi
    
    # List reference files if they exist
    if [ $ref_count -gt 0 ]; then
        cat >> "$skills_index_dir/steering/skill.md" <<EOF

  **Reference Files:**
EOF
        find "$original_skill_dir/references" -type f -name "*.md" 2>/dev/null | while read ref_file; do
            ref_name=$(basename "$ref_file")
            cat >> "$skills_index_dir/steering/skill.md" <<EOF
  - \`$ref_name\`
EOF
        done
    fi
    
    # List template files if they exist
    if [ $template_count -gt 0 ]; then
        cat >> "$skills_index_dir/steering/skill.md" <<EOF

  **Template Files:**
EOF
        find "$original_skill_dir/templates" -type f 2>/dev/null | while read tmpl_file; do
            tmpl_name=$(basename "$tmpl_file")
            cat >> "$skills_index_dir/steering/skill.md" <<EOF
  - \`$tmpl_name\`
EOF
        done
    fi
    
    echo >> "$skills_index_dir/steering/skill.md"
done

# Add usage section to skills index
cat >> "$skills_index_dir/steering/skill.md" <<'FOOTER'

## Usage Guidelines

### Accessing Skill Resources

All skills are available through Kiro's power system:

1. **Skill Documentation**: Located in `~/.kiro/powers/installed/*/steering/skill.md`
2. **Reference Files**: Available in the original skill directories
3. **Template Files**: Can be copied from the original skill directories

### Using References

When a skill includes reference files, you can:

```bash
# View available references for a skill
ls ~/.kiro/skills/skill-name/references/

# Read a specific reference
cat ~/.kiro/skills/skill-name/references/reference-name.md
```

### Using Templates

When a skill includes templates, you can:

```bash
# List available templates
ls ~/.kiro/skills/skill-name/templates/

# Copy a template to your project
cp ~/.kiro/skills/skill-name/templates/template-name.md ./
```

## Skill Categories

Skills are organized by their functionality:

- **Tool Skills**: Provide command-line tool integrations (ripgrep, fd, etc.)
- **Domain Skills**: Provide domain-specific knowledge (rust-skills-*, etc.)
- **Utility Skills**: Provide utility functions (agent-browser, dogfood, etc.)

## Updating Skills

To update skills and regenerate this summary:

```bash
# Run the adapter script
./kiro-adapter.sh

# Force reinstall all skills
./kiro-adapter.sh --force
```

## See Also

- Tool preferences: `~/.kiro/steering/tool-preferences.md`
- Individual skill files: `~/.kiro/powers/installed/*/steering/skill.md`
- [Kiro Powers Documentation](https://kiro.ai/docs/powers)

---

*This file is automatically regenerated each time kiro-adapter.sh runs.*
FOOTER

echo -e "  ${GREEN}✓${NC} Generated skills index with $skill_count skills"

# Register skills-index in registry
if [ -f "$REGISTRY_JSON" ]; then
    tmp=$(mktemp)
    jq --arg n "skills-index" \
       --arg d "Index of all installed skills with their references and templates" \
       '.powers[$n] = {
           "name": $n,
           "description": $d,
           "author": "System",
           "license": "MIT",
           "keywords": ["skills", "index", "references", "templates"],
           "displayName": "Skills Index",
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
    if ! grep -q "skills-index" "$INSTALLED_JSON"; then
        tmp=$(mktemp)
        jq '.installedPowers += [{"name": "skills-index", "registryId": "local-skills"}]' \
           "$INSTALLED_JSON" > "$tmp" && mv "$tmp" "$INSTALLED_JSON" || true
    fi
else
    cat > "$INSTALLED_JSON" <<EOF
{
  "version": "1.0.0",
  "installedPowers": [{"name": "skills-index", "registryId": "local-skills"}],
  "dismissedAutoInstalls": []
}
EOF
fi

# Update default agent to include all installed powers
echo -e "${BLUE}Updating default agent...${NC}"
default_agent="$HOME/.kiro/agents/default.json"
if [ -f "$default_agent" ]; then
    # Update resources path to match new structure
    sed -i '' 's|"skill://.*"|"skill://~/.kiro/powers/installed/*/steering/skill.md"|g' "$default_agent"
    # Also add tool-preferences to resources if not already present
    if ! grep -q "tool-preferences" "$default_agent"; then
        tmp=$(mktemp)
        jq '.resources += ["steering://~/.kiro/steering/*-tool-preferences.md"]' "$default_agent" > "$tmp" && mv "$tmp" "$default_agent"
    fi
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
    "skill://~/.kiro/powers/installed/*/steering/skill.md",
    "steering://~/.kiro/steering/*-tool-preferences.md"
  ]
}
EOF
    echo -e "  ${GREEN}✓${NC} Created $default_agent"
fi

echo
echo "Powers are in: $INSTALLED_DIR"
echo "Restart Kiro to load the powers"
