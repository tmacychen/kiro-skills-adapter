# --fix 功能改进说明

## 改进时间
2026-03-06

## 改进目标

增强 `--fix` 功能，使其能够：
1. 使用 checksum 比较源目录和目标目录的文件是否一致
2. 同步模板更新到目标目录
3. 智能处理文件同步
4. 检测并提示额外文件

## 新增功能

### 1. Checksum 比较

**目的**: 比较源目录（`templates/steering/`）和目标目录（`~/.kiro/steering/`）的文件是否一致

**实现**:
- 计算源文件的 MD5 checksum
- 计算目标文件的 MD5 checksum
- 比较两者是否相同

**作用**:
- 检测目标文件是否与源模板一致
- 当不一致时，备份旧文件并复制新模板
- 显示源和目标的 checksum 信息

### 2. 同步逻辑

#### 场景 1: 文件与模板一致
```
目标 checksum == 源 checksum
→ 无需操作
→ 显示: ✓ filename is up to date
```

#### 场景 2: 文件与模板不一致
```
目标 checksum != 源 checksum
→ 备份旧文件为 filename.bak
→ 复制新模板
→ 显示: ⟳ Regenerated filename (backup: filename.bak)
→ 显示源和目标的 checksum
```

#### 场景 3: 文件不存在
```
目标文件不存在
→ 从模板创建
→ 显示: ✓ Created filename
```

### 3. 额外文件检测

检测目标目录中不在标准配置中的文件：
- ✅ 列出所有额外文件
- ✅ 提供删除命令建议
- ✅ 不自动删除（需要用户确认）

### 4. 支持的目录和文件

#### Steering 目录 (`~/.kiro/steering/`)

从 `templates/steering/` 同步的文件：
- `product.md` - 产品概述
- `tech.md` - 技术栈
- `structure.md` - 项目结构
- `powers.md` - Powers 系统介绍
- `ai-guidelines.md` - AI 编程规范

自动生成的文件（跳过检查）：
- `tool-preferences.md` - 工具偏好（由脚本自动生成）

#### 其他生成的目录

- `~/.kiro/powers/installed/` - Powers 安装目录（由主循环处理）
- `~/.kiro/agents/default.json` - 默认 agent 配置（自动生成）
- `~/.kiro/hooks/enforce-rg-fd.kiro.hook` - Hook 文件（自动生成）

## 使用示例

### 示例 1: 首次运行 --fix

```bash
$ ./kiro-adapter.sh --fix

Fixing old configuration...
  ✓ Created product.md
  ✓ Created tech.md
  ✓ Created structure.md
  ✓ Created powers.md
  ✓ Created ai-guidelines.md

✓ Created 5 files
```

### 示例 2: 文件与模板不一致

```bash
# 用户修改了 product.md 或模板更新了
$ vim ~/.kiro/steering/product.md

# 运行 --fix
$ ./kiro-adapter.sh --fix

Fixing old configuration...
  ⟳ Regenerated product.md (backup: product.md.bak)
     Source: def456...
     Target: abc123...
  ✓ tech.md is up to date
  ✓ structure.md is up to date
  ✓ powers.md is up to date
  ✓ ai-guidelines.md is up to date

Regenerated 1 files
```

### 示例 3: 检测到额外文件

```bash
$ ./kiro-adapter.sh --fix

Fixing old configuration...
  ✓ product.md is up to date
  ✓ tech.md is up to date
  ✓ structure.md is up to date
  ✓ powers.md is up to date
  ✓ ai-guidelines.md is up to date

⚠ Extra files detected in steering directory:
  • old-config.md
  • deprecated.md

These files are not part of the standard configuration.
If they are not needed, you can remove them:

  rm ~/.kiro/steering/old-config.md
  rm ~/.kiro/steering/deprecated.md
```

## 技术实现

### calculate_file_checksum()

```bash
calculate_file_checksum() {
    local file="$1"
    if [ -f "$file" ]; then
        if command -v md5 &> /dev/null; then
            md5 -q "$file"
        elif command -v md5sum &> /dev/null; then
            md5sum "$file" | awk '{print $1}'
        else
            echo "CHECKSUM_NOT_AVAILABLE"
        fi
    else
        echo "FILE_NOT_FOUND"
    fi
}
```

**特点**:
- 跨平台支持（macOS 的 `md5` 和 Linux 的 `md5sum`）
- 错误处理（文件不存在或命令不可用）

### fix_old_configuration()

主要逻辑：

1. **遍历模板文件**：检查 `templates/steering/` 中的所有 .md 文件
2. **计算 checksum**：计算源文件和目标文件的 MD5
3. **比较并同步**：
   - 如果 checksum 相同 → 显示 "up to date"
   - 如果 checksum 不同 → 备份旧文件，复制新模板
   - 如果文件不存在 → 创建新文件
4. **检测额外文件**：列出不在标准配置中的文件

## 优势

### 1. 简单直接
- ✅ 直接比较源和目标的 checksum
- ✅ 不需要额外的状态文件
- ✅ 逻辑清晰易懂

### 2. 安全保护
- ✅ 自动创建备份文件（.bak）
- ✅ 显示详细的 checksum 信息
- ✅ 不会丢失任何数据

### 3. 透明操作
- ✅ 显示源和目标的 checksum
- ✅ 清晰的状态提示
- ✅ 易于调试和验证

### 4. 易于恢复
- ✅ 备份文件（.bak）可以随时恢复
- ✅ 模板文件始终可用

## 未来改进

### 可选功能

1. **用户修改检测**
   - 使用额外的 checksum 文件追踪用户修改
   - 区分"用户修改"和"模板更新"
   - 提供更智能的合并策略

2. **交互式合并**
   - 检测到冲突时，提示用户选择
   - 提供 diff 视图
   - 支持手动合并

3. **版本历史**
   - 记录每次变更的时间戳
   - 保留多个历史版本
   - 支持回滚到任意版本

4. **配置选项**
   - 允许用户配置哪些文件需要追踪
   - 自定义备份策略
   - 配置同步行为

## 测试建议

### 测试场景

1. **首次运行**
   ```bash
   rm -rf ~/.kiro/steering
   ./kiro-adapter.sh --fix
   # 验证: 所有文件已创建
   ```

2. **文件不一致**
   ```bash
   echo "# Modified" >> ~/.kiro/steering/product.md
   ./kiro-adapter.sh --fix
   # 验证: 文件已更新，旧版本备份为 .bak
   ```

3. **模板更新**
   ```bash
   # 修改模板文件
   echo "# New Section" >> templates/steering/tech.md
   ./kiro-adapter.sh --fix
   # 验证: 文件已更新，旧版本备份为 .bak
   ```

4. **额外文件**
   ```bash
   touch ~/.kiro/steering/extra.md
   ./kiro-adapter.sh --fix
   # 验证: 检测到额外文件并提示
   ```

5. **Orphaned powers 清理**
   ```bash
   # 从源目录删除一个 skill
   rm -rf ~/.kiro/skills/some-skill
   ./kiro-adapter.sh --fix
   # 验证: 对应的 power 被删除
   ```

## 总结

改进后的 `--fix` 功能：
- ✅ 使用 checksum 比较源和目标文件
- ✅ 自动同步模板更新
- ✅ 创建备份文件保护数据
- ✅ 检测并提示额外文件
- ✅ 清理 orphaned powers（不在源目录中的 powers）
- ✅ 提供详细的变更信息

这使得 `--fix` 功能更加可靠、安全、易用。

---

**更新时间**: 2026-03-06  
**版本**: v3.4.0  
**状态**: ✅ 已实现
