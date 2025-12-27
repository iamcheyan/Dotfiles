# zshcp - Zsh 剪贴板管理插件

## 简介

zshcp 是一个轻量级且直观的 Zsh 剪贴板管理插件，增强了命令行工作流程，提供便捷的复制粘贴操作。它支持复制命令行、文件内容、路径等多种内容到剪贴板，并提供了历史记录管理功能。

**官方仓库**: https://github.com/0mykull/zshcp

## 安装

zshcp 已通过 Zinit 自动安装和管理。插件配置位于 `~/.dotfiles/plugins/plugins/plugins.zsh`。

## 前置要求

zshcp 需要系统剪贴板工具才能工作。支持的剪贴板工具包括：

- **Linux**: `xclip` 或 `xsel`（X11）或 `wl-copy`/`wl-paste`（Wayland）
- **macOS**: `pbcopy`/`pbpaste`（系统自带）
- **Windows (WSL)**: `clip.exe`（系统自带）

当前系统已检测到：`xsel`（已安装）

## 基本使用

### 查看帮助

```bash
# 查看所有可用命令和快捷键
cphelp
```

### 复制操作

#### 复制当前命令行

```bash
# 在命令行中输入命令后，使用快捷键复制
# 默认快捷键：Ctrl+Alt+C
```

#### 复制文件内容

```bash
# 复制文件内容到剪贴板
zcp <文件名>

# 示例
zcp ~/.zshrc
zcp config.yaml
```

#### 复制文件夹路径

```bash
# 复制文件夹路径到剪贴板
zcp <目录路径>

# 示例
zcp ~/Documents
zcp /path/to/directory
```

#### 复制当前工作目录

```bash
# 复制当前目录路径
zcp .

# 或使用快捷键
```

### 粘贴操作

#### 粘贴剪贴板内容

```bash
# 粘贴最近复制的内容
zpp

# 或使用快捷键：Ctrl+Alt+V
```

#### 从剪贴板创建文件

```bash
# 从剪贴板内容创建或覆盖文件
zpp > <文件名>

# 示例
zpp > newfile.txt
```

### 历史记录管理

#### 查看剪贴板历史

```bash
# 查看复制历史记录
zch

# 或使用快捷键
```

#### 从历史记录粘贴

```bash
# 从历史记录中选择并粘贴
# 使用 zch 查看历史，然后选择要粘贴的内容
```

## 键盘快捷键

zshcp 提供了以下键盘快捷键（可在插件中自定义）：

- **Ctrl+Alt+C**: 复制当前命令行到剪贴板
- **Ctrl+Alt+V**: 粘贴剪贴板内容
- **Ctrl+Alt+H**: 查看剪贴板历史记录

**注意**: 快捷键可能因系统而异，使用 `cphelp` 查看实际快捷键。

## 使用场景

### 1. 复制命令到剪贴板

```bash
# 输入命令
echo "Hello World"

# 使用快捷键复制（不执行）
# 然后可以在其他地方粘贴
```

### 2. 快速复制文件内容

```bash
# 复制配置文件内容
zcp ~/.zshrc

# 然后粘贴到文档或聊天工具中
```

### 3. 复制路径用于分享

```bash
# 复制项目路径
cd ~/my-project
zcp .

# 分享路径给其他人
```

### 4. 从剪贴板创建文件

```bash
# 从剪贴板内容创建文件
zpp > backup.txt

# 从剪贴板内容覆盖文件
zpp > existing.txt
```

### 5. 管理复制历史

```bash
# 查看之前复制的内容
zch

# 选择历史记录中的内容使用
```

## 与现有工具的区别

本 dotfiles 中已经存在其他剪贴板相关工具：

| 工具 | 功能 | 使用场景 |
|------|------|----------|
| **zshcp** | 剪贴板管理、历史记录、快捷键 | 命令行剪贴板操作、历史管理 |
| **copypath** | 复制文件/目录路径 | 快速复制路径 |
| **copyfile** | 复制文件内容 | 复制文件内容到剪贴板 |
| **zsh-vi-mode** | Vim 模式剪贴板集成 | 在 Vim 模式中使用系统剪贴板 |

**推荐使用**:
- **zshcp**: 用于命令行剪贴板管理和历史记录
- **copypath/copyfile**: 用于快速复制路径或文件内容
- **zsh-vi-mode**: 用于 Vim 模式下的剪贴板操作

## 高级用法

### 自定义快捷键

可以在插件文件中修改快捷键（需要编辑插件源码）：

```zsh
# 在 ~/.zinit/plugins/0mykull---zshcp/zshcp.plugin.zsh 中修改
# 注意：修改插件文件后，更新插件时会丢失修改
```

### 结合其他工具使用

```bash
# 复制命令输出到剪贴板
ls -la | zcp

# 从剪贴板内容搜索
zpp | grep "pattern"

# 复制多个文件内容
for file in *.txt; do
    zcp "$file"
    echo "已复制: $file"
done
```

### 在脚本中使用

```bash
#!/bin/bash
# 复制脚本输出到剪贴板
output=$(some_command)
echo "$output" | zcp

# 从剪贴板读取内容
content=$(zpp)
echo "剪贴板内容: $content"
```

## 故障排除

### zshcp 命令未找到

1. **检查插件是否加载**:
   ```bash
   zinit list | grep zshcp
   ```

2. **重新加载配置**:
   ```bash
   source ~/.zshrc
   ```

3. **检查函数定义**:
   ```bash
   type zcp
   type zpp
   type zch
   ```

### 剪贴板操作失败

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

### 快捷键不工作

1. **检查快捷键冲突**:
   ```bash
   # 查看当前键绑定
   bindkey | grep -i "clipboard\|copy\|paste"
   ```

2. **查看帮助**:
   ```bash
   cphelp
   ```

3. **检查终端支持**:
   某些终端可能不支持某些快捷键组合。

### 历史记录不显示

1. **检查历史记录文件**:
   ```bash
   # zshcp 可能使用临时文件存储历史
   # 检查插件目录
   ls -la ~/.zinit/plugins/0mykull---zshcp/
   ```

2. **重新加载插件**:
   ```bash
   source ~/.zshrc
   ```

## 实用技巧

### 1. 快速复制命令

在输入命令后，使用快捷键复制（不执行），然后可以在其他终端或应用中粘贴。

### 2. 批量复制文件内容

```bash
# 复制多个文件内容到剪贴板（会覆盖，只保留最后一个）
for file in *.txt; do
    zcp "$file"
done
```

### 3. 从剪贴板创建配置文件

```bash
# 从剪贴板内容创建配置文件
zpp > ~/.config/app.conf
```

### 4. 查看复制历史

定期使用 `zch` 查看复制历史，可以找回之前复制的内容。

## 相关资源

- **copypath**: `~/.dotfiles/plugins/copypath/README.md` - 复制路径工具
- **copyfile**: `~/.dotfiles/plugins/copyfile/README.md` - 复制文件内容工具
- **zsh-vi-mode**: `~/.dotfiles/plugins/zsh-vi-mode/README.md` - Vim 模式剪贴板集成

## 参考资源

- [zshcp GitHub](https://github.com/0mykull/zshcp)
- [Zsh 剪贴板集成](https://zsh.sourceforge.io/Guide/zshguide04.html)

