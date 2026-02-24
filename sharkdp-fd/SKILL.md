---
name: sharkdp-fd
description: fd - A fast, user-friendly alternative to the find command
user-invocable: true
keywords: ["fd", "find", "file search", "filesystem", "cli", "command line", "regex", "grep", "file management", "directory traversal", "sharkdp"]
---

# fd - Fast File Search Tool

`fd` is a simple, fast, and user-friendly alternative to the `find` command. Written in Rust, it supports regex and glob patterns, with smart case sensitivity, automatic hidden file ignoring, and `.gitignore` support.

**Tool Usage:** Use `execute_bash` to run `fd` commands.

---

## Basic Usage

### Simple Search

```bash
fd PATTERN              # Recursively search for entries containing PATTERN in current directory
fd netfl                # Search for files containing "netfl"
```

### Specify Search Path

```bash
fd PATTERN PATH         # Search in a specific directory
fd passwd /etc          # Search for "passwd" in /etc
```

### Search with No Arguments

```bash
fd                      # List all files in current directory (like ls -R)
fd .                    # List all files in specified directory
```

---

## Common Options

### File Type Filtering

| Option | Description |
|--------|-------------|
| `-t f` or `--type file` | Search only files |
| `-t d` or `--type directory` | Search only directories |
| `-t l` or `--type symlink` | Search only symlinks |
| `-t x` or `--type executable` | Search only executable files |
| `-t e` or `--type empty` | Search only empty files/directories |

```bash
fd -t f .py$            # Search all .py files
fd -t d src             # Search all directories under src
```

### Extension Filtering

```bash
-e, --extension <ext>   # Filter by file extension
fd -e md                # Search all Markdown files
fd -e rs mod            # Search .rs files containing "mod"
```

### Exact Filename Match (Glob)

```bash
-g, --glob              # Use glob patterns instead of regex
fd -g libc.so /usr      # Exact match for "libc.so"
```

### Hidden and Ignored Files

| Option | Description |
|--------|-------------|
| `-H` or `--hidden` | Search hidden files and directories |
| `-I` or `--no-ignore` | Don't respect .gitignore/.fdignore files |
| `-u` or `--unrestricted` | Unrestricted mode (equivalent to -HI) |

```bash
fd -H pre-commit        # Search hidden files (including in .git/)
fd -I num_cpu           # Search files ignored by .gitignore
```

### Full Path Search

```bash
-p, --full-path         # Match full path instead of filename only
fd -p -g '**/.git/config'  # Search for .git/config files
```

### Command Execution

| Option | Description |
|--------|-------------|
| `-x, --exec <cmd>...` | Execute command for each result (parallel) |
| `-X, --exec-batch <cmd>...` | Execute command once with all results |

```bash
fd -e zip -x unzip      # Unzip all zip files
fd -e rs -x wc -l       # Count lines in each .rs file
fd -e py -X vim         # Open all .py files in vim
```

#### Placeholder Syntax

| Placeholder | Description |
|-------------|-------------|
| `{}` | Full path |
| `{.}` | Path without extension |
| `{/}` | Basename |
| `{//}` | Parent directory |
| `{/.}` | Basename without extension |

```bash
fd -e jpg -x convert {} {.}.png  # Convert jpg to png
```

### Other Filtering Options

| Option | Description |
|--------|-------------|
| `-d, --max-depth <depth>` | Set maximum search depth |
| `-E, --exclude <pattern>` | Exclude matching patterns |
| `-S, --size <size>` | Filter by file size |
| `-s, --case-sensitive` | Case-sensitive search |
| `-i, --ignore-case` | Case-insensitive search |
| `-l, --list-details` | Long format listing (ls -l) |

```bash
fd -d 3 src             # Search only 3 levels deep under src
fd -E '*.bak'           # Exclude .bak files
fd -S +10M -S -100M     # Search files between 10MB-100MB
```

---

## Common Examples

### Find and Delete Files

```bash
fd -H '^\.DS_Store$' -tf -X rm  # Delete all .DS_Store files
```

### Find and Execute Commands

```bash
fd -e h -e cpp -x clang-format -i  # Format C/C++ files
fd -e rs -X rg 'std::cout'         # Search in C++ files
```

### List File Details

```bash
fd … -X ls -lhd --color=always   # Show detailed file info
fd … -l                          # Shorthand
```

### Use with fzf

```bash
export FZF_DEFAULT_COMMAND='fd --type file'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
```

---

## Comparison with find

| Feature | find | fd |
|---------|------|----|
| Syntax | `find -iname '*pattern*'` | `fd pattern` |
| Speed | Slower | 10-20x faster |
| Ignores hidden files by default | No | Yes |
| Ignores .gitignore by default | No | Yes |
| Smart case sensitivity | No | Yes |
| Color output | No | Yes |

---

## Installation

### macOS

```bash
brew install fd
port install fd
```

### Linux

```bash
# Ubuntu/Debian
apt install fd-find

# Fedora
dnf install fd-find

# Arch Linux
pacman -S fd
```

### Windows

```bash
scoop install fd
choco install fd
winget install sharkdp.fd
```

---

## Notes

1. **Regex is the default mode**: Use `-g` for glob patterns
2. **Hidden files are ignored by default**: Use `-H` or `-u` to enable
3. **.gitignore is respected by default**: Use `-I` or `-u` to disable
4. **Command execution arguments**: `-x` must come last; subsequent args pass to the command
5. **Placeholders with special characters**: Wrap in quotes

---

## Output Files

| File | Description |
|------|-------------|
| `SKILL.md` | This documentation |
