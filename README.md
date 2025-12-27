# Dotfiles 配置仓库

个人 dotfiles 配置仓库，包含 zsh 配置、工具脚本、别名等。

## 📁 目录结构

```
.dotfiles/
├── config/              # 配置文件目录
│   └── zsh/            # Zsh 配置
├── plugins/             # Zsh 插件配置
├── scripts/            # 脚本目录
│   ├── utils/          # 通用工具脚本
│   ├── dev/            # 开发相关脚本
│   └── system/         # 系统管理脚本
├── tools/              # 专业工具和工作流脚本
├── resources/          # 资源文件（字体等）
├── dotlink/            # 符号链接管理工具
├── aliases.conf        # 别名配置
└── zshrc               # Zsh 主配置文件
```

---

## 🚀 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/iamcheyan/Dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. 运行初始化脚本

```bash
bash init.sh
```

初始化脚本会自动完成：
- ✅ 检查并安装 zsh（如果未安装）
- ✅ 安装 zinit 插件管理器
- ✅ 创建 `~/Dotfiles` 软链接
- ✅ 使用 dotlink 创建所有配置文件的软链接
- ✅ 创建 `~/.zshrc` 软链接

### 3. 启动 Zsh

```bash
zsh
```

首次启动时会自动：
- 安装 zinit（如果初始化脚本未完成）
- 安装 Powerlevel10k 主题
- 安装所有配置的插件和工具
- 询问是否安装 Meslo 字体

### 手动初始化（可选）

如果不想使用 `init.sh`，也可以手动执行：

```bash
# 1. 安装 zsh（如果未安装）
# Ubuntu/Debian:
sudo apt-get install zsh

# 2. 安装 zinit
mkdir -p ~/.zinit
git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin

# 3. 创建软链接
ln -s ~/.dotfiles ~/Dotfiles
ln -s ~/.dotfiles/zshrc ~/.zshrc

# 4. 使用 dotlink 创建配置文件软链接
bash ~/.dotfiles/dotlink/dotlink link
```

---

## 📚 文档索引

### 核心配置

- **[zshrc](zshrc)** - Zsh 主配置文件
- **[aliases.conf](aliases.conf)** - 所有别名定义

### 脚本文档

- **[Scripts Utils](scripts/utils/README.md)** - 通用工具脚本文档
  - `extract.sh` - 通用解压工具
  - `url_encode.sh` / `url_decode.sh` - URL 编码/解码
  - `random_string.sh` - 随机字符串生成

- **[Scripts Dev](scripts/dev/)** - 开发相关脚本
  - `git_clean.sh` - Git 清理工具
  - `push_dotfiles.sh` - Dotfiles 推送工具

- **[Scripts System](scripts/system/)** - 系统管理脚本
  - `backup_config.sh` - 配置文件备份
  - `disk_usage.sh` - 磁盘使用查看
  - `find_large_files.sh` - 查找大文件
  - `port_check.sh` - 端口检查

- **[Tools](tools/README.md)** - 专业工具文档
  - `easygit.sh` - Git 仓库管理工具
  - `repo_size.sh` - 仓库大小分析
  - `packtar.sh` - 目录打包工具
  - `unzip_here.sh` - 批量解压工具
  - `jp_convert.sh` - 日语转换工具
  - `sbzr.sh` - Rime 输入法配置工具
  - `VirtualBox.sh` - 虚拟机管理工具
  - `remove_zone_identifier.sh` - Zone.Identifier 清理
  - `open_windows_folder.sh` - WSL Windows 文件夹打开
  - `run_wine.sh` - Wine 运行工具
  - `winetricks.sh` - Winetricks 工具

### 详细说明

- **[Scripts 目录说明](scripts/README.md)** - Scripts 目录结构和组织原则

---

## 🛠️ 主要功能

### Zsh 配置

- **Zinit** - 插件管理器
- **Powerlevel10k** - 主题
- **自动补全** - zsh-autosuggestions, zsh-syntax-highlighting
- **工具管理** - 通过 zinit 自动安装和管理 CLI 工具

### 工具管理

所有工具通过 zinit 自动安装和管理，包括：
- `btop`, `bottom`, `duf` - 系统监控
- `lazygit`, `delta`, `gh` - Git 工具
- `bat`, `rg`, `fd` - 文件搜索
- `zoxide`, `yazi`, `eza` - 目录导航
- `fzf` - 模糊搜索
- 等等...

