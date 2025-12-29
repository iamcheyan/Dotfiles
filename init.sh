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

# 创建 Dotfiles 软链接（确保 ~/.dotfiles 指向 ~/Dotfiles）
# 注意：~/Dotfiles 是真实目录，~/.dotfiles 是软链接
create_dotfiles_link() {
    local dotfiles_real="$HOME/Dotfiles"
    local dotfiles_link="$HOME/.dotfiles"

    # 如果 ~/Dotfiles 不存在，说明仓库不在标准位置，跳过此步骤
    if [[ ! -d "$dotfiles_real" ]]; then
        print_warning "~/Dotfiles 目录不存在，跳过软链接创建"
        return 0
    fi

    # 检查 ~/.dotfiles 是否已存在且指向正确
    if [[ -L "$dotfiles_link" ]]; then
        local current_target=$(readlink -f "$dotfiles_link")
        if [[ "$current_target" == "$dotfiles_real" ]]; then
            print_success "软链接已存在: $dotfiles_link -> $dotfiles_real"
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
        read -p "是否要备份并创建软链接? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            local backup_file="${dotfiles_link}.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$dotfiles_link" "$backup_file"
            print_info "已备份到: $backup_file"
        else
            print_warning "跳过软链接创建"
            return 0
        fi
    fi

    # 创建 ~/.dotfiles -> ~/Dotfiles 的软链接
    if ln -s "$dotfiles_real" "$dotfiles_link" 2>/dev/null; then
        print_success "已创建软链接: $dotfiles_link -> $dotfiles_real"
    else
        print_error "创建软链接失败"
        return 1
    fi
}

# 使用 dotlink 创建配置文件的软链接
run_dotlink() {
    local dotlink_script="${DOTFILES_DIR:-$HOME/.dotfiles}/dotlink/dotlink"

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
    local zshrc_source="${DOTFILES_DIR:-$HOME/.dotfiles}/zshrc"
    local zshrc_source_abs=$(readlink -f "$zshrc_source" 2>/dev/null || echo "$zshrc_source")

    if [[ -L "$zshrc_target" ]]; then
        local current_target=$(readlink -f "$zshrc_target")
        # 比较实际文件路径（解析所有软链接后）
        if [[ "$current_target" == "$zshrc_source_abs" ]]; then
            print_success ".zshrc 软链接已存在: $zshrc_target -> $current_target"
            return 0
        else
            print_warning ".zshrc 软链接指向不同目标: $current_target"
            print_info "预期目标: $zshrc_source_abs"
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
        # 使用相对路径或绝对路径创建软链接
        # 如果 DOTFILES_DIR 是软链接，使用相对路径可能更稳定
        local link_target
        if [[ -L "${DOTFILES_DIR:-$HOME/.dotfiles}" ]]; then
            # DOTFILES_DIR 本身是软链接，使用绝对路径
            link_target="$zshrc_source_abs"
        else
            # 使用相对路径（从 HOME 目录的相对路径）
            link_target="${DOTFILES_DIR:-$HOME/.dotfiles}/zshrc"
        fi
        
        if ln -s "$link_target" "$zshrc_target" 2>/dev/null; then
            print_success "已创建 .zshrc 软链接: $zshrc_target -> $link_target"
        else
            print_error "创建 .zshrc 软链接失败"
            return 1
        fi
    fi
}

