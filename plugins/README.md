# Zsh 插件目录

所有 Zsh 插件及其专属配置集中在一个文件：

```text
plugins/zsh-plugins.zsh
```

这个文件包含：

- 插件名称、GitHub 仓库、用途和启用状态
- 所有 `zinit` 加载调用
- `zsh-autosuggestions`、`zsh-vi-mode`、`fzf-tab` 等插件配置
- 加载顺序和阶段函数
- `zsh-plugins` / `plugin-status` 状态检查命令

## 查看加载状态

启动 Zsh 后执行：

```zsh
zsh-plugins
# 或
plugin-status
```

状态含义：

- `loaded`：当前 shell 已实际加载
- `cached`：已经下载到 Zinit，但当前 shell 未加载
- `missing`：启用但尚未下载
- `disabled`：清单中保留但明确停用

## 为什么文件内有三个加载阶段

插件仍然全部集中在 `zsh-plugins.zsh`，只是由 `zshrc` 在正确的时机调用：

```text
zsh_plugins_load_pre_compinit   zsh-completions
zsh_plugins_load_post_compinit  fzf-tab + fzf-tab 配置
zsh_plugins_load_main           其余插件，fast-syntax-highlighting 最后
```

这样既能让用户一眼看到完整插件列表，又不会破坏 Zsh 的补全和语法高亮顺序。

## 修改插件

只需要编辑：

```bash
$EDITOR ~/dotfiles/plugins/zsh-plugins.zsh
```

新增插件时同时完成三件事：

1. 加入 `_ZSH_PLUGIN_ORDER`。
2. 加入名称和用途说明。
3. 在对应阶段的函数中加入 `_zsh_plugin_light owner/repo` 及其配置。

检查：

```bash
zsh -n ./zshrc
zsh -n ./plugins/zsh-plugins.zsh
git diff --check
```

## 非 Shell 插件

`plugins/tools/tools.zsh` 中的 btop、bat、fd、ripgrep、atuin 等是通过 Zinit 下载的 CLI 工具，不是 Zsh 功能插件，因此继续单独管理。

`plugins/prompt/prompt.zsh` 中的 Starship 也属于 Prompt/CLI 工具层，不计入 Shell 插件清单。
