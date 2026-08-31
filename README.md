# 🚀 Dotfiles — 现代化终端开发环境一键配置

> 基于 **Zsh + 自管 Neovim (lazy.nvim) + 本地 AI 工具 (Herdr)** 的全套极速、开箱即用终端配置方案。
> 纯公开、零外部强依赖，一行命令跨平台全自动交付！

## 🗺️ 配置仓库边界

本仓库是三层配置中的 **公开基础层**：只保存可公开复用的 Zsh、Neovim 和 CLI
配置。NixOS 系统包、服务、硬件及 Nixarchy 接线位于 `~/nixos-config`；个人
软件、Agent、输入法、终端与敏感配置编排位于私有 `~/chezmoi`。同一配置只在
一个仓库拥有，不跨仓库复制。

---

## 🌟 核心卖点

### 1. ⚡ 一键全自动初始化（One-Click Setup）
* **跨平台全自动适配**：原生支持 **Debian / Ubuntu / Arch Linux / Fedora / Void / NixOS / macOS**。
* **NixOS 独立处理**：检测到 NixOS 时使用用户级 `nix profile install` 安装公共 CLI 基线，不调用 apt/pacman/brew，也不依赖任何个人 NixOS 配置仓库。
* **一行命令搞定一切**：自动安装并配置所需工具链（`eza`、`bat`、`fd`、`ripgrep`、`zoxide`、`fzf`、`jq`、`btop` 等）、Nerd Font 字体、Zsh 插件与软链接，无需手动折腾。

### 2. 🐚 极速现代化 Zsh 终端体验
* **Zinit 异步加载**：零延迟秒开，告别臃肿缓慢的 oh-my-zsh。
* **Starship 智能 Prompt**：优雅、信息丰富、极速渲染的终端提示符。
* **zsh-vi-mode 深度整合**：原生 Vim 命令行编辑模式，在终端直接享受 `hjkl`。
* **强大的补全与历史**：
  * `fzf-tab`：可视化的模糊搜索交互补全界面。
  * `zsh-autosuggestions` + `zsh-autopair`：智能历史建议与括号自动配对。
  * `Atuin`（`Ctrl+R`）：支持上下文关联的增强版命令历史搜索。
  * `Zoxide`（`z`）：智能目录学习与快速跳转。
* **现代 CLI 替换传统命令**：
  * `ls` $\rightarrow$ `eza`（带色彩与图标的高颜值文件列表，支持 `l`, `ll`, `la`）
  * `cat` $\rightarrow$ `bat`（带语法高亮与行号的文件查看器）
  * `find` $\rightarrow$ `fd` / `grep` $\rightarrow$ `ripgrep`（千百倍极速文本与文件检索）

### 3. 📝 开箱即用的专业自管 Neovim（基于 lazy.nvim）
* **纯自管轻量架构**：直接基于 `lazy.nvim` 精心构建，**非** 臃肿黑盒发行版（非 AstroNvim/LazyVim），代码结构透明清晰，启动时间 < 50ms。
* **完整的现代 IDE 能力**：
  * **LSP 自动管理**：Mason + Mason-LSPconfig 一键安装并管理各语言 Language Server。
  * **代码补全与格式化**：Blink.cmp 极速智能补全 + Conform 自动代码格式化。
  * **语法分析与高亮**：Treesitter 语法高亮、代码折叠与文本对象。
* **生产力神器合集**：
  * `Telescope` + `Snacks`：极速模糊搜索文件、文本与符号。
  * `Neo-tree` + `Oil.nvim`：支持双模式文件树管理（侧边栏文件树 + Buffer 自由编辑重构目录）。
  * `Flash.nvim`：键盘任意位置双键直达跳转。
  * `Gitsigns` + `Diffview`：行级 Git 变动高亮与完整文件历史对比。
  * `Auto-session`：根据工作目录（cwd）全自动保存和恢复编辑现场。
  * `Yanky.nvim`：支持持久化剪贴板历史与循环粘贴。
  * `Vimquest`：内置英语单词拼写练习扩展。

