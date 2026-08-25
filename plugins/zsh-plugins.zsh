# Zsh 插件总配置
#
# 这里是唯一需要查看和修改的 Zsh 插件文件：
# - 每个插件的 zinit 加载调用
# - 插件专属环境变量、zstyle 和 hook 配置
#
# 加载分为三个阶段，是为了遵守 Zsh 的顺序约束：
#   pre-compinit  -> zsh-completions
#   post-compinit -> fzf-tab
#   main          -> 其余插件；fast-syntax-highlighting 最后

# ==============================
# 阶段 1：compinit 之前
# ==============================
zsh_plugins_load_pre_compinit() {
  zinit ice blockf
  # 额外的命令补全定义，例如 Docker、Git 等工具的补全。
  zinit light zsh-users/zsh-completions
}

# ==============================
# 阶段 2：compinit 之后
# ==============================
zsh_plugins_load_post_compinit() {
  # fzf-tab 必须在 compinit 后、autosuggestions 前加载。
  # 用 fzf 替换 Zsh 默认补全菜单，支持模糊搜索和预览。
  zinit light Aloxaf/fzf-tab

  zstyle ':completion:*:git-checkout:*' sort false
  zstyle ':completion:*:descriptions' format '[%d]'
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  zstyle ':completion:*' menu no

  if command -v eza >/dev/null 2>&1; then
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always $realpath'
  else
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:z:*' fzf-preview 'ls -1 --color=always $realpath'
  fi
  zstyle ':fzf-tab:*' switch-group '<' '>'
}

# ==============================
# 阶段 3：普通 Shell 插件及其配置
# ==============================
zsh_plugins_load_main() {
  # evalcache：缓存 shell hook 的初始化输出。
  zinit light mroth/evalcache

  # zsh-vi-mode：提供 Vim 风格的命令行编辑模式。
  # 必须在 autosuggestions 前加载，避免按键绑定冲突。
  zinit ice lucid
  zinit light jeffreytse/zsh-vi-mode
  export ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
  function zvm_after_init() {
    zvm_bindkey viins '^[[A' atuin-up-search
    zvm_bindkey viins '^[OA' atuin-up-search
  }

  # zsh-autosuggestions：根据历史和补全结果显示命令建议。
  zinit light zsh-users/zsh-autosuggestions
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100
  ZSH_AUTOSUGGEST_USE_ASYNC=1

  # zsh-autopair：自动补全括号和引号。
  zinit light hlissner/zsh-autopair
  # you-should-use：提醒使用已经存在的别名。
  zinit light MichaelAquilina/zsh-you-should-use

  # 必须最后加载，避免被后续插件覆盖高亮规则。
  zinit light zdharma-continuum/fast-syntax-highlighting
}
