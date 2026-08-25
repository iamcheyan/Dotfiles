#!/bin/bash
# Neovim installation script
# Install the latest Neovim release from GitHub
# Usage: install_nvim.sh [--force] [--version VERSION]

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Detect the operating system and architecture
detect_system() {
    local os=""
    local arch=""
    
    # Detect the operating system
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        os="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os="macos"
    else
        print_error "Unsupported operating system: $OSTYPE"
        return 1
    fi
    
    # Detect the architecture
    local machine=$(uname -m)
    case "$machine" in
        x86_64|amd64)
            arch="x86_64"
            ;;
        aarch64|arm64)
            arch="aarch64"
            ;;
        armv7l|armv6l)
            arch="armv7l"
            ;;
        *)
            print_error "Unsupported architecture: $machine"
            return 1
            ;;
    esac
    
    export NVIM_OS="$os"
    export NVIM_ARCH="$arch"
    print_info "Detected system: $os ($arch)"
    return 0
}

# Get the latest version number (for display and checking)
get_latest_version() {
    local version=""
    
    if command -v curl >/dev/null 2>&1; then
        version=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
    elif command -v wget >/dev/null 2>&1; then
        version=$(wget -qO- https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
    else
        print_error "curl or wget is required to retrieve version information"
        return 1
    fi
    
    if [[ -z "$version" ]]; then
        print_error "Unable to retrieve the latest version number"
        return 1
    fi
    
    echo "$version"
}

# Download and install Neovim (Linux)
install_nvim_linux() {
    local version="$1"
    local arch="$2"
    local install_dir="$HOME/.local/nvim"
    local download_url=""
    local filename=""
    
    # Build the download URL and filename
    if [[ "$arch" == "x86_64" ]]; then
        filename="nvim-linux-x86_64.tar.gz"
        if [[ -z "$version" ]]; then
            download_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
        else
            download_url="https://github.com/neovim/neovim/releases/download/v${version}/nvim-linux-x86_64.tar.gz"
        fi
    elif [[ "$arch" == "aarch64" ]]; then
        filename="nvim-linux-arm64.tar.gz"
        if [[ -z "$version" ]]; then
            download_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz"
        else
            download_url="https://github.com/neovim/neovim/releases/download/v${version}/nvim-linux-arm64.tar.gz"
        fi
    else
        print_error "Linux architecture $arch is unsupported; install it with a package manager"
        return 1
    fi
    
    local tmp_file="/tmp/$filename"
    
    # Step 1: Download
    if [[ -n "$version" ]]; then
        print_info "Downloading Neovim ${version}..."
    else
        print_info "Downloading the latest Neovim version..."
    fi
    
    if [[ -f "$tmp_file" ]] && [[ "$force" != "true" ]]; then
        print_info "Temporary file already exists: $tmp_file"
    else
        if command -v curl >/dev/null 2>&1; then
            curl -L -o "$tmp_file" "$download_url" || {
                print_error "Download failed"
                return 1
            }
        elif command -v wget >/dev/null 2>&1; then
            wget -q --show-progress -O "$tmp_file" "$download_url" || {
                print_error "Download failed"
                return 1
            }
        else
            print_error "curl or wget is required for downloading"
            return 1
        fi
        print_success "Download complete: $tmp_file"
    fi
    
    # Step 2: Verify the file type
    print_info "Verifying file type..."
    local file_type=$(file "$tmp_file" 2>/dev/null | grep -o "gzip compressed data" || echo "")
    if [[ -z "$file_type" ]]; then
        print_error "Incorrect file type; this is not a gzip archive"
        print_info "File information: $(file "$tmp_file" 2>/dev/null || echo 'Unable to read')"
        return 1
    fi
    print_success "File type verified"
    
    # Step 3: Install to ~/.local/nvim
    print_info "Installing to $install_dir..."
    rm -rf "$install_dir"
    mkdir -p "$install_dir"
    
    tar xf "$tmp_file" -C "$install_dir" --strip-components=1 || {
        print_error "Extraction failed"
        return 1
    }
    
    # Verify the installation
    if [[ ! -f "$install_dir/bin/nvim" ]]; then
        print_error "Binary file not found: $install_dir/bin/nvim"
        return 1
    fi
    
    if [[ ! -d "$install_dir/share/nvim/runtime" ]]; then
        print_error "Runtime directory not found: $install_dir/share/nvim/runtime"
        return 1
    fi
    
    chmod +x "$install_dir/bin/nvim"
    print_success "Neovim installed in $install_dir"
    
    # Step 4: Verify the installation (quiet mode; suppress all terminal control sequences)
    print_info "Verifying the installation..."
    # Use TERM=dumb and --headless to suppress terminal control sequences
    local vimruntime=$(TERM=dumb "$install_dir/bin/nvim" --clean --headless +'lua print(vim.env.VIMRUNTIME)' +q 2>&1 | grep -v "^$" | grep -vE '^\[' | tail -1)
    if [[ "$vimruntime" == "$install_dir/share/nvim/runtime" ]]; then
        print_success "Installation verified: VIMRUNTIME=$vimruntime"
    else
        print_warning "VIMRUNTIME verification warning: $vimruntime (expected: $install_dir/share/nvim/runtime)"
    fi

    # Add to PATH (notice)
    local nvim_bin="$install_dir/bin"
    if [[ ":$PATH:" != *":$nvim_bin:"* ]]; then
        print_warning "Add $nvim_bin to PATH"
        print_info "You can add it to ~/.zshrc or ~/.bashrc:"
        print_info "  export PATH=\"\$HOME/.local/nvim/bin:\$PATH\""
    else
        print_success "PATH already includes $nvim_bin"
    fi
}

# Download and install Neovim (macOS)
install_nvim_macos() {
    local version="$1"
    local arch="$2"
    local install_dir="$HOME/.local/bin"
    local cache_dir="$HOME/.cache/nvim"
    local download_url=""
    local filename=""
    
    # Build the download URL (using the format recommended by the project)
    if [[ "$arch" == "aarch64" ]] || [[ "$arch" == "arm64" ]]; then
        filename="nvim-macos-arm64.tar.gz"
        # If the version is empty, use /latest/download/; otherwise use the specified version
        if [[ -z "$version" ]]; then
            download_url="https://github.com/neovim/neovim/releases/latest/download/nvim-macos-arm64.tar.gz"
        else
            download_url="https://github.com/neovim/neovim/releases/download/v${version}/nvim-macos-arm64.tar.gz"
        fi
    elif [[ "$arch" == "x86_64" ]]; then
        filename="nvim-macos-x86_64.tar.gz"
        # If the version is empty, use /latest/download/; otherwise use the specified version
        if [[ -z "$version" ]]; then
            download_url="https://github.com/neovim/neovim/releases/latest/download/nvim-macos-x86_64.tar.gz"
        else
            download_url="https://github.com/neovim/neovim/releases/download/v${version}/nvim-macos-x86_64.tar.gz"
        fi
    else
        print_error "macOS architecture $arch is unsupported"
        return 1
    fi
    
    local cache_file="$cache_dir/$filename"
    mkdir -p "$cache_dir" "$install_dir"
    
    # Download
    if [[ -n "$version" ]]; then
        print_info "Downloading Neovim ${version}..."
    else
        print_info "Downloading the latest Neovim version..."
    fi
    if [[ -f "$cache_file" ]]; then
        print_info "Cached file already exists; skipping download"
    else
        if command -v curl >/dev/null 2>&1; then
            curl -L -o "$cache_file" "$download_url" || {
                print_error "Download failed"
                return 1
            }
        else
            print_error "curl is required for downloading"
            return 1
        fi
        print_success "Download complete"
    fi
    
    # Extract
    print_info "Extracting..."
    local extract_dir="$cache_dir/nvim-${version:-latest}"
    rm -rf "$extract_dir"
    mkdir -p "$extract_dir"
    tar -xzf "$cache_file" -C "$extract_dir" --strip-components=1 || {
        print_error "Extraction failed"
        return 1
    }
    
    # Install
    print_info "Installing to $install_dir..."
    if [[ -d "$extract_dir/bin" ]]; then
        # Copy the nvim binary
        cp -f "$extract_dir/bin/nvim" "$install_dir/nvim" || {
            print_error "Installation failed"
            return 1
        }
        chmod +x "$install_dir/nvim"
        
        # Install runtime files to ~/.local/share/nvim (Neovim looks here)
        local runtime_dir="$HOME/.local/share/nvim"
        if [[ -d "$extract_dir/share/nvim" ]]; then
            print_info "Installing runtime files to $runtime_dir..."
            mkdir -p "$runtime_dir"
            # Copy all runtime files (including the runtime directory)
            if [[ -d "$extract_dir/share/nvim/runtime" ]]; then
                cp -rf "$extract_dir/share/nvim/runtime" "$runtime_dir/" || {
                    print_warning "Failed to copy runtime files, but the binary was installed"
                }
            fi
            # Also copy other possible runtime files (such as Lua modules)
            if [[ -d "$extract_dir/share/nvim" ]]; then
                # Copy all non-runtime files
                for item in "$extract_dir/share/nvim"/*; do
                    if [[ -e "$item" ]] && [[ "$(basename "$item")" != "runtime" ]]; then
                        cp -rf "$item" "$runtime_dir/" 2>/dev/null || true
                    fi
                done
            fi
        fi
        
        print_success "Neovim installed in $install_dir/nvim"
    else
        print_error "The extracted directory structure is invalid"
        return 1
    fi
    
    # Clean up
    rm -rf "$extract_dir"
    
    # Add to PATH (if it is not already present)
    if [[ ":$PATH:" != *":$install_dir:"* ]]; then
        print_warning "Make sure $install_dir is in PATH"
        print_info "You can add it to ~/.zshrc:"
        print_info "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
}

readonly NVIM_MIN_MAJOR=0
readonly NVIM_MIN_MINOR=11
readonly NVIM_MIN_VERSION="${NVIM_MIN_MAJOR}.${NVIM_MIN_MINOR}.0"

nvim_version_supported() {
    local version="$1"
    local major=$(echo "$version" | cut -d. -f1)
    local minor=$(echo "$version" | cut -d. -f2)

    [[ $major -gt $NVIM_MIN_MAJOR ]] || [[ $major -eq $NVIM_MIN_MAJOR && $minor -ge $NVIM_MIN_MINOR ]]
}

# Check whether Neovim is installed
check_installed() {
    local version="$1"
    
    if command -v nvim >/dev/null 2>&1; then
        # Use TERM=dumb and filter control sequences
        local installed_version=$(TERM=dumb nvim --version 2>&1 | grep -vE '^\[' | head -n 1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/^v//')
        
        # The current configuration uses Neovim 0.11+'s native LSP API.
        if [[ -n "$installed_version" ]]; then
            if ! nvim_version_supported "$installed_version"; then
                print_warning "Installed version detected: ${installed_version}"
                print_error "The current Neovim configuration requires Neovim ${NVIM_MIN_VERSION} or later!"
                print_info "The current version is too old; upgrading to the latest version is recommended"
                return 1
            fi
        fi
        
        if [[ "$installed_version" == "$version" ]]; then
            print_success "Neovim ${version} is installed"
            return 0
        else
            print_info "Installed version detected: ${installed_version}"
            if [[ -n "$version" ]]; then
                print_info "Target version: ${version}"
            fi
            return 1
        fi
    else
        return 1
    fi
}

# Main function
main() {
    local force_install=false
    local target_version=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force|-f)
                force_install=true
                shift
                ;;
            --version|-v)
                target_version="$2"
                shift 2
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Usage: $0 [--force] [--version VERSION]"
                exit 1
                ;;
        esac
    done
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Neovim installation script"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_info "Note: the current Neovim configuration requires Neovim ${NVIM_MIN_VERSION} or later"
    echo ""
    
    # Detect the system
    if ! detect_system; then
        exit 1
    fi
    
    # Get the version (for display and checking; downloads use /latest/download/)
    if [[ -z "$target_version" ]]; then
        print_info "Retrieving the latest version information..."
        target_version=$(get_latest_version)
        if [[ -z "$target_version" ]]; then
            print_warning "Unable to retrieve the version number; downloading via /latest/download/"
            target_version="latest"
        else
            print_success "Latest version: ${target_version}"
        fi
    else
        print_info "Target version: ${target_version}"
    fi
    
    # Check whether it is installed (only for a specific version)
    if [[ "$target_version" != "latest" ]]; then
        if ! $force_install && check_installed "$target_version"; then
            print_info "The latest version is already installed; no installation is needed"
            print_info "Use --force to reinstall"
            exit 0
        fi
        
        # Ask for confirmation (unless force installation is enabled)
        if ! $force_install; then
            if check_installed "$target_version" 2>/dev/null; then
                read -p "Reinstall Neovim ${target_version}? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    print_info "Installation canceled"
                    exit 0
                fi
            fi
        fi
    fi
    
    # Install
    # If the version is "latest", pass an empty string to the install function to use /latest/download/
    local install_version=""
    if [[ "$target_version" != "latest" ]]; then
        install_version="$target_version"
    fi
    
    print_info "Installing Neovim ${target_version}..."
    if [[ "$NVIM_OS" == "linux" ]]; then
        install_nvim_linux "$install_version" "$NVIM_ARCH"
    elif [[ "$NVIM_OS" == "macos" ]]; then
        install_nvim_macos "$install_version" "$NVIM_ARCH"
    else
        print_error "Unsupported operating system"
        exit 1
    fi
    
    if [[ $? -eq 0 ]]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        if [[ "$target_version" == "latest" ]]; then
            print_success "Latest Neovim version installed!"
        else
            print_success "Neovim ${target_version} installed!"
        fi
        echo ""
        print_info "Installation location: ~/.local/nvim/"
        print_info "Binary: ~/.local/nvim/bin/nvim"
        print_info "Runtime files: ~/.local/nvim/share/nvim/runtime"
        echo ""
        print_info "Verify the installation:"
        print_info "  ~/.local/nvim/bin/nvim --version"
        print_info "  ~/.local/nvim/bin/nvim --clean +'lua print(vim.env.VIMRUNTIME)' +q"
        echo ""
        
        # Check PATH and version
        local nvim_bin="$HOME/.local/nvim/bin"
        if [[ ":$PATH:" == *":$nvim_bin:"* ]]; then
            local nvim_path=$(command -v nvim 2>/dev/null || echo "")
            if [[ -n "$nvim_path" ]] && [[ "$nvim_path" == "$nvim_bin/nvim" ]]; then
                print_success "PATH is configured; the nvim command is ready to use"
                # Use TERM=dumb and filter control sequences
                local installed_version=$(TERM=dumb "$nvim_path" --version 2>&1 | grep -vE '^\[' | head -n 1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/^v//' || echo "")
                if [[ -n "$installed_version" ]]; then
                    if ! nvim_version_supported "$installed_version"; then
                        print_warning "Older version detected: ${installed_version}"
                        print_error "The current Neovim configuration requires Neovim ${NVIM_MIN_VERSION} or later!"
                    else
                        print_success "Version check passed: ${installed_version}"
                    fi
                fi
            fi
        else
            print_warning "Add $nvim_bin to PATH"
            print_info "Add it to ~/.zshrc:"
            print_info "  export PATH=\"\$HOME/.local/nvim/bin:\$PATH\""
            print_info "Then reload it: source ~/.zshrc"
        fi
        echo ""
        print_info "Start Neovim:"
        if [[ ":$PATH:" == *":$nvim_bin:"* ]]; then
            print_info "  nvim  # PATH is configured; ready to use"
        else
            print_info "  ~/.local/nvim/bin/nvim  # Or add it to PATH and use nvim"
        fi
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    else
        print_error "Installation failed"
        exit 1
    fi
}

# Run the main function
main "$@"