### 脚本工具

- **通用工具** (`scripts/utils/`) - 轻量级、跨平台工具
- **开发工具** (`scripts/dev/`) - Git 操作、项目管理
- **系统工具** (`scripts/system/`) - 备份、磁盘、端口检查
- **专业工具** (`tools/`) - 复杂工作流和特定用途工具

---

## 📖 常用命令

### Dotfiles 管理

```bash
# 推送 dotfiles 到 GitHub（自动包含 IP、设备名、时间戳）
dotfiles:push

# 自定义提交信息
dotfiles:push "Update config"
```

### Git 工具

```bash
# Git 清理未跟踪文件
git:clean
git:clean --dry-run    # 预览模式
git:clean --force      # 强制删除

# Git 仓库管理
easygit init           # 初始化仓库
easygit push           # 推送
easygit pull           # 拉取
```

### 系统工具

```bash
# 备份配置文件
backup:config ~/.zshrc

# 查看磁盘使用
disk:usage
disk:usage /path 2     # 指定目录和深度

# 查找大文件
find:large
find:large . 500M      # 查找大于 500M 的文件

# 检查端口
port:check 8080
```

### 通用工具

```bash
# 解压文件
extract archive.tar.gz

# URL 编码/解码
url:encode "hello world"
url:decode "hello%20world"

# 生成随机字符串
random:string
random:string 64
```

### 文件操作

```bash
# 打包目录
packtar myarchive

# 批量解压
unzip:here

# 删除 Zone.Identifier
zone:remove
```

### 其他工具

```bash
# 日语转换
jp "日本語"

# Rime 配置
sbzr

# 虚拟机管理
vbox start

# WSL 工具
win:open
```

---

## 🔧 配置说明

### Zsh 配置结构

```
plugins/
├── zinit.zsh          # Zinit 初始化
├── prompt.zsh         # Powerlevel10k 主题
├── plugins.zsh        # Zsh 插件
├── tools.zsh          # CLI 工具管理
├── completion.zsh     # 补全配置
├── fzf.zsh            # Fzf 配置
├── superfile.zsh      # Superfile 配置
└── local.zsh          # 机器特定配置
```

### 别名配置

所有别名定义在 `aliases.conf` 中，按类别组织：
- 应用程序启动别名
- 脚本工具别名
- 命令别名
- 翻译别名
- 等等...

---

## 📝 目录区分原则

### `scripts/utils/` vs `tools/`

| 特性 | `scripts/utils/` | `tools/` |
|------|-----------------|----------|
| **复杂度** | 简单（< 100 行） | 复杂（> 100 行） |
| **功能** | 单功能 | 多功能/工作流 |
| **依赖** | 最小依赖 | 可能有特定环境依赖 |
| **平台** | 跨平台 | 可能平台特定 |
| **交互** | 命令行参数 | 可能有交互式菜单 |

### `scripts/dev/` vs `scripts/system/`

- **dev/** - 开发相关（Git 操作、项目管理）
- **system/** - 系统管理（备份、磁盘、端口检查）

---

## 🔄 更新和维护

### 推送更改

```bash
# 自动推送（包含 IP、设备名、时间戳）
dotfiles:push

# 自定义提交信息
dotfiles:push "Add new feature"
```

### 添加新工具

1. **通用工具** → `scripts/utils/`
2. **开发工具** → `scripts/dev/`
3. **系统工具** → `scripts/system/`
4. **专业工具** → `tools/`

### 添加别名

在 `aliases.conf` 中添加别名，格式：
```bash
alias command:name="bash ${HOME}/.dotfiles/path/to/script.sh"
```

---

## 📄 许可证

个人使用，自由修改。

---

## 🔗 相关链接

- [Zinit 文档](https://github.com/zdharma-continuum/zinit)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [GitHub 仓库](https://github.com/iamcheyan/Dotfiles)

---

## 💡 提示

- 首次使用前确保已安装 Git
- 某些工具需要特定依赖（如 Python、特定命令）
- 字体安装脚本会在首次启动时询问
- 所有工具都支持 `--help` 或查看脚本注释获取帮助

---

**最后更新**: 2025-01-XX

