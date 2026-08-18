# Scripts 目录说明

## 目录结构

```
scripts/
├── install/     # 工具安装脚本
├── setup/       # 环境配置脚本
├── translate/   # 翻译工具
└── README.md
```

### `scripts/install/` - 工具安装脚本

用于安装各种 CLI 工具和软件。

- `install_codex.sh` - 安装 Codex
- `install_deja.sh` - 安装 Deja
- `install_fnm.sh` - 安装 fnm
- `install_font.sh` - 安装字体
- `install_fzf.sh` - 安装 fzf
- `install_gemini.sh` - 安装 Gemini
- `install_httpie.sh` - 安装 HTTPie
- `install_nvim.sh` - 安装 Neovim
- `install_opencode.sh` - 安装 Opencode
- `install_sbzr.sh` - 安装 Sbzr
- `install_treesitter.sh` - 安装 Tree-sitter
- `install_zellij.sh` - 安装 Zellij
- `firefox_theme_install.sh` - Firefox 主题安装
- `lib/npmrc_cleanup.sh` - npmrc 清理辅助脚本

### `scripts/setup/` - 环境配置脚本

用于配置开发环境和系统设置。

- `setup_fnm.sh` - fnm lazy loader（zshrc 中 source）
- `setup_github.sh` - GitHub 配置
- `setup_node.sh` - Node.js 环境配置
- `setup_npm_globals.sh` - npm 全局包安装
- `setup_nopasswd_sudo.sh` - 免密 sudo 配置
- `setup_ssh_key.sh` - SSH 密钥配置
- `setup_ssh_server.sh` - SSH 服务器安装配置

### `scripts/translate/` - 翻译工具

- `translate.py` - 翻译脚本
