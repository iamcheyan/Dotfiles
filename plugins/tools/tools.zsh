# 通用 helper（你以后只加工具，不改结构）
zi_cmd() {
  zinit ice as"command" from"gh-r" pick"$2"
  zinit light "$1"
}

# 系统监控
zi_cmd aristocratos/btop btop
zi_cmd ClementTsang/bottom btm
zi_cmd muesli/duf duf
# ncdu: 使用系统包管理器安装: sudo apt install ncdu
# glances: 使用 pip 安装: pip install glances
# htop: 使用系统包管理器安装: sudo apt install htop

# Git / 开发
zi_cmd jesseduffield/lazygit lazygit
zi_cmd dandavison/delta delta
zi_cmd cli/cli gh
# gitui: 使用 cargo 安装: cargo install gitui 或从源码编译

# 文本处理
zi_cmd jqlang/jq jq
zi_cmd mikefarah/yq yq
zi_cmd chmln/sd sd
zi_cmd theryangeary/choose choose
zi_cmd charmbracelet/glow glow
# tealdeer: GitHub releases 不可用，使用系统包管理器安装: sudo apt install tealdeer
# zi_cmd dbrgn/tealdeer tldr

# 网络工具
zi_cmd ducaale/xh xh
# dog: 没有 arm64 版本，使用系统包管理器安装: sudo apt install dog
# zi_cmd ogham/dog dog
# httpie: 使用 pip 安装: pip install httpie

# 文件工具
zi_cmd sharkdp/bat bat
# fd 需要特殊处理，因为文件在子目录中
zinit ice as"command" from"gh-r" mv"fd-*/fd -> fd" pick"fd" sbin"fd"
zinit light sharkdp/fd
# ripgrep 需要特殊处理，因为文件在子目录中
zinit ice as"command" from"gh-r" mv"ripgrep-*/rg -> rg" pick"rg" sbin"rg"
zinit light BurntSushi/ripgrep
zi_cmd ajeetdsouza/zoxide zoxide
# yazi 使用 musl 版本（静态链接，不依赖系统 GLIBC）
zinit ice as"command" from"gh-r" bpick"*linux-musl.zip" mv"yazi-*/yazi -> yazi"
zinit light sxyazi/yazi

# fzf（需要特殊处理：二进制 + 补全 + 键绑定）
zinit ice from"gh-r" as"command" bpick"*linux_arm64.tar.gz"
zinit light junegunn/fzf
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/completion.zsh
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh

# 其他核心工具
zi_cmd eza-community/eza eza
zi_cmd bootandy/dust dust
zi_cmd dalance/procs procs
zi_cmd zellij-org/zellij zellij
# tig: 使用系统包管理器安装: sudo apt install tig 或从源码编译
# superfile: 使用官方安装脚本: bash -c "$(curl -sLo- https://superfile.netlify.app/install.sh)"
# 或者使用 x-cmd: x install superfile
# mdcat: 使用 cargo 安装: cargo install mdcat
# aws: 使用官方安装脚本: curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"

# atuin（单独处理，必须）
# 根据操作系统选择不同的 mv 模式
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  zinit ice \
    as"command" \
    from"gh-r" \
    bpick"*apple-darwin.tar.gz" \
    mv"atuin-*-apple-darwin/atuin -> atuin" \
    atclone"./atuin init zsh > init.zsh" \
    atpull"%atclone" \
    src"init.zsh"
else
  # Linux
zinit ice \
  as"command" \
  from"gh-r" \
  bpick"*.tar.gz" \
  mv"atuin-*-unknown-linux-gnu/atuin -> atuin" \
  atclone"./atuin init zsh > init.zsh" \
  atpull"%atclone" \
  src"init.zsh"
fi

zinit light atuinsh/atuin

