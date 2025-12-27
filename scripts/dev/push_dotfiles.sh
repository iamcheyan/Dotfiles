#!/bin/bash
# Dotfiles 推送脚本：自动提交并推送到 GitHub
# 用法: push_dotfiles [提交信息前缀]

set -e

DOTFILES_DIR="$HOME/.dotfiles"
cd "$DOTFILES_DIR" || {
    echo "错误: 无法进入 dotfiles 目录: $DOTFILES_DIR" >&2
    exit 1
}

# 检查是否为 Git 仓库
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "错误: 当前目录不是 Git 仓库" >&2
    echo "正在初始化 Git 仓库..."
    git init
fi

# 检查远程仓库
REMOTE_URL="https://github.com/iamcheyan/Dotfiles.git"
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "添加远程仓库: $REMOTE_URL"
    git remote add origin "$REMOTE_URL"
elif [ "$(git remote get-url origin)" != "$REMOTE_URL" ]; then
    echo "更新远程仓库 URL: $REMOTE_URL"
    git remote set-url origin "$REMOTE_URL"
fi

# 获取设备名
get_hostname() {
    if command -v hostname >/dev/null 2>&1; then
        hostname 2>/dev/null || echo "unknown"
    else
        echo "unknown"
    fi
}

# 生成时间戳（格式：YYYY-MM-DD HH:MM:SS）
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# 获取信息
HOSTNAME=$(get_hostname)
TIMESTAMP=$(get_timestamp)
COMMIT_PREFIX="${1:-Update}"

# 构建提交信息：Update: Tetsuya-Apple-M1-Max.local - 2025-12-27 20:05:37
COMMIT_MSG="${COMMIT_PREFIX}: ${HOSTNAME} - ${TIMESTAMP}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  准备推送 dotfiles 到 GitHub"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "提交信息: $COMMIT_MSG"
echo "设备名: $HOSTNAME"
echo "时间戳: $TIMESTAMP"
echo ""

# 检查是否有更改
if git diff --quiet && git diff --cached --quiet; then
    echo "没有需要提交的更改"
    exit 0
fi

# 添加所有更改
echo "正在添加文件..."
git add .

# 提交
echo "正在提交..."
git commit -m "$COMMIT_MSG" || {
    echo "错误: 提交失败" >&2
    exit 1
}

# 推送
echo "正在推送到 GitHub..."
BRANCH=$(git branch --show-current 2>/dev/null || echo "main")

# 如果分支不存在，创建并推送
if ! git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
    git branch -M main 2>/dev/null || true
    BRANCH="main"
fi

# 尝试推送，如果失败则设置上游分支
if ! git push -u origin "$BRANCH" 2>/dev/null; then
    git push origin "$BRANCH" || {
        echo "错误: 推送失败" >&2
        echo "提示: 请检查网络连接和 GitHub 权限" >&2
        exit 1
    }
fi

echo ""
echo "✓ 推送成功！"
echo "  仓库: $REMOTE_URL"
echo "  分支: $BRANCH"