# 检测并设置 dotfiles 目录
# 注意：~/Dotfiles 是真实目录，~/.dotfiles 是软链接
detect_dotfiles_dir() {
    local current_dir="$(pwd)"
    local dotfiles_real=""
    local dotfiles_link="$HOME/.dotfiles"
    
    # 优先检查 ~/Dotfiles（真实目录）
    if [[ -d "$HOME/Dotfiles" ]] && [[ -f "$HOME/Dotfiles/zshrc" ]]; then
        dotfiles_real="$HOME/Dotfiles"
        print_info "检测到 dotfiles 真实目录: $dotfiles_real"
        
        # 确保 ~/.dotfiles 软链接指向 ~/Dotfiles
        if [[ ! -e "$dotfiles_link" ]]; then
            print_info "正在创建 ~/.dotfiles 软链接..."
            if ln -s "$dotfiles_real" "$dotfiles_link" 2>/dev/null; then
                print_success "已创建软链接: ~/.dotfiles -> ~/Dotfiles"
            else
                print_error "创建软链接失败"
                return 1
            fi
        elif [[ -L "$dotfiles_link" ]]; then
            local target=$(readlink -f "$dotfiles_link")
            if [[ "$target" == "$dotfiles_real" ]]; then
                print_success "软链接已存在: ~/.dotfiles -> ~/Dotfiles"
            else
                print_warning "~/.dotfiles 软链接指向不同目标: $target"
                print_info "预期目标: $dotfiles_real"
                read -p "是否要重新创建软链接? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -f "$dotfiles_link"
                    if ln -s "$dotfiles_real" "$dotfiles_link" 2>/dev/null; then
                        print_success "已重新创建软链接: ~/.dotfiles -> ~/Dotfiles"
                    else
                        print_error "重新创建软链接失败"
                        return 1
                    fi
                fi
            fi
        elif [[ -d "$dotfiles_link" ]]; then
            print_warning "~/.dotfiles 已存在但是目录（不是软链接）"
            print_info "如果 ~/Dotfiles 是真实目录，应该删除 ~/.dotfiles 并创建软链接"
            read -p "是否要备份 ~/.dotfiles 并创建软链接? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                local backup_file="${dotfiles_link}.backup.$(date +%Y%m%d_%H%M%S)"
                mv "$dotfiles_link" "$backup_file"
                print_info "已备份到: $backup_file"
                if ln -s "$dotfiles_real" "$dotfiles_link" 2>/dev/null; then
                    print_success "已创建软链接: ~/.dotfiles -> ~/Dotfiles"
                else
                    print_error "创建软链接失败"
                    return 1
                fi
            fi
        fi
    # 如果当前目录是 dotfiles 仓库（但不是 ~/Dotfiles）
    elif [[ -f "$current_dir/zshrc" ]] && [[ -f "$current_dir/init.sh" ]]; then
        dotfiles_real="$current_dir"
        print_info "检测到 dotfiles 仓库在: $dotfiles_real"
        
        # 如果当前目录不是 ~/Dotfiles，询问是否要创建软链接
        if [[ "$dotfiles_real" != "$HOME/Dotfiles" ]]; then
            print_info "当前目录不是 ~/Dotfiles，是否要创建软链接?"
            print_info "  选项 1: 创建 ~/.dotfiles -> $dotfiles_real"
            print_info "  选项 2: 创建 ~/Dotfiles -> $dotfiles_real（然后 ~/.dotfiles -> ~/Dotfiles）"
            read -p "选择选项 (1/2/N，跳过): " -n 1 -r
            echo
            if [[ $REPLY == "1" ]]; then
                if [[ -e "$dotfiles_link" ]]; then
                    print_warning "~/.dotfiles 已存在，需要先删除"
                    read -p "是否继续? (y/N): " -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        rm -rf "$dotfiles_link"
                    else
                        return 1
                    fi
                fi
                if ln -s "$dotfiles_real" "$dotfiles_link" 2>/dev/null; then
                    print_success "已创建软链接: ~/.dotfiles -> $dotfiles_real"
                else
                    print_error "创建软链接失败"
                    return 1
                fi
            elif [[ $REPLY == "2" ]]; then
                if [[ ! -e "$HOME/Dotfiles" ]]; then
                    if ln -s "$dotfiles_real" "$HOME/Dotfiles" 2>/dev/null; then
                        print_success "已创建软链接: ~/Dotfiles -> $dotfiles_real"
                        dotfiles_real="$HOME/Dotfiles"
                    else
                        print_error "创建软链接失败"
                        return 1
                    fi
                fi
                # 然后创建 ~/.dotfiles -> ~/Dotfiles
                if [[ ! -e "$dotfiles_link" ]]; then
                    if ln -s "$HOME/Dotfiles" "$dotfiles_link" 2>/dev/null; then
                        print_success "已创建软链接: ~/.dotfiles -> ~/Dotfiles"
                    else
                        print_error "创建软链接失败"
                        return 1
                    fi
                fi
            fi
        fi
    fi
    
    # 最终检查 ~/.dotfiles 是否存在且可访问
    if [[ ! -e "$dotfiles_link" ]]; then
        print_error "未找到 ~/.dotfiles"
        print_info "请确保："
        print_info "  1. 在 dotfiles 仓库目录中运行此脚本，或"
        print_info "  2. 已克隆仓库到 ~/Dotfiles 或当前目录"
        return 1
    fi
    
    if [[ ! -f "$dotfiles_link/zshrc" ]]; then
        print_error "~/.dotfiles/zshrc 不存在"
        return 1
    fi
    
    export DOTFILES_DIR="$dotfiles_link"
    print_success "Dotfiles 目录: $DOTFILES_DIR"
    return 0
}

# 主函数
main() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Dotfiles 初始化脚本"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # 检测并设置 dotfiles 目录
    print_info "步骤 0/5: 检测 dotfiles 仓库位置"
    if ! detect_dotfiles_dir; then
        exit 1
    fi
    echo ""

    # 1. 安装 zsh
    print_info "步骤 1/6: 检查并安装 zsh"
    install_zsh
    echo ""

    # 2. 安装 zinit
    print_info "步骤 2/6: 检查并安装 zinit"
    install_zinit
    echo ""

    # 3. 创建 Dotfiles 软链接（如果不存在）
    print_info "步骤 3/6: 创建 Dotfiles 软链接"
    create_dotfiles_link
    echo ""

    # 4. 使用 dotlink 创建配置文件软链接
    print_info "步骤 4/6: 使用 dotlink 创建配置文件软链接"
    run_dotlink
    echo ""

    # 5. 创建 .zshrc 软链接
    print_info "步骤 5/6: 创建 .zshrc 软链接"
    create_zshrc_link
    echo ""

    # 完成提示
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "初始化完成！"
    echo ""
    print_info "下一步操作："
    echo -e "  1. 切换到 zsh:"
    echo -e "     ${GREEN}zsh${NC}"
    echo ""
    echo "  2. 首次启动 zsh 时会自动："
    echo "     - 安装 Powerlevel10k 主题"
    echo "     - 安装所有配置的插件和工具"
    echo "     - 询问是否安装 Meslo 字体"
    echo ""
    echo -e "  3. 如果需要安装字体，可以运行："
    echo -e "     ${GREEN}install:font${NC}"
    echo ""
    echo -e "  4. 如果需要安装 Rime 配置，可以运行："
    echo -e "     ${GREEN}install:rime${NC}"
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

