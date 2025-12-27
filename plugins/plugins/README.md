# Zsh 功能插件配置

## 简介

此文件负责配置和管理 Zsh 的功能插件，包括自动建议、语法高亮、vim 模式、以及各种实用插件。这些插件增强了 Zsh 的功能和用户体验。

## 文件位置

- **配置文件**: `~/.dotfiles/plugins/plugins/plugins.zsh`
- **加载位置**: 在 `~/.zshrc` 中，在 `completion.zsh` 之后加载

## 已安装的插件

### 核心功能插件

#### 1. zsh-vi-mode

Vim 键绑定模式，提供 Vim 风格的编辑体验。

```zsh
zinit light jeffreytse/zsh-vi-mode
```

**功能**:
- Vim 模式的命令编辑
- 可视模式选择
- 文本对象操作
- 自定义键绑定

**加载顺序**: 必须在 `zsh-autosuggestions` 之前加载，因为会影响键绑定。

#### 2. zsh-autosuggestions

自动建议插件，根据历史记录提供命令建议。

```zsh
zinit light zsh-users/zsh-autosuggestions
```

**功能**:
- 根据历史记录自动建议
- 使用 `→` 键接受建议
- 使用 `Ctrl+→` 接受部分建议

#### 3. zsh-syntax-highlighting

语法高亮插件，实时高亮命令语法。

```zsh
zinit light zsh-users/zsh-syntax-highlighting
```

**功能**:
- 命令语法高亮
- 错误命令红色显示
- 有效命令绿色显示

**加载顺序**: 必须最后加载，以确保正确高亮。

### Oh My Zsh 插件片段

#### 4. sudo

自动在命令前添加 `sudo`（双击 `Esc` 键）。

```zsh
zinit snippet OMZP::sudo
```

**使用**: 输入命令后，双击 `Esc` 键自动添加 `sudo`。

#### 5. git

Git 相关的别名和函数。

```zsh
zinit snippet OMZP::git
```

**功能**: 提供 Git 相关的别名和辅助函数。

#### 6. copypath

复制文件或目录路径到剪贴板。

```zsh
zinit snippet OMZP::copypath
```

**使用**: `copypath` 或 `copypath <文件/目录>`

#### 7. copyfile

复制文件内容到剪贴板。

```zsh
zinit snippet OMZP::copyfile
```

**使用**: `copyfile <文件名>`

### 其他插件

#### 8. you-should-use

提醒使用已存在的别名。

```zsh
zinit light MichaelAquilina/zsh-you-should-use
```

**功能**: 当输入命令时，如果存在对应别名，会显示提醒。

## 配置选项

### AUTO_CD

启用自动 cd 功能，输入目录路径时自动切换：

```zsh
setopt AUTO_CD
```

**使用**: 直接输入目录路径，无需 `cd` 命令。

## 使用说明

### 插件管理

#### 查看已安装的插件

```bash
zinit list
```

#### 更新插件

```bash
# 更新所有插件
zinit update

# 更新特定插件
zinit update jeffreytse/zsh-vi-mode
```

#### 删除插件

```bash
zinit delete jeffreytse/zsh-vi-mode
```

### 插件使用

#### zsh-vi-mode

- 按 `Esc` 进入普通模式
- 使用 `h`, `j`, `k`, `l` 移动光标
- 使用 `i` 进入插入模式
- 使用 `v` 进入可视模式

#### zsh-autosuggestions

- 输入命令时自动显示建议（灰色）
- 按 `→` 键接受完整建议
- 按 `Ctrl+→` 接受部分建议

#### copypath / copyfile

```bash
# 复制当前目录路径
copypath

# 复制指定文件路径
copypath ~/.zshrc

# 复制文件内容
copyfile ~/.zshrc
```

#### you-should-use

自动提醒使用别名，无需额外操作。

## 添加新插件

### 使用 Zinit 安装

```zsh
# 从 GitHub 安装
zinit light owner/repo

# 从 Oh My Zsh 安装片段
zinit snippet OMZP::plugin-name
```

### 示例

```zsh
# 添加新插件
zinit light zsh-users/zsh-history-substring-search
```

## 加载顺序

正确的加载顺序很重要：

1. **zsh-vi-mode**: 必须在 autosuggestions 之前
2. **zsh-autosuggestions**: 在 vi-mode 之后
3. **zsh-syntax-highlighting**: 必须最后加载

## 故障排除

### 插件未加载

1. **检查插件是否安装**:
   ```bash
   zinit list | grep plugin-name
   ```

2. **重新加载配置**:
   ```bash
   source ~/.zshrc
   ```

3. **检查加载顺序**: 确保加载顺序正确

### 键绑定冲突

如果键绑定不工作：

1. **检查加载顺序**: 确保 `zsh-vi-mode` 在 `zsh-autosuggestions` 之前
2. **检查其他插件**: 可能有其他插件覆盖了键绑定

### 语法高亮不工作

1. **检查加载顺序**: 确保 `zsh-syntax-highlighting` 最后加载
2. **检查插件是否加载**:
   ```bash
   zinit list | grep syntax-highlighting
   ```

## 相关文件

- **补全配置**: `~/.dotfiles/plugins/completion/completion.zsh` - 补全系统配置
- **工具配置**: `~/.dotfiles/plugins/tools/tools.zsh` - CLI 工具安装
- **fzf 配置**: `~/.dotfiles/plugins/fzf/fzf.zsh` - fzf 详细配置

## 参考资源

- [zsh-vi-mode GitHub](https://github.com/jeffreytse/zsh-vi-mode)
- [zsh-autosuggestions GitHub](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting GitHub](https://github.com/zsh-users/zsh-syntax-highlighting)
- [Oh My Zsh 插件列表](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins)

