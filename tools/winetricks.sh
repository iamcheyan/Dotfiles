#!/bin/bash

# Check whether this is Silverblue/Kinoite
is_silverblue_kinoite() {
    grep -q "silverblue\|kinoite" /etc/os-release
}

# Install winetricks
install_winetricks() {
    echo "winetricks is not installed; installing..."
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y winetricks
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y winetricks
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm winetricks
    else
        echo "Unsupported system type; install winetricks manually"
        exit 1
    fi
}

# Main function
main() {
    if is_silverblue_kinoite; then
        toolbox run --container wine winetricks "$@"
        exit 0
    fi

    if ! command -v winetricks &> /dev/null; then
        install_winetricks
    fi

    if [ $# -eq 0 ]; then
        echo "Provide the winetricks command to run as an argument"
        exit 1
    fi

    # Ensure winetricks is installed, then run the command
    if command -v winetricks &> /dev/null; then
        winetricks "$@"
    else
        echo "winetricks installation failed; cannot run command"
        exit 1
    fi
}

main "$@"
