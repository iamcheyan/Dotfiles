# fzf-tab - Zsh 补全增强插件

## 简介

fzf-tab 是一个强大的 Zsh 插件，用 fzf 替换 Zsh 的默认补全选择菜单。它提供了模糊搜索、多选、预览等功能，让命令行补全更加高效和直观。

**官方仓库**: https://github.com/Aloxaf/fzf-tab

## 安装

fzf-tab 已通过 Zinit 自动安装和管理。插件配置位于 `~/.dotfiles/plugins/completion/completion.zsh`。

### 前置要求

1. **fzf 必须已安装**: fzf-tab 依赖 fzf，确保 fzf 已正确安装
2. **加载顺序很重要**: fzf-tab 必须在 `compinit` 之后加载，但在 `zsh-autosuggestions` 之前加载

### 当前配置

在本 dotfiles 中，fzf-tab 的加载顺序已正确配置：

```zsh
# 1. 首先执行 compinit
autoload -Uz compinit
compinit -C

# 2. 然后加载 fzf-tab（在 compinit 之后）
zinit light Aloxaf/fzf-tab

# 3. 最后加载其他插件（如 zsh-autosuggestions）
```

## 基本使用

### 触发补全

只需像往常一样按 `Tab` 键，fzf-tab 会自动显示 fzf 风格的补全菜单。

**示例**:
```bash
cd <Tab>              # 显示目录列表
git checkout <Tab>    # 显示分支列表
ls <Tab>              # 显示文件列表
```

## 快捷键

### 基本操作

| 快捷键 | 功能 |
|--------|------|
| `Tab` | 触发补全（显示 fzf 菜单） |
| `Enter` | 选择当前项并完成补全 |
| `Esc` | 取消补全 |
| `Ctrl+C` | 取消补全 |

### 多选操作

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+Space` | 选择/取消选择当前项（多选模式） |
| `Tab` | 在多选模式下，选择当前项并继续选择 |

### 分组切换

| 快捷键 | 功能 |
|--------|------|
| `F1` / `<` | 切换到上一个分组 |
| `F2` / `>` | 切换到下一个分组 |

### 连续补全

| 快捷键 | 功能 |
|--------|------|
| `/` | 触发连续补全（用于完成深层路径，如 `/usr/local/bin/`） |

## 可用命令

### 控制 fzf-tab 状态

```bash
# 禁用 fzf-tab，回退到默认补全系统
disable-fzf-tab

# 启用 fzf-tab
enable-fzf-tab

# 切换 fzf-tab 状态（也是一个 zle widget）
toggle-fzf-tab
```

## 配置

### 当前配置

本 dotfiles 已包含以下常用配置（位于 `~/.dotfiles/plugins/completion/completion.zsh`）：

```zsh
# 禁用某些命令的排序（如 git checkout）
zstyle ':completion:*:git-checkout:*' sort false

# 设置描述格式以启用分组支持
# 注意：不要使用转义序列（如 '%F{red}%d%f'），fzf-tab 会忽略它们
zstyle ':completion:*:descriptions' format '[%d]'

# 设置列表颜色以启用文件名着色
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# 强制 zsh 不显示补全菜单，允许 fzf-tab 捕获明确的前缀
zstyle ':completion:*' menu no

# 预览目录内容（使用 eza，如果可用则使用 eza，否则使用 ls）
if command -v eza >/dev/null 2>&1; then
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always $realpath'
else
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:z:*' fzf-preview 'ls -1 --color=always $realpath'
fi

# 使用 < 和 > 切换分组
zstyle ':fzf-tab:*' switch-group '<' '>'
```

### 高级配置

#### 自定义 fzf 标志

```zsh
# 自定义 fzf 标志
# 注意：fzf-tab 默认不遵循 FZF_DEFAULT_OPTS
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept

# 让 fzf-tab 遵循 FZF_DEFAULT_OPTS
# 注意：这可能导致意外行为，因为某些标志会破坏此插件
zstyle ':fzf-tab:*' use-fzf-default-opts yes
```

#### 自定义预览命令

```zsh
# 预览文件内容（使用 bat）
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always $realpath'

# 预览图片（使用图片查看器）
zstyle ':fzf-tab:complete:*:*' fzf-preview '[[ -f $realpath ]] && (kitty +kitten icat $realpath 2>/dev/null || catimg $realpath 2>/dev/null || echo "无法预览图片")'

