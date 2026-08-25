#!/bin/bash
# Font installation script
# Supports installing Meslo and Noto Serif fonts
# Usage: install_font.sh [--meslo] [--noto] [--all] [--force]

# Meslo font download URL
MESLO_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.tar.xz"
MESLO_TAR="$HOME/.cache/fonts/Meslo.tar.xz"
MESLO_VERSION="v3.4.0"

# Download the Meslo font
download_meslo_font() {
  local cache_dir=$(dirname "$MESLO_TAR")

  # Create the cache directory
  mkdir -p "$cache_dir"

  # Check whether the file already exists
  if [ -f "$MESLO_TAR" ]; then
    echo "Meslo font file already exists; skipping download"
    return 0
  fi

  echo "Downloading Meslo font from GitHub ($MESLO_VERSION)..."

  # Use wget or curl to download
  if command -v wget >/dev/null 2>&1; then
    if wget -q --show-progress -O "$MESLO_TAR" "$MESLO_URL"; then
      echo "✓ Meslo font downloaded"
      return 0
    else
      echo "Error: failed to download Meslo font" >&2
      return 1
    fi
  elif command -v curl >/dev/null 2>&1; then
    if curl -L -o "$MESLO_TAR" "$MESLO_URL"; then
      echo "✓ Meslo font downloaded"
      return 0
    else
      echo "Error: failed to download Meslo font" >&2
      return 1
    fi
  else
    echo "Error: neither wget nor curl was found" >&2
    return 1
  fi
}

# Install the Meslo font
install_meslo_font() {
  # Download the font file first
  if ! download_meslo_font; then
    return 1
  fi

  # Check whether the file exists
  if [ ! -f "$MESLO_TAR" ]; then
    echo "Error: Meslo font archive not found: $MESLO_TAR" >&2
    return 1
  fi

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Install fonts on Linux
    FONTS_DIR="$HOME/.fonts"
    mkdir -p "$FONTS_DIR"

    echo "Extracting Meslo font..."
    if tar -xJf "$MESLO_TAR" -C "$FONTS_DIR" 2>/dev/null; then
      if command -v fc-cache >/dev/null 2>&1; then
        echo "Refreshing font cache..."
        fc-cache -fv "$FONTS_DIR" >/dev/null 2>&1
        echo "✓ Meslo font installed in $FONTS_DIR and font cache refreshed"
      else
        echo "✓ Meslo font installed in $FONTS_DIR"
        echo "Warning: fc-cache not found; refresh the font cache manually"
      fi
      return 0
    else
      echo "Error: failed to extract font files" >&2
      return 1
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Install fonts on macOS
    FONTS_DIR="$HOME/Library/Fonts"
    mkdir -p "$FONTS_DIR"

    echo "Extracting Meslo font..."
    if tar -xJf "$MESLO_TAR" -C "$FONTS_DIR" 2>/dev/null; then
      echo "✓ Meslo font installed in $FONTS_DIR"
      echo "On macOS, fonts load automatically; no manual cache refresh is needed."
      return 0
    else
      echo "Error: failed to extract font files" >&2
      return 1
    fi
  else
    echo "Error: unsupported operating system: $OSTYPE" >&2
    return 1
  fi
}

