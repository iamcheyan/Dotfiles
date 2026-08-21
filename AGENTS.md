# dotfiles（dotlink 体系）

本仓库是一个面向公开分享的 Zsh 一键初始化模板（`git clone → bash init.sh`），
并用自研的 **dotlink** 通过软链接管理配置文件。

## 重要规则

- **本仓库不用 chezmoi**。配置以普通文件形式存放在 `~/dotfiles/`（如 `config/tmux/tmux.conf`、`zshrc`），
  dotlink 把它们软链到目标位置（如 `~/.tmux.conf → ~/dotfiles/config/tmux/tmux.conf`）。
- **要改配置：直接改 `~/dotfiles/` 里的源文件**，然后跑 `bash ~/dotfiles/dotlink/dotlink link` 重建软链。
  绝不要直接编辑 `~/.config/` 或 `~/.tmux.conf` 那些软链目标——它们是指向本仓库的链接。
- 新增/删除某项配置时，在 `dotlink/dotlinkrc` 的 `[link]` 段增删对应行，再 `dotlink link`。

## 本仓库管理范围（dotlink）

本公开仓库只管理通用、可分享的 Zsh + Neovim 基础配置，以及通用终端工具配置：

* `zshrc`、`aliases.conf`
* Zsh 插件、补全、fzf、zoxide、atuin 与通用工具
* Neovim、Tmux、Ranger、Vifm、Ghostty、Starship 等公开配置
* `dotlink` 软链接规则与跨平台初始化脚本

## 私有配置边界

以下内容不属于本公开仓库，由私有 **Chezmoi** 仓库管理：

* AI Agent wrappers、配额工具与个人 provider 配置
* Kitty、Yazi、Zellij、Fcitx5、Karabiner、Sumika Shell、Bitwarden、Hermes 等个人配置
* API Key、Token、`.env`、私有服务器地址与机器专属脚本

改这些内容应编辑 `~/chezmoi` 或其 Git 子模块并执行 `chezmoi apply`，**不要重新放回本仓库**。

## 子模块

`config/nvim/lua/vimquest`、`config/ranger/plugins/archives`、`config/ranger/plugins/ranger_devicons` 是 git 子模块，
克隆后跑 `git submodule update --init --recursive` 拉取。