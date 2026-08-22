#!/bin/bash
# dotfiles initialization script
# Used for first-time setup after cloning the repository
# Usage: bash init.sh
# Usage: bash init.sh --repair   # Repair broken zinit plugins (e.g., atuin)
# Usage: bash init.sh --minimal  # Skip fonts, neovim and heavy extras (translate-shell, yt-dlp, jq, viu)

set -e

# Fix broken Docker repo (e.g. wrong distro in docker.list) before any apt-get update
fix_docker_repo() {
    local list_file="/etc/apt/sources.list.d/docker.list"
    [[ -f "$list_file" ]] || return 0
    command -v apt-get >/dev/null 2>&1 || return 0

    local distro_id codename
    distro_id=$(. /etc/os-release && echo "$ID")
    codename=$(. /etc/os-release && echo "${VERSION_CODENAME}")

    if [[ "$distro_id" == "debian" ]]; then
        if [[ "$codename" != "bookworm" && "$codename" != "bullseye" && "$codename" != "buster" ]]; then
            codename="bookworm"
        fi
    fi

    local expected_line="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${distro_id} ${codename} stable"
    local current_line
    current_line=$(grep '^deb ' "$list_file" | head -1)

    if [[ "$current_line" != "$expected_line" ]]; then
        echo "$expected_line" | sudo tee "$list_file" >/dev/null
        echo -e "${GREEN}✓${NC} Fixed Docker repo: ${distro_id} ${codename}"
    fi
}
fix_docker_repo

MINIMAL="false"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Reset color

# Print colored messages
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

# Check whether a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect the operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists apt-get; then
            OS="debian"
        elif command_exists yum || command_exists dnf; then
            # Distinguish Fedora from RHEL/CentOS
            if [[ -f /etc/os-release ]]; then
                source /etc/os-release
                if [[ "$ID" == "fedora" ]]; then
                    OS="fedora"
                else
                    OS="rhel"
                fi
            else
                OS="rhel"
            fi
        elif command_exists pacman; then
            OS="arch"
        elif command_exists xbps-install; then
            OS="void"
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

# Install zsh
install_zsh() {
    if command_exists zsh; then
        print_success "zsh is already installed: $(zsh --version)"
        return 0
    fi

    print_info "zsh was not found. Installing..."

    OS=$(detect_os)
    case "$OS" in
        debian)
            if command_exists sudo; then
                sudo apt-get update || true
                sudo apt-get install -y zsh || true
            else
                print_error "sudo privileges are required to install zsh"
                return 1
            fi
            ;;
        rhel|fedora)
            if command_exists sudo; then
                if command_exists dnf; then
                    sudo dnf install -y zsh
                else
                    sudo yum install -y zsh
                fi
            else
                print_error "sudo privileges are required to install zsh"
                return 1
            fi
            ;;
        arch)
            if command_exists sudo; then
                sudo pacman -S --noconfirm zsh
            else
                print_error "sudo privileges are required to install zsh"
                return 1
            fi
            ;;
        void)
            if command_exists sudo; then
                sudo xbps-install -Sy zsh
            else
                print_error "sudo privileges are required to install zsh"
                return 1
            fi
            ;;
        macos)
            if command_exists brew; then
                brew install zsh
            else
                print_warning "On macOS, install Homebrew first or install zsh manually"
                return 1
            fi
            ;;
        *)
            print_warning "Could not detect the operating system automatically. Please install zsh manually"
            print_info "Ubuntu/Debian: sudo apt-get install zsh"
            print_info "Fedora/RHEL: sudo dnf install zsh"
            print_info "Arch Linux: sudo pacman -S zsh"
            print_info "macOS: brew install zsh"
            return 1
            ;;
    esac

    if command_exists zsh; then
        print_success "zsh installed successfully: $(zsh --version)"
    else
        print_error "Failed to install zsh"
        return 1
    fi
}

# Install zinit
install_zinit() {
    local zinit_dir="$HOME/.zinit/bin"
    
    if [[ -f "$zinit_dir/zinit.zsh" ]]; then
        print_success "zinit is already installed: $zinit_dir"
        return 0
    fi

    print_info "Installing zinit..."

    if ! command_exists git; then
        print_error "git is required to install zinit. Please install git first"
        return 1
    fi

    mkdir -p "$zinit_dir"
    if git clone https://github.com/zdharma-continuum/zinit.git "$zinit_dir" 2>/dev/null; then
        print_success "zinit installed successfully: $zinit_dir"
    else
        print_error "Failed to install zinit"
        return 1
    fi
}

