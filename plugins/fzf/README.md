# fzf 配置和函数

## 简介

此文件包含 fzf（模糊查找工具）的详细配置和自定义函数。fzf 提供了强大的文件搜索、内容搜索和交互式选择功能。

## 文件位置

- **配置文件**: `~/.dotfiles/plugins/fzf/fzf.zsh`
- **加载位置**: 在 `~/.zshrc` 中，在 `tools.zsh` 之后加载（确保 fzf 二进制已安装）

## 功能

### 1. 工具 PATH 设置

提供后备方案，如果 Zinit 未安装工具，尝试使用系统安装的版本：

- **fd**: 如果 zinit 的 `fd` 不存在，尝试使用系统的 `fdfind`
- **fzf**: 如果 zinit 的 `fzf` 不存在，尝试使用 `~/.fzf/bin` 中的版本

### 2. fzf 基础设置

配置 fzf 的默认选项和键绑定：

```zsh
export FZF_DEFAULT_OPTS='...'
```

### 3. 自定义函数

#### ff - 文件搜索和编辑

使用 fzf 模糊搜索文件或目录：

```bash
ff                    # 交互式搜索
ff "config"           # 搜索包含 "config" 的文件
```

**功能**:
- 文件用 `nvim` 打开
- 目录用 `yazi` 打开
- 支持参数传递搜索内容

#### rf - 内容搜索

在当前目录中精确搜索内容，并实时预览：

```bash
rf                    # 交互式搜索
rf "function name"    # 搜索包含 "function name" 的内容
```

**功能**:
- 使用 `ripgrep` 搜索
- 实时预览文件内容
- 选中后自动用 `nvim` 打开并跳转到相应行

#### zd - 目录选择

使用 zoxide 结合 fzf 交互式选择目录：

```bash
zd
```

**功能**:
- 显示 zoxide 记录的目录
- 使用 fzf 选择
- 自动切换到选中的目录

#### zc - 命令历史选择

交互式选择并执行最近使用的命令：

```bash
zc
```

**功能**:
- 显示去重后的命令历史
- 使用 fzf 选择
- 自动执行选中的命令

#### y - Yazi 文件管理器

启动 yazi 文件管理器，退出后自动切换到选择的目录：

```bash
y                    # 从当前目录启动
y ~/Documents        # 从指定目录启动
```

**功能**:
- 启动 yazi 文件管理器
- 退出后自动切换到 yazi 中的当前目录
- 解决 Terminal Response Timeout 问题

## 使用说明

### 文件搜索 (ff)

```bash
# 基本使用
ff

# 带搜索参数
ff "config"
ff "test.py"
ff "src main"

# 搜索后：
# - 文件会用 nvim 打开
# - 目录会用 yazi 打开
```

### 内容搜索 (rf)

```bash
# 基本使用
rf

# 搜索特定内容
rf "function name"
rf "import.*module"
rf "TODO"

# 搜索后：
# - 显示匹配的行
# - 实时预览文件内容
# - 选中后自动打开并跳转
```

### 目录跳转 (zd)

```bash
# 交互式选择目录
zd

# 会显示 zoxide 记录的常用目录
# 选择后自动切换
```

### 命令历史 (zc)

```bash
# 交互式选择历史命令
zc

# 显示去重后的命令历史
# 选择后自动执行
```

### Yazi 文件管理器 (y)

```bash
# 从当前目录启动
y

# 从指定目录启动
y ~/Documents
y /path/to/directory

# 退出 yazi 后，终端会自动切换到 yazi 退出时的目录
```

## 配置选项

### FZF_DEFAULT_OPTS

可以在文件中修改 fzf 的默认选项：

```zsh
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --preview-window=right:60%
  ...
'
```

### 搜索命令配置

`ff` 函数会自动选择搜索命令：

1. 优先使用 `fd`
2. 其次使用 `fdfind`
3. 最后使用 `find`

### 编辑器配置

- 文件使用 `nvim` 打开
- 目录使用 `yazi` 打开
- 可以通过修改函数改变行为

## 高级用法

### 组合使用

```bash
# 搜索文件，然后搜索内容
ff "config"
# 在打开的文件中
rf "setting"

# 快速跳转到项目目录
zd
# 然后搜索文件
ff
```

### 自定义搜索

可以修改函数来添加自定义搜索逻辑：

```zsh
# 在 fzf.zsh 中修改 ff 函数
ff() {
    # 添加自定义逻辑
    ...
}
```

## 故障排除

### ff 命令不工作

1. **检查搜索工具**:
   ```bash
   command -v fd fdfind find
   ```

2. **检查 fzf**:
   ```bash
   command -v fzf
   ```

3. **检查函数定义**:
   ```bash
   type ff
   ```

### rf 命令不工作

1. **检查 ripgrep**:
   ```bash
   command -v rg
   ```

2. **检查 bat**:
   ```bash
   command -v bat
   ```

### zd 命令不工作

1. **检查 zoxide**:
   ```bash
   command -v zoxide
   ```

2. **初始化 zoxide**:
   ```bash
   eval "$(zoxide init zsh)"
   ```

### y 命令不工作

1. **检查 yazi**:
   ```bash
   command -v yazi
   ```

2. **检查临时文件权限**:
   ```bash
   ls -la /tmp/yazi-cwd.*
   ```

## 相关文件

- **工具配置**: `~/.dotfiles/plugins/tools/tools.zsh` - fzf 安装配置
- **补全配置**: `~/.dotfiles/plugins/completion/completion.zsh` - fzf 补全配置

## 参考资源

- [fzf GitHub](https://github.com/junegunn/fzf)
- [fzf 使用教程](https://github.com/junegunn/fzf#usage)
- [ripgrep GitHub](https://github.com/BurntSushi/ripgrep)
- [fd GitHub](https://github.com/sharkdp/fd)

