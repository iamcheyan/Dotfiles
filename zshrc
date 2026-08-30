# 如果 TERM 对应的 terminfo 条目缺失（例如卸载 kitty 后残留 xterm-kitty），
# 退回到通用值，避免 tput / 终端程序启动时报 "unknown terminal"
if [[ -n "$TERM" ]] && ! infocmp -- "$TERM" >/dev/null 2>&1; then
    export TERM=xterm-256color
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

# Zsh 插件唯一配置文件：清单、加载调用、插件专属配置和状态检查
source ~/dotfiles/plugins/zsh-plugins.zsh

# 提示符主题，显示目录、Git 状态和环境信息
if [[ -t 1 ]]; then
  source ~/dotfiles/plugins/prompt/prompt.zsh
fi

# 核心工具集合：通过 zinit 安装命令行工具，并初始化 pyenv/direnv/atuin 等 shell 集成
source ~/dotfiles/plugins/tools/tools.zsh

# zsh-completions 必须在 compinit 前加载
zsh_plugins_load_pre_compinit

# 补全系统：初始化 compinit 和 PATH
source ~/dotfiles/plugins/completion/completion.zsh
zsh_plugins_load_post_compinit

# 首次调用 node/npm/npx/corepack/fnm 时才初始化 fnm 环境
source "${HOME}/dotfiles/scripts/setup/setup_fnm.sh"

# 其余 Shell 插件及其专属配置；语法高亮在此阶段最后加载
zsh_plugins_load_main

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
[[ -f ~/.config/aliases.conf ]] && source ~/.config/aliases.conf
[[ -f ~/dotfiles/aliases.conf ]] && source ~/dotfiles/aliases.conf

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

# fnm lazy loader 已在 setup_fnm.sh (line 51) 中设置，这里不再重复初始化。

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<
