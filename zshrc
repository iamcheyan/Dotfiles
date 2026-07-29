# 如果 TERM 对应的 terminfo 条目缺失（例如卸载 kitty 后残留 xterm-kitty），
# 退回到通用值，避免 tput / 终端程序启动时报 "unknown terminal"
if [[ -n "$TERM" ]] && ! infocmp -- "$TERM" >/dev/null 2>&1; then
    export TERM=xterm-256color
fi

# WSL 上如果 Windows 挂载（/mnt/c 等）异常，zsh 在扫描 PATH 时会卡死。
# 交互 shell 里先移除 /mnt 下的 PATH 项，优先保证 shell 可用性。
if [[ -n "$WSL_DISTRO_NAME" ]]; then
    typeset -gaU path
    path=(${path:#/mnt/*})
    export PATH="${(j/:/)path}"
fi

export HISTSIZE=100000
export SAVEHIST=100000
export HISTFILE=~/.zsh_history

setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS   # 移除历史记录中的多余空格
setopt HIST_VERIFY          # 执行前允许编辑历史扩展
setopt INC_APPEND_HISTORY   # 立即追加历史（而不是退出时）
setopt AUTO_CD              # 启用 AUTO_CD：输入目录路径时自动 cd

# SSH 会话中降级 TERM，避免远程服务器不认识 xterm-kitty
if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    export TERM=xterm-256color
fi

export PATH="$HOME/.fzf/bin:$PATH"

# zinit: 插件管理器，负责下载、缓存和加载后面的 zsh 插件/命令
source ~/dotfiles/plugins/zinit/zinit.zsh

# 提示符主题，显示目录、Git 状态和环境信息
if [[ -t 1 ]]; then
  source ~/dotfiles/plugins/prompt/prompt.zsh
fi

# 核心工具集合：通过 zinit 安装命令行工具，并初始化 pyenv/direnv/atuin 等 shell 集成
source ~/dotfiles/plugins/tools/tools.zsh

# grok: PATH 和 fpath 必须在 compinit 之前设置，否则补全不生效
# （原来 grok installer 在文件末尾跑了一次冗余 compinit，现在提前到此处避免重复）
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)

# 补全系统：初始化 compinit、额外补全定义和 fzf-tab 补全界面
source ~/dotfiles/plugins/completion/completion.zsh

# evalcache: 缓存 init 脚本输出，减少 atuin/zoxide/direnv 这类 hook 的重复开销
zinit light mroth/evalcache

# 首次调用 node/npm/npx/corepack/fnm 时才初始化 fnm 环境
source "${HOME}/dotfiles/scripts/setup/setup_fnm.sh"

# zsh-autosuggestions: 根据历史记录提供自动建议
zinit light zsh-users/zsh-autosuggestions
# autosuggestions 配置
ZSH_AUTOSUGGEST_STRATEGY=(history completion)  # 优先历史，然后补全
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"         # 灰色显示建议
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100            # 大命令禁用建议，提升性能
ZSH_AUTOSUGGEST_USE_ASYNC=1                    # 异步获取建议

# zsh-autopair: 自动补全括号、引号等
zinit light hlissner/zsh-autopair

# zsh-vi-mode: 为命令行编辑提供 Vim 模式和模式切换
# 必须在 autosuggestions 之前加载，避免按键绑定冲突
zinit ice lucid
zinit light jeffreytse/zsh-vi-mode

# 配置 zsh-vi-mode
export ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT  # 每次新行开始默认进入插入模式
function zvm_after_init() {
  zvm_bindkey viins '^[[A' atuin-up-search
  zvm_bindkey viins '^[OA' atuin-up-search
}

# 其他增强插件集合：autosuggestions、语法高亮、autopair 等
# 这里直接 source 本地文件，避免 zinit 对本地 snippet 的缓存副本滞后
# 具体插件是否异步加载，仍由 plugins.zsh 内部的各个 zinit ice 控制
source ~/dotfiles/plugins/plugins/plugins.zsh

# fzf 相关函数和默认选项：ff/rf/zd/zc/y 等交互工具
# 这里必须同步加载，否则 ff/rf 在新 shell 中可能不存在
source ~/dotfiles/plugins/fzf/fzf.zsh

# atuin: 增强版 shell 历史，支持更强的搜索和历史同步
# 这里初始化 shell hook，并用 evalcache 缓存其输出
if command -v atuin > /dev/null; then
  _evalcache atuin init zsh
fi

# zoxide: 智能目录跳转，替代传统 cd 记忆能力较弱的问题
# 这里初始化 shell hook，并用 evalcache 缓存其输出
if command -v zoxide > /dev/null; then
  _evalcache zoxide init zsh
  # zoxide + fzf 交互式目录选择
  alias zi='z -i'      # 交互式选择
  alias za='z -a'      # 添加目录
  alias zr='z -r'      # 移除目录
fi


# vi 别名：优先使用 nvim，其次 vim，最后 vi
unalias vi 2>/dev/null
vi() {
    if command -v nvim &> /dev/null; then
        nvim "$@"
    elif command -v vim &> /dev/null; then
        vim "$@"
    else
        command vi "$@"
    fi
}

# 设置编辑器环境变量（ranger 等工具会使用）
# 优先使用 nvim，其次 vim，最后 vi
if command -v nvim &> /dev/null; then
    export EDITOR=nvim
    export VISUAL=nvim
elif command -v vim &> /dev/null; then
    export EDITOR=vim
    export VISUAL=vim
else
    export EDITOR=vi
    export VISUAL=vi
fi

# aliases
[[ -f ~/dotfiles/aliases.conf ]] && source ~/dotfiles/aliases.conf
[[ -f ~/chezmoi/dot_config/aliases.conf ]] && source ~/chezmoi/dot_config/aliases.conf

# SSH 会话时在窗口标题前加 [SSH] 标记
function _update_window_title() {
    local prefix=""
    if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
        prefix="[SSH] "
    fi
    print -Pn "\e]2;${prefix}%n@%m: %~\a"
}
precmd_functions+=(_update_window_title)

# vifm
v() {
  local tmp="$(mktemp -t vifm-cwd.XXXXXX)"
  vifm --choose-dir="$tmp" "$@"
  if [ -f "$tmp" ]; then
    cd "$(cat "$tmp")"
    rm -f "$tmp"
  fi
}

# mimocode
export PATH="$HOME/.mimocode/bin:$PATH"


# bun completions
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# npm global packages (user-level prefix)
export PATH="$HOME/.npm-global/bin:$PATH"

# pi wrapper (points at user-installed pi-coding-agent, not /usr/bin/pi)
export PATH="$HOME/.pi/bin:$PATH"

# fnm lazy loader 已在 setup_fnm.sh (line 51) 中设置，这里不再重复初始化。

# tmux-persist: Ctrl-d 退出 shell 前自动保存当前 session
# 确保退出会话时 pane 内容和运行中的进程被快照捕获
# 用 #{session_name} 而非 #{client_session}：后者在无 attached client 时为空，
# 前者始终能从当前 pane 上下文解析出 session 名
if [[ -n "$TMUX" ]]; then
  zshexit() {
    local script
    script="$(tmux show-option -gqv @persist-save-script-path)"
    [[ -n "$script" ]] && "$script" quiet "$(tmux display-message -p '#{session_name}')" >/dev/null 2>&1
  }
fi
