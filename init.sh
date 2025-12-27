#!/bin/bash
# Dotfiles 初始化脚本
# 用于第一次克隆仓库后的初始化
# 用法: bash init.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists apt-get; then
            OS="debian"
        elif command_exists yum || command_exists dnf; then
            OS="rhel"
        elif command_exists pacman; then
            OS="arch"
        else
            OS="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        OS="unknown"
    fi
    echo "$OS"
}

# 安装 zsh
install_zsh() {
    if command_exists zsh; then
        print_success "zsh 已安装: $(zsh --version)"
        return 0
    fi

    print_info "zsh 未安装，正在安装..."

    OS=$(detect_os)
    case "$OS" in
        debian)
            if command_exists sudo; then
                sudo apt-get update
                sudo apt-get install -y zsh
            else
                print_error "需要 sudo 权限来安装 zsh"
                return 1
            fi
            ;;
        rhel)
            if command_exists sudo; then
                if command_exists dnf; then
                    sudo dnf install -y zsh
                else
                    sudo yum install -y zsh
                fi
            else
                print_error "需要 sudo 权限来安装 zsh"
                return 1
            fi
            ;;
        arch)
            if command_exists sudo; then
                sudo pacman -S --noconfirm zsh
            else
                print_error "需要 sudo 权限来安装 zsh"
                return 1
            fi
            ;;
        macos)
            if command_exists brew; then
                brew install zsh
            else
                print_warning "macOS 上请先安装 Homebrew，或手动安装 zsh"
                return 1
            fi
            ;;
        *)
            print_warning "无法自动检测操作系统，请手动安装 zsh"
            print_info "Ubuntu/Debian: sudo apt-get install zsh"
            print_info "Fedora/RHEL: sudo dnf install zsh"
            print_info "Arch: sudo pacman -S zsh"
            print_info "macOS: brew install zsh"
            return 1
            ;;
    esac

    if command_exists zsh; then
        print_success "zsh 安装成功: $(zsh --version)"
    else
        print_error "zsh 安装失败"
        return 1
    fi
}

# 安装 zinit
install_zinit() {
    local zinit_dir="$HOME/.zinit/bin"
    
    if [[ -f "$zinit_dir/zinit.zsh" ]]; then
        print_success "zinit 已安装: $zinit_dir"
        return 0
    fi

    print_info "正在安装 zinit..."

    if ! command_exists git; then
        print_error "需要 git 来安装 zinit，请先安装 git"
        return 1
    fi

    mkdir -p "$zinit_dir"
    if git clone https://github.com/zdharma-continuum/zinit.git "$zinit_dir" 2>/dev/null; then
        print_success "zinit 安装成功: $zinit_dir"
    else
        print_error "zinit 安装失败"
        return 1
    fi
}

# 创建 Dotfiles 软链接
create_dotfiles_link() {
    local dotfiles_link="$HOME/Dotfiles"
    local dotfiles_dir="$HOME/.dotfiles"

    if [[ -L "$dotfiles_link" ]]; then
        local current_target=$(readlink -f "$dotfiles_link")
        if [[ "$current_target" == "$dotfiles_dir" ]]; then
            print_success "软链接已存在: $dotfiles_link -> $dotfiles_dir"
            return 0
        else
            print_warning "软链接指向不同目标: $dotfiles_link -> $current_target"
            read -p "是否要重新创建软链接? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm -f "$dotfiles_link"
            else
                return 0
            fi
        fi
    elif [[ -e "$dotfiles_link" ]]; then
        print_warning "$dotfiles_link 已存在但不是软链接"
        read -p "是否要删除并创建软链接? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$dotfiles_link"
        else
            return 0
        fi
    fi

    if ln -s "$dotfiles_dir" "$dotfiles_link" 2>/dev/null; then
        print_success "已创建软链接: $dotfiles_link -> $dotfiles_dir"
    else
        print_error "创建软链接失败"
        return 1
    fi
}

