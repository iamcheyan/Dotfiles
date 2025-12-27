# You Should Use - 别名提醒插件

## 简介

You Should Use 是一个智能的 Zsh 插件，当您输入命令时，如果存在对应的别名，它会提醒您使用该别名。这有助于您更好地利用已定义的别名，提高工作效率并养成使用别名的习惯。

**官方仓库**: https://github.com/MichaelAquilina/zsh-you-should-use

## 安装

You Should Use 已通过 Zinit 自动安装和管理。插件配置位于 `~/.dotfiles/plugins/plugins/plugins.zsh`。

## 基本使用

### 自动提醒

插件会自动检测您输入的命令，如果存在对应的别名，会在命令执行前或执行后显示提醒消息。

**示例**:
```bash
# 如果您定义了别名: alias ll='ls -lh'
$ ls -lh
Found existing alias for "ls -lh". You should use: "ll"

# 如果您定义了别名: alias gs='git status'
$ git status
Found existing alias for "git status". You should use: "gs"
```

### 检查别名使用情况

使用 `check_alias_usage` 命令来分析您的别名使用情况：

```bash
# 分析所有历史记录中的别名使用情况
check_alias_usage

# 限制分析最近 N 条历史记录
check_alias_usage 200
```

**输出示例**:
```
924: curl='curl --silent'
652: gco='git checkout'
199: json='jq '.' -C'
157: less='less -R'
100: ll='ls -lh --group-directories-first'
93: vim='nvim'
```

这个功能可以帮助您：
- 了解哪些别名使用频率高
- 发现未使用的别名（可以考虑删除）
- 提醒自己记住常用的别名

## 配置选项

### 消息位置

默认情况下，提醒消息会在命令**执行前**显示。您可以配置为在命令**执行后**显示：

```zsh
# 在 ~/.dotfiles/plugins/local/local.zsh 中添加
export YSU_MESSAGE_POSITION="after"
```

### 显示模式

默认只显示最佳匹配的别名。您可以配置为显示所有匹配的别名：

```zsh
# 只显示最佳匹配（默认）
export YSU_MODE=BESTMATCH

# 显示所有匹配
export YSU_MODE=ALL
```

### 自定义消息格式

默认消息格式为：
```
Found existing %alias_type for "%command". You should use: "%alias"
```

您可以自定义消息格式：

```zsh
# 自定义消息格式（红色显示）
export YSU_MESSAGE_FORMAT="$(tput setaf 1)Hey! I found this %alias_type for %command: %alias$(tput sgr0)"

# 使用其他颜色
export YSU_MESSAGE_FORMAT="$(tput setaf 3)💡 Tip: Use '%alias' instead of '%command'$(tput sgr0)"
```

**可用变量**:
- `%alias_type`: 别名类型（alias、git alias、global alias）
- `%command`: 用户输入的命令
- `%alias`: 找到的匹配别名

### 忽略特定别名

如果您不想让某些别名显示提醒，可以将它们添加到忽略列表：

```zsh
# 忽略特定别名
export YSU_IGNORED_ALIASES=("g" "ll" "gs")

# 忽略全局别名
export YSU_IGNORED_GLOBAL_ALIASES=("...")
```

### 硬核模式

硬核模式会**强制**您使用别名。如果输入的命令有对应的别名但没有使用，命令将**不会执行**。

```zsh
# 启用硬核模式（谨慎使用！）
export YSU_HARDCORE=1
```

**示例**:
```bash
$ export YSU_HARDCORE=1
$ ls -lh
Found existing alias for "ls -lh". You should use: "ll"
You Should Use hardcore mode enabled. Use your aliases!
$ ll
total 8.0K
-rw-r--r-- 1 user users 2.4K Jun 19 20:46 README.md
```

### 选择性硬核模式

如果您只想对特定别名启用硬核模式，可以使用：

```zsh
# 只对特定别名启用硬核模式
export YSU_HARDCORE_ALIASES=("gs" "ll" "gco")
```

**注意**:
- `YSU_HARDCORE_ALIASES` 只在 `YSU_HARDCORE` 未设置时生效
- 如果 `YSU_HARDCORE=1`，所有别名都会强制执行
- 在 `YSU_IGNORED_ALIASES` 中的别名不会触发硬核模式

### 临时禁用

您可以临时禁用提醒功能：

```bash
# 禁用提醒
disable_you_should_use

# 重新启用提醒
enable_you_should_use
```

## 使用场景

### 1. 学习新别名

当您定义新别名后，插件会提醒您使用，帮助您快速记住：

```bash
# 定义新别名
alias gco='git checkout'

# 下次输入 git checkout 时会提醒
$ git checkout main
Found existing alias for "git checkout". You should use: "gco"
```

### 2. 发现未使用的别名

使用 `check_alias_usage` 来发现未使用的别名：

