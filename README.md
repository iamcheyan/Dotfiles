# dotfiles

基于 Zsh + Zinit + 自管 Neovim/lazy.nvim 的终端配置方案，追求快速启动与可控的开发体验。

## 快速开始

### 第一步：克隆仓库

```bash
git clone https://github.com/iamcheyan/dotfiles ~/dotfiles
cd ~/dotfiles
```

### 第二步：运行初始化脚本

```bash
bash init.sh              # 完整安装（推荐）
bash init.sh --minimal    # 轻量安装（跳过字体、Neovim 等）
bash init.sh --repair     # 修复损坏的 zinit 插件
```

初始化脚本会自动完成以下操作：
- 安装 Zsh 并设置为默认 Shell
- 安装所有必备工具（git, curl, ripgrep, fd, bat, eza, zoxide 等）
- 安装 zinit 插件管理器
- 安装 pyenv（Python 版本管理）
- 安装 fnm（Fast Node Manager）
- 安装 fzf（模糊搜索）
- 安装 direnv（目录级环境变量）
- 创建配置文件符号链接
- 安装 Neovim + lazy.nvim 自管配置
- 安装 Nerd Font 字体
- 初始化 Ranger 文件管理器配置
- 安装 Zellij、Codex、Opencode 等额外工具

### 第三步：启动 Zsh

```bash
zsh
```

首次启动会自动安装 Starship 主题和所有插件。

## 核心组件

| 组件 | 说明 |
|------|------|
| **Shell** | Zsh + Starship |
| **插件管理** | Zinit（异步加载，极速启动） |
| **Vim 模式** | zsh-vi-mode |
| **历史搜索** | Atuin（Ctrl+R） |
| **编辑器** | Neovim（lazy.nvim，自管配置） |
| **文件管理** | Ranger（`r` 函数，见 aliases.conf） |
| **终端多路复用** | Tmux（tmux-persist + tmux-continuum 自动保存/恢复） |
| **终端模拟器** | Kitty / Ghostty |

## 工具链替换

我们用更现代的工具替换了传统命令：

| 原命令 | 替换工具 | 说明 |
|--------|----------|------|
| `ls` | eza | 带颜色和图标的目录列表 |
| `cat` | bat | 带语法高亮的文件查看 |
| `find` | fd | 更快的文件查找 |
| `grep` | ripgrep | 极速文本搜索 |
| `top` | btop | 美化的系统监控 |
| `ps` | procs | 更友好的进程查看 |
| `cd` | zoxide | 智能目录跳转（记住历史路径） |

## Neovim 插件列表

Neovim 配置直接基于 `lazy.nvim`，不导入 LazyVim 发行版。会话保存/恢复由 **auto-session** 插件处理（按 cwd 自动保存和恢复），不依赖 vim-obsession 或 Session.vim。

| 插件 | 功能 |
|------|------|
| **aerial** | 代码大纲/符号导航 |
| **auto-session** | 按 cwd 自动保存/恢复会话（tmux-persist 恢复 nvim 时依赖此插件） |
| **blink.cmp** | 自动补全 |
| **bufferline** | 顶部标签栏 |
| **ccc** | 颜色预览/编辑器 |
| **conform** | 代码格式化 |
| **diffview** | Git diff 与文件历史 |
| **fidget** | LSP 进度提示 |
| **flash** | 快速跳转 |
| **gitsigns** | Git 增删改标记和 hunk 操作 |
| **grug-far** | 全局搜索替换 |
| **heirline** | 状态栏/窗口栏 |
| **indent-blankline** | 缩进引导线 |
| **lsp / lsp-keymaps** | LSP 配置和快捷键 |
| **mason / mason-lspconfig** | LSP server 安装 |
| **mini.ai / mini.pairs** | 文本对象和成对符号 |
| **neo-tree** | 文件浏览器（侧栏） |
| **oil** | 文件浏览器（buffer 式编辑） |
| **snacks** | picker、dashboard、notifier 等 UI 工具 |
| **telescope** | 模糊搜索（配置文件查找 + yanky 剪贴板历史） |
| **treesitter / treesitter-textobjects** | 语法高亮、折叠、缩进 |
| **vim-visual-multi** | 多光标编辑 |
| **vimquest** | 英语单词拼写练习 |
| **which-key** | 快捷键提示 |
| **yanky** | 复制/粘贴增强（持久化剪贴板历史） |
## 目录结构

