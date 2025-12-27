# Yazi 插件配置

## 简介

本目录包含 Yazi 文件管理器的相关配置和工具脚本。

## 文件说明

### `update_flavors.sh` - 主题更新脚本

从 [yazi-rs/flavors](https://github.com/yazi-rs/flavors) 仓库克隆/更新所有主题到 `~/.dotfiles/config/yazi/flavors` 目录。

**功能：**
- 自动从 GitHub 克隆 flavors 仓库
- 检测并更新已存在的主题
- 安装新的主题
- 显示详细的更新统计信息

**使用方法：**

```bash
# 直接运行脚本
~/.dotfiles/plugins/yazi/update_flavors.sh

# 或者添加别名后使用
alias yazi:update-flavors='~/.dotfiles/plugins/yazi/update_flavors.sh'
yazi:update-flavors
```

**工作原理：**

1. 克隆 yazi-rs/flavors 仓库到临时目录（使用 `--depth 1` 仅克隆最新版本）
2. 查找所有 `.yazi` 格式的主题目录
3. 将每个主题目录复制到 `~/.dotfiles/config/yazi/flavors/`
4. 安装额外的主题仓库（如 kanagawa、flexoki-dark、synthwave84 等）
5. 如果主题已存在，先删除再复制（更新）
6. 自动清理临时文件
7. 显示更新统计信息

**额外主题支持：**

脚本支持从独立的 GitHub 仓库安装主题。当前已配置的额外主题：

- `kanagawa.yazi` - [dangooddd/kanagawa.yazi](https://github.com/dangooddd/kanagawa.yazi)
- `flexoki-dark.yazi` - [gosxrgxx/flexoki-dark.yazi](https://github.com/gosxrgxx/flexoki-dark.yazi)
- `synthwave84.yazi` - [Miuzarte/synthwave84.yazi](https://github.com/Miuzarte/synthwave84.yazi)

要添加更多额外主题，编辑脚本中的 `EXTRA_FLAVORS` 数组：

```bash
EXTRA_FLAVORS=(
    "https://github.com/user/repo.git|target-name.yazi"
)
```

格式：`仓库URL|目标目录名`

**输出示例：**

```
ℹ 正在从 GitHub 克隆/更新 flavors 仓库...
✓ 仓库克隆成功
ℹ 正在查找所有 flavor 主题...
ℹ 更新主题: catppuccin-mocha.yazi
✓   catppuccin-mocha.yazi
ℹ 安装新主题: tokyo-night.yazi
✓   tokyo-night.yazi

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Yazi Flavors 更新完成
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ 总计: 20 个主题
✓ 新增: 5 个主题
✓ 更新: 15 个主题

ℹ 主题已安装到: /home/tetsuya/.dotfiles/config/yazi/flavors
ℹ 使用 'y' 命令启动 yazi 查看效果
```

## 可用主题

从 yazi-rs/flavors 仓库可以获取以下主题：

- **Catppuccin 系列**
  - `catppuccin-mocha.yazi` - Catppuccin Mocha（深色）
  - `catppuccin-latte.yazi` - Catppuccin Latte（浅色）
  - `catppuccin-macchiato.yazi` - Catppuccin Macchiato
  - `catppuccin-frappe.yazi` - Catppuccin Frappe

- **其他主题（来自 yazi-rs/flavors）**
  - `dracula.yazi` - Dracula
  - `tokyo-night.yazi` - Tokyo Night
  - `gruvbox-dark.yazi` - Gruvbox Dark
  - `flexoki-light.yazi` - Flexoki Light
  - `rose-pine.yazi` - Rose Pine
  - 更多主题请查看 [yazi-rs/flavors](https://github.com/yazi-rs/flavors) 仓库

- **额外主题（独立仓库）**
  - `kanagawa.yazi` - Kanagawa（来自 [dangooddd/kanagawa.yazi](https://github.com/dangooddd/kanagawa.yazi)）
  - `flexoki-dark.yazi` - Flexoki Dark（来自 [gosxrgxx/flexoki-dark.yazi](https://github.com/gosxrgxx/flexoki-dark.yazi)）
  - `synthwave84.yazi` - SynthWave '84（来自 [Miuzarte/synthwave84.yazi](https://github.com/Miuzarte/synthwave84.yazi)）

## 配置主题

### 方法 1: 使用 theme.toml

编辑 `~/.dotfiles/config/yazi/theme.toml`：

```toml
[flavor]
dark = "catppuccin-mocha"
light = "catppuccin-latte"
```


## 常用操作和快捷键

### 基本导航

| 快捷键 | 功能 |
|--------|------|
| `h` | 返回上级目录 |
| `l` 或 `Enter` | 进入选中的目录或打开文件 |
| `j` | 向下移动光标 |
| `k` | 向上移动光标 |
| `gg` | 跳转到列表顶部 |
| `G` | 跳转到列表底部 |
| `~` | 跳转到家目录 |
| `-` | 跳转到上一个目录 |
| `Space` | 选择/取消选择文件 |
| `v` | 进入可视模式（批量选择） |
| `u` | 撤销选择 |

### 文件操作

| 快捷键 | 功能 |
|--------|------|
| `yy` | 复制选中的文件或目录 |
| `dd` | 剪切选中的文件或目录 |
| `p` | 粘贴复制或剪切的文件 |
| `P` | 粘贴到当前目录（强制） |
| `x` | 删除选中的文件或目录（移动到回收站） |
| `X` | 永久删除文件（不可恢复） |
| `r` | 重命名选中的文件或目录 |
| `a` | 创建新文件或目录 |
| `A` | 创建新文件 |
| `c` | 复制文件路径 |
| `C` | 复制文件名 |

### 视图和面板

| 快捷键 | 功能 |
|--------|------|
| `Tab` | 切换面板 |
| `Ctrl+w` | 关闭当前面板 |
| `Ctrl+o` | 打开文件（使用系统默认程序） |
| `o` | 打开文件（使用关联程序） |
| `O` | 打开文件（选择程序） |
| `i` | 显示文件信息 |
| `I` | 显示文件详细信息 |
| `:` | 进入命令模式 |
| `?` | 显示帮助 |

### 搜索和过滤

| 快捷键 | 功能 |
|--------|------|
| `/` | 进入搜索模式（文件名） |
| `f` | 进入过滤模式 |
| `F` | 进入智能过滤模式 |
| `n` | 跳转到下一个匹配项 |
| `N` | 跳转到上一个匹配项 |
| `Esc` | 退出搜索/过滤模式 |

### 标签页操作

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+t` | 新建标签页 |
| `Ctrl+w` | 关闭当前标签页 |
| `[` | 切换到上一个标签页 |
| `]` | 切换到下一个标签页 |
| `g[` | 移动到第一个标签页 |
| `g]` | 移动到最后一个标签页 |

### 预览功能

| 快捷键 | 功能 |
|--------|------|
| `;` | 切换预览窗口显示/隐藏 |
| `=` | 调整预览窗口大小 |
| `-` | 减小预览窗口 |
| `+` | 增大预览窗口 |

### 其他操作

| 快捷键 | 功能 |
|--------|------|
| `z` | 进入选择模式 |
| `Z` | 取消选择所有文件 |
| `q` | 退出 Yazi |
| `Q` | 强制退出 |
| `:` | 进入命令模式 |
| `!` | 执行 shell 命令 |

## 实用技巧

### 1. 批量操作

1. **批量选择**：
   - 使用 `Space` 逐个选择文件
   - 使用 `v` 进入可视模式，然后使用 `j`/`k` 选择范围
   - 使用 `z` 进入选择模式，可以按模式选择文件

2. **批量重命名**：
   - 选中多个文件后，使用 `r` 进行批量重命名
   - 支持正则表达式替换

3. **批量复制/移动**：
   - 选中多个文件后，使用 `yy` 复制或 `dd` 剪切
   - 导航到目标目录，使用 `p` 粘贴

### 2. 快速导航

- **跳转到目录**：
  - 使用 `:` 进入命令模式，输入 `cd /path/to/directory`
  - 使用 `~` 快速跳转到家目录
  - 使用 `-` 跳转到上一个目录

- **历史记录**：
  - Yazi 会记住访问过的目录
  - 使用 `-` 可以快速返回上一个目录

### 3. 文件预览

- **预览支持**：
  - 文本文件：自动语法高亮
  - 图片：内置图片预览（支持多种终端协议）
  - 视频：显示视频信息
  - PDF：显示 PDF 信息
  - 代码：语法高亮显示

- **预览窗口**：
  - 使用 `;` 切换预览窗口
  - 使用 `=` 调整预览窗口大小
  - 预览窗口支持滚动查看长文件

### 4. 搜索和过滤

- **文件名搜索**：
  - 使用 `/` 进入搜索模式
  - 支持模糊搜索和正则表达式
  - 使用 `n`/`N` 在匹配项间跳转

- **智能过滤**：
  - 使用 `F` 进入智能过滤模式
  - 可以按文件类型、大小、修改时间等过滤

### 5. 命令模式

- **常用命令**：
  - `:cd <path>` - 切换目录
  - `:mkdir <name>` - 创建目录
  - `:touch <name>` - 创建文件
  - `:rm <name>` - 删除文件
  - `:mv <old> <new>` - 重命名/移动文件
  - `:cp <src> <dst>` - 复制文件
  - `:shell <cmd>` - 执行 shell 命令

### 6. Git 集成

- **Git 状态**：
  - Yazi 会自动显示 Git 仓库状态
  - 显示修改、新增、删除的文件
  - 支持 Git 操作（需要配置）

### 7. 异步任务管理

- **任务进度**：
  - Yazi 使用异步 I/O，所有操作都是非阻塞的
  - 可以同时执行多个任务
  - 实时显示任务进度

### 8. 自定义配置

- **键位映射**：
  - 编辑 `~/.config/yazi/keymap.toml` 自定义快捷键
  - 支持 Vim 风格的键位映射

- **主题配置**：
  - 编辑 `~/.config/yazi/theme.toml` 自定义主题
  - 支持深色/浅色主题切换

- **插件系统**：
  - Yazi 支持 Lua 插件扩展功能
  - 可以编写自定义插件

## 注意事项

1. **主题兼容性**: 请确保主题与您的 Yazi 版本兼容。查看 [yazi-rs/flavors](https://github.com/yazi-rs/flavors) 仓库了解兼容性信息。

2. **本地主题优先**: 如果 `~/.config/yazi/flavors/` 目录下有本地主题文件，Yazi 会自动识别并使用。

3. **更新频率**: 建议定期运行 `update_flavors.sh` 脚本以获取最新的主题更新。

4. **Git 依赖**: 脚本需要 `git` 命令，请确保已安装。

5. **退出后切换目录**: 使用 `y` 命令启动 Yazi，退出后会自动切换到 Yazi 中的当前目录。

## 相关链接

- **Yazi 官方文档**: https://yazi-rs.github.io/
- **Flavors 仓库**: https://github.com/yazi-rs/flavors
- **Flavors 文档**: https://yazi-rs.github.io/docs/flavors/overview


