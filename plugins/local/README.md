# 本地机器特定配置

## 简介

此文件用于存放机器特定的配置，包括字体安装、NVM 配置等。这些配置通常因机器而异，不应提交到版本控制系统（或使用条件判断）。

## 文件位置

- **配置文件**: `~/.dotfiles/plugins/local/local.zsh`
- **加载位置**: 在 `~/.zshrc` 中最后加载（在其他配置之后）

## 功能

### 1. 字体安装功能

提供交互式字体安装功能：

```zsh
install:font() {
    bash "$HOME/.dotfiles/scripts/install/install_font.sh" "$@"
}
```

**功能**:
- 自动检测字体是否已安装
- 首次启动时询问是否安装
- 可通过命令手动安装

**使用**:
```bash
# 手动安装字体
install:font
```

### 2. 自动字体检测

在 Zsh 初始化时（仅在交互式 shell 中）自动检测字体：

- **Linux**: 检查 `fc-list` 或 `~/.fonts` 目录
- **macOS**: 检查 `~/Library/Fonts` 目录

如果未安装，会在首次启动时询问是否安装。

### 3. NVM (Node Version Manager) 配置

自动加载 NVM（如果已安装）：

```zsh
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi
```

**功能**:
- 自动检测 NVM 安装
- 自动加载 NVM 和补全
- 设置 `NVM_DIR` 环境变量

## 使用说明

### 字体安装

#### 自动安装

首次启动 Zsh 时，如果检测到字体未安装，会询问：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Meslo 字体未安装
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
是否要安装 Meslo 字体？(y/N):
```

输入 `y` 确认安装，输入 `N` 跳过。

#### 手动安装

```bash
# 随时可以手动安装
install:font
```

#### 跳过自动询问

如果不想在启动时询问，可以：

1. 手动安装字体
2. 或者创建标记文件：`touch ~/.dotfiles/.font_install_asked`

### NVM 使用

如果已安装 NVM，会自动加载：

```bash
# 查看已安装的 Node 版本
nvm list

# 安装新版本
nvm install 20

# 使用特定版本
nvm use 20

# 设置默认版本
nvm alias default 20
```

## 自定义配置

### 添加机器特定配置

可以在此文件中添加机器特定的配置：

```zsh
# 示例：设置机器特定的 PATH
if [[ "$HOSTNAME" == "my-laptop" ]]; then
    export PATH="$HOME/custom/bin:$PATH"
fi

# 示例：设置机器特定的别名
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi
```

### 添加环境变量

```zsh
# 机器特定的环境变量
export MY_CUSTOM_VAR="value"

# 条件设置
if [[ -d "$HOME/custom" ]]; then
    export CUSTOM_PATH="$HOME/custom"
fi
```

### 添加函数

```zsh
# 机器特定的函数
my_custom_function() {
    # 函数内容
}
```

## 最佳实践

### 1. 使用条件判断

对于可能不存在的工具或目录，使用条件判断：

```zsh
if [[ -d "$HOME/custom" ]]; then
    # 配置
fi
```

### 2. 检查操作系统

使用 `$OSTYPE` 检查操作系统：

```zsh
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS 特定配置
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux 特定配置
fi
```

### 3. 检查命令存在

在使用命令前检查是否存在：

```zsh
if command -v custom_command >/dev/null 2>&1; then
    # 使用命令
fi
```

### 4. 避免硬编码路径

使用环境变量和 `$HOME`：

```zsh
# 好
export PATH="$HOME/custom/bin:$PATH"

# 不好
export PATH="/home/username/custom/bin:$PATH"
```

## 故障排除

### 字体安装问题

1. **检查脚本是否存在**:
   ```bash
   ls -la ~/.dotfiles/scripts/install/install_font.sh
   ```

2. **手动运行脚本**:
   ```bash
   bash ~/.dotfiles/scripts/install/install_font.sh
   ```

3. **检查权限**:
   ```bash
   chmod +x ~/.dotfiles/scripts/install/install_font.sh
   ```

### NVM 不工作

1. **检查 NVM 是否安装**:
   ```bash
   ls -la ~/.nvm
   ```

2. **手动加载 NVM**:
   ```bash
   source ~/.nvm/nvm.sh
   ```

3. **检查 NVM_DIR**:
   ```bash
   echo $NVM_DIR
   ```

### 配置未生效

1. **检查文件是否加载**:
   ```bash
   # 在 local.zsh 中添加测试
   echo "local.zsh loaded"
   ```

2. **检查加载顺序**: 确保在 `.zshrc` 中最后加载

3. **重新加载配置**:
   ```bash
   source ~/.zshrc
   ```

## 相关文件

- **字体安装脚本**: `~/.dotfiles/scripts/install/install_font.sh`
- **主配置文件**: `~/.zshrc` - 加载此文件

## 注意事项

1. **不要提交敏感信息**: 此文件可能包含机器特定的配置，注意不要提交敏感信息
2. **使用条件判断**: 对于可能不存在的工具，使用条件判断
3. **保持简洁**: 只在此文件中放置机器特定的配置，通用配置应放在其他文件中

