# Zsh 插件目录

Zsh 功能插件及其专属配置集中在：

```text
plugins/zsh-plugins.zsh
```

文件只保留实际会生效的配置：

- 各插件的 `zinit light` 加载调用
- 插件专属环境变量、`zstyle` 和 hook
- 必须遵守的加载顺序

## 加载阶段

```text
zsh_plugins_load_pre_compinit   zsh-completions
zsh_plugins_load_post_compinit  fzf-tab + fzf-tab 配置
zsh_plugins_load_main           其余 Shell 插件；语法高亮最后加载
```

三个阶段只是为了满足 Zsh 的加载顺序，所有 Shell 功能插件和对应配置仍然在同一个文件里。

## 修改插件

```bash
$EDITOR ~/dotfiles/plugins/zsh-plugins.zsh
```

新增插件时：

1. 在对应加载阶段加入真实的 `zinit light owner/repo`。
2. 在调用附近写清楚插件作用。
3. 把该插件的环境变量、`zstyle` 和 hook 配置放在同一处。

检查：

```bash
zsh -d -n ./plugins/zsh-plugins.zsh
TERM=xterm-256color zsh -lic 'source ./zshrc >/dev/null 2>&1; true'
git diff --check
```

## 其他 Zinit 配置

CLI 工具和 Prompt 不是 Zsh 功能插件，保持在各自的有效配置文件中：

- `plugins/tools/tools.zsh`：btop、bat、fd、ripgrep、atuin 等命令行工具
- `plugins/prompt/prompt.zsh`：Starship Prompt
- `plugins/fzf/fzf.zsh`：fzf 函数和本地系统集成
