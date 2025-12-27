# CLI 工具管理配置

## 简介

此文件负责通过 Zinit 管理各种 CLI 工具，从 GitHub Releases 自动下载和安装二进制工具。所有工具都通过统一的 `zi_cmd` 辅助函数安装，确保配置简洁且易于维护。

## 文件位置

- **配置文件**: `~/.dotfiles/plugins/tools/tools.zsh`
- **加载位置**: 在 `~/.zshrc` 中，在 prompt 之后、completion 之前加载

## 功能

### 通用安装函数

`zi_cmd` 函数简化了工具的安装过程：

```zsh
zi_cmd() {
  zinit ice as"command" from"gh-r" pick"$2"
  zinit light "$1"
}
```

**参数说明**:
- `$1`: GitHub 仓库（格式：`owner/repo`）
- `$2`: 二进制文件名

### 已安装的工具

#### 系统监控

- **btop**: 系统资源监控工具
- **bottom (btm)**: 系统监控工具
- **duf**: 磁盘使用情况查看器

#### Git / 开发工具

- **lazygit**: Git 的终端 UI
- **delta**: Git diff 查看器
- **gh**: GitHub CLI

#### 文本处理

- **jq**: JSON 处理工具
- **yq**: YAML 处理工具
- **sd**: 字符串替换工具
- **choose**: 文本选择工具
- **glow**: Markdown 渲染器

#### 网络工具

- **xh**: HTTP 客户端（curl 的替代品）

#### 文件工具

- **bat**: 带语法高亮的 cat 替代品
- **fd**: 快速文件查找工具
- **ripgrep (rg)**: 快速文本搜索工具
- **zoxide**: 智能目录跳转工具
- **yazi**: 终端文件管理器
- **eza**: ls 的现代化替代品
- **dust**: du 的现代化替代品
- **procs**: ps 的现代化替代品
- **zellij**: 终端多路复用器

#### 其他工具

- **fzf**: 模糊查找工具（包含补全和键绑定）
- **atuin**: 命令历史管理工具

## 特殊处理

### fd 和 ripgrep

这两个工具需要特殊处理，因为二进制文件在压缩包的子目录中：

```zsh
# fd
zinit ice as"command" from"gh-r" mv"fd-*/fd -> fd" pick"fd" sbin"fd"
zinit light sharkdp/fd

# ripgrep
zinit ice as"command" from"gh-r" mv"ripgrep-*/rg -> rg" pick"rg" sbin"rg"
zinit light BurntSushi/ripgrep
```

### yazi

使用 musl 版本（静态链接，不依赖系统 GLIBC）：

```zsh
zinit ice as"command" from"gh-r" bpick"*linux-musl.zip" mv"yazi-*/yazi -> yazi"
zinit light sxyazi/yazi
```

### fzf

需要特殊处理：二进制 + 补全 + 键绑定：

```zsh
# 二进制
zinit ice from"gh-r" as"command" bpick"*linux_arm64.tar.gz"
zinit light junegunn/fzf

# 补全
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/completion.zsh

# 键绑定
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh
```

### atuin

根据操作系统选择不同的安装方式：

```zsh
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS 版本
else
  # Linux 版本
fi
```

## 使用说明

### 添加新工具

要添加新工具，只需在文件中添加一行：

```zsh
zi_cmd owner/repo binary_name
```

**示例**:
```zsh
zi_cmd charmbracelet/vhs vhs
```

### 查看已安装的工具

```bash
# 列出所有工具
zinit list

# 查看特定工具
zinit list | grep tool_name
```

### 更新工具

```bash
# 更新所有工具
zinit update

# 更新特定工具
zinit update owner/repo
```

### 删除工具

```bash
# 删除工具
zinit delete owner/repo
```

## 工具说明

### 系统监控工具

- **btop**: `btop` - 实时系统监控
- **bottom**: `btm` - 系统监控（类似 htop）
- **duf**: `duf` - 磁盘使用情况（比 df 更友好）

### Git 工具

- **lazygit**: `lazygit` - Git 的 TUI
- **delta**: `delta` - Git diff 查看器
- **gh**: `gh` - GitHub CLI

### 文本处理

- **jq**: `jq` - JSON 处理
- **yq**: `yq` - YAML 处理
- **sd**: `sd` - 字符串替换（比 sed 更快）
- **choose**: `choose` - 文本选择工具
- **glow**: `glow` - Markdown 渲染器

### 文件工具

- **bat**: `bat` - 带语法高亮的 cat
- **fd**: `fd` - 快速文件查找
- **ripgrep**: `rg` - 快速文本搜索
- **zoxide**: `z` - 智能目录跳转
- **yazi**: `yazi` - 终端文件管理器
- **eza**: `eza` - ls 的现代化替代品
- **dust**: `dust` - du 的现代化替代品
- **procs**: `procs` - ps 的现代化替代品

### 其他工具

- **fzf**: `fzf` - 模糊查找
- **atuin**: `atuin` - 命令历史管理
- **zellij**: `zellij` - 终端多路复用器

## 注意事项

### 系统包管理器安装的工具

某些工具建议使用系统包管理器安装（已在注释中说明）：

- **ncdu**: `sudo apt install ncdu`
- **htop**: `sudo apt install htop`
- **glances**: `pip install glances`
- **gitui**: `cargo install gitui`
- **tig**: `sudo apt install tig`
- **tealdeer**: `sudo apt install tealdeer`
- **dog**: `sudo apt install dog`

### 架构兼容性

某些工具可能不支持所有架构（如 arm64），已在注释中说明。

## 相关文件

- **fzf 配置**: `~/.dotfiles/plugins/fzf/fzf.zsh` - fzf 的详细配置和函数
- **补全配置**: `~/.dotfiles/plugins/completion/completion.zsh` - 补全系统配置

## 参考资源

- [Zinit 文档](https://github.com/zdharma-continuum/zinit)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository)

