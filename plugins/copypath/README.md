# copypath - 路径复制插件

## 简介

copypath 是 Oh My Zsh 提供的一个实用插件，用于快速将文件或目录的绝对路径复制到系统剪贴板。这对于需要在不同应用程序之间共享路径、在文档中引用文件位置或快速获取完整路径非常有用。

**官方仓库**: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/copypath

## 安装

copypath 已通过 Zinit 自动安装和管理。插件配置位于 `~/.dotfiles/plugins/plugins/plugins.zsh`。

### 前置要求

copypath 需要系统剪贴板工具才能工作。支持的剪贴板工具包括：

- **Linux**: `xclip` 或 `xsel`（X11）或 `wl-copy`（Wayland）
- **macOS**: `pbcopy`（系统自带）
- **Windows (WSL)**: `clip.exe`（系统自带）

当前系统已检测到：`xsel`（已安装）

## 基本使用

### 复制当前目录路径

```bash
# 复制当前工作目录的绝对路径
copypath
```

**示例**:
```bash
cd ~/Documents/projects
copypath
# 剪贴板内容: /home/tetsuya/Documents/projects
```

### 复制指定文件或目录路径

```bash
# 复制指定文件或目录的绝对路径
copypath <文件或目录>
```

**示例**:
```bash
# 复制文件的绝对路径
copypath ~/.zshrc
# 剪贴板内容: /home/tetsuya/.zshrc

# 复制目录的绝对路径
copypath ~/Documents
# 剪贴板内容: /home/tetsuya/Documents

# 复制相对路径（会转换为绝对路径）
copypath ./config.yaml
# 剪贴板内容: /home/tetsuya/当前目录/config.yaml
```

## 使用场景

### 1. 在文档中引用文件位置

```bash
# 快速获取配置文件路径
copypath ~/.zshrc
# 然后粘贴到文档中
```

### 2. 在不同应用程序间共享路径

```bash
# 在终端中复制路径，然后在文件管理器或编辑器中打开
copypath ~/Documents/project/src/main.py
# 在文件管理器中按 Ctrl+L 并粘贴路径
```

### 3. 快速获取 Git 仓库路径

```bash
cd ~/my-project
copypath
# 复制项目根目录路径，用于配置或文档
```

### 4. 复制脚本路径用于执行

```bash
# 复制脚本路径，用于在其他地方引用
copypath ~/scripts/backup.sh
```

### 5. 在配置文件中引用路径

```bash
# 快速获取配置文件路径，用于其他工具的配置
copypath ~/.config/nvim/init.lua
```

## 与其他工具集成

### 与 fzf 结合使用

```bash
# 使用 fzf 选择文件，然后复制路径
ff  # 使用 fzf 选择文件
# 在选择的文件上使用 copypath
copypath $(ff)
```

### 与 yazi 结合使用

```bash
# 在 yazi 中选择文件后，退出到终端
y ~/Documents
# 然后复制当前目录路径
copypath
```

### 与 Neovim 结合使用

在 Neovim 中，您可以使用 `:!copypath %` 来复制当前文件的路径：

```vim
" 在命令模式下
:!copypath %
```

## 验证剪贴板内容

### Linux (xclip)

```bash
# 查看剪贴板内容
xclip -o -selection clipboard
```

### Linux (xsel)

```bash
# 查看剪贴板内容
xsel --clipboard --output
```

### macOS

```bash
# 查看剪贴板内容
pbpaste
```

## 故障排除

### copypath 命令未找到

如果 `copypath` 命令不可用，请检查：

1. **重新加载配置**:
   ```bash
   source ~/.zshrc
   ```

2. **检查插件是否加载**:
   ```bash
   # 检查 zinit 是否加载了插件
   zinit list | grep copypath
   ```

3. **手动加载插件**:
   ```bash
   # 临时加载
   source ~/.zinit/plugins/ohmyzsh---ohmyzsh/plugins/copypath/copypath.plugin.zsh
   ```

### 路径未复制到剪贴板

如果路径没有复制到剪贴板，请检查：

1. **检查剪贴板工具**:
   ```bash
   # 检查是否有可用的剪贴板工具
   command -v xclip xsel pbcopy wl-copy clip.exe 2>/dev/null
   ```

2. **安装剪贴板工具**:
   ```bash
   # Linux (Debian/Ubuntu)
   sudo apt install xclip  # 或 xsel
   
   # Linux (Wayland)
   sudo apt install wl-clipboard
   
   # macOS (通常已安装 pbcopy)
   # 无需安装
   ```

3. **测试剪贴板工具**:
   ```bash
   # 测试 xsel
   echo "test" | xsel --clipboard --input
   xsel --clipboard --output
   
   # 测试 xclip
   echo "test" | xclip -selection clipboard
   xclip -selection clipboard -o
   ```

### 路径格式不正确

copypath 总是复制绝对路径。如果您需要相对路径，可以：

```bash
# 获取相对路径（手动方法）
realpath --relative-to=. ~/Documents/file.txt

# 或者使用其他工具
```

## 高级用法

### 创建别名简化操作

可以在 `~/.dotfiles/aliases.conf` 中添加别名：

```zsh
# 复制当前目录路径的简短别名
alias cpp='copypath'

# 复制当前文件路径（如果在编辑器中）
alias cpf='copypath $(pwd)/$(ls -t | head -1)'
```

### 在脚本中使用

```bash
#!/bin/bash
# 复制脚本所在目录的路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
copypath "$SCRIPT_DIR"
```

### 结合管道使用

```bash
# 复制最近修改的文件路径
copypath $(ls -t | head -1)

# 复制当前目录下所有 .md 文件的路径（需要循环）
for file in *.md; do
    copypath "$file"
    echo "已复制: $file"
done
```

## 相关插件

- **copyfile**: 复制文件内容到剪贴板（不是路径）
- **copydir**: 复制目录内容到剪贴板

## 参考资源

- [Oh My Zsh copypath 插件](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/copypath)
- [Oh My Zsh 官方文档](https://github.com/ohmyzsh/ohmyzsh)

