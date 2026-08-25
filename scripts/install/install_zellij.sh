#!/bin/bash

# zellij installation script
# zellij is a terminal multiplexer (similar to tmux)
# Usage: install_zellij.sh [--method cargo|binary] [--force]

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Detect the architecture
detect_arch() {
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)
            ARCH="x86_64"
            ;;
        aarch64|arm64)
            ARCH="aarch64"
            ;;
        *)
            print_warning "Unrecognized architecture: $ARCH; defaulting to x86_64"
            ARCH="x86_64"
            ;;
    esac
    echo "$ARCH"
}

# Check whether a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check whether zellij is already installed
check_installed() {
    if command_exists zellij; then
        print_success "zellij is installed: $(zellij --version 2>/dev/null || echo 'unknown version')"
        return 0
    fi
    return 1
}

# Install with cargo
install_with_cargo() {
    if ! command_exists cargo; then
        print_error "cargo not found; install Rust first"
        return 1
    fi

    # Check whether it is already installed
    local was_installed=false
    if command_exists zellij; then
        was_installed=true
        print_info "Installed version detected: $(zellij --version 2>/dev/null || echo 'unknown')"
    fi

    print_info "Installing zellij with cargo (this may take a few minutes)..."
    cargo install zellij

    if [ $? -eq 0 ]; then
        print_success "zellij installed successfully!"
        return 0
    else
        if [ "$was_installed" = "true" ]; then
            print_warning "Reinstallation failed, but the previous version is still available"
            print_info "Current version: $(zellij --version 2>/dev/null || echo 'unknown')"
            print_info "If compilation fails (for example, SIGKILL), you may be out of memory or hitting system resource limits"
            print_info "Try installing from a binary instead: install:zellij --method binary"
            return 0  # Return success because the old version is still available
        else
            print_error "cargo installation failed"
            print_info "Try installing from a binary instead: install:zellij --method binary"
            return 1
        fi
    fi
}

# Install from a binary
install_with_binary() {
    ARCH=$(detect_arch)
    VERSION=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' || echo "v0.40.0")
    VERSION_NUM=${VERSION#v}
    
    DOWNLOAD_URL="https://github.com/zellij-org/zellij/releases/download/${VERSION}/zellij-${ARCH}-unknown-linux-musl.tar.gz"
    TEMP_DIR="/tmp/zellij-install"
    BIN_DIR="$HOME/.local/bin"

    print_info "Detected architecture: $ARCH"
    print_info "Latest version: $VERSION"
    print_info "Download URL: $DOWNLOAD_URL"

    # Create the temporary directory
    mkdir -p "$TEMP_DIR"
    mkdir -p "$BIN_DIR"

    # Download
    print_info "Downloading zellij..."
    if command_exists curl; then
        curl -L "$DOWNLOAD_URL" -o "$TEMP_DIR/zellij.tar.gz"
    elif command_exists wget; then
        wget "$DOWNLOAD_URL" -O "$TEMP_DIR/zellij.tar.gz"
    else
        print_error "curl or wget is required to download the file"
        return 1
    fi

    if [ ! -f "$TEMP_DIR/zellij.tar.gz" ]; then
        print_error "Download failed"
        return 1
    fi

    # Extract
    print_info "Extracting..."
    cd "$TEMP_DIR"
    tar -xzf zellij.tar.gz

    # Install
    if [ -f "$TEMP_DIR/zellij" ]; then
        cp "$TEMP_DIR/zellij" "$BIN_DIR/zellij"
        chmod +x "$BIN_DIR/zellij"
        print_success "zellij installed at: $BIN_DIR/zellij"
        
        # Check PATH
        if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
            print_warning "$BIN_DIR is not in PATH"
            print_info "Add the following to ~/.zshrc or ~/.bashrc:"
            echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        fi
        
        # Clean up
        rm -rf "$TEMP_DIR"
        return 0
    else
        print_error "zellij binary not found after extraction"
        return 1
    fi
}

# Main function
main() {
    INSTALL_METHOD="auto"
    FORCE=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --method)
                INSTALL_METHOD="$2"
                shift 2
                ;;
            --force)
                FORCE=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Usage: $0 [--method cargo|binary] [--force]"
                exit 1
                ;;
        esac
    done

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Installing zellij...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Check whether it is already installed
    if check_installed && [ "$FORCE" != "true" ]; then
        read -p "zellij is installed; reinstall it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation canceled"
            exit 0
        fi
    fi

    # Choose the installation method
    if [ "$INSTALL_METHOD" = "auto" ]; then
        if command_exists cargo; then
            INSTALL_METHOD="cargo"
        else
            INSTALL_METHOD="binary"
        fi
    fi

    case "$INSTALL_METHOD" in
        cargo)
            install_with_cargo
            ;;
        binary)
            install_with_binary
            ;;
        *)
            print_error "Unknown installation method: $INSTALL_METHOD"
            exit 1
            ;;
    esac

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ zellij installation complete!${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${YELLOW}📋 Usage:${NC}"
        echo ""
        echo "Start zellij:"
        echo "  zellij"
        echo ""
        echo "Show help:"
        echo "  zellij --help"
        echo ""
        echo "Keyboard shortcuts (default):"
        echo "  Ctrl+g  - Enter command mode"
        echo "  Ctrl+o  - Switch panes"
        echo "  Alt+n    - Create a new tab"
        echo ""
        echo -e "${YELLOW}💡 Tip:${NC}"
        echo "  If the command is not found, make sure ~/.local/bin or ~/.cargo/bin is in PATH"
        echo "  Reload the shell configuration: source ~/.zshrc"
        echo ""
    else
        print_error "Installation failed"
        exit 1
    fi
}

main "$@"

