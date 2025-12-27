# Lazygit - 终端 Git 管理工具

## 简介

Lazygit 是一个简洁的终端用户界面（TUI）工具，用于简化 Git 操作。它提供了一个直观的交互界面，让您可以在终端中高效地管理 Git 仓库，无需记忆复杂的 Git 命令。

**官方仓库**: https://github.com/jesseduffield/lazygit

## 安装

Lazygit 已通过 Zinit 自动安装和管理。首次使用时，Zinit 会自动从 GitHub Releases 下载并安装。

### 手动安装

如果需要手动安装，可以使用以下方法：

```bash
# macOS (Homebrew)
brew install jesseduffield/lazygit/lazygit

# Linux (从 GitHub Releases)
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/

# Go 安装
go install github.com/jesseduffield/lazygit@latest
```

## 基本使用

### 启动 Lazygit

在 Git 仓库目录下运行：

```bash
lazygit
```

或者使用别名（如果已配置）：

```bash
lg
```

### 界面布局

Lazygit 的界面分为多个面板：

- **文件面板**：显示工作目录中的文件状态
- **分支面板**：显示本地和远程分支
- **提交面板**：显示提交历史
- **暂存区面板**：显示已暂存的文件
- **状态面板**：显示仓库状态信息

使用 `←` / `→` 键在面板之间切换。

## 常用快捷键

### 基本导航

| 快捷键 | 功能 |
|--------|------|
| `←` / `→` | 在面板之间切换 |
| `↑` / `↓` | 在列表中上下移动 |
| `Enter` | 进入/展开选中项 |
| `Esc` | 返回/取消操作 |
| `q` | 退出 Lazygit |
| `?` | 显示帮助（快捷键列表） |

### 文件操作

| 快捷键 | 功能 |
|--------|------|
| `Space` | 暂存/取消暂存文件 |
| `c` | 提交更改 |
| `a` | 修改最后一次提交（amend） |
| `d` | 查看文件差异 |
| `o` | 打开文件（使用系统默认程序） |
| `i` | 忽略文件（添加到 .gitignore） |
| `D` | 删除文件 |
| `r` | 刷新文件列表 |

### 提交操作

| 快捷键 | 功能 |
|--------|------|
| `c` | 创建新提交 |
| `w` | 提交并推送到远程 |
| `p` | 推送到远程仓库 |
| `f` | 从远程拉取（fetch） |
| `P` | 从远程拉取并合并（pull） |
| `R` | 变基（rebase） |

### 分支操作

| 快捷键 | 功能 |
|--------|------|
| `b` | 查看分支列表 |
| `n` | 创建新分支 |
| `m` | 合并分支 |
| `d` | 删除分支 |
| `c` | 检出分支（在分支列表中） |

### 提交历史

| 快捷键 | 功能 |
|--------|------|
| `l` | 查看提交日志 |
| `s` | 压缩提交（squash） |
| `r` | 重置提交（reset） |
| `t` | 创建标签 |
| `d` | 查看提交差异 |

### 其他操作

| 快捷键 | 功能 |
|--------|------|
| `:` | 执行自定义命令 |
| `e` | 编辑文件 |
| `x` | 执行命令 |
| `z` | 撤销/重做操作 |

## 使用示例

### 示例 1: 提交并推送更改

**场景**：修改了文件，需要提交并推送到远程仓库。

**步骤**：

1. 启动 Lazygit：
   ```bash
   lazygit
   ```

2. 在文件面板中，使用 `↑` / `↓` 选择已修改的文件

3. 按 `Space` 暂存文件（文件会移动到暂存区）

4. 按 `c` 创建提交
   - 输入提交消息
   - 按 `Enter` 确认

5. 按 `p` 推送到远程仓库
   - 选择要推送的分支
   - 确认推送

**快捷方式**：也可以使用 `w` 键一次性提交并推送。

### 示例 2: 查看文件差异

**场景**：查看文件修改前后的差异。

**步骤**：

1. 在文件面板中，选择要查看的文件

2. 按 `d` 查看差异
   - 会显示文件的详细差异
   - 使用 `↑` / `↓` 滚动查看

3. 按 `Esc` 返回文件列表

### 示例 3: 创建并切换分支

**场景**：创建新功能分支并切换到该分支。

**步骤**：

1. 按 `b` 打开分支列表

2. 按 `n` 创建新分支
   - 输入分支名称（如 `feature/new-feature`）
   - 按 `Enter` 确认

3. 新分支会自动被检出（切换）

### 示例 4: 合并分支

**场景**：将功能分支合并到主分支。

**步骤**：

1. 切换到目标分支（主分支）：
   - 按 `b` 打开分支列表
   - 选择主分支（如 `main`）
   - 按 `Enter` 检出

