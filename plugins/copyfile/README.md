# copyfile - 文件内容复制插件

## 简介

copyfile 是 Oh My Zsh 提供的一个实用插件，用于快速将文件的内容复制到系统剪贴板。这对于需要快速分享代码片段、配置文件内容、日志文件或其他文本文件内容非常有用。

**官方仓库**: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/copyfile

## 安装

copyfile 已通过 Zinit 自动安装和管理。插件配置位于 `~/.dotfiles/plugins/plugins/plugins.zsh`。

### 前置要求

copyfile 需要系统剪贴板工具才能工作。支持的剪贴板工具包括：

- **Linux**: `xclip` 或 `xsel`（X11）或 `wl-copy`（Wayland）
- **macOS**: `pbcopy`（系统自带）
- **Windows (WSL)**: `clip.exe`（系统自带）

当前系统已检测到：`xsel`（已安装）

## 基本使用

### 复制文件内容

```bash
# 复制指定文件的内容到剪贴板
copyfile <文件名>
```

**示例**:
```bash
# 复制配置文件内容
copyfile ~/.zshrc

# 复制当前目录下的文件
copyfile config.yaml

# 复制脚本内容
copyfile ~/scripts/backup.sh

# 复制日志文件内容
copyfile /var/log/app.log
```

## 使用场景

### 1. 快速分享代码片段

```bash
# 复制代码文件内容，用于分享或粘贴到其他地方
copyfile src/main.py
# 然后可以在聊天工具、邮件或文档中粘贴
```

### 2. 复制配置文件内容

```bash
# 复制配置文件内容，用于备份或分享配置
copyfile ~/.config/nvim/init.lua
```

### 3. 复制日志文件内容

```bash
# 复制日志文件内容，用于错误报告或调试
copyfile /var/log/nginx/error.log
```

### 4. 复制文档内容

```bash
# 复制 README 或其他文档内容
copyfile README.md
```

### 5. 复制脚本内容用于执行

```bash
# 复制脚本内容，然后可以在其他终端中粘贴并执行
copyfile ~/scripts/setup.sh
```

### 6. 快速复制命令输出到文件后再复制

```bash
# 将命令输出保存到文件，然后复制
ls -la > /tmp/filelist.txt
copyfile /tmp/filelist.txt
```

## 与其他工具集成

### 与 fzf 结合使用

```bash
# 使用 fzf 选择文件，然后复制其内容
selected_file=$(ff)
if [[ -n "$selected_file" ]]; then
    copyfile "$selected_file"
    echo "已复制: $selected_file"
fi
```

### 与 yazi 结合使用

```bash
# 在 yazi 中选择文件后，退出到终端
y ~/Documents
# 然后复制文件内容
copyfile selected_file.txt
```

### 与 Neovim 结合使用

在 Neovim 中，您可以使用 `:!copyfile %` 来复制当前文件的内容：

```vim
" 在命令模式下
:!copyfile %
```

或者使用 Neovim 的内置命令：

```vim
" 复制整个文件内容到系统剪贴板
:%y+  " 在普通模式下
```

### 与 Git 结合使用

```bash
# 复制 Git 配置文件内容
copyfile ~/.gitconfig

# 复制特定提交的文件内容
git show HEAD:path/to/file | copyfile -
```

## 验证剪贴板内容

### Linux (xsel)

```bash
# 查看剪贴板内容
xsel --clipboard --output

# 查看剪贴板内容的前几行
xsel --clipboard --output | head -20
```

### Linux (xclip)

```bash
# 查看剪贴板内容
xclip -selection clipboard -o

# 查看剪贴板内容的前几行
xclip -selection clipboard -o | head -20
```

### macOS

```bash
# 查看剪贴板内容
pbpaste

# 查看剪贴板内容的前几行
pbpaste | head -20
```

## 高级用法

### 创建别名简化操作

可以在 `~/.dotfiles/aliases.conf` 中添加别名：

```zsh
# 复制当前目录下最近修改的文件内容
alias cpf='copyfile $(ls -t | head -1)'

# 复制当前编辑的文件内容（如果在特定目录）
alias cpfc='copyfile $(pwd)/$(ls -t | head -1)'
```

### 复制多个文件内容

