# Public Dotfiles (Zsh + Neovim)

本仓库是一个可独立运行、面向公开分享的 Zsh + Neovim 配置项目。
它使用自研的 `dotlink` 建立软链接，不依赖 Chezmoi。

## 1. 仓库定位

本仓库只存放适合公开分享的通用配置：

- Zsh 启动文件、通用 aliases、插件、补全与 prompt
- Neovim 配置与公开插件
- Tmux、Ranger、Vifm、Ghostty、Starship 等通用工具配置
- `dotlink` 软链接工具与跨平台初始化脚本
- 通用安装、维护和文档脚本

本仓库**不负责**个人私有配置。以下内容由私有 `~/chezmoi` 管理：

- Kitty、Yazi、Zellij、Fcitx5、Karabiner、Sumika Shell
- AI Agent wrappers、Agent quota、OpenCode 私人 provider 配置
- tmux 私有 Agent 恢复规则
- API Key、Token、`.env`、私有服务器地址、机器专属脚本

公开仓库中不得提交密码、Token、API Key、SSH 私钥、真实凭据或个人机器的绝对路径。

## 2. 独立使用

不安装 Chezmoi 也可以独立使用本项目：

```bash
git clone https://github.com/iamcheyan/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash init.sh
bash dotlink/dotlink link
```

`init.sh` 负责安装通用依赖和初始化环境；`dotlink` 负责建立配置软链接。

## 3. 修改配置

直接编辑仓库源文件，不要编辑软链接目标：

```bash
cd ~/dotfiles
$EDITOR zshrc
$EDITOR aliases.conf
$EDITOR config/nvim/lua/

bash dotlink/dotlink link
exec zsh
```

新增或删除需要部署的配置时，修改 `dotlink/dotlinkrc` 的 `[link]` 段，然后运行：

```bash
bash ~/dotfiles/dotlink/dotlink link
```

## 4. 路径与跨平台规则

- 使用 `$HOME`、`~` 和相对路径；禁止写死 `/Users/<name>` 或 `/home/<name>`。
- 公共 Zsh 保留通用的 `TERM` terminfo 降级保护。
- WSL 的 Windows PATH 过滤默认关闭；只有显式设置以下变量时才启用：
  ```bash
  export WSL_STRIP_WINDOWS_PATH=1
  ```
- 不在公开 Zsh 中手动加载 Kitty shell integration。Kitty 自己的 shell integration 由私有 Kitty 配置管理。
- 公共配置可以探测可选命令，例如 `command -v eza`，缺少时应保留可用的 fallback，而不是启动失败。

## 5. 与 Chezmoi 的边界

主力机器的私有配置位于：

```text
~/chezmoi/
```

Chezmoi 会通过 `symlink_dot_zshrc.tmpl` 创建：

```text
~/.zshrc -> ~/dotfiles/zshrc
```

这意味着：

- `zshrc` 的通用内容在本公开仓库维护。
- `~/.config/aliases.conf` 等本机私有扩展由 Chezmoi提供，公开 Zsh 只在文件存在时加载。
- 修改 Kitty、Agent、Fcitx5、Karabiner 等私有内容时，进入 `~/chezmoi`，不要把它们复制回本仓库。

## 6. 提交前检查

```bash
zsh -n zshrc
bash -n init.sh
bash -n aliases.conf

git diff --check

git status
```

提交前确认：

- 没有 `.env`、密钥、Token 或凭据文件
- 没有个人绝对路径、内网 IP 或私有域名
- 没有个人 Agent wrapper 或 provider 配置
- README、脚本路径与实际目录一致

## 7. 发布流程

```bash
cd ~/dotfiles
git add .
git diff --cached --check
git commit -m "feat: describe the public configuration change"
git push origin main
```

发布后的配置应当能被另一台没有 `~/chezmoi` 的机器单独克隆并运行。若某项功能只有个人环境可用，应移到私有 Chezmoi，而不是在公开仓库中添加更多机器特判。
