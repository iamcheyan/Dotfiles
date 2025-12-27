if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
  mkdir -p ~/.zinit
  git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
fi

source ~/.zinit/bin/zinit.zsh

# zz 函数：交互式 zoxide 目录查询并切换
function zz() {
  local dir
  dir=$(zoxide query -i)
  if [[ -n "$dir" ]]; then
    cd "$dir"
  fi
}