# Repair broken zinit plugins (e.g., atuin downloaded wrong binary)
repair_zinit_plugins() {
    local atuin_dir="$HOME/.zinit/plugins/atuinsh---atuin"
    local broot_dir="$HOME/.zinit/plugins/Canop---broot"
    
    # Repair atuin
    if [[ -d "$atuin_dir" ]]; then
        if [[ ! -f "$atuin_dir/atuin" ]] || [[ ! -x "$atuin_dir/atuin" ]]; then
            print_warning "Detected broken atuin installation (wrong binary downloaded)"
            print_info "Removing broken atuin plugin..."
            rm -rf "$atuin_dir"
            print_success "Broken atuin plugin removed. It will be reinstalled on next zsh launch"
        else
            # Check for architecture mismatch (e.g. x86_64 binary on ARM64 host)
            local current_arch
            current_arch=$(uname -m)
            local binary_info=""
            if command_exists file; then
                binary_info=$(file "$atuin_dir/atuin" 2>/dev/null)
            fi

            local architecture_mismatch=false
            if [[ "$current_arch" == "aarch64" || "$current_arch" == "arm64" ]]; then
                if [[ "$binary_info" == *"x86-64"* ]]; then
                    architecture_mismatch=true
                fi
            elif [[ "$current_arch" == "x86_64" ]]; then
                if [[ "$binary_info" == *"ARM"* || "$binary_info" == *"aarch64"* ]]; then
                    architecture_mismatch=true
                fi
            fi

            if [[ "$architecture_mismatch" == "true" ]]; then
                print_warning "Detected atuin architecture mismatch (downloaded x86_64 on ARM64 or vice versa)"
                print_info "Removing misconfigured atuin plugin and clearing evalcache..."
                rm -rf "$atuin_dir"
                rm -rf "$HOME/.zsh-evalcache"/* 2>/dev/null || true
                print_success "Atuin plugin and evalcache cleared. Correct binary will be downloaded on next zsh launch"
            else
                print_success "atuin binary looks correct"
            fi
        fi
    fi
    
    # Repair broot: zinit mv sometimes fails to move binary from subdir to root
    if [[ -d "$broot_dir" ]]; then
        if [[ ! -f "$broot_dir/broot" ]] || [[ ! -x "$broot_dir/broot" ]]; then
            print_warning "Detected broken broot installation (binary not in PATH)"
            # Find the actual broot binary in subdirectories
            local broot_binary
            broot_binary=$(find "$broot_dir" -name "broot" -type f -executable 2>/dev/null | head -n 1)
            if [[ -n "$broot_binary" ]]; then
                print_info "Copying broot binary from $(dirname "$broot_binary") to plugin root..."
                cp "$broot_binary" "$broot_dir/broot"
                chmod +x "$broot_dir/broot"
                print_success "broot binary fixed"
            else
                print_error "broot binary not found in subdirectories, removing plugin..."
                rm -rf "$broot_dir"
                print_success "Broken broot plugin removed. It will be reinstalled on next zsh launch"
            fi
        else
            print_success "broot binary looks correct"
        fi
        
        # Regenerate br shell function if needed
        local broot_launcher="${XDG_CONFIG_HOME:-$HOME/.config}/broot/launcher/br"
        local broot_init_script="$HOME/dotfiles/config/broot/init.sh"
        if [[ -f "$broot_dir/broot" ]] && [[ -f "$broot_init_script" ]]; then
            if [[ ! -f "$broot_launcher" ]]; then
                print_info "Regenerating br shell function..."
                bash "$broot_init_script" >/dev/null 2>&1 || true
                print_success "br shell function regenerated"
            fi
        fi
    fi
    
    # Add more plugin repairs here as needed
}

# Install essential tools
install_essentials() {
    print_info "Checking essential tools..."

    local common_packages="git curl wget unzip git-extras ffmpeg"
    local debian_packages="build-essential ripgrep fd-find bat eza zoxide translate-shell glow mdcat yt-dlp tealdeer gping jq httpie broot htop ranger"
    local rhel_packages="make automake gcc gcc-c++ ripgrep fd-find bat eza zoxide translate-shell glow mdcat yt-dlp tealdeer gping jq httpie broot htop ranger"
    local arch_packages="base-devel ripgrep fd bat eza zoxide translate-shell glow mdcat yt-dlp tealdeer gping jq httpie broot htop ranger"
    local void_packages="base-devel ripgrep fd-find bat eza zoxide translate-shell glow mdcat yt-dlp tealdeer gping jq httpie broot htop ranger"
    local brew_packages="ripgrep fd bat eza zoxide translate-shell glow mdcat viu yt-dlp tealdeer gping jq httpie broot htop ranger"

    if [[ "$MINIMAL" == "true" ]]; then
        print_info "Minimal mode: skipping translate-shell, yt-dlp, jq, viu"
        for pkg_list in debian_packages rhel_packages arch_packages brew_packages void_packages; do
            local cleaned=""
            for pkg in ${!pkg_list}; do
                if [[ "$pkg" != "translate-shell" && "$pkg" != "yt-dlp" && "$pkg" != "jq" && "$pkg" != "viu" ]]; then
                    cleaned="$cleaned $pkg"
                fi
            done
            eval "$pkg_list=\"$cleaned\""
        done
    fi

    OS=$(detect_os)
    if [[ "$OS" == "debian" ]]; then
        if command_exists sudo; then
            sudo apt-get update || true
            # Only install packages that are available in the configured repositories
            local install_list=""
            for pkg in $common_packages $debian_packages; do
                if apt-cache policy "$pkg" | grep "Candidate:" | grep -v "(none)" >/dev/null 2>&1; then
                    install_list="$install_list $pkg"
                else
                    print_warning "Package '$pkg' is not available in the current repositories and will be skipped"
                fi
            done
            
            if [[ -n "$install_list" ]]; then
                sudo apt-get install -y $install_list
            else
                print_warning "No installable packages were found"
            fi
            # On Debian, bat and fd may require aliases, but aliases.conf already handles that
        else
            print_error "sudo privileges are required to install essential tools"
            return 1
        fi
    elif [[ "$OS" == "rhel" ]]; then
         if command_exists sudo; then
            if command_exists dnf; then
                sudo dnf install -y epel-release
                sudo dnf groupinstall -y "Development Tools"
                sudo dnf install -y $common_packages $rhel_packages
            else
                sudo yum groupinstall -y "Development Tools"
                sudo yum install -y $common_packages $rhel_packages
            fi
        else
            print_error "sudo privileges are required to install essential tools"
            return 1
        fi
    elif [[ "$OS" == "fedora" ]]; then
        if command_exists sudo; then
            # Fedora does not need epel-release
            # dnf5 uses "group install" instead of "groupinstall"
            # Using the group ID is more reliable than the display name
            sudo dnf group install -y development-tools || sudo dnf group install -y "Development Tools" || sudo dnf groupinstall -y "Development Tools" || true
            # Skip packages that are not available
            sudo dnf install -y --skip-unavailable $common_packages $rhel_packages || true
        else
            print_error "sudo privileges are required to install essential tools"
            return 1
        fi
    elif [[ "$OS" == "arch" ]]; then
        if command_exists sudo; then
             sudo pacman -S --noconfirm $common_packages $arch_packages
        else
            print_error "sudo privileges are required to install essential tools"
            return 1
        fi
    elif [[ "$OS" == "void" ]]; then
        if command_exists sudo; then
            sudo xbps-install -Sy $common_packages $void_packages
        else
            print_error "sudo privileges are required to install essential tools"
            return 1
        fi
    elif [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            brew install $common_packages $brew_packages
        else
            print_warning "On macOS, install Homebrew first"
            return 1
        fi
    else
         print_warning "Could not install essential tools automatically. Please install these manually: git, curl, wget, build-essential, ripgrep, fd, bat, eza, zoxide, ranger"
         return 1
    fi
    
    print_success "Essential tools installation/check completed"
}

# Install pyenv
install_pyenv() {
    local pyenv_dir="$HOME/.pyenv"
    
    if [[ -d "$pyenv_dir" ]]; then
        print_success "pyenv is already installed: $pyenv_dir"
        return 0
    fi

    print_info "Installing pyenv..."

    if ! command_exists git; then
        print_error "git is required to install pyenv"
        return 1
    fi

    git clone https://github.com/pyenv/pyenv.git "$pyenv_dir"
    if [[ $? -eq 0 ]]; then
        print_success "pyenv installed successfully: $pyenv_dir"
        
        # Install the pyenv-virtualenv plugin
        if [[ ! -d "$pyenv_dir/plugins/pyenv-virtualenv" ]]; then
            print_info "Installing pyenv-virtualenv..."
            git clone https://github.com/pyenv/pyenv-virtualenv.git "$pyenv_dir/plugins/pyenv-virtualenv"
            print_success "pyenv-virtualenv installed successfully"
        fi
    else
        print_error "Failed to install pyenv"
        return 1
    fi
}

# Install fnm
load_fnm_env() {
    export FNM_DIR="${FNM_DIR:-$HOME/.fnm}"
    export PATH="$FNM_DIR:$FNM_DIR/bin:$HOME/.local/share/fnm:$HOME/.local/bin:$PATH"

    if ! command_exists fnm; then
        print_error "fnm was not found after installation"
        return 1
    fi

    eval "$(fnm env --shell bash)"
}

# Migrate from old nvm: detect the latest Node major version from ~/.nvm
get_legacy_nvm_node_major() {
    local legacy_nvm_dir="$HOME/.nvm/versions/node"
    local latest_installed
    latest_installed=$(ls -1 "$legacy_nvm_dir" 2>/dev/null | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1)
    if [[ -n "$latest_installed" ]]; then
        echo "${latest_installed#v}" | cut -d. -f1
    fi
}

ensure_fnm_node() {
    load_fnm_env || return $?

    local node_version
    node_version="$(get_legacy_nvm_node_major)"

    if [[ -n "$node_version" ]]; then
        print_info "Installing/using Node.js $node_version with fnm"
        if ! fnm list 2>/dev/null | grep -Eq "v${node_version}\\.[0-9]+\\.[0-9]+"; then
            fnm install "$node_version"
        fi
        fnm default "$node_version"
    elif ! fnm use default >/dev/null 2>&1; then
        print_info "No fnm-managed Node.js version found. Installing latest LTS Node.js..."
        fnm install --lts
        local latest_installed
        latest_installed=$(fnm list 2>/dev/null | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n 1)
        if [[ -n "$latest_installed" ]]; then
            fnm default "$latest_installed"
        fi
    fi

    fnm use default >/dev/null 2>&1 || true
    print_success "Node.js is ready: $(node --version)"
}

install_fnm() {
    export FNM_DIR="${FNM_DIR:-$HOME/.fnm}"
    export PATH="$FNM_DIR:$FNM_DIR/bin:$HOME/.local/share/fnm:$HOME/.local/bin:$PATH"

    if command_exists fnm || [[ -x "$HOME/.fnm/fnm" ]] || [[ -x "$HOME/.fnm/bin/fnm" ]] || [[ -x "$HOME/.local/share/fnm/fnm" ]]; then
        print_success "fnm is already installed"
        ensure_fnm_node
        return $?
    fi

    print_info "Installing fnm..."

    if ! command_exists curl; then
        print_error "curl is required to install fnm"
        return 1
    fi

    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    ensure_fnm_node
}

# Install fzf
install_fzf() {
    if command_exists fzf; then
        print_success "fzf is already installed: $(fzf --version | head -n 1)"
        return 0
    fi

    print_info "fzf was not found. Installing..."

    OS=$(detect_os)
    case "$OS" in
        debian)
            if command_exists sudo; then
                sudo apt-get update || true
                sudo apt-get install -y fzf || true
            else
                print_error "sudo privileges are required to install fzf"
                return 1
            fi
            ;;
        rhel|fedora)
            if command_exists sudo; then
                if command_exists dnf; then
                    sudo dnf install -y fzf
                else
                    sudo yum install -y fzf
                fi
            else
                print_error "sudo privileges are required to install fzf"
                return 1
            fi
            ;;
        arch)
            if command_exists sudo; then
                sudo pacman -S --noconfirm fzf
            else
                print_error "sudo privileges are required to install fzf"
                return 1
            fi
            ;;
        void)
            if command_exists sudo; then
                sudo xbps-install -Sy fzf
            else
                print_error "sudo privileges are required to install fzf"
                return 1
            fi
            ;;
        macos)
            if command_exists brew; then
                brew install fzf
            else
                print_warning "On macOS, install Homebrew first or install fzf manually"
                return 1
            fi
            ;;
        *)
            print_warning "Could not detect the operating system automatically. Please install fzf manually"
            print_info "Ubuntu/Debian: sudo apt-get install fzf"
            print_info "Fedora/RHEL: sudo dnf install fzf"
            print_info "Arch Linux: sudo pacman -S fzf"
            print_info "Void Linux: sudo xbps-install -Sy fzf"
            print_info "macOS: brew install fzf"
            return 1
            ;;
    esac

    if command_exists fzf; then
        print_success "fzf installed successfully: $(fzf --version | head -n 1)"
    else
        print_error "Failed to install fzf"
        return 1
    fi
}

# Initialize git submodules (e.g. VimQuest.nvim)
init_git_submodules() {
    local dotfiles_dir="${DOTFILES_DIR:-$HOME/dotfiles}"
    if [[ -f "$dotfiles_dir/.gitmodules" ]]; then
        print_info "Initializing git submodules..."
        git -C "$dotfiles_dir" submodule update --init --recursive
        print_success "Git submodules initialized"
    else
        print_info "No .gitmodules found, skipping"
    fi
}

# Use dotlink to create symlinks for config files
run_dotlink() {
    local dotlink_script="${DOTFILES_DIR:-$HOME/dotfiles}/dotlink/dotlink"

    if [[ ! -f "$dotlink_script" ]]; then
        print_error "dotlink script not found: $dotlink_script"
        return 1
    fi

    if [[ ! -x "$dotlink_script" ]]; then
        chmod +x "$dotlink_script"
    fi

    print_info "Creating config file symlinks with dotlink..."
    
    # Set backup directory environment variable to enable dotlink backup behavior
    export DOTLINK_BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$DOTLINK_BACKUP_DIR"
    print_info "Backup directory: $DOTLINK_BACKUP_DIR"

    bash "$dotlink_script" link
    
    # Remove the backup directory if nothing was backed up
    if [[ -d "$DOTLINK_BACKUP_DIR" ]] && [[ -z "$(ls -A "$DOTLINK_BACKUP_DIR")" ]]; then
        rmdir "$DOTLINK_BACKUP_DIR"
    fi

    if [[ $? -eq 0 ]]; then
        print_success "dotlink completed successfully"
    else
        print_warning "dotlink may have encountered issues. Please review the output"
    fi
}

# Install ranger devicons plugin into the dotfiles source tree.
install_ranger_devicons() {
    local plugin_dir="${DOTFILES_DIR:-$HOME/dotfiles}/config/ranger/plugins/ranger_devicons"
    local plugin_parent
    plugin_parent="$(dirname "$plugin_dir")"

    if [[ -d "$plugin_dir" ]]; then
        if [[ -z "$(ls -A "$plugin_dir" 2>/dev/null)" ]]; then
            print_info "ranger_devicons directory exists but is empty, removing and reinstalling..."
            rm -rf "$plugin_dir"
        else
            print_success "ranger_devicons is already installed: $plugin_dir"
            return 0
        fi
    fi

    if ! command_exists git; then
        print_error "git is required to install ranger_devicons"
        return 1
    fi

    mkdir -p "$plugin_parent"
    print_info "Installing ranger_devicons..."
    if git clone --depth 1 https://github.com/alexanderjeurissen/ranger_devicons.git "$plugin_dir"; then
        print_success "ranger_devicons installed successfully: $plugin_dir"
    else
        print_error "Failed to install ranger_devicons"
        return 1
    fi
}

# Install ranger archives plugin for extracting/creating archives
install_ranger_archives() {
    local plugin_dir="${DOTFILES_DIR:-$HOME/dotfiles}/config/ranger/plugins/archives"
    local plugin_parent
    plugin_parent="$(dirname "$plugin_dir")"

    if [[ -d "$plugin_dir" ]]; then
        if [[ -z "$(ls -A "$plugin_dir" 2>/dev/null)" ]]; then
            print_info "ranger-archives directory exists but is empty, removing and reinstalling..."
            rm -rf "$plugin_dir"
        else
            print_success "ranger-archives is already installed: $plugin_dir"
            return 0
        fi
    fi

    if ! command_exists git; then
        print_error "git is required to install ranger-archives"
        return 1
    fi

    mkdir -p "$plugin_parent"
    print_info "Installing ranger-archives..."
    if git clone --depth 1 https://github.com/maximtrp/ranger-archives.git "$plugin_dir"; then
        print_success "ranger-archives installed successfully: $plugin_dir"
    else
        print_error "Failed to install ranger-archives"
        return 1
    fi
}

# Create the .zshrc symlink if needed
create_zshrc_link() {
    local zshrc_target="$HOME/.zshrc"
    local zshrc_source="${DOTFILES_DIR:-$HOME/dotfiles}/zshrc"
    local zshrc_source_abs=$(readlink -f "$zshrc_source" 2>/dev/null || echo "$zshrc_source")

    if [[ -L "$zshrc_target" ]]; then
        local current_target=$(readlink -f "$zshrc_target")
        # Compare resolved real paths
        if [[ "$current_target" == "$zshrc_source_abs" ]]; then
            print_success ".zshrc symlink already exists: $zshrc_target -> $current_target"
            return 0
        else
            print_warning ".zshrc symlink points to a different target: $current_target"
            print_info "Expected target: $zshrc_source_abs"
        fi
    elif [[ -f "$zshrc_target" ]]; then
        print_info "Removing existing .zshrc"
        rm -f "$zshrc_target"
    fi

    if [[ ! -L "$zshrc_target" ]]; then
        # Use a relative or absolute path when creating the symlink
        # If DOTFILES_DIR is itself a symlink, an absolute path may be more stable
        local link_target
        if [[ -L "${DOTFILES_DIR:-$HOME/dotfiles}" ]]; then
            # DOTFILES_DIR itself is a symlink, so use the absolute path
            link_target="$zshrc_source_abs"
        else
            # Use a path relative to HOME
            link_target="${DOTFILES_DIR:-$HOME/dotfiles}/zshrc"
        fi
        
        if ln -s "$link_target" "$zshrc_target" 2>/dev/null; then
            print_success "Created .zshrc symlink: $zshrc_target -> $link_target"
        else
            print_error "Failed to create .zshrc symlink"
            return 1
        fi
    fi
}

# Detect and configure the dotfiles directory
detect_dotfiles_dir() {
    local current_dir="$(pwd)"
    local dotfiles_dir=""

    # Prefer ~/dotfiles first
    if [[ -d "$HOME/dotfiles" ]] && [[ -f "$HOME/dotfiles/zshrc" ]]; then
        dotfiles_dir="$HOME/dotfiles"
        print_info "Detected dotfiles directory: $dotfiles_dir"
    # If the current directory is a dotfiles repository
    elif [[ -f "$current_dir/zshrc" ]] && [[ -f "$current_dir/init.sh" ]]; then
        dotfiles_dir="$current_dir"
        print_info "Detected dotfiles repository at: $dotfiles_dir"
    fi

    if [[ -z "$dotfiles_dir" ]]; then
        print_error "dotfiles directory not found"
        print_info "Please make sure:"
        print_info "  1. You run this script inside the dotfiles repository, or"
        print_info "  2. The repository has been cloned into ~/dotfiles"
        return 1
    fi

    if [[ ! -f "$dotfiles_dir/zshrc" ]]; then
        print_error "$dotfiles_dir/zshrc does not exist"
        return 1
    fi

    export DOTFILES_DIR="$dotfiles_dir"
    print_success "dotfiles directory: $DOTFILES_DIR"
    return 0
}

# Install Neovim
install_neovim() {
    local install_script="${DOTFILES_DIR:-$HOME/dotfiles}/scripts/install/install_nvim.sh"
    if [[ -f "$install_script" ]]; then
        print_info "Installing Neovim..."
        bash "$install_script"
    else
        print_warning "Neovim install script not found: $install_script"
    fi
}

# Install fonts
install_fonts() {
    local install_script="${DOTFILES_DIR:-$HOME/dotfiles}/scripts/install/install_font.sh"
    if [[ -f "$install_script" ]]; then
        print_info "Installing fonts..."
        bash "$install_script"
    else
        print_warning "Font install script not found: $install_script"
    fi
}

# Install Docker (Linux only)
install_docker() {
    local os
    local current_user

    os=$(detect_os)
    current_user="${SUDO_USER:-$USER}"

    case "$os" in
        macos)
            print_info "macOS detected. Skipping Docker Engine install in init.sh. Use Docker Desktop or Colima manually."
            return 0
            ;;
        unknown)
            print_warning "Unknown OS. Skipping Docker install."
            return 0
            ;;
    esac

    if command_exists docker; then
        print_success "Docker is already installed: $(docker --version 2>/dev/null || true)"
        if command_exists systemctl; then
            sudo systemctl enable --now docker >/dev/null 2>&1 || true
        fi
        return 0
    fi

    if ! command_exists sudo; then
        print_error "sudo privileges are required to install Docker"
        return 1
    fi

    print_info "Installing Docker for $os..."

    case "$os" in
        debian)
            sudo apt-get update || true
            sudo apt-get install -y ca-certificates curl gnupg || true
            sudo install -m 0755 -d /etc/apt/keyrings

            # 从 /etc/os-release 读取发行版 ID（debian / ubuntu / linuxmint ...）
            local distro_id
            distro_id=$(. /etc/os-release && echo "$ID")

            if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
                curl -fsSL "https://download.docker.com/linux/${distro_id}/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                sudo chmod a+r /etc/apt/keyrings/docker.gpg
            fi
            local codename
            codename=$(. /etc/os-release && echo "${VERSION_CODENAME}")
            # Docker 不支持 Debian testing/unstable，使用 bookworm 代替
            if [[ "$distro_id" == "debian" && "$codename" != "bookworm" && "$codename" != "bullseye" && "$codename" != "buster" ]]; then
                codename="bookworm"
            fi
            local expected_line="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${distro_id} ${codename} stable"
            local current_line=""
            [[ -f /etc/apt/sources.list.d/docker.list ]] && current_line=$(grep '^deb ' /etc/apt/sources.list.d/docker.list | head -1)
            if [[ "$current_line" != "$expected_line" ]]; then
                echo "$expected_line" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
            fi
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        fedora)
            sudo dnf install -y dnf-plugins-core
            sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo || true
            sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        rhel)
            if command_exists dnf; then
                sudo dnf install -y dnf-plugins-core
                sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo || true
                sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            else
                sudo yum install -y yum-utils
                sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo || true
                sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            fi
            ;;
        arch)
            sudo pacman -S --noconfirm docker docker-buildx docker-compose
            ;;
        void)
            sudo xbps-install -Sy docker docker-compose
            ;;
        *)
            print_warning "Unsupported Linux distribution for automatic Docker install: $os"
            return 0
            ;;
    esac

    if command_exists systemctl; then
        sudo systemctl enable --now docker || true
    elif [[ -d /etc/sv/docker ]]; then
        # Void Linux uses runit
        sudo ln -sf /etc/sv/docker /var/service/ || true
    fi

    if getent group docker >/dev/null 2>&1; then
        sudo usermod -aG docker "$current_user" || true
    fi

    if command_exists docker; then
        print_success "Docker installed successfully: $(sudo docker --version 2>/dev/null || docker --version 2>/dev/null)"
        print_info "You may need to restart the shell or run 'newgrp docker' before using docker without sudo."
    else
        print_error "Failed to install Docker"
        return 1
    fi
}

# Install additional tools (Docker, Zellij, TPM tmux plugins)
install_extra_tools() {
    local install_dir="${DOTFILES_DIR:-$HOME/dotfiles}/scripts/install"
    
    print_info "Checking and installing additional tools..."

    # Docker (Linux only)
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        install_docker
    else
        print_info "Skipping Docker install on non-Linux system"
    fi

    # Zellij
    if ! command_exists zellij; then
        print_info "Installing Zellij..."
        [[ -f "$install_dir/install_zellij.sh" ]] && bash "$install_dir/install_zellij.sh"
    else
        print_success "Zellij is already installed"
    fi
    # Herdr — local AI coding assistant
    if ! command_exists herdr; then
        print_info "Installing Herdr..."
        curl -fsSL https://herdr.dev/install.sh | sh
        print_success "Herdr installed successfully"
    else
        print_success "Herdr is already installed"
    fi


    # Tmux Plugins (TPM)
    if command_exists tmux; then
        print_info "Checking and installing tmux plugins (TPM)..."
        local tpm_dir="$HOME/.tmux/plugins/tpm"
        if [[ ! -d "$tpm_dir" ]]; then
            print_info "Cloning Tmux Plugin Manager (TPM)..."
            git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"
        fi
        
        # Start a detached tmux session if not running to allow script-based plugin installation
        tmux new-session -d -s tpm-install 2>/dev/null || true
        tmux source-file "$HOME/.tmux.conf" 2>/dev/null || true
        bash "$tpm_dir/bin/install_plugins" >/dev/null 2>&1 || true
        tmux kill-session -t tpm-install 2>/dev/null || true
        print_success "Tmux plugins installation completed"
    else
        print_warning "tmux is not installed, skipping tmux plugins installation"
    fi
}


# Main function
main() {
    # Parse arguments
    local REPAIR="false"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --minimal)
                MINIMAL="true"
                shift
                ;;
            --repair)
                REPAIR="true"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    if [[ "$MINIMAL" == "true" ]]; then
        echo -e "${YELLOW}⚠  Minimal mode enabled${NC}"
        echo "Skipping: fonts, neovim, and heavy extras (translate-shell, yt-dlp, jq, viu)"
        echo ""
    fi

    echo -e "${BLUE}"
    cat << "EOF"
   ___  ____  ________   _____  ____ __
  / _ \/ __ \/_  __/ /  /  _/ |/ / //_/
 / // / /_/ / / / / /___/ //    / ,<   
/____/\____/ /_/ /____/___/_/|_/_/|_|  
                                       
EOF
    echo -e "${NC}"

    # Important notice
    echo -e "${YELLOW}⚠  Important Notice:${NC}"
    echo ""
    echo "This script will:"
    echo "  1. Create symlinks for config files (replacing existing files)"
    echo "  2. Create a ~/.zshrc symlink (replacing the existing file)"
    echo ""
    echo -e "${RED}Warning: existing config files will be overwritten.${NC}"
    echo ""
    # 3-second countdown
    echo "The script will start in 3 seconds..."
    for i in {3..1}; do
        echo -ne "$i... \r"
        sleep 1
    done
    echo "Starting...      "
    echo ""

    # Helper: run a step, catch errors and continue
    run_step() {
        local step_name="$1"; shift
        if ! "$@"; then
            print_warning "$step_name failed, skipping..."
        fi
    }

    # Detect and configure the dotfiles directory
    print_info "Step 1/12: Detecting the dotfiles repository location"
    if ! detect_dotfiles_dir; then
        exit 1
    fi
    echo ""

    # 1. Install zsh
    print_info "Step 2/12: Checking and installing zsh"
    run_step "zsh install" install_zsh
    echo ""

    # 2. Install essential tools
    print_info "Step 3/12: Installing essential tools (git, curl, build-essential, etc.)"
    run_step "essential tools install" install_essentials
    echo ""

    # 2.5 Initialize git submodules
    print_info "Step 3.5/12: Initializing git submodules"
    run_step "git submodules" init_git_submodules
    echo ""

    # 3. Install zinit
    print_info "Step 4/12: Checking and installing zinit"
    run_step "zinit install" install_zinit
    echo ""

    # 3.5 Repair broken zinit plugins (if --repair flag is passed)
    if [[ "$REPAIR" == "true" ]]; then
        print_info "Repair mode: Checking for broken zinit plugins..."
        run_step "zinit repair" repair_zinit_plugins
        echo ""
    fi

    # 4. Install pyenv
    print_info "Step 5/12: Checking and installing pyenv"
    run_step "pyenv install" install_pyenv
    echo ""

    # 5. Install fnm
    print_info "Step 6/12: Checking and installing fnm"
    run_step "fnm install" install_fnm
    echo ""

    # 7. Install fzf
    print_info "Step 7/12: Checking and installing fzf"
    run_step "fzf install" install_fzf
    echo ""

    # 8. Create config file symlinks with dotlink
    print_info "Step 8/12: Creating config file symlinks with dotlink"
    run_step "dotlink" run_dotlink
    echo ""

    # 8.5 Install ranger plugins if missing
    print_info "Step 8.5/12: Checking ranger plugins"
    run_step "ranger_devicons install" install_ranger_devicons
    run_step "ranger_archives install" install_ranger_archives
    echo ""

    # 9. Create the .zshrc symlink
    print_info "Step 9/12: Creating the .zshrc symlink"
    run_step "zshrc link" create_zshrc_link
    echo ""

    # 10. Install Neovim
    if [[ "$MINIMAL" != "true" ]]; then
        print_info "Step 10/12: Installing Neovim"
        run_step "neovim install" install_neovim
    else
        print_info "Step 10/12: Skipping Neovim (minimal mode)"
    fi
    echo ""

    # 11. Install fonts
    if [[ "$MINIMAL" != "true" ]]; then
        print_info "Step 11/12: Installing fonts"
        run_step "fonts install" install_fonts
    else
        print_info "Step 11/12: Skipping fonts (minimal mode)"
    fi
    echo ""

    # 12. Install additional tools
    print_info "Step 12/12: Installing additional tools (Docker, Zellij, TPM)"
    run_step "extra tools install" install_extra_tools
    echo ""

    # Completion message
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "Initialization completed"
    echo ""

    print_info "Next steps:"
    echo -e "  1. Switch to zsh:"
    echo -e "     ${GREEN}zsh${NC}"
    echo ""
    echo "  2. On the first zsh launch, it will automatically:"
    echo "     - Install the Starship prompt"
    echo "     - Install all configured plugins and tools"
    echo ""
    echo -e "  3. If you need additional configuration, refer to the documentation"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Show backup information
    if [[ -d "$DOTLINK_BACKUP_DIR" ]]; then
        echo -e "${YELLOW}📦 Backup Information:${NC}"
        echo "  Backup location: $DOTLINK_BACKUP_DIR"
        echo "  To restore, copy the files from the backup directory back to their original locations"
        echo ""
    fi

    # Ask whether to switch to zsh immediately and set it as the default shell
    if command_exists zsh && [[ "$SHELL" != "$(command -v zsh)" ]]; then
        read -p "Switch to zsh now and set it as the default shell? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ZSH_PATH=$(command -v zsh)
            print_info "Setting zsh as the default shell..."
            
            # Check whether zsh is listed in /etc/shells
            if ! grep -Fxq "$ZSH_PATH" /etc/shells 2>/dev/null; then
                print_warning "zsh is not listed in /etc/shells. Administrator privileges may be required to add it"
                if command_exists sudo; then
                    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
                    print_success "Added zsh to /etc/shells"
                else
                    print_warning "Could not add zsh to /etc/shells automatically. Please add it manually:"
                    echo "  sudo echo '$ZSH_PATH' >> /etc/shells"
                fi
            fi
            
            # Set zsh as the default shell
            if command_exists chsh; then
                print_info "Authentication may be required to set the default shell:"
                if chsh -s "$ZSH_PATH"; then
                    print_success "zsh has been set as the default shell"
                else
                    print_warning "Failed to set the default shell"
                    print_info "Please run this manually: chsh -s $ZSH_PATH"
                fi
            else
                print_warning "The chsh command was not found. Cannot set the default shell"
            fi
            
            print_info "Switching to zsh..."
            exec zsh
        fi
    fi
}

# Run the main function
main "$@"
