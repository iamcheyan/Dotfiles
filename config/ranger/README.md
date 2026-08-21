# Ranger 文件管理器配置

## 目录

- [简介](#简介)
- [安装与配置](#安装与配置)
- [配置文件说明](#配置文件说明)
- [已安装插件](#已安装插件)
- [快捷键大全](#快捷键大全)
- [使用技巧](#使用技巧)
- [常见问题](#常见问题)

---

## 简介
Ranger 是一个基于 ncurses 的终端文件管理器，具有 vim 风格的操作方式。本配置由公开 dotfiles 仓库与 `dotlink` 管理，支持跨机器同步。

### 主要特性

- vim 风格的快捷键操作
- 文件预览功能（支持图片、文本、PDF 等）
- 多标签页支持
- 丰富的插件生态系统
- 自动打开文件配置（rifle.conf）

---

## 安装与配置

### 自动安装

通过 dotfiles 的 `init.sh` 脚本自动安装：

```bash
cd ~/Dotfiles
bash init.sh
```

脚本会自动：
- 安装 ranger（如果未安装）
- 配置文件符号链接
- 安装所有插件

### 手动安装

```bash
# Debian/Ubuntu
sudo apt-get install ranger

# macOS
brew install ranger

# Arch Linux
sudo pacman -S ranger
```

### 配置文件位置

- **源文件**：`~/Dotfiles/config/ranger/`（Chezmoi 管理）
- **实际配置**：`~/.config/ranger/`（符号链接）

---

## 配置文件说明

### rc.conf - 主配置文件

```conf
# Ranger config

# 快速连接提示
alias alpine echo "sftp://student@localhost:2222 (密码: student)"

# 设置编辑器
set preview_images true    # 启用图片预览
set draw_borders both      # 显示边框

# icon plugins
default_linemode devicons  # 使用文件图标
set show_hidden true       # 显示隐藏文件
set preview_files true     # 启用文件预览

# 使用 LazyVim (nvim) 打开文件
map <C-o> shell nvim "$@"

# Archives plugin shortcuts
map ex extract
map ec compress
```

### rifle.conf - 文件打开规则

配置如何打开不同类型的文件：

```conf
# 文本文件
ext text? = nvim "$@"

# 特定格式
ext csv?|tsv?|json?|yaml?|yml?|toml?|xml?|ini?|conf?|cfg?|rc? = nvim "$@"

# 编程语言
ext c|h|cpp|hpp|cc|cxx = nvim "$@"
ext py|pyw = nvim "$@"
ext js|ts|jsx|tsx|vue|svelte = nvim "$@"
ext sh|bash|zsh|fish = nvim "$@"
ext rb|erb = nvim "$@"
ext go = nvim "$@"
ext rs = nvim "$@"
ext java = nvim "$@"
ext php = nvim "$@"

# 配置和文档文件
ext md|rst|txt|log = nvim "$@"
ext gitignore|gitconfig|editorconfig = nvim "$@"

# 文本文件回退规则
mime text = nvim "$@"
```

---

## 已安装插件

### 1. ranger_devicons - 文件图标

为文件和目录添加 Nerd Font 图标，提升视觉体验。

**依赖**：需要安装 [Nerd Font](https://github.com/ryanoasis/nerd-fonts)

**配置**：
```bash
# 环境变量（可选）
export RANGER_DEVICONS_SEPARATOR=" "  # 图标和文件名之间的分隔符
export DEVICONS_LANG="zh_cn"          # 目录名翻译语言
```

**目录结构**：
```
plugins/ranger_devicons/
├── __init__.py
├── devicons.py
├── locales/
│   ├── zh_cn.py
│   ├── ja.py
│   └── ...
└── README.md
```

### 2. ranger-archives - 压缩包管理

支持创建和解压多种格式的压缩包。

**支持格式**：
- ZIP (.zip)
- 7-Zip (.7z)
- RAR (.rar)
- TAR (.tar, .tar.gz, .tar.bz2, .tar.xz, .tar.lz4, .tar.zst)
- 以及其他 20+ 格式

**命令**：
```bash
:extract [目录]           # 解压到指定目录
:extract_raw [标志]       # 使用自定义标志解压
:extract_to_dirs [标志]   # 解压到各自子目录
:compress [标志] [文件名]  # 压缩选中文件
```

**目录结构**：
```
plugins/archives/
├── __init__.py
├── archive_cli.py
├── archives_utils.py
├── compress.py
├── extract.py
└── README.md
```

---

## 快捷键大全

### 导航

| 快捷键 | 功能 |
|--------|------|
| `h` | 进入父目录 |
| `j` | 下移一行 |
| `k` | 上移一行 |
| `l` | 进入选中目录/打开文件 |
| `gg` | 跳转到文件列表顶部 |
| `G` | 跳转到文件列表底部 |
| `~` | 跳转到家目录 |
| `cd` | 跳转到指定目录 |

### 文件操作

| 快捷键 | 功能 |
|--------|------|
| `Space` | 选择/取消选择文件 |
| `v` | 进入可视化选择模式 |
| `V` | 反向可视化选择模式 |
| `uv` | 清除所有选择 |
| `uV` | 反向取消选择 |
| `yy` | 复制文件 |
| `dd` | 剪切文件 |
| `pp` | 粘贴文件 |
| `d` | 删除文件（移至回收站） |
| `r` | 重命名文件 |
| `A` | 创建新文件 |
| `a` | 在当前目录创建新文件 |
| `cw` | 批量重命名 |
| `:shell` | 执行 shell 命令 |

### 视图控制

| 快捷键 | 功能 |
|--------|------|
| `zh` | 显示/隐藏隐藏文件 |
| `s` | 按文件大小排序 |
| `t` | 按文件修改时间排序 |
| `c` | 按文件创建时间排序 |
| `i` | 按文件名排序 |
| `A` | 按文件扩展名排序 |
| `zh` | 显示/隐藏隐藏文件 |
| `I` | 切换大小写敏感排序 |
| `<` | 反转排序顺序 |

### 标签页

| 快捷键 | 功能 |
|--------|------|
| `gt` | 下一个标签页 |
| `gT` | 上一个标签页 |
| `gn` | 创建新标签页 |
| `gc` | 关闭当前标签页 |
| `gC` | 关闭其他标签页 |
| `uq` | 恢复已关闭的标签页 |

### Shell 操作

| 快捷键 | 功能 |
|--------|------|
| `S` | 在当前目录打开 shell |
| `!` | 执行 shell 命令 |
| `@` | 执行 shell 命令并捕获输出 |
| `#` | 通过 shell 过滤选中文件 |

### 插件快捷键

| 快捷键 | 功能 |
|--------|------|
| `ex` | 解压文件（archives 插件） |
| `ec` | 压缩文件（archives 插件） |
| `<C-o>` | 用 LazyVim (nvim) 打开文件 |

### 其他

| 快捷键 | 功能 |
|--------|------|
| `q` | 退出 ranger |
| `Q` | 退出 ranger（不保存） |
| `z` | 快速跳转（书签） |
| `f` | 快速定位文件 |
| `/` | 搜索文件 |
| `?` | 显示帮助 |
| `:help` | 显示完整帮助文档 |

---

## 使用技巧

### 1. 快速定位文件

按 `f` 键后输入文件名的一部分，ranger 会高亮匹配的文件。

### 2. 批量操作

1. 用 `Space` 选择多个文件
2. 执行操作（如 `dd` 剪切、`yy` 复制）
3. 到目标目录按 `pp` 粘贴

### 3. 文件预览

- 文本文件：显示内容预览
- 图片：显示缩略图（需要 `w3m` 或 `ueberzug`）
- PDF：显示前几页（需要 `pdftotext`）
- 音频：显示标签信息（需要 `mediainfo`）

### 4. 快速打开文件

- 按 `l` 或 `Enter` 根据 rifle.conf 规则打开文件
- 按 `<C-o>` 直接用 LazyVim 打开当前文件

### 5. 压缩包操作

```bash
# 解压
1. 选中压缩包
2. 按 `ex` 或输入 `:extract`

# 压缩
1. 选中要压缩的文件
2. 按 `ec` 或输入 `:compress filename.zip`
```

### 6. 自定义 rifle.conf

编辑 `~/.config/ranger/rifle.conf` 添加新的文件类型规则：

```conf
# 示例：用 mpv 打开视频
ext mp4|mkv|avi|mov = mpv "$@"

# 示例：用 feh 打开图片
ext jpg|jpeg|png|gif = feh "$@"
```

---

## 常见问题

### Q: 图片预览不工作？

A: 需要安装图片预览依赖：

```bash
# Ubuntu/Debian
sudo apt-get install w3m

# macOS
brew install w3m
```

然后在 rc.conf 中设置：
```conf
set preview_images true
set preview_images_method w3m
```

### Q: 文件图标不显示？

A: 需要：
1. 安装 Nerd Font：https://github.com/ryanoasis/nerd-fonts
2. 在终端中设置使用该字体
3. 确保 `default_linemode devicons` 已配置

### Q: 如何恢复已关闭的标签页？

A: 按 `uq` 恢复最近关闭的标签页。

### Q: 如何设置默认打开程序？

A: 编辑 `~/.config/ranger/rifle.conf`，按照格式添加规则。

### Q: Dotlink 同步后配置不生效？

A: 运行 `bash ~/dotfiles/dotlink/dotlink link` 重新创建配置软链接。

---

## 相关资源

- [Ranger 官方文档](https://ranger.github.io/)
- [Ranger GitHub](https://github.com/ranger/ranger)
- [ranger_devicons](https://github.com/alexanderjeurissen/ranger_devicons)
- [ranger-archives](https://github.com/maximtrp/ranger-archives)
- [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)

---

*最后更新：2026-06-05*