### 4. 🤖 本地 AI 工具与终端复用生态
* **内置热门本地 AI 助手 Herdr**：
  * `init.sh` 脚本自动安装并配置当前热门的终端本地 AI 编程助手 [Herdr](https://herdr.dev/)。
  * 预置优雅的主题配置文件（`~/.config/herdr/config.toml`），开箱即用。
* **轻量文件管理器**：内置配置好的 `Ranger`（按 `ra` 快速调用）与 `Vifm`（按 `v` 快速调用）。
* **自研零依赖软链工具 `dotlink`**：纯 Shell 编写的极简配置软链管理器，不依赖 Chezmoi 或任何外部工具即可独立运转。

---

## 📦 快速安装与使用

### 第一步：克隆本仓库

```bash
git clone https://github.com/iamcheyan/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 第二步：运行全自动初始化脚本

```bash
bash init.sh              # 推荐：完整全自动安装
bash init.sh --minimal    # 轻量安装（跳过字体等大型组件）
bash init.sh --repair     # 修复损坏的插件缓存
```

> **初始化脚本会自动完成**：
> 1. 安装 Zsh 并设为系统默认 Shell。
> 2. 安装必备现代工具链（`git`、`curl`、`ripgrep`、`fd`、`bat`、`eza`、`zoxide`、`fzf`、`jq`、`btop` 等）。
> 3. 安装配置 `zinit`、`Starship`、`Atuin`、`pyenv`、`fnm`。
> 4. 安装并拉取 Neovim 插件与 Treesitter 解析器。
> 5. 安装 Docker（支持的 Linux 发行版）与 Herdr 本地 AI 助手。
> 6. 通过 `dotlink` 自动建立全部配置文件的符号链接。

### 第三步：应用软链接并进入环境

```bash
bash dotlink/dotlink link
exec zsh
```

---

## 📂 部署目标软链接清单

通过 `dotlink` 会在系统中建立以下干净的符号链接：

| 源码路径 | 目标部署路径 | 对应功能 |
|---|---|---|
| `~/dotfiles/zshrc` | `~/.zshrc` | Zsh 主配置文件 |
| `~/dotfiles/config/nvim` | `~/.config/nvim` | Neovim 完整 IDE 配置 |
| `~/dotfiles/config/ranger` | `~/.config/ranger` | Ranger 终端文件管理器 |
| `~/dotfiles/config/vifm/*` | `~/.config/vifm/*` | Vifm 终端文件管理器 |
| `~/dotfiles/config/atuin` | `~/.config/atuin` | Atuin 命令历史搜索配置 |
| `~/dotfiles/config/herdr/config.toml` | `~/.config/herdr/config.toml` | Herdr 本地 AI 助手配置 |
| `~/dotfiles/config/starship/starship.toml` | `~/.config/starship.toml` | Starship 终端提示符主题 |

---

## ⌨️ 常用快捷键速查

### 1. 终端命令行（Zsh Vim 模式）
* **`Ctrl + R`**：呼出 Atuin 增强版历史命令搜索
* **`Esc`**：进入命令行 Vim 普通模式（支持 `h/j/k/l` 移动、`w/b` 跳词、`dd` 删行、`cw` 改词）
* **`l` / `ll` / `la`**：调用 `eza` 查看带图标与 Git 状态的文件列表
* **`z <目录名>`**：Zoxide 智能跳转目录
* **`ra`**：打开 Ranger 并在退出时自动 `cd` 到最后停留的目录
* **`v`**：打开 Vifm 并在退出时自动 `cd` 到最后停留的目录

### 2. Neovim 核心键位（空格键 Leader）
* **`<Space> e`**：展开/折叠 Neo-tree 侧边栏文件树
* **`-`**：打开 Oil 目录编辑器（直接把目录当作 Buffer 增删重命名文件）
* **`<Space> ff`**：全局模糊查找文件（Find Files）
* **`<Space> fg`**：全局代码文本搜索（Live Grep）
* **`<Space> gg`**：打开 Lazygit 交互界面
* **`<Space> xx`**：打开 Trouble 错误与警告诊断列表
* **`s` + 双字符**：Flash 屏幕任意位置双键直达跳转
* **`gcc`**：单行注释 / 取消注释
* **`gc`**：选中区域代码块注释

---

## 🛠️ 项目目录结构

```text
dotfiles/
├── zshrc                  # Zsh 主入口配置
├── aliases.conf           # 通用别名与实用函数
├── init.sh                # 跨平台一键全自动初始化脚本
├── dotlink/               # 自研轻量符号链接管理器
├── config/                # 应用配置集合
│   ├── nvim/              # Neovim lazy.nvim 配置
│   ├── herdr/             # Herdr 本地 AI 助手配置
│   ├── ranger/            # Ranger 文件管理器配置
│   ├── vifm/              # Vifm 文件管理器配置
│   ├── atuin/             # Atuin 命令历史配置
│   └── starship/          # Starship 提示符主题
├── plugins/               # Zsh 插件与补全辅助
├── scripts/               # 安装与系统检测脚本
└── tools/                 # 通用实用工具脚本
```

---

## 🔒 纯净与安全承诺

* **100% 通用开源**：本仓库**绝不包含**任何个人 API Key、密码、Token、私有服务器 IP 或硬编码绝对路径。
* **独立运行**：不强绑 Chezmoi 或任何私有系统，任何人均可放心 Fork 与二次定制。

---

## 📄 开源许可证

本项目基于 [MIT 许可证](LICENSE) 开源。欢迎 Star 🌟 与 Fork！
