# Powerlevel10k 提示符配置

## 简介

此文件负责配置 Powerlevel10k (p10k) 主题，这是一个高度可定制的 Zsh 提示符主题，提供快速启动和丰富的配置选项。

**官方仓库**: https://github.com/romkatv/powerlevel10k

## 文件位置

- **配置文件**: `~/.dotfiles/plugins/prompt/prompt.zsh`
- **加载位置**: 在 `~/.zshrc` 中，在 zinit 初始化之后、其他插件之前加载

## 功能

### 安装 Powerlevel10k

通过 Zinit 安装 Powerlevel10k：

```zsh
zinit ice depth=1
zinit light romkatv/powerlevel10k
```

### 加载用户配置

如果存在用户自定义的 p10k 配置文件，会自动加载：

```zsh
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
```

## 使用说明

### 配置提示符

运行配置向导来自定义提示符：

```bash
p10k configure
```

配置向导会引导您完成：
- 提示符样式选择
- 颜色方案
- 显示的元素（Git 状态、时间、路径等）
- 各种显示选项

### 手动编辑配置

编辑 `~/.p10k.zsh` 文件来自定义提示符：

```bash
nvim ~/.p10k.zsh
```

### Instant Prompt

Powerlevel10k 支持 Instant Prompt，可以在 Zsh 初始化完成前显示提示符，提供更快的启动体验。

Instant Prompt 配置在 `~/.zshrc` 的开头：

```zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
```

## 常用配置

### 显示 Git 状态

在 `~/.p10k.zsh` 中配置 Git 状态显示：

```zsh
typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '
typeset -g POWERLEVEL9K_VCS_GIT_ICON='\uF1D3 '
```

### 自定义路径显示

```zsh
# 缩短路径显示
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
```

### 显示时间

```zsh
# 在右侧显示时间
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(time)
```

## 故障排除

### 提示符不显示

1. **检查插件是否加载**:
   ```bash
   zinit list | grep powerlevel10k
   ```

2. **重新加载配置**:
   ```bash
   source ~/.zshrc
   ```

3. **检查配置文件**:
   ```bash
   ls -la ~/.p10k.zsh
   ```

### Instant Prompt 警告

如果看到 Instant Prompt 警告，可以：

1. **设置为 quiet 模式**（已在配置中）:
   ```zsh
   typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
   ```

2. **禁用 Instant Prompt**:
   ```zsh
   typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
   ```

### 字体问题

如果提示符显示异常字符，需要安装 Nerd Fonts：

```bash
# 使用字体安装脚本
install:font
```

## 相关文件

- **Zinit 配置**: `~/.dotfiles/plugins/zinit/zinit.zsh`
- **用户配置**: `~/.p10k.zsh` - Powerlevel10k 用户配置文件

## 参考资源

- [Powerlevel10k GitHub](https://github.com/romkatv/powerlevel10k)
- [Powerlevel10k 配置指南](https://github.com/romkatv/powerlevel10k#configuration-wizard)

