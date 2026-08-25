#!/bin/bash
# ==========================================
# WSL full-system cleanup script
# Clean Rust, Python, apt, Snap, logs, and temporary files
# ==========================================

echo "===== Starting WSL cleanup ====="

# 1️⃣ Clean Cargo cache
if command -v cargo >/dev/null 2>&1; then
    echo ">>> Cleaning Cargo cache"
    cargo cache -a
fi

# 2️⃣ Clean up old Rust toolchains
if command -v rustup >/dev/null 2>&1; then
    echo ">>> Cleaning old Rust toolchains"
    rustup cleanup -y 2>/dev/null || echo "⚠️ rustup cleanup failed; run rustup cleanup manually"
fi

# 3️⃣ Clean pip cache
if command -v pip >/dev/null 2>&1; then
    echo ">>> Cleaning pip cache"
    rm -rf ~/.cache/pip
fi

# 4️⃣ Clean apt cache and unused packages
if command -v apt >/dev/null 2>&1; then
    echo ">>> Cleaning apt cache"
    sudo apt clean
    sudo apt autoremove -y
fi

# 5️⃣ Clean journal logs (keep only the last 3 days)
if command -v journalctl >/dev/null 2>&1; then
    echo ">>> Cleaning system logs"
    sudo journalctl --vacuum-time=3d
fi

# 6️⃣ Clean Snap cache
if command -v snap >/dev/null 2>&1; then
    echo ">>> Cleaning Snap cache"
    sudo du -hx /var/lib/snapd/snaps 2>/dev/null | sort -hr | head -n 10
    # Optional: remove old versions
    # sudo snap remove <old-package-name>
fi

# 7️⃣ Clean temporary files
echo ">>> Cleaning /tmp directory"
sudo rm -rf /tmp/*

# 8️⃣ Find large files (>500MB)
echo ">>> List files larger than 500MB (do not cross /mnt)"
sudo find / -xdev -type f -size +500M 2>/dev/null | sort -hr | head -n 20

# 9️⃣ Show disk usage by directory
echo ">>> Show disk usage for top-level directories (do not cross /mnt)"
sudo du -hx --max-depth=1 / 2>/dev/null | sort -hr


echo "===== Cleanup complete ====="