# Install the Noto Serif font
install_noto_font() {
  echo "Fetching the font repository from GitHub..."

  # Define the target directory
  fonts_dir="$HOME/.cache/fonts"

  # Check whether the directory exists; create it if necessary
  if [ ! -d "$fonts_dir" ]; then
    mkdir -p "$fonts_dir"
  fi

  # Clone or update the repository
  if [ -d "$fonts_dir/.git" ]; then
    echo "Font repository already exists; updating..."
    git -C "$fonts_dir" pull
  else
    echo "Cloning the font repository..."
    git clone https://github.com/iamcheyan/fonts.git "$fonts_dir"
  fi

  # Check whether the operation succeeded
  if [ $? -ne 0 ]; then
    echo "Warning: error fetching the font repository; continuing with the download method" >&2
  else
    echo "Font repository successfully fetched to $fonts_dir"
  fi

  # Download Noto Serif CJK and Noto Serif fonts
  echo "Downloading Noto Serif fonts..."

  # Define the download URL array
  download_links=(
    "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/07_NotoSerifCJKjp.zip"
    "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/12_NotoSerifJP.zip"
    "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/09_NotoSerifCJKsc.zip"
    "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/14_NotoSerifSC.zip"
  )

  # Download each URL
  for link in "${download_links[@]}"; do
    filename=$(basename "$link")
    if [ -f "$fonts_dir/$filename" ]; then
      echo "File already exists; skipping download: $filename"
    else
      if command -v wget >/dev/null 2>&1; then
        if wget -q --show-progress -P "$fonts_dir" "$link"; then
          echo "Downloaded successfully: $filename"
        else
          echo "Download failed: $filename" >&2
        fi
      elif command -v curl >/dev/null 2>&1; then
        if curl -L -o "$fonts_dir/$filename" "$link"; then
          echo "Downloaded successfully: $filename"
        else
          echo "Download failed: $filename" >&2
        fi
      else
        echo "Error: neither wget nor curl was found" >&2
        return 1
      fi
    fi
  done

  echo "Noto Serif fonts downloaded"

  # Install the fonts
  echo "Installing fonts..."

  # Extract all zip files
  echo "Extracting font files..."
  if command -v unzip >/dev/null 2>&1; then
    find "$fonts_dir" -name "*.zip" -exec unzip -q -o {} -d "$fonts_dir" \;
    if [ $? -eq 0 ]; then
      echo "All font files extracted successfully"
    else
      echo "Error extracting font files" >&2
      return 1
    fi
  else
    echo "Error: unzip was not found" >&2
    return 1
  fi

  # Copy font files to the $HOME/.fonts directory
  echo "Copying font files..."
  mkdir -p "$HOME/.fonts"
  find "$fonts_dir" -type f \( -name "*.ttc" -o -name "*.ttf" -o -name "*.otf" \) -exec cp -f {} "$HOME/.fonts" \;

  # Organize the $HOME/.fonts directory
  echo "Organizing font files..."
  find "$HOME/.fonts" -type f \( -name "*.ttc" -o -name "*.ttf" -o -name "*.otf" \) -exec mv -f {} "$HOME/.fonts" \;
  find "$HOME/.fonts" -type d -empty -delete
  echo "Font files organized"

  # Clear the font cache
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v fc-cache >/dev/null 2>&1; then
      echo "Clearing the font cache..."
      fc-cache -f -v
    else
      echo "Warning: fc-cache not found; refresh the font cache manually"
    fi
  fi

  echo "Noto Serif fonts installed"
}

# Check whether the Meslo font is installed
check_meslo_installed() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v fc-list >/dev/null 2>&1 && fc-list | grep -qi "meslo" 2>/dev/null; then
      return 0
    fi
    # Check whether font files exist
    if [ -d "$HOME/.fonts" ] && find "$HOME/.fonts" -name "*Meslo*" -o -name "*meslo*" 2>/dev/null | grep -q .; then
      return 0
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -d "$HOME/Library/Fonts" ] && find "$HOME/Library/Fonts" -name "*Meslo*" -o -name "*meslo*" 2>/dev/null | grep -q .; then
      return 0
    fi
  fi
  return 1
}

# Main function
main() {
  local install_meslo=false
  local install_noto=false
  local force=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --meslo | -m)
      install_meslo=true
      shift
      ;;
    --noto | -n)
      install_noto=true
      shift
      ;;
    --all | -a)
      install_meslo=true
      install_noto=true
      shift
      ;;
    --force | -f)
      force=true
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Usage: $0 [--meslo] [--noto] [--all] [--force]" >&2
      exit 1
      ;;
    esac
  done

  # If no font type is specified, install Meslo by default (for backward compatibility)
  if [ "$install_meslo" = false ] && [ "$install_noto" = false ]; then
    install_meslo=true
  fi

  # Install the Meslo font
  if [ "$install_meslo" = true ]; then
    if check_meslo_installed; then
      if [ "$force" = true ]; then
        echo "Meslo font is installed, but will be reinstalled in force mode..."
        install_meslo_font
      else
        echo "✓ Meslo font is installed; skipping installation"
      fi
    else
      # If it is not installed
      if [ "$force" = false ] && [ -t 0 ]; then
        # Interactive mode: ask whether to install
        # This can also be improved for init.sh's automated experience
        # but for now, keep the prompt logic or default to Yes
        read -p "Install the Meslo font? (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
          echo "Skipped Meslo font installation"
        else
          install_meslo_font
        fi
      else
        # Non-interactive or force mode: install directly
        install_meslo_font
      fi
    fi
  fi

  # Install the Noto Serif font
  if [ "$install_noto" = true ]; then
    if [ "$force" = false ] && [ -t 0 ]; then
      # Interactive mode
      read -p "Install the Noto Serif font? (y/N): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_noto_font
      else
        echo "Skipped Noto Serif font installation"
      fi
    else
      # Non-interactive or force mode
      install_noto_font
    fi
  fi
}

# Run the main function when invoked as a script
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main "$@"
fi
