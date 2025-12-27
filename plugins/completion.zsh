autoload -Uz compinit
compinit -C

# 添加本地 bin 目录到 PATH（用于手动安装的工具，如 superfile）
export PATH="$HOME/.local/bin:$PATH"

# 添加 zinit 管理的工具目录到 PATH
# 注意：zinit 使用 sbin 时会将工具安装到 $ZPFX/bin
# 对于使用 as"command" 的工具，它们会被安装到插件目录
if [[ -n "$ZPFX" ]] && [[ -d "$ZPFX/bin" ]]; then
    export PATH="$ZPFX/bin:$PATH"
fi

# 添加 zinit 插件目录到 PATH（用于 as"command" 安装的工具）
# 工具文件可能在插件目录的子目录中，需要递归查找
# 使用 setopt nullglob 避免 glob 扩展错误
setopt nullglob
for plugin_dir in ~/.zinit/plugins/*/; do
    if [[ -d "$plugin_dir" ]]; then
        # 添加插件根目录（工具可能直接在根目录）
        export PATH="$plugin_dir:$PATH"
        # 递归查找并添加包含可执行文件的子目录（最多查找 2 层深度）
        for subdir in "$plugin_dir"*/; do
            if [[ -d "$subdir" ]]; then
                # 检查子目录本身是否包含可执行文件
                if find "$subdir" -maxdepth 1 -type f -executable 2>/dev/null | grep -q .; then
                    export PATH="$subdir:$PATH"
                fi
                # 检查子目录的下一层（例如 bat-v10.3.0-aarch64-unknown-linux-gnu/bat）
                for subsubdir in "$subdir"*/; do
                    if [[ -d "$subsubdir" ]] && find "$subsubdir" -maxdepth 1 -type f -executable 2>/dev/null | grep -q .; then
                        export PATH="$subsubdir:$PATH"
                    fi
                done
            fi
        done
        # 特别处理 bin 子目录
        if [[ -d "$plugin_dir/bin" ]]; then
            export PATH="$plugin_dir/bin:$PATH"
        fi
    fi
done
unsetopt nullglob

# zoxide
eval "$(zoxide init zsh)"

