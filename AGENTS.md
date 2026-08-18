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

zshrc、aliases.conf、tmux、nvim、zellij、ranger、vifm、ghostty、atuin、starship、nano、gvim、herdr、`.env → ~/.hermes/.env`。
具体见 `dotlink/dotlinkrc`。

## 另一套：chezmoi（个人私有，独立仓库）

另一批偏个人/私有的配置（kitty、fcitx5、alacritty、yazi、omnyssh、cliphist、sumika-shell、hermes、bitwarden、secrets 等）
由 **chezmoi** 管理，源在 `~/chezmoi`（仓库 github.com/iamcheyan/chezmoi），与本项目互不重叠。
改那些配置要编辑 `~/chezmoi` 下的源并 `chezmoi apply`，**不要在本仓库里动它们**。

## 子模块

`config/nvim/lua/vimquest`、`config/ranger/plugins/archives`、`config/ranger/plugins/ranger_devicons` 是 git 子模块，
克隆后跑 `git submodule update --init --recursive` 拉取。