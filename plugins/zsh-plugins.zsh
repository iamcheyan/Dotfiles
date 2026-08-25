# Zsh 插件总配置
#
# 这里是唯一需要查看和修改的 Zsh 插件文件：
# - 插件清单、仓库、用途、启用状态
# - 每个插件的 zinit 加载调用
# - 插件专属环境变量、zstyle 和 hook 配置
#
# 加载分为三个阶段，是为了遵守 Zsh 的顺序约束：
#   pre-compinit  -> zsh-completions
#   post-compinit -> fzf-tab
#   main          -> 其余插件；fast-syntax-highlighting 最后

# ==============================
# 插件清单：新增/停用插件先改这里
# ==============================
typeset -ga _ZSH_PLUGIN_ORDER=(
  # 额外的命令补全定义，例如 Docker、Git 等工具的补全。
  'zsh-users/zsh-completions'
  # 用 fzf 替换 Zsh 默认补全菜单，支持模糊搜索和预览。
  'Aloxaf/fzf-tab'
  # 缓存 atuin、zoxide、direnv 等 shell hook，减少启动开销。
  'mroth/evalcache'
  # 为命令行提供 Vim 风格的 normal/insert 模式和按键绑定。
  'jeffreytse/zsh-vi-mode'
  # 根据历史记录和补全结果显示灰色命令建议。
  'zsh-users/zsh-autosuggestions'
  # 自动补全括号、引号等成对符号。
  'hlissner/zsh-autopair'
  # 输入已有命令的替代别名时给出提醒。
  'MichaelAquilina/zsh-you-should-use'
  # 实时高亮命令语法，必须作为最后一个插件加载。
  'zdharma-continuum/fast-syntax-highlighting'
)

typeset -gA _ZSH_PLUGIN_NAME _ZSH_PLUGIN_PURPOSE _ZSH_PLUGIN_LOADED
_ZSH_PLUGIN_NAME=(
  'zsh-users/zsh-completions' 'zsh-completions'
  'Aloxaf/fzf-tab' 'fzf-tab'
  'mroth/evalcache' 'evalcache'
  'jeffreytse/zsh-vi-mode' 'zsh-vi-mode'
  'zsh-users/zsh-autosuggestions' 'zsh-autosuggestions'
  'hlissner/zsh-autopair' 'zsh-autopair'
  'MichaelAquilina/zsh-you-should-use' 'you-should-use'
  'zdharma-continuum/fast-syntax-highlighting' 'fast-syntax-highlighting'
)
_ZSH_PLUGIN_PURPOSE=(
  'zsh-users/zsh-completions' '额外命令补全定义'
  'Aloxaf/fzf-tab' 'fzf 驱动的补全菜单'
  'mroth/evalcache' '缓存 shell hook 初始化输出'
  'jeffreytse/zsh-vi-mode' 'Vim 风格命令行编辑'
  'zsh-users/zsh-autosuggestions' '历史命令灰色建议'
  'hlissner/zsh-autopair' '括号和引号自动配对'
  'MichaelAquilina/zsh-you-should-use' '提醒已有别名'
  'zdharma-continuum/fast-syntax-highlighting' '命令语法高亮（最后加载）'
)

# 所有实际加载调用都经过这里，状态报告可区分 loaded/cached/missing。
_zsh_plugin_light() {
  local repo="$1"
  shift
  zinit light "$repo" "$@"
  _ZSH_PLUGIN_LOADED[$repo]=1
}

_zsh_plugin_cache_dir() {
  local repo="$1"
  print -r -- "${ZINIT_HOME:-$HOME/.zinit}/plugins/${repo//\//---}"
}

# ==============================
# 阶段 1：compinit 之前
# ==============================
zsh_plugins_load_pre_compinit() {
  zinit ice blockf
  _zsh_plugin_light zsh-users/zsh-completions
}

# ==============================
# 阶段 2：compinit 之后
# ==============================
zsh_plugins_load_post_compinit() {
  # fzf-tab 必须在 compinit 后、autosuggestions 前加载。
  _zsh_plugin_light Aloxaf/fzf-tab

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
  _zsh_plugin_light mroth/evalcache

  # zsh-vi-mode：提供 Vim 风格的命令行编辑模式。
  # 必须在 autosuggestions 前加载，避免按键绑定冲突。
  zinit ice lucid
  _zsh_plugin_light jeffreytse/zsh-vi-mode
  export ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
  function zvm_after_init() {
    zvm_bindkey viins '^[[A' atuin-up-search
    zvm_bindkey viins '^[OA' atuin-up-search
  }

  # zsh-autosuggestions：根据历史和补全结果显示命令建议。
  _zsh_plugin_light zsh-users/zsh-autosuggestions
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100
  ZSH_AUTOSUGGEST_USE_ASYNC=1

  # zsh-autopair：自动补全括号和引号。
  _zsh_plugin_light hlissner/zsh-autopair
  # you-should-use：提醒使用已经存在的别名。
  _zsh_plugin_light MichaelAquilina/zsh-you-should-use

  # 必须最后加载，避免被后续插件覆盖高亮规则。
  _zsh_plugin_light zdharma-continuum/fast-syntax-highlighting
}

# ==============================
# 状态检查
# ==============================
zsh-plugins() {
  local repo name purpose state cache_dir
  local loaded=0 cached=0 missing=0
  print -r -- 'Zsh plugins'
  print -r -- '────────────'
  printf '%-24s %-8s %s\n' 'PLUGIN' 'STATUS' 'PURPOSE'
  for repo in "${_ZSH_PLUGIN_ORDER[@]}"; do
    name="${_ZSH_PLUGIN_NAME[$repo]}"
    purpose="${_ZSH_PLUGIN_PURPOSE[$repo]}"
    cache_dir="$(_zsh_plugin_cache_dir "$repo")"
    if [[ -n "${_ZSH_PLUGIN_LOADED[$repo]}" ]]; then
      state='loaded'; ((loaded++))
    elif [[ -d "$cache_dir" ]]; then
      state='cached'; ((cached++))
    else
      state='missing'; ((missing++))
    fi
    printf '%-24s %-8s %s\n' "$name" "$state" "$purpose"
  done
  print -r -- '────────────'
  printf 'loaded=%d cached=%d missing=%d total=%d\n' "$loaded" "$cached" "$missing" "${#_ZSH_PLUGIN_ORDER[@]}"
}
alias plugin-status='zsh-plugins'