```bash
# 使用循环复制多个文件内容（会覆盖，只保留最后一个）
for file in *.txt; do
    copyfile "$file"
    echo "已复制: $file"
    read -p "按 Enter 继续下一个文件..."
done
```

### 复制文件的部分内容

```bash
# 先提取文件的部分内容，然后复制
head -50 ~/large-file.txt > /tmp/partial.txt
copyfile /tmp/partial.txt
rm /tmp/partial.txt
```

### 在脚本中使用

```bash
#!/bin/bash
# 复制脚本的配置部分
CONFIG_FILE="$HOME/.config/app.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    copyfile "$CONFIG_FILE"
    echo "配置已复制到剪贴板"
fi
```

### 结合管道使用

```bash
# 复制命令输出（需要先保存到文件）
command_output > /tmp/output.txt
copyfile /tmp/output.txt
rm /tmp/output.txt

# 或者直接使用管道（如果支持）
echo "test content" | xsel --clipboard --input
```

## 与 copypath 的区别

| 功能 | copypath | copyfile |
|------|----------|----------|
| 复制内容 | 文件/目录的**路径** | 文件的**内容** |
| 使用场景 | 需要路径时 | 需要文件内容时 |
| 示例 | `copypath ~/.zshrc` → `/home/user/.zshrc` | `copyfile ~/.zshrc` → 文件的实际内容 |

**组合使用示例**:
```bash
# 先复制路径
copypath ~/.zshrc
# 然后复制内容
copyfile ~/.zshrc
```

## 故障排除

### copyfile 命令未找到

如果 `copyfile` 命令不可用，请检查：

1. **重新加载配置**:
   ```bash
   source ~/.zshrc
   ```

2. **检查插件是否加载**:
   ```bash
   # 检查 zinit 是否加载了插件
   zinit list | grep copyfile
   ```

3. **手动加载插件**:
   ```bash
   # 临时加载
   source ~/.zinit/plugins/ohmyzsh---ohmyzsh/plugins/copyfile/copyfile.plugin.zsh
   ```

### 文件内容未复制到剪贴板

如果文件内容没有复制到剪贴板，请检查：

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

3. **检查文件权限**:
   ```bash
   # 确保有读取文件的权限
   ls -l <文件名>
   ```

4. **测试剪贴板工具**:
   ```bash
   # 测试 xsel
   echo "test" | xsel --clipboard --input
   xsel --clipboard --output
   
   # 测试 xclip
   echo "test" | xclip -selection clipboard
   xclip -selection clipboard -o
   ```

### 大文件复制问题

对于非常大的文件，复制到剪贴板可能会：

1. **速度慢**: 大文件复制可能需要一些时间
2. **内存占用**: 大文件会占用系统内存
3. **剪贴板限制**: 某些系统对剪贴板大小有限制

**解决方案**:
```bash
# 只复制文件的前 N 行
head -1000 large-file.txt > /tmp/partial.txt
copyfile /tmp/partial.txt
rm /tmp/partial.txt

# 或者使用 tail 复制最后 N 行
tail -1000 large-file.txt > /tmp/partial.txt
copyfile /tmp/partial.txt
rm /tmp/partial.txt
```

### 二进制文件问题

copyfile 主要用于文本文件。对于二进制文件：

1. **可能无法正确复制**: 二进制内容可能无法在文本编辑器中正确显示
2. **建议使用其他工具**: 对于二进制文件，建议使用专门的工具

## 安全注意事项

### 敏感信息

复制文件内容到剪贴板时，请注意：

1. **密码和密钥**: 避免复制包含密码、API 密钥或其他敏感信息的文件
2. **剪贴板历史**: 某些系统会保存剪贴板历史，敏感信息可能被记录
3. **共享剪贴板**: 在远程桌面或共享环境中，剪贴板可能被其他用户访问

### 最佳实践

```bash
# 复制前检查文件内容
head -20 sensitive-file.txt
# 确认后再复制
copyfile sensitive-file.txt

# 复制后立即清除（如果可能）
# 某些系统支持清除剪贴板
```

## 相关插件

- **copypath**: 复制文件或目录路径到剪贴板
- **copydir**: 复制目录内容到剪贴板

## 参考资源

- [Oh My Zsh copyfile 插件](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/copyfile)
- [Oh My Zsh 官方文档](https://github.com/ohmyzsh/ohmyzsh)

