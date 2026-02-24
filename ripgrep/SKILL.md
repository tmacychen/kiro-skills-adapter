---
name: ripgrep
description: ripgrep (rg) - A fast line-oriented search tool that recursively searches directories for regex patterns
user-invocable: true
keywords: ["ripgrep", "rg", "grep", "search", "regex", "cli", "command line", "file search", "text search", "gitignore", "recursive search"]
replaces: grepSearch
replaces-description: Text/code content search - 10-20x faster with smart defaults
---

# ripgrep (rg)

`ripgrep` is a line-oriented search tool that recursively searches the current directory for a regex pattern. It respects `.gitignore` rules and automatically skips hidden files/directories and binary files.

**Tool Usage:** Use `execute_bash` to run `rg` commands.

---

## Basic Usage

### Simple Search

```bash
rg PATTERN              # Search for PATTERN in current directory
rg "fn main"            # Search for "fn main"
```

### Search in Specific Directory

```bash
rg PATTERN /path/to/dir # Search in specific directory
rg "error" src/         # Search for "error" in src/ directory
```

### Search Current Directory Only (No Recursion)

```bash
rg -d PATTERN           # Search only in current directory
```

---

## Common Options

### File Type Filtering

| Option | Description |
|--------|-------------|
| `-t, --type <type>` | Search only in files of type (e.g., `py`, `rs`, `js`, `c`, `h`) |
| `-T, --type-not <type>` | Exclude files of type |
| `--type-add <type>:<glob>` | Add a custom file type |

```bash
rg -t py "def "         # Search only in Python files
rg -T js "TODO"         # Exclude JavaScript files
rg -t py "import" --type-add 'pyi:*.pyxi'  # Add custom type
```

### File Name Filtering

| Option | Description |
|--------|-------------|
| `-g, --glob <pattern>` | Include files matching glob pattern |
| `-g !<pattern>` | Exclude files matching glob pattern |

```bash
rg "TODO" -g "*.md"     # Search only in Markdown files
rg "TODO" -g "!test*"   # Exclude files starting with "test"
rg "TODO" -g "src/**/*" # Search in src/ directory
```

### Search Options

| Option | Description |
|--------|-------------|
| `-i, --ignore-case` | Case-insensitive search |
| `-s, --case-sensitive` | Case-sensitive search |
| `-w, --word-regexp` | Match whole words only |
| `-e, --regexp <pattern>` | Use pattern as regex (useful for patterns starting with `-`) |
| `-F, --fixed-strings` | Disable regex, search as literal strings |

```bash
rg -i "error"           # Case-insensitive search
rg -w "fn"              # Match whole words only
rg -e "-pattern"        # Search for pattern starting with dash
rg -F "exact string"    # Literal string search
```

### Output Options

| Option | Description |
|--------|-------------|
| `-n, --line-number` | Show line numbers |
| `-H, --with-filename` | Show filename for each match |
| `--no-heading` | Don't group matches by file |
| `-o, --only-matching` | Show only the matching part |
| `-c, --context <n>` | Show n lines of context around matches |
| `-A, --after-context <n>` | Show n lines after match |
| `-B, --before-context <n>` | Show n lines before match |

```bash
rg "error" -n           # Show line numbers
rg "error" -c 3         # Show 3 lines of context
rg "error" -o           # Show only matching part
rg "error" -A 2 -B 2    # Show 2 lines before and after
```

### Hidden and Binary Files

| Option | Description |
|--------|-------------|
| `-u, --unrestricted` | Disable automatic filtering (search hidden and binary files) |
| `-uu` | Search hidden files |
| `-uuu` | Search everything (including binary files) |

```bash
rg -u "secret"          # Search hidden files
rg -uuu "data"          # Search binary files
```

### Multiline Search

| Option | Description |
|--------|-------------|
| `-U, --multiline` | Allow patterns to match across lines |
| `-P, --pcre2` | Use PCRE2 regex engine (supports look-around, backreferences) |

```bash
rg -U "start.*end"      # Match across lines
rg -P "(?<=before)after"  # Lookbehind (requires PCRE2)
```

---

## Common Examples

### Find TODO Comments

```bash
rg "TODO" -n            # Find all TODO comments
rg "FIXME" -t py -n     # Find FIXME in Python files
```

### Search in Specific File Types

```bash
rg "import" -t py       # Python imports
rg "use " -t rs         # Rust use statements
rg "console.log" -t js  # JavaScript console.log
```

### Exclude Directories

```bash
rg "TODO" --ignore-dir node_modules
rg "TODO" --ignore-dir .git --ignore-dir target
rg "TODO" -g "!node_modules/*" -g "!dist/*"
```

### Count Matches

```bash
rg -c "error"           # Count matches per file
rg -c "TODO" | awk -F: '{sum+=$NF} END {print sum}'  # Total count
```

### JSON Output

```bash
rg "error" --json       # JSON output for parsing
rg "error" --json | jq '.path'  # Extract paths
```

### Use with Other Tools

```bash
# Edit all matches in place
rg "old_text" -r "new_text" --files-with-matches | xargs sed -i '' 's/old_text/new_text/g'

# Open in editor
rg "TODO" --files-with-matches | xargs vim

# Find and replace
rg "foo" -r "bar"       # Replace foo with bar in output
```

---

## Configuration File

ripgrep supports a configuration file at `$HOME/.ripgreprc` or `$HOME/.config/ripgrep/ripgreprc`:

```ini
# ~/.ripgreprc
# Always show line numbers
--line-number

# Always use colors
--color=always

# Set default type filter
--type-add
py:*.py
rs:*.rs
js:*.js

# Ignore common directories
--ignore-dir=node_modules
--ignore-dir=target
--ignore-dir=.git
```

---

## Installation

### macOS

```bash
brew install ripgrep
port install ripgrep
```

### Linux

```bash
# Debian/Ubuntu
apt install ripgrep

# Fedora
dnf install ripgrep

# Arch
pacman -S ripgrep
```

### Windows

```bash
choco install ripgrep
scoop install ripgrep
winget install BurntSushi.ripgrep.MSVC
```

### From Source

```bash
cargo install ripgrep
```

---

## Comparison with grep

| Feature | ripgrep (rg) | grep |
|---------|--------------|------|
| Speed | ~10x faster | Slower |
| Recursive by default | Yes | No (needs -r) |
| Respects .gitignore | Yes | No |
| Colors | Yes | No (needs --color) |
| Unicode support | Yes | Limited |

---

## Notes

1. **Default behavior**: ripgrep automatically ignores files in `.gitignore`, hidden files, and binary files
2. **Use `-u` to disable filtering**: `rg -u` searches everything
3. **Regex is default**: Use `-F` for literal string matching
4. **Smart case**: Case-insensitive by default, switches to case-sensitive if pattern has uppercase
5. **Performance**: ripgrep is significantly faster than grep for most use cases

---

## Output Files

| File | Description |
|------|-------------|
| `SKILL.md` | This documentation |
