# このファイルはマシン固有の設定用です
# 必要に応じて編集してください

# ============================================
# 字体安装功能
# ============================================

# 移除可能存在的别名（避免与函数定义冲突）
unalias install:font 2>/dev/null || true

# 字体安装函数（可通过命令调用）
install:font() {
    bash "$HOME/.dotfiles/scripts/install/install_font.sh" "$@"
}

# zsh 初始化时询问是否安装字体（仅在交互式 shell 中）
if [[ -o interactive ]] && [ -t 0 ]; then
    # 检查字体是否已安装（通过检查字体文件）
    FONT_INSTALLED=false
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v fc-list >/dev/null 2>&1 && fc-list | grep -qi "meslo" 2>/dev/null; then
            FONT_INSTALLED=true
        elif [ -d "$HOME/.fonts" ] && find "$HOME/.fonts" -name "*Meslo*" -o -name "*meslo*" 2>/dev/null | grep -q .; then
            FONT_INSTALLED=true
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if [ -d "$HOME/Library/Fonts" ] && find "$HOME/Library/Fonts" -name "*Meslo*" -o -name "*meslo*" 2>/dev/null | grep -q .; then
            FONT_INSTALLED=true
        fi
    fi

    # 如果未安装，询问用户
    if [ "$FONT_INSTALLED" = false ]; then
        # 只在首次启动时询问（检查标记文件）
        FONT_INSTALL_CHECK="$HOME/.dotfiles/.font_install_asked"
        if [ ! -f "$FONT_INSTALL_CHECK" ]; then
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "  Meslo 字体未安装"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            read -q "?是否要安装 Meslo 字体？(y/N): " && echo
            if [ $? -eq 0 ]; then
                install:font
            else
                echo "已跳过字体安装。以后可以使用 'install:font' 命令安装。"
            fi
            # 创建标记文件，避免每次启动都询问
            touch "$FONT_INSTALL_CHECK"
        fi
    fi
fi

# ============================================
# nvm (Node Version Manager) 配置
# ============================================

# 自动加载 nvm（如果已安装）
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    export NVM_DIR="$HOME/.nvm"
    # 使用 source 加载 nvm（兼容 zsh 和 bash）
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    # 加载 bash completion（如果存在）
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

