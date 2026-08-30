# fzf 配置和函数

## 简介

此文件包含 fzf（模糊查找工具）的详细配置和自定义函数。fzf 提供了强大的文件搜索、内容搜索和交互式选择功能。

## 安装方式

- **fzf 二进制**：由**系统包管理器**安装，PATH 中已包含 `~/.fzf/bin`（见 `fzf.zsh` 的后备 PATH 设置）。
- **fzf 补全与键绑定**：在 `tools/tools.zsh` 中通过 Zinit snippet 加载官方脚本：
  ```zsh
  zinit ice as"completion"
  zinit snippet https://github.com/junegunn/fzf/raw/master/shell/completion.zsh
  zinit ice as"completion"
  zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh
  ```
- 若系统已安装 fzf（如 `/usr/share/fzf/`），`fzf.zsh` 也会兼容 source 其补全与键绑定。

## 文件位置

- **配置文件**: `~/dotfiles/plugins/fzf/fzf.zsh`
- **加载位置**: 在 `~/.zshrc` 中，在 `tools.zsh` 之后、`plugins.zsh` 之后加载

## 功能

### 1. 工具 PATH 后备设置

- **fd / fdfind**：若 zinit 未提供 `fd`，尝试使用系统 `fdfind` 并建立 `~/.local/bin/fd` 软链。
- **fzf**：若 `fzf` 不在 PATH 中且 `$HOME/.fzf/bin` 存在，则将其加入 PATH。

### 2. fzf 基础设置

- `FZF_DEFAULT_COMMAND`：优先使用 `fd --hidden --follow --exclude .git`，回退到 `fdfind` 或 `find`。
- `FZF_CTRL_T_COMMAND`：与默认命令一致。
- 启用 fzf 官方键绑定（Ctrl+T / Alt+C / Ctrl+R）。

### 3. 预览设置（FZF_DEFAULT_OPTS）

- 高度 90% / 反向布局 / 边框。
- 目录用 `ls -F --color=always` 预览，文件用 `bat --style=numbers --color=always` 预览（右侧 40% 窗口）。

### 4. 自定义函数

#### `f` - 交互式文件列表

弹出 fzf 文件列表，用键盘搜索文件：

- **Enter**：文件用 `nvim` 打开，目录用 `ra`（ranger 包装函数，见 `aliases.conf`）打开
- **Alt+Enter**：强制用 `ra` 打开（文件用 `--selectfile`，目录直接打开）
- **Alt+C**：复制当前选中路径到剪挂板
- `Tab` / `Shift+Tab` / `Alt+j` / `Alt+k` 等：移动 / 翻页

```bash
f              # 从当前目录列出文件
ls | f         # 从管道读取列表
```

#### `ffd` - 按文件名搜索后选择

先使用 `fd` / `plocate` 按文件名搜索，再交给 fzf 选择：

```bash
ffd                       # 在 $HOME 下搜索
ffd bundle.mjs            # 在 $HOME 下搜索 bundle.mjs
ffd . bundle.mjs          # 在当前目录搜索
ffd /some/path bundle.mjs # 在指定目录搜索
```

选中后：文件用 `nvim` 打开，目录用 `ra` 打开。`ffd` 已设置 `noglob` 别名。

> 说明：旧文档中提到的 `ff` / `rf` / `zd` / `zc` / `y` 等函数**当前配置中已不存在**（未在 `fzf.zsh`、`aliases.conf` 或 zshrc 中定义）。如有需要请自行添加。

## 使用说明

### 默认键绑定

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+T` | 用 fzf 搜索文件并插入路径 |
| `Alt+C` | 用 fzf 选择目录并 `cd` |
| `Ctrl+R` | 用 fzf 搜索命令历史 |

### 文件搜索 (f)

```bash
f              # 交互式文件列表
# Enter 打开文件 / 目录；Alt+Enter 强制用 ranger 打开
```

### 按名搜索 (ffd)

```bash
ffd config     # 在 $HOME 下按名搜索 "config"
ffd . main.py  # 在当前目录按名搜索 "main.py"
```

## 配置选项

### FZF_DEFAULT_OPTS

可在 `fzf.zsh` 中修改 fzf 的默认选项（边框、预览窗口、高度等）。

### 搜索命令配置

`f` / `ffd` 自动选择搜索命令：

1. 优先使用 `fd`
2. 其次使用 `fdfind`
3. 最后使用 `find`（`f` 函数内）

### 编辑器配置

- 文件使用 `nvim` 打开
- 目录使用 `ra`（ranger 包装函数，定义在 `aliases.conf`）

## 故障排除

### f 命令不工作

1. **检查 fzf**:
   ```bash
   command -v fzf
   ```
2. **检查 fd**:
   ```bash
   command -v fd fdfind find
   ```
3. **检查函数定义**:
   ```bash
   type f
   ```

### ffd 命令不工作

1. **检查 fd**:
   ```bash
   command -v fd
   ```
2. **检查函数定义**:
   ```bash
   type ffd
   ```

### 预览不显示

1. **检查 bat**:
   ```bash
   command -v bat
   ```
2. **检查 FZF_DEFAULT_OPTS** 中的 `--preview` 设置

## 相关文件

- **工具配置**: `~/dotfiles/plugins/tools/tools.zsh` - fzf 补全/键绑定 snippet 加载
- **补全配置**: `~/dotfiles/plugins/completion/completion.zsh` - fzf-tab 补全配置
- **别名配置**: `~/dotfiles/aliases.conf` - `ra` (ranger) 等包装函数

## 参考资源

- [fzf GitHub](https://github.com/junegunn/fzf)
- [fzf 使用教程](https://github.com/junegunn/fzf#usage)
- [ripgrep GitHub](https://github.com/BurntSushi/ripgrep)
- [fd GitHub](https://github.com/sharkdp/fd)