# 使用 dotlink 创建配置文件的软链接
run_dotlink() {
    local dotlink_script="$HOME/.dotfiles/dotlink/dotlink"

    if [[ ! -f "$dotlink_script" ]]; then
        print_error "未找到 dotlink 脚本: $dotlink_script"
        return 1
    fi

    if [[ ! -x "$dotlink_script" ]]; then
        chmod +x "$dotlink_script"
    fi

    print_info "正在使用 dotlink 创建配置文件软链接..."
    bash "$dotlink_script" link

    if [[ $? -eq 0 ]]; then
        print_success "dotlink 执行成功"
    else
        print_warning "dotlink 执行过程中可能有错误，请检查输出"
    fi
}

# 创建 zshrc 软链接（如果不存在）
create_zshrc_link() {
    local zshrc_target="$HOME/.zshrc"
    local zshrc_source="$HOME/.dotfiles/zshrc"

    if [[ -L "$zshrc_target" ]]; then
        local current_target=$(readlink -f "$zshrc_target")
        if [[ "$current_target" == "$zshrc_source" ]]; then
            print_success ".zshrc 软链接已存在: $zshrc_target -> $zshrc_source"
            return 0
        else
            print_warning ".zshrc 软链接指向不同目标: $current_target"
        fi
    elif [[ -f "$zshrc_target" ]]; then
        print_warning ".zshrc 已存在，是否要备份并创建软链接?"
        read -p "备份现有 .zshrc 并创建软链接? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            local backup_file="${zshrc_target}.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$zshrc_target" "$backup_file"
            print_info "已备份到: $backup_file"
        else
            print_warning "跳过 .zshrc 软链接创建"
            return 0
        fi
    fi

    if [[ ! -L "$zshrc_target" ]]; then
        if ln -s "$zshrc_source" "$zshrc_target" 2>/dev/null; then
            print_success "已创建 .zshrc 软链接: $zshrc_target -> $zshrc_source"
        else
            print_error "创建 .zshrc 软链接失败"
            return 1
        fi
    fi
}

# 主函数
main() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Dotfiles 初始化脚本"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # 检查是否在正确的目录
    if [[ ! -f "$HOME/.dotfiles/zshrc" ]]; then
        print_error "未找到 ~/.dotfiles/zshrc，请确保在正确的目录运行此脚本"
        print_info "请先执行: git clone https://github.com/iamcheyan/Dotfiles.git ~/.dotfiles"
        exit 1
    fi

    # 1. 安装 zsh
    print_info "步骤 1/5: 检查并安装 zsh"
    install_zsh
    echo ""

    # 2. 安装 zinit
    print_info "步骤 2/5: 检查并安装 zinit"
    install_zinit
    echo ""

    # 3. 创建 Dotfiles 软链接
    print_info "步骤 3/5: 创建 Dotfiles 软链接"
    create_dotfiles_link
    echo ""

    # 4. 使用 dotlink 创建配置文件软链接
    print_info "步骤 4/5: 使用 dotlink 创建配置文件软链接"
    run_dotlink
    echo ""

    # 5. 创建 .zshrc 软链接
    print_info "步骤 5/5: 创建 .zshrc 软链接"
    create_zshrc_link
    echo ""

    # 完成提示
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "初始化完成！"
    echo ""
    print_info "下一步操作："
    echo "  1. 切换到 zsh:"
    echo "     ${GREEN}zsh${NC}"
    echo ""
    echo "  2. 首次启动 zsh 时会自动："
    echo "     - 安装 Powerlevel10k 主题"
    echo "     - 安装所有配置的插件和工具"
    echo "     - 询问是否安装 Meslo 字体"
    echo ""
    echo "  3. 如果需要安装字体，可以运行："
    echo "     ${GREEN}install:font${NC}"
    echo ""
    echo "  4. 如果需要安装 Rime 配置，可以运行："
    echo "     ${GREEN}install:rime${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # 询问是否立即切换到 zsh
    if command_exists zsh && [[ "$SHELL" != "$(command -v zsh)" ]]; then
        read -p "是否要立即切换到 zsh? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "正在切换到 zsh..."
            exec zsh
        fi
    fi
}

# 运行主函数
main "$@"

