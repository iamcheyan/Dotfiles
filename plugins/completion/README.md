# 补全系统配置

## 简介

此文件负责配置 Zsh 的补全系统，包括 `compinit` 初始化、fzf-tab 插件配置以及 PATH 管理。这是 Zsh 配置的核心部分，确保命令补全、路径补全等功能正常工作。

## 文件位置

- **配置文件**: `~/.dotfiles/plugins/completion/completion.zsh`
- **加载位置**: 在 `~/.zshrc` 中，必须在 `plugins.zsh` 之前加载

## 加载顺序说明

此文件必须在 `plugins.zsh` 之前加载，原因：

1. **compinit 必须在 fzf-tab 之前执行**: fzf-tab 需要补全系统已初始化
2. **fzf-tab 必须在 zsh-autosuggestions 之前加载**: fzf-tab 需要绑定 Tab 键，必须在其他插件之前

## 功能

### 1. 补全系统初始化

```zsh
autoload -Uz compinit
compinit -C
```

- `autoload -Uz compinit`: 自动加载 compinit 函数
- `compinit -C`: 初始化补全系统（`-C` 选项跳过安全检查，加快启动速度）

### 2. fzf-tab 插件

用 fzf 替换 Zsh 的默认补全选择菜单：

```zsh
zinit light Aloxaf/fzf-tab
```

### 3. fzf-tab 配置

包含以下配置：

- **禁用某些命令的排序**: 如 `git checkout`
- **启用分组支持**: 显示补全分组
- **文件名着色**: 使用 `LS_COLORS`
- **目录预览**: 使用 `eza` 或 `ls` 预览目录内容
- **分组切换**: 使用 `<` 和 `>` 切换分组

### 4. PATH 管理

自动添加以下目录到 PATH（如果存在且未添加）：

- `~/.local/bin`: 手动安装的工具（如 superfile）
- `~/.local/nvim/bin`: Neovim 二进制文件
- `~/.cargo/bin`: Rust cargo 工具
- `~/.npm-global/bin`: npm 全局包
- `$ZPFX/bin`: Zinit 管理的工具
- Zinit 插件目录中的可执行文件

### 5. zoxide 初始化

```zsh
eval "$(zoxide init zsh)"
```

初始化 zoxide，启用智能目录跳转功能。

## 使用说明

### 补全功能

启动 Zsh 后，补全功能自动启用：

```bash
# 命令补全
git <Tab>          # 显示 Git 子命令
cd <Tab>           # 显示目录列表

# 参数补全
ls --<Tab>         # 显示 ls 选项
```

### fzf-tab 使用

按 `Tab` 键时会显示 fzf 风格的补全菜单：

```bash
# 使用 Tab 键触发补全
cd <Tab>           # 显示 fzf 补全菜单

# 快捷键
Ctrl+Space        # 多选
F1/F2 或 </>      # 切换分组
/                 # 连续补全
```

### PATH 管理

PATH 会自动管理，无需手动配置。如果需要手动清理 PATH：

```bash
# 清理 PATH 中的重复条目
clean_path
```

## 配置选项

### fzf-tab 配置

可以在文件中修改 fzf-tab 的配置：

```zsh
# 自定义预览命令
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# 自定义 fzf 标志
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2
```

### PATH 配置

如果需要添加其他目录到 PATH，可以在文件中添加：

```zsh
if [[ -d "$HOME/custom/bin" ]] && [[ ":$PATH:" != *":$HOME/custom/bin:"* ]]; then
    export PATH="$HOME/custom/bin:$PATH"
fi
```

## 故障排除

### 补全不工作

1. **检查 compinit 是否执行**:
   ```bash
   echo $fpath
   ```

2. **重新初始化补全**:
   ```bash
   rm ~/.zcompdump*
   source ~/.zshrc
   ```

3. **检查文件权限**:
   ```bash
   ls -la ~/.zcompdump*
   ```

### fzf-tab 不工作

1. **检查插件是否加载**:
   ```bash
   zinit list | grep fzf-tab
   ```

2. **检查加载顺序**: 确保在 `plugins.zsh` 之前加载

3. **重新加载配置**:
   ```bash
   source ~/.zshrc
   ```

### PATH 问题

1. **检查 PATH**:
   ```bash
   echo $PATH
   ```

2. **手动清理 PATH**:
   ```bash
   clean_path
   ```

3. **检查目录是否存在**:
   ```bash
   ls -la ~/.local/bin
   ls -la ~/.cargo/bin
   ```

## 相关文件

- **插件配置**: `~/.dotfiles/plugins/plugins/plugins.zsh` - Zsh 功能插件
- **工具配置**: `~/.dotfiles/plugins/tools/tools.zsh` - CLI 工具安装
- **fzf 配置**: `~/.dotfiles/plugins/fzf/fzf.zsh` - fzf 详细配置

## 参考资源

- [Zsh 补全系统文档](https://zsh.sourceforge.io/Doc/Release/Completion-System.html)
- [fzf-tab GitHub](https://github.com/Aloxaf/fzf-tab)
- [zoxide GitHub](https://github.com/ajeetdsouza/zoxide)