# 预览 Git 文件状态
zstyle ':fzf-tab:complete:git-(add|diff| checkout):*' fzf-preview 'git diff $word | delta'
```

#### 自定义多选绑定

```zsh
# 使用不同的键进行多选
zstyle ':fzf-tab:*' fzf-bindings 'space:accept,ctrl-a:toggle-all'
```

#### 自定义连续补全触发键

```zsh
# 使用不同的键触发连续补全
zstyle ':fzf-tab:*' continuous-trigger 'space'
```

## Tmux 集成

如果您使用 tmux >= 3.2，可以使用 `ftb-tmux-popup` 脚本充分利用 tmux 的 "popup" 功能：

```zsh
# 在 fzf-tab 中使用 tmux popup
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
```

您也可以在 fzf-tab 之外使用此脚本：

```bash
ls | ftb-tmux-popup
```

## 二进制模块（性能优化）

默认情况下，fzf-tab 使用纯 zsh 脚本（zsh-ls-colors）来解析和应用 `ZLS_COLORS`。如果文件数量很多，这可能会比较慢。

fzf-tab 附带一个二进制模块来加速此过程：

```bash
# 构建二进制模块
build-fzf-tab-module

# 构建后会自动启用
```

## 与其他插件的区别

fzf-tab **不会**执行"补全"操作，它只是显示默认补全系统的结果。

这意味着：

1. **兼容性**: fzf-tab 可以在任何地方工作（变量、函数名、目录栈、字内补全等）
2. **配置保留**: 您对默认补全系统的大部分配置仍然有效
3. **功能完整**: 支持所有 Zsh 补全功能，只是用 fzf 界面展示

## 兼容性

### 与其他插件的兼容性

某些插件也可能将 `^I`（Tab 键）绑定到自定义 widget，例如：
- `fzf/shell/completion.zsh`
- `ohmyzsh/lib/completion.zsh`

默认情况下，fzf-tab 会调用之前绑定到 `^I` 的 widget 来获取补全列表。在大多数情况下这没有问题，除非 fzf-tab 在一个不能正确处理之前绑定的插件之前初始化。

**解决方案**: 如果 fzf-tab 无法正常工作，请确保它是最后一个绑定 `^I` 的插件。在本 dotfiles 中，加载顺序已正确配置。

### 加载顺序要求

正确的加载顺序应该是：

1. `compinit` - 初始化补全系统
2. `fzf-tab` - 加载 fzf-tab（在 compinit 之后）
3. 其他插件 - 加载其他插件（如 zsh-autosuggestions、zsh-syntax-highlighting）

## 实用技巧

### 1. 快速补全深层路径

当补全深层路径时（如 `/usr/local/bin/`），使用 `/` 键触发连续补全，可以逐层补全路径。

### 2. 多选文件

使用 `Ctrl+Space` 选择多个文件，然后按 `Enter` 完成补全。这对于需要同时选择多个文件的命令很有用。

### 3. 预览文件内容

配置预览命令后，在补全时可以看到文件内容预览，帮助您快速识别需要的文件。

### 4. 分组浏览

当补全结果分为多个组时（如命令、文件、目录），使用 `F1`/`F2` 或 `<`/`>` 在不同组之间切换。

### 5. 临时禁用

如果某个命令的补全出现问题，可以临时禁用 fzf-tab：

```bash
disable-fzf-tab
# 执行命令
enable-fzf-tab
```

## 故障排除

### fzf-tab 不工作

1. **检查 fzf 是否安装**:
   ```bash
   command -v fzf
   ```

2. **检查加载顺序**: 确保 fzf-tab 在 `compinit` 之后、`zsh-autosuggestions` 之前加载

3. **检查是否有冲突的插件**: 确保没有其他插件绑定 `^I`（Tab 键）

4. **重新加载配置**:
   ```bash
   source ~/.zshrc
   ```

### 补全速度慢

1. **构建二进制模块**: 运行 `build-fzf-tab-module` 来加速颜色解析

2. **减少预览命令的复杂度**: 如果预览命令太复杂，可能会影响性能

3. **检查文件数量**: 如果目录中有大量文件，补全可能会变慢

### 预览不显示

1. **检查预览命令**: 确保预览命令正确且可执行

2. **检查文件路径**: 确保 `$realpath` 变量正确设置

3. **测试预览命令**: 手动运行预览命令，确保它能正常工作

## 相关项目

- [fzf-tab-completion](https://github.com/lincheney/fzf-tab-completion) - 用于 zsh、bash 和 GNU readline 应用的 fzf 制表补全

## 参考资源

- [官方 GitHub 仓库](https://github.com/Aloxaf/fzf-tab)
- [配置 Wiki](https://github.com/Aloxaf/fzf-tab/wiki/Configuration)
- [问题追踪](https://github.com/Aloxaf/fzf-tab/issues)
