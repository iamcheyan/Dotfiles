# plugins/ - Zsh 插件和工具配置

此目录包含所有 Zsh 插件和工具的配置文件，通过 `~/.zshrc` 按顺序加载。所有插件都通过 [Zinit](https://github.com/zdharma-continuum/zinit) 插件管理器管理。

> 提示符主题使用 **Starship**，详见 `prompt/`。

## 文件列表和加载顺序

```
zshrc 加载顺序:
1. zinit/zinit.zsh         → Zinit 引导
2. prompt/prompt.zsh       → Starship 提示符
3. tools/tools.zsh         → CLI 工具（zinit gh-r 二进制）
4. grok PATH/fpath         → grok 补全（在 compinit 之前）
5. completion/completion.zsh → compinit + fzf-tab + PATH
6. evalcache               → 缓存 init 脚本
7. setup_fnm.sh            → fnm 懒加载（首次调用 node/npm 时初始化）
8. zsh-autosuggestions     → 历史建议
9. zsh-autopair            → 括号配对
10. zsh-vi-mode            → Vim 模式
11. plugins/plugins.zsh    → you-should-use + fast-syntax-highlighting
12. fzf/fzf.zsh            → fzf 配置 + 自定义函数（f/ffd）
13. atuin / zoxide init    → 历史搜索 + 目录跳转（evalcache 缓存）
14. aliases.conf           → 命令别名
```

## Shell 功能插件

| 插件 | 仓库 | 加载位置 | 功能 |
|------|------|----------|------|
| **evalcache** | `mroth/evalcache` | zshrc | 缓存 atuin/zoxide/direnv 的 init 脚本 |
| **zsh-autosuggestions** | `zsh-users/zsh-autosuggestions` | zshrc | 命令行灰色建议 |
| **zsh-autopair** | `hlissner/zsh-autopair` | zshrc | 括号/引号自动配对 |
| **zsh-vi-mode** | `jeffreytse/zsh-vi-mode` | zshrc | Vim 模式编辑 |
| **you-should-use** | `MichaelAquilina/zsh-you-should-use` | plugins.zsh | 提醒已存在的别名 |
| **fast-syntax-highlighting** | `zdharma-continuum/fast-syntax-highlighting` | plugins.zsh | 语法高亮（最后加载） |
| **zsh-completions** | `zsh-users/zsh-completions` | completion.zsh | 额外补全定义 |
| **fzf-tab** | `Aloxaf/fzf-tab` | completion.zsh | fzf 驱动的补全菜单 |

## CLI 工具（tools.zsh，zinit gh-r 二进制）

| 工具 | 命令 | 仓库 | 类别 |
|------|------|------|------|
| **bat** | `bat` | `sharkdp/bat` | 文件查看 |
| **fd** | `fd` | `sharkdp/fd` | 文件搜索 |
| **ripgrep** | `rg` | `BurntSushi/ripgrep` | 内容搜索 |
| **delta** | `delta` | `dandavison/delta` | Git diff |
| **broot** | `broot` | `Canop/broot` | 目录树 |
| **lazygit** | `lazygit` | `jesseduffield/lazygit` | Git TUI |
| **gitui** | `gitui` | `gitui-org/gitui` | Git TUI |
| **gh** | `gh` | `cli/cli` | GitHub CLI |
| **jq** | `jq` | `jqlang/jq` | JSON 处理 |
| **yq** | `yq` | `mikefarah/yq` | YAML 处理 |
| **sd** | `sd` | `chmln/sd` | sed 替代 |
| **choose** | `choose` | `theryangeary/choose` | awk/cut 替代 |
| **glow** | `glow` | `charmbracelet/glow` | Markdown 查看 |
| **tealdeer** | `tldr` | `tealdeer-rs/tealdeer` | tldr 客户端 |
| **xh** | `xh` | `ducaale/xh` | HTTP 客户端 |
| **gping** | `gping` | `orf/gping` | 图形化 ping |
| **procs** | `procs` | `dalance/procs` | 进程查看 |
| **btop** | `btop` | `aristocratos/btop` | 系统监控 |
| **bottom** | `btm` | `ClementTsang/bottom` | 系统监控 |
| **duf** | `duf` | `muesli/duf` | 磁盘使用 |
| **direnv** | `direnv` | `direnv/direnv` | 目录级环境变量 |
| **atuin** | `atuin` | `atuinsh/atuin` | 历史搜索 |
| **zoxide** | `z` | `ajeetdsouza/zoxide` | 智能目录跳转 |
| **zellij** | `zellij` | `zellij-org/zellij` | 终端复用 |

## fzf 集成

fzf 二进制由系统包管理器安装。`tools.zsh` 通过 zinit snippet 加载 fzf 官方补全和键绑定，`fzf.zsh` 从 `/usr/share/fzf/shell/` 加载系统键绑定作为后备。

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+T` | fzf 文件选择（fzf-file-widget） |
| `Alt+C` | fzf 目录跳转（fzf-cd-widget） |
| `Ctrl+R` | 历史搜索（Atuin 接管） |

自定义函数：`f`（当前目录文件搜索）、`ffd`（fd 全局文件搜索）。

## 加载顺序要求

- `fzf-tab` 必须在 `compinit` 之后、`zsh-autosuggestions` 之前
- `zsh-vi-mode` 必须在 `zsh-autosuggestions` 之前
- `fast-syntax-highlighting` 必须最后加载
- grok 的 `fpath` 必须在 `compinit` 之前设置（否则补全不生效）