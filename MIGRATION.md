# Migration Guide

## Migrating from Old Versions

If you've used previous versions of `kiro-adapter.sh`, it's recommended to run the fix command to ensure correct configuration.

## Quick Migration

```bash
# 1. Update code
git pull

# 2. Run fix (optional, recommended)
./kiro-adapter.sh --fix

# 3. Normal usage
./kiro-adapter.sh
```

## --fix Feature Explanation

The `--fix` option will:

1. **Fix Steering Configuration**
   - Compare file content with standard templates
   - Regenerate if inconsistent (creates `.bak` backup)
   - Skip if consistent, no modification
   - Correct `inclusion: auto` → `inclusion: always`

2. **Clean Up Excess Powers**
   - Scan source directory, build expected powers list
   - Compare with installed powers
   - Automatically delete powers not in source directory
   - Clean up checksum records simultaneously

## Verify Migration

### Check File Structure

```bash
# Steering directory
ls ~/.kiro/steering/
# Should see:
# - tool-preferences.md
# - product.md, tech.md, structure.md, powers.md (templates)

# Powers directory
ls ~/.kiro/powers/installed/
# Should see your skills, such as:
# - ripgrep
# - sharkdp-fd
# - rust-skills-*
# - etc.
```

### Check Frontmatter

```bash
# Check Steering files
head -5 ~/.kiro/steering/tool-preferences.md
# Should see:
# ---
# description: "..."
# inclusion: always
# ---
```

## Common Questions

### Q: Will --fix overwrite my custom content?

A: No. `--fix` will compare file content:
- If content is consistent, skip
- If content is different, regenerate and create `.bak` backup
- You can restore custom content from backup files

### Q: Do I need to run --fix?

A: It's recommended to run in the following cases:
- Upgrading from old version
- Suspecting configuration files have been modified
- Wanting to verify configuration correctness
- Finding excess powers

### Q: Is --fix safe?

A: Yes, `--fix` is safe:
- Will create backup files (`.bak`)
- Only deletes powers not in source directory
- Won't affect source files

### Q: How to rollback?

A: If rollback is needed:

```bash
# Restore Steering files
cp ~/.kiro/steering/product.md.bak ~/.kiro/steering/product.md

# Reinstall powers (if accidentally deleted)
./kiro-adapter.sh --force
```

## Command Reference

| Function | Command |
|----------|---------|
| Normal installation | `./kiro-adapter.sh` |
| Fix configuration | `./kiro-adapter.sh --fix` |
| Force reinstall | `./kiro-adapter.sh --force` |
| Detailed output | `./kiro-adapter.sh --verbose` |
| View help | `./kiro-adapter.sh --help` |

## Get Help

If you encounter issues during migration:

1. Check [README.md](./README.md)
2. Check [QUICKSTART.md](./QUICKSTART.md)
3. Check [CHANGELOG.md](./CHANGELOG.md)
4. Submit an Issue

## Related Documentation

- [README.md](./README.md) - Complete documentation
- [QUICKSTART.md](./QUICKSTART.md) - Quick start guide
- [CHANGELOG.md](./CHANGELOG.md) - Changelog
- [PROJECT-STRUCTURE.md](./PROJECT-STRUCTURE.md) - Project structure