2. 按 `m` 合并分支
   - 选择要合并的分支（如 `feature/new-feature`）
   - 确认合并

### 示例 5: 查看提交历史

**场景**：查看仓库的提交历史。

**步骤**：

1. 按 `l` 打开提交日志面板

2. 使用 `↑` / `↓` 浏览提交历史

3. 选择某个提交，按 `Enter` 查看详细信息

4. 按 `d` 查看该提交的差异

### 示例 6: 撤销更改

**场景**：撤销对文件的修改。

**步骤**：

1. 在文件面板中，选择要撤销的文件

2. 按 `z` 打开撤销菜单
   - 选择撤销选项
   - 确认撤销

### 示例 7: 解决冲突

**场景**：合并分支时出现冲突。

**步骤**：

1. 在文件面板中，冲突文件会显示特殊标记

2. 选择冲突文件，按 `Enter` 查看冲突

3. 编辑文件解决冲突（使用外部编辑器）

4. 解决冲突后，按 `Space` 暂存文件

5. 按 `c` 完成合并提交

### 示例 8: 交互式变基

**场景**：整理提交历史。

**步骤**：

1. 按 `l` 打开提交日志

2. 选择要变基的提交

3. 按 `r` 打开重置菜单
   - 选择变基选项（如 `rebase interactive`）
   - 选择要变基到的提交

4. 在交互式变基界面中：
   - `pick`：保留提交
   - `squash`：压缩到上一个提交
   - `edit`：编辑提交
   - `drop`：删除提交

### 示例 9: 暂存部分更改

**场景**：只提交文件的部分更改。

**步骤**：

1. 选择已修改的文件

2. 按 `Enter` 进入文件视图

3. 使用 `Space` 选择要暂存的行或块

4. 按 `c` 创建提交（只包含选中的更改）

### 示例 10: 查看远程仓库状态

**场景**：查看本地与远程的同步状态。

**步骤**：

1. 在分支面板中，查看分支状态：
   - 绿色：已同步
   - 黄色：本地有未推送的提交
   - 红色：远程有未拉取的提交

2. 按 `f` 从远程拉取最新信息

3. 按 `P` 拉取并合并远程更改

## 高级功能

### 自定义命令

Lazygit 支持自定义命令，可以在配置文件中定义：

```yaml
# ~/.config/lazygit/config.yml
customCommands:
  - key: 'C'
    description: 'Checkout branch'
    command: 'git checkout {{.SelectedBranchName}}'
```

### 退出后切换目录

如果需要在退出 Lazygit 后自动切换到 Lazygit 中的当前目录，可以使用以下函数：

```bash
lg()
{
    export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir
    lazygit "$@"
    if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
        cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
        rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
    fi
}
```

添加到 `~/.zshrc` 后，使用 `lg` 命令启动 Lazygit，退出后会自动切换目录。

### Git Flow 支持

Lazygit 支持 Git Flow。在分支视图中按 `i` 可以访问 Git Flow 选项。

## 配置

Lazygit 的配置文件位于：

- Linux/macOS: `~/.config/lazygit/config.yml`
- Windows: `%APPDATA%\lazygit\config.yml`

可以自定义：
- 主题和颜色
- 快捷键绑定
- 自定义命令
- 编辑器设置

## 提示和技巧

1. **快速提交**：使用 `w` 键可以一次性提交并推送

2. **查看帮助**：任何时候按 `?` 可以查看所有快捷键

3. **撤销操作**：按 `z` 可以撤销或重做操作

4. **自定义命令**：使用 `:` 可以执行自定义 Git 命令

5. **文件搜索**：在文件面板中直接输入文件名可以快速搜索

6. **批量操作**：使用 `Space` 可以批量暂存多个文件

7. **提交消息模板**：可以在配置文件中设置提交消息模板

8. **集成编辑器**：配置外部编辑器，按 `e` 可以直接编辑文件

## 故障排除

### 问题 1: 命令未找到

**解决方法**：
- 检查 PATH 中是否包含 lazygit 的安装路径
- 重新加载 shell 配置：`source ~/.zshrc`

### 问题 2: 无法推送到远程

**解决方法**：
- 检查远程仓库配置：`git remote -v`
- 确认有推送权限
- 检查网络连接

### 问题 3: 界面显示异常

**解决方法**：
- 检查终端是否支持 TUI
- 尝试调整终端大小
- 检查配置文件是否有语法错误

## 相关链接

- **官方仓库**: https://github.com/jesseduffield/lazygit
- **官方文档**: https://github.com/jesseduffield/lazygit/tree/master/docs
- **快捷键列表**: https://github.com/jesseduffield/lazygit/blob/master/docs/keybindings
- **配置文档**: https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md

---

**最后更新**: 2025-01-XX