```
dotfiles/
├── zshrc                 # Zsh 主配置
├── aliases.conf          # 命令别名
├── init.sh               # 初始化脚本
├── dotlink/              # 符号链接管理
│   ├── dotlink           # 链接创建/管理
│   ├── dotsync           # 同步编排
│   └── dotlinkrc         # 链接配置
├── plugins/              # Zinit 插件配置
│   ├── zinit/            # Zinit 管理器
│   ├── prompt/           # Starship 提示符主题
│   ├── tools/            # CLI 工具（基于 as"command" from"gh-r"）
│   ├── completion/       # 补全配置（zsh-completions + fzf-tab）
│   ├── plugins/          # Zsh 功能插件（plugins.zsh）
│   ├── fzf/              # fzf 配置与函数
│   ├── zellij/           # Zellij 集成
│   ├── yazi/             # Yazi 主题更新脚本
│   └── sshfs/            # vssh（fzf 选择 SSH 主机）与 vifm-sshfs 脚本
├── config/               # 应用配置（指向 ~/.config 下各应用）
│   ├── nvim/             # Neovim (lazy.nvim self-managed)
│   ├── ranger/           # Ranger 文件管理器
│   ├── atuin/            # Atuin 历史搜索
│   ├── starship/         # Starship 提示符配置
│   ├── ghostty/          # Ghostty 终端
│   ├── zellij/           # Zellij
│   └── tmux/             # Tmux
├── scripts/              # 自动化脚本
│   ├── install/          # 安装脚本
│   ├── dev/              # 开发工具
│   └── system/           # 系统工具
├── tools/                # 通用工具脚本
├── documents/            # 文档/笔记
└── rime/                 # Rime 输入法配置（独立仓库，不由本项目管理）
```

## 日常命令

| 命令 | 说明 |
|------|------|
| `dotlink` | 链接配置文件到 $HOME |
| `dotsync` | 同步配置（备份/推送/恢复） |
| `dp` | 推送 dotfiles 到远程 |
| `reload` | 重载 zsh 配置 |

## 常用快捷键

### Zsh（Vim 模式）

| 按键 | 说明 |
|------|------|
| `Ctrl+R` | 历史命令搜索（Atuin） |
| `;;` | 切换输入法（SBZR） |
| `j/k` | 历史命令搜索（上/下） |

### Neovim

| 按键 | 说明 |
|------|------|
| `<leader>e` | 文件浏览器 |
| `<leader>ff` | 模糊搜索文件 |
| `<leader>fg` | 模糊搜索内容 |
| `<leader>gg` | Git 状态 |
| `<leader>xx` | 诊断列表 |
| `gcc` | 注释/取消注释行 |
| `gc` | 注释/取消注释选中区域 |

## 自定义配置

### 添加新插件

在 `~/.config/nvim/lua/plugins/` 目录下创建新的 `.lua` 文件：

```lua
return {
  {
    "author/plugin-name",
    config = function()
      -- 插件配置
    end,
  },
}
```

### 修改别名

编辑 `~/dotfiles/aliases.conf`，添加你的自定义别名：

```bash
alias mycommand="original-command"
```

然后运行 `reload` 使配置生效。

## 故障排除

### Zinit 插件损坏

```bash
bash init.sh --repair
```

### 重新创建符号链接

```bash
dotlink link
```

### 重置 Neovim 配置

```bash
rm -rf ~/.config/nvim
dotlink link
```

## 许可证

MIT License