```bash
check_alias_usage
# 如果某个别名从未使用，可以考虑删除或提醒自己使用
```

### 3. 团队协作

在团队环境中，可以确保每个人都使用统一的别名，提高协作效率。

### 4. 强制使用最佳实践

使用硬核模式可以强制使用别名，帮助养成良好习惯。

## 配置示例

### 基础配置

在 `~/.dotfiles/plugins/local.zsh` 中添加：

```zsh
# You Should Use 配置
# 消息在执行后显示
export YSU_MESSAGE_POSITION="after"

# 显示所有匹配的别名
export YSU_MODE=ALL

# 忽略一些常用但不想提醒的别名
export YSU_IGNORED_ALIASES=("ll" "la")
```

### 硬核模式配置

```zsh
# 只对特定别名启用硬核模式
export YSU_HARDCORE_ALIASES=("gs" "gco" "gp")
```

### 自定义消息配置

```zsh
# 使用彩色和 emoji 的自定义消息
export YSU_MESSAGE_FORMAT="$(tput setaf 2)✨ Found alias: $(tput setaf 3)%alias$(tput setaf 2) for $(tput setaf 1)%command$(tput sgr0)"
```

## 支持的别名类型

插件支持以下类型的别名：

1. **普通别名** (`alias`): 使用 `alias` 命令定义的别名
2. **Git 别名**: Git 配置中的别名（`git config --global alias.xxx`）
3. **全局别名** (`global alias`): 使用 `alias -g` 定义的全局别名

## 实用技巧

### 1. 定期检查别名使用情况

定期运行 `check_alias_usage` 来了解您的别名使用习惯：

```bash
# 每周检查一次
check_alias_usage
```

### 2. 逐步启用硬核模式

不要一开始就启用全局硬核模式，而是：

1. 先使用默认模式观察
2. 使用 `YSU_HARDCORE_ALIASES` 对特定别名启用硬核模式
3. 逐步增加硬核模式的别名
4. 最后考虑启用全局硬核模式

### 3. 忽略干扰性别名

某些别名可能过于常见或干扰性太强，可以添加到忽略列表：

```zsh
# 忽略一些基础别名
export YSU_IGNORED_ALIASES=("ll" "la" "l" ".." "...")
```

### 4. 结合别名管理

与 `aliases.conf` 文件结合使用，确保别名定义清晰：

```bash
# 查看所有别名
alias

# 检查别名使用情况
check_alias_usage
```

## 故障排除

### 插件未工作

1. **检查插件是否加载**:
   ```bash
   zinit list | grep you-should-use
   ```

2. **重新加载配置**:
   ```bash
   source ~/.zshrc
   ```

3. **检查别名是否定义**:
   ```bash
   alias | grep <别名名>
   ```

### 消息未显示

1. **检查别名是否在忽略列表中**:
   ```bash
   echo $YSU_IGNORED_ALIASES
   ```

2. **检查消息位置设置**:
   ```bash
   echo $YSU_MESSAGE_POSITION
   ```

3. **测试插件**:
   ```bash
   # 定义一个测试别名
   alias test='echo test'
   # 使用完整命令
   echo test
   ```

### 硬核模式问题

如果硬核模式导致命令无法执行：

1. **临时禁用**:
   ```bash
   disable_you_should_use
   ```

2. **移除硬核模式**:
   ```bash
   unset YSU_HARDCORE
   unset YSU_HARDCORE_ALIASES
   ```

3. **检查别名定义**:
   ```bash
   # 确保别名正确定义
   alias | grep <别名名>
   ```

## 最佳实践

### 1. 渐进式使用

- 开始时使用默认设置
- 观察哪些别名经常被提醒
- 逐步调整配置

### 2. 合理配置忽略列表

不要忽略太多别名，否则插件就失去了意义。只忽略那些：
- 过于基础、不需要提醒的别名
- 干扰性太强的别名
- 您已经非常熟悉的别名

### 3. 定期审查

定期运行 `check_alias_usage` 来：
- 发现未使用的别名
- 了解使用频率
- 优化别名定义

### 4. 团队共享配置

如果是团队使用，可以：
- 共享 `YSU_IGNORED_ALIASES` 配置
- 统一别名定义
- 使用硬核模式确保一致性

## 相关资源

- [官方 GitHub 仓库](https://github.com/MichaelAquilina/zsh-you-should-use)
- [问题追踪](https://github.com/MichaelAquilina/zsh-you-should-use/issues)

## 注意事项

1. **硬核模式**: 启用硬核模式前请确保您已经熟悉所有别名，否则可能会影响正常工作流程。

2. **性能**: 插件会在每个命令执行时检查别名，对于大量别名的系统可能会有轻微的性能影响。

3. **兼容性**: 插件与大多数 Zsh 插件兼容，但如果遇到问题，可以尝试调整加载顺序。

