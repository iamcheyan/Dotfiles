# Scripts 目录说明

本目录只保留**被引用**的脚本。未被引用的脚本已迁至 chezmoi 管理：`~/.config/scripts/dotfiles-migrated/`（源：`~/chezmoi/dot_config/scripts/dotfiles-migrated/`）。

## 目录结构

```
scripts/
├── install/     # init.sh 调用的安装脚本
├── setup/       # shell 运行时 source 的配置脚本
└── README.md
```

### `scripts/install/` - 工具安装脚本

- `install_font.sh` - 安装字体（init.sh `install_fonts` 调用）
- `install_httpie.sh` - 安装 HTTPie（plugins/tools/tools.zsh 调用）
- `install_nvim.sh` - 安装 Neovim（init.sh `install_neovim` 调用）
- `install_zellij.sh` - 安装 Zellij（init.sh `install_extra_tools` 调用）

### `scripts/setup/` - 环境配置脚本

- `setup_fnm.sh` - fnm lazy loader（zshrc 中 source）

> fnm/fzf 的安装逻辑在 init.sh 内联（`install_fnm`/`install_fzf` 函数），不依赖独立脚本。
