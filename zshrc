# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# Set instant prompt to quiet to suppress warnings during zinit tool installation
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Instant prompt (p10k)
[[ -r ~/.cache/p10k-instant-prompt.zsh ]] && source ~/.cache/p10k-instant-prompt.zsh

source ~/.dotfiles/plugins/zinit/zinit.zsh
source ~/.dotfiles/plugins/prompt/prompt.zsh
source ~/.dotfiles/plugins/tools/tools.zsh
# completion.zsh 必须在 plugins.zsh 之前加载，因为：
# 1. compinit 需要在 fzf-tab 之前执行
# 2. fzf-tab 需要在 zsh-autosuggestions 之前加载
source ~/.dotfiles/plugins/completion/completion.zsh
source ~/.dotfiles/plugins/plugins/plugins.zsh

# fzf 配置（需要在 tools.zsh 之后加载，因为 fzf 二进制需要先安装）
[[ -f ~/.dotfiles/plugins/fzf/fzf.zsh ]] && source ~/.dotfiles/plugins/fzf/fzf.zsh

# superfile 配置（自动安装功能）
[[ -f ~/.dotfiles/plugins/spf/superfile.zsh ]] && source ~/.dotfiles/plugins/spf/superfile.zsh

[[ -f ~/.dotfiles/plugins/local/local.zsh ]] && source ~/.dotfiles/plugins/local/local.zsh

# vi 别名：优先使用 nvim，其次 vim，最后 vi
vi() {
    if command -v nvim &> /dev/null; then
        nvim "$@"
    elif command -v vim &> /dev/null; then
        vim "$@"
    else
        command vi "$@"
    fi
}

# 设置编辑器环境变量（yazi 等工具会使用）
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

# 加载别名配置
[[ -f ~/.dotfiles/aliases.conf ]] && source ~/.dotfiles/aliases.conf

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
