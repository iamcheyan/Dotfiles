# plugins/ - Zsh 插件和工具配置

此目录包含所有 Zsh 插件和工具的配置文件，通过 `~/.zshrc` 按顺序加载。所有文件都通过 [Zinit](https://github.com/zdharma-continuum/zinit) 插件管理器来管理插件和 CLI 工具。

## 文件列表和加载顺序

配置文件按以下顺序在 `~/.zshrc` 中加载：

```
1. zinit.zsh      → Zinit 引导和初始化
2. prompt.zsh     → Powerlevel10k 主题
3. plugins.zsh    → Zsh 功能插件
4. tools.zsh      → CLI 工具管理
5. completion.zsh → 补全和 PATH 设置
6. fzf.zsh        → fzf 配置和函数
7. spf/superfile.zsh → superfile 自动安装（退出后切换目录）
8. local.zsh      → 机器特定配置
```

## 文件详细说明

### 1. zinit.zsh - Zinit 插件管理器引导

**作用：**
- 自动安装 Zinit（如果不存在）
- 初始化 Zinit 插件管理器
- 提供 `zz` 别名（`zoxide query -i`）

**调用方式：**
- 在 `~/.zshrc` 中通过 `source ~/.dotfiles/plugins/zinit/zinit.zsh` 加载
- 必须在所有其他插件配置之前加载

**提供的功能：**
- `zinit` 命令可用
- `zz` 别名（交互式 zoxide 目录查询）

### 2. prompt.zsh - Powerlevel10k 主题配置

**作用：**
- 通过 Zinit 安装 Powerlevel10k 主题
- 加载用户自定义的 `~/.p10k.zsh` 配置

**调用方式：**
- 在 `~/.zshrc` 中通过 `source ~/.dotfiles/plugins/prompt/prompt.zsh` 加载
- 在 `zinit.zsh` 之后加载

**提供的功能：**
- 美观的 Zsh 提示符
- 快速启动（instant prompt）
- 可自定义的配置（通过 `p10k configure`）

### 3. plugins.zsh - Zsh 功能插件

**作用：**
- 管理 Zsh 功能增强插件
- 替代 Oh My Zsh，只加载需要的插件

**调用方式：**
- 在 `~/.zshrc` 中通过 `source ~/.dotfiles/plugins/plugins/plugins.zsh` 加载

**安装的插件：**

#### 核心功能插件
- `jeffreytse/zsh-vi-mode` - Vim 模式支持（必须在 autosuggestions 之前加载）
- `zsh-users/zsh-autosuggestions` - 命令自动建议
- `zsh-users/zsh-syntax-highlighting` - 语法高亮（必须最后加载）

#### Oh My Zsh 插件片段
- `OMZP::sudo` - 双击 ESC 键添加 `sudo` 前缀
- `OMZP::git` - Git 命令别名和函数（不加载整个 OMZ）
- `OMZP::copypath` - 复制文件或目录路径到剪贴板
- `OMZP::copyfile` - 复制文件内容到剪贴板

#### 实用工具插件
- `MichaelAquilina/zsh-you-should-use` - 提醒使用已存在的别名
- `le0me55i/zsh-extract` - 自动解压各种压缩文件
- `paulirish/git-open` - 在浏览器中打开 Git 仓库页面
- `0mykull/zshcp` - Zsh 剪贴板管理（历史记录、快捷键）

**提供的功能：**
- 输入命令时显示历史建议
- 命令语法高亮显示
- Vim 键绑定支持
- `sudo` 快捷键（双击 ESC）
- Git 常用命令别名
- 路径和文件内容复制到剪贴板
- 别名使用提醒
- 自动解压压缩文件
- 在浏览器中打开 Git 仓库
- 剪贴板管理和历史记录

### 4. tools.zsh - CLI 工具管理

**作用：**
- 通过 Zinit 从 GitHub Releases 自动安装 CLI 工具
- 使用统一的 `zi_cmd()` 函数简化工具安装

**调用方式：**
- 在 `~/.zshrc` 中通过 `source ~/.dotfiles/plugins/tools/tools.zsh` 加载
- 工具会在首次使用时自动下载安装

**安装的工具：**

#### 系统监控
- `btop` - 系统资源监控（替代 htop）
- `bottom` (`btm`) - 系统监控工具
- `duf` - 磁盘使用情况查看

#### Git / 开发
- `lazygit` - Git 交互式界面
- `delta` - Git diff 查看器
- `gh` - GitHub CLI

#### 文本处理
- `jq` - JSON 处理工具
- `yq` - YAML 处理工具
- `sd` - 字符串替换工具
- `choose` - 文本选择工具
- `glow` - Markdown 渲染器

#### 网络工具
- `xh` - HTTP 客户端（替代 curl）

#### 文件工具
- `bat` - 文件查看器（带语法高亮）
- `fd` - 文件搜索工具（替代 find）
- `rg` (`ripgrep`) - 文本搜索工具（替代 grep）
- `zoxide` - 智能目录跳转
- `yazi` - 终端文件管理器
- `eza` - `ls` 的现代替代品
- `dust` - 磁盘使用分析
- `procs` - `ps` 的现代替代品
- `zellij` - 终端多路复用器

#### 特殊工具
- `fzf` - 模糊查找器（需要特殊配置，见 `fzf.zsh`）
- `atuin` - 命令历史搜索（需要初始化脚本）

**使用方式：**
- 直接使用工具命令，例如：`bat file.txt`、`fd pattern`、`rg search`
- 工具会在首次使用时自动下载（通过 Zinit）
- 所有工具都自动添加到 PATH

**特殊说明：**
- `rg` 需要特殊处理（文件在子目录中）
- `yazi` 使用 musl 版本（静态链接，兼容旧 GLIBC）
- `fzf` 需要额外配置（见 `fzf.zsh`）
- `atuin` 会自动初始化并加载历史搜索功能

### 5. completion.zsh - 补全和 PATH 设置

**作用：**
- 初始化 Zsh 补全系统
- 配置 fzf-tab 补全增强
- 配置 PATH，确保所有工具可用
- 初始化 `zoxide`

**调用方式：**
- 在 `~/.zshrc` 中通过 `source ~/.dotfiles/plugins/completion/completion.zsh` 加载
- 在 `tools.zsh` 之后、`plugins.zsh` 之前加载（确保加载顺序正确）

**补全插件：**
- `Aloxaf/fzf-tab` - 用 fzf 替换 Zsh 的默认补全选择菜单
  - 必须在 `compinit` 之后加载
  - 必须在 `zsh-autosuggestions` 之前加载

**PATH 配置逻辑：**
1. 添加 `~/.local/bin`（手动安装的工具，如 superfile）
2. 添加 `~/.local/nvim/bin`（Neovim 二进制文件）
3. 添加 `~/.cargo/bin`（Rust cargo 工具）
4. 添加 `~/.npm-global/bin`（npm 全局包）
5. 添加 `$ZPFX/bin`（Zinit 使用 `sbin` 安装的工具）
6. 递归查找 `~/.zinit/plugins/*/` 目录中的可执行文件
7. 自动添加包含可执行文件的子目录到 PATH

**提供的功能：**
- Zsh 命令补全（使用 fzf-tab 增强）
- `zoxide` 目录跳转（`z` 命令）
- 所有工具自动在 PATH 中可用

### 6. fzf.zsh - fzf 模糊查找器配置

**作用：**
- 配置 fzf 的默认行为和预览
- 提供自定义搜索函数

**调用方式：**
- 在 `~/.zshrc` 中通过 `source ~/.dotfiles/plugins/fzf/fzf.zsh` 加载
- 在 `tools.zsh` 之后加载（确保 fzf 已安装）

**配置内容：**
- 使用 `fd` 作为默认搜索命令
- 配置预览窗口（支持 `bat` 语法高亮）
- 启用官方键绑定（Ctrl+T / Alt+C / Ctrl+R）

**提供的函数：**

#### `ff [查询内容]` - 文件/目录模糊搜索
- 使用 fzf 搜索文件或目录
- 文件用 `nvim` 打开，目录用 `yazi` 打开
- 支持参数传递查询内容（支持空格、标点等）

**示例：**
```bash
ff                    # 交互式搜索
ff "config"           # 搜索包含 "config" 的文件
ff "my file.txt"      # 搜索包含 "my file.txt" 的文件
```

#### `rf [搜索关键字]` - 内容精确搜索
- 使用 `ripgrep` 在当前目录搜索内容
- 实时预览，选中后用 `nvim` 打开并跳转到相应行
- 支持完整参数作为搜索关键字（整体匹配）

**示例：**
```bash
rf                    # 交互式搜索所有内容
rf "function name"    # 搜索包含 "function name" 的行
rf "中文内容"         # 搜索包含中文的行
```

#### `zd` - 交互式目录跳转
- 结合 `zoxide` 和 `fzf` 选择目录
- 从访问历史中选择目录并切换

#### `zc` - 交互式命令历史搜索
- 从命令历史中选择并执行
- 替代经典的 Ctrl+R 风格

#### `y [目录路径]` - Yazi 文件管理器（退出后自动切换目录）
- 启动 yazi 文件管理器
- 退出后自动切换到 yazi 中的当前目录
- 支持指定初始目录：`y /path/to/dir`
- 不指定路径时从当前目录启动

**示例：**
```bash
y                    # 从当前目录启动 yazi
y ~/Documents        # 从指定目录启动 yazi
# 在 yazi 中导航后退出，终端会自动切换到 yazi 退出时的目录
```

**工作原理：**
- 使用临时文件保存 yazi 退出时的当前目录
- 退出后读取临时文件并自动切换目录
- 临时文件会自动清理

**键绑定：**
- `Ctrl+T` - 搜索文件
- `Alt+C` - 切换目录
- `Ctrl+R` - 搜索命令历史

### 7. superfile.zsh - superfile 自动安装

**作用：**
- 提供 `spf` 函数，自动安装 superfile（如果不存在）
- 退出后自动切换到 superfile 最后的目录（类似 yazi）
- 创建别名以支持拼写容错

**调用方式：**
- 在 `~/.zshrc` 中通过 `source ~/.dotfiles/plugins/spf/superfile.zsh` 加载

**提供的功能：**
- `spf` 函数 - 自动安装并执行 superfile，退出后切换目录
- `superfile` 别名 - 指向 `spf`
- `superfiles` 别名 - 拼写容错

**使用方式：**
```bash
spf                    # 从当前目录启动 superfile
spf ~/Documents        # 从指定目录启动 superfile
superfile              # 同上
superfiles             # 同上（拼写容错）

# 在 superfile 中浏览文件后退出
# 终端会自动切换到 superfile 退出时的目录
```

**工作原理：**
1. 检查 `~/.local/bin/spf` 是否存在
2. 检查系统 PATH 中是否有 `spf`
3. 如果都不存在，自动下载并安装到 `~/.local/bin/`
4. 执行 superfile
5. 退出后读取 `~/.local/state/superfile/lastdir` 文件
6. 自动切换到 superfile 退出时的目录

**退出后切换目录：**
- Linux: `~/.local/state/superfile/lastdir`
- macOS: `~/Library/Application Support/superfile/lastdir`
- 自动创建目录并读取最后目录路径

### 8. local.zsh - 机器特定配置

**作用：**
- 存放机器特定的配置
- 提供字体安装功能

**调用方式：**
- 在 `~/.zshrc` 中通过 `source ~/.dotfiles/plugins/local/local.zsh` 加载
- 最后加载，可以覆盖之前的配置

**提供的功能：**

#### `install:font` 函数 - 字体安装
- 安装 Meslo 和 Noto Serif 字体
- 首次启动时自动询问是否安装

**使用方式：**
```bash
install:font              # 安装所有字体（Meslo + Noto）
install:font --meslo       # 只安装 Meslo
install:font --noto        # 只安装 Noto Serif
install:font --all         # 安装所有字体
install:font --force       # 强制重新安装
```

**自动安装逻辑：**
- 首次启动 zsh 时，如果检测到 Meslo 字体未安装，会询问用户
- 只在交互式 shell 中询问
- 创建标记文件避免重复询问

## 调用流程

```
用户启动 zsh
    ↓
~/.zshrc 被加载
    ↓
1. zinit.zsh      → 初始化 Zinit
    ↓
2. prompt.zsh     → 加载 Powerlevel10k
    ↓
3. plugins.zsh    → 安装 Zsh 插件
    ↓
4. tools.zsh      → 安装 CLI 工具（首次使用时下载）
    ↓
5. completion.zsh → 设置补全和 PATH
    ↓
6. fzf.zsh        → 配置 fzf 和自定义函数
    ↓
7. spf/superfile.zsh → 配置 superfile 自动安装（退出后切换目录）
    ↓
8. local.zsh      → 加载机器特定配置（字体安装询问等）
    ↓
9. aliases.conf   → 加载别名配置
    ↓
10. ~/.p10k.zsh   → 加载 Powerlevel10k 用户配置
    ↓
完成，提示符显示
```

## 工具调用方式总结

### 直接命令调用
所有通过 `tools.zsh` 安装的工具都可以直接使用：
```bash
bat file.txt          # 查看文件
fd pattern            # 搜索文件
rg "search"           # 搜索内容
z path/to/dir         # 跳转目录
yazi                  # 文件管理器
```

### 自定义函数调用
通过 `fzf.zsh` 提供的函数：
```bash
ff [查询]             # 文件/目录搜索
rf [关键字]           # 内容搜索
zd                     # 目录跳转
zc                     # 命令历史
y [目录]               # Yazi 文件管理器（退出后自动切换目录）
```

### 自动安装工具
```bash
spf [目录]            # superfile（自动安装，退出后切换目录）
y [目录]              # Yazi 文件管理器（退出后切换目录）
install:font          # 字体安装
```

## 完整插件列表

### Zsh 功能插件（plugins.zsh）

| 插件 | 仓库 | 类型 | 功能描述 |
|------|------|------|----------|
| **zsh-vi-mode** | `jeffreytse/zsh-vi-mode` | 核心功能 | Vim 模式支持，提供 Vim 键绑定 |
| **zsh-autosuggestions** | `zsh-users/zsh-autosuggestions` | 核心功能 | 命令自动建议，根据历史记录提示 |
| **zsh-syntax-highlighting** | `zsh-users/zsh-syntax-highlighting` | 核心功能 | 语法高亮，实时高亮命令语法 |
| **sudo** | `OMZP::sudo` | OMZ 片段 | 双击 ESC 键添加 `sudo` 前缀 |
| **git** | `OMZP::git` | OMZ 片段 | Git 命令别名和辅助函数 |
| **copypath** | `OMZP::copypath` | OMZ 片段 | 复制文件或目录路径到剪贴板 |
| **copyfile** | `OMZP::copyfile` | OMZ 片段 | 复制文件内容到剪贴板 |
| **you-should-use** | `MichaelAquilina/zsh-you-should-use` | 实用工具 | 提醒使用已存在的别名 |
| **extract** | `le0me55i/zsh-extract` | 实用工具 | 自动解压各种压缩文件（30+ 格式） |
| **git-open** | `paulirish/git-open` | 实用工具 | 在浏览器中打开 Git 仓库页面 |
| **zshcp** | `0mykull/zshcp` | 实用工具 | Zsh 剪贴板管理（历史记录、快捷键） |

**加载顺序要求**:
- `zsh-vi-mode` 必须在 `zsh-autosuggestions` 之前加载
- `zsh-syntax-highlighting` 必须最后加载

### 补全插件（completion.zsh）

| 插件 | 仓库 | 功能描述 |
|------|------|----------|
| **fzf-tab** | `Aloxaf/fzf-tab` | 用 fzf 替换 Zsh 的默认补全选择菜单 |

**加载顺序要求**:
- 必须在 `compinit` 之后加载
- 必须在 `zsh-autosuggestions` 之前加载

### CLI 工具（tools.zsh）

#### 系统监控
| 工具 | 命令 | 功能描述 |
|------|------|----------|
| **btop** | `btop` | 系统资源监控（替代 htop） |
| **bottom** | `btm` | 系统监控工具 |
| **duf** | `duf` | 磁盘使用情况查看 |

#### Git / 开发
| 工具 | 命令 | 功能描述 |
|------|------|----------|
| **lazygit** | `lazygit` | Git 交互式界面（TUI） |
| **delta** | `delta` | Git diff 查看器 |
| **gh** | `gh` | GitHub CLI |

#### 文本处理
| 工具 | 命令 | 功能描述 |
|------|------|----------|
| **jq** | `jq` | JSON 处理工具 |
| **yq** | `yq` | YAML 处理工具 |
| **sd** | `sd` | 字符串替换工具（比 sed 更快） |
| **choose** | `choose` | 文本选择工具 |
| **glow** | `glow` | Markdown 渲染器 |

#### 网络工具
| 工具 | 命令 | 功能描述 |
|------|------|----------|
| **xh** | `xh` | HTTP 客户端（替代 curl） |

#### 文件工具
| 工具 | 命令 | 功能描述 |
|------|------|----------|
| **bat** | `bat` | 文件查看器（带语法高亮） |
| **fd** | `fd` | 文件搜索工具（替代 find） |
| **ripgrep** | `rg` | 文本搜索工具（替代 grep） |
| **zoxide** | `z` | 智能目录跳转 |
| **yazi** | `yazi` | 终端文件管理器 |
| **eza** | `eza` | `ls` 的现代替代品 |
| **dust** | `dust` | 磁盘使用分析 |
| **procs** | `procs` | `ps` 的现代替代品 |
| **zellij** | `zellij` | 终端多路复用器 |

#### 特殊工具
| 工具 | 命令 | 功能描述 | 特殊说明 |
|------|------|----------|----------|
| **fzf** | `fzf` | 模糊查找器 | 需要额外配置（见 `fzf.zsh`） |
| **atuin** | `atuin` | 命令历史搜索 | 自动初始化并加载历史搜索功能 |

## 注意事项

1. **首次使用**：工具会在首次使用时自动下载，可能需要等待几秒钟
2. **PATH 设置**：所有工具都通过 `completion.zsh` 自动添加到 PATH
3. **加载顺序**：不要随意更改加载顺序，某些配置有依赖关系
   - `zinit.zsh` → `prompt.zsh` → `tools.zsh` → `completion.zsh` → `plugins.zsh` → `fzf.zsh` → `local.zsh`
   - `fzf-tab` 必须在 `compinit` 之后、`zsh-autosuggestions` 之前加载
   - `zsh-vi-mode` 必须在 `zsh-autosuggestions` 之前加载
   - `zsh-syntax-highlighting` 必须最后加载
4. **机器特定配置**：`local.zsh` 是唯一应该手动编辑的文件（如果需要）
5. **字体安装**：首次启动时会询问，也可以随时使用 `install:font` 命令

## 故障排除

### 工具找不到
- 检查 `completion.zsh` 是否正确加载
- 运行 `zinit install <工具仓库>` 手动安装
- 检查 `~/.zinit/plugins/` 目录

### 函数冲突
- 检查 `aliases.conf` 中是否有冲突的别名
- 使用 `type <命令>` 查看命令类型

### 字体安装失败
- 检查网络连接
- 手动运行：`bash ~/.dotfiles/scripts/install/install_font.sh --force`

