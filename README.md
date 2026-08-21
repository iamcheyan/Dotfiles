# Public Dotfiles

Portable Zsh and Neovim environment for terminal-first development.

This repository is intentionally public and standalone. It can be cloned and used without Chezmoi. It provides a practical shell, editor, Tmux, file-manager, and terminal workflow while keeping machine-specific credentials and private integrations outside the repository.

## What You Get After Cloning

After running the initializer and linking the configuration, you get:

### Zsh

- Zsh startup configuration with safe `TERM`/terminfo fallback.
- Zsh Vim editing mode.
- Zinit-based plugin loading.
- Starship prompt support.
- Autosuggestions, syntax highlighting, autopair, completion, and `fzf-tab`.
- Atuin history integration when Atuin is installed.
- Zoxide directory jumping when Zoxide is installed.
- Optional WSL Windows-PATH filtering through `WSL_STRIP_WINDOWS_PATH=1`.
- Portable aliases and helper functions for `eza`, `bat`, `fd`, `ripgrep`, Ranger, Vifm, and Yazi-compatible workflows.

### Neovim

- Standalone `lazy.nvim` setup; it does not depend on LazyVim.
- LSP and Mason server management.
- Treesitter syntax highlighting, folding, and text objects.
- Telescope, Snacks, Neo-tree, Oil, and Flash navigation tools.
- Blink completion, conform formatting, Gitsigns, Diffview, and Fidget.
- Heirline statusline and Bufferline tabline.
- Auto-session persistence by working directory.
- Yanky clipboard history, mini.ai, mini.pairs, Which-Key, and Vim Visual Multi.
- Vimquest language-learning plugin and other optional public plugins.

### Tmux

- Tmux configuration with mouse support, RGB/true-color settings, and a compact status bar.
- Tmux Plugin Manager (TPM), tmux-resurrect, and tmux-continuum integration.
- Public configuration remains portable; personal AI-agent restore rules are loaded only from an optional private file managed by Chezmoi.
- A local uncommitted customization may be added to `config/tmux/tmux.conf` without affecting the public baseline.

### Herdr Local AI Assistant

The initializer installs **Herdr**, a local AI coding assistant designed for terminal workflows. This is a deliberate public feature of this repository:

- `bash init.sh` installs Herdr when it is not already available.
- `config/herdr/config.toml` provides a small, shareable baseline theme configuration.
- The configuration is linked to `~/.config/herdr/config.toml` by `dotlink`.
- No API keys, tokens, conversations, or private provider credentials are stored here.
- If you do not want Herdr, remove or comment out the Herdr block in `init_extra_tools()` before running the initializer.

Herdr is separate from the private Agent wrappers in Chezmoi: this repository provides only the public installation and baseline configuration.

### Other Public Configurations

- Ranger with Vim-style navigation and public plugins.
- Vifm configuration and helper functions.
- Ghostty configuration.
- Atuin, Starship, Nano, and related terminal utilities.
- `dotlink`, a small shell-based symlink manager with no Chezmoi dependency.

## What This Repository Does Not Include

The following remain in the private `iamcheyan/chezmoi` repository:

- Kitty, Yazi, and Zellij configurations.
- Other personal AI-agent wrappers, provider configuration, quota tools, and private tmux-agent restore logic.
- API keys, tokens, `.env` files, credentials, private server addresses, and machine-specific scripts.

The public repository may optionally load `~/.config/aliases.conf` from a user's own system. That file is not part of this repository and is the extension point used by the private Chezmoi configuration.

## Installation

### 1. Clone

```bash
git clone https://github.com/iamcheyan/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Run the initializer

```bash
bash init.sh              # Full installation
bash init.sh --minimal    # Minimal installation
bash init.sh --repair     # Repair cached Zinit plugins
```

The initializer detects the host operating system and can install common dependencies such as:

- Git, curl, wget, ripgrep, fd, bat, eza, zoxide, fzf, jq, and related CLI tools.
- Zsh and the configured shell environment.
- Neovim and its public lazy.nvim configuration.
- Python/Node tooling used by the shell setup.
- Docker on supported Linux distributions.
- Zellij, Herdr, and Tmux Plugin Manager when available.

Package availability varies by distribution. The script skips unavailable packages and prints warnings instead of assuming every package exists everywhere.

### 3. Create symlinks

```bash
bash dotlink/dotlink link
```

The public link set includes:

```text
~/dotfiles/zshrc                         -> ~/.zshrc
~/dotfiles/config/nvim                   -> ~/.config/nvim
~/dotfiles/config/tmux/tmux.conf         -> ~/.tmux.conf
~/dotfiles/config/ranger                 -> ~/.config/ranger
~/dotfiles/config/vifm/*                 -> ~/.config/vifm/*
~/dotfiles/config/ghostty                -> ~/.config/ghostty
~/dotfiles/config/atuin                  -> ~/.config/atuin
~/dotfiles/config/herdr/config.toml      -> ~/.config/herdr/config.toml
~/dotfiles/config/starship/starship.toml -> ~/.config/starship.toml
```

### 4. Start a new shell

```bash
exec zsh
```

The first interactive shell may install or cache Zinit-managed plugins. Restart the shell after plugin installation if a newly installed plugin is not immediately available.

## Common Commands

```bash
bash dotlink/dotlink link       # Create or repair symlinks
bash init.sh --repair           # Repair Zinit/plugin state
exec zsh                        # Reload the current shell
```

Useful aliases are conditionally enabled when their commands exist:

```text
l / ll / la    eza directory listings
r              Ranger with cwd handoff
v              Vifm with cwd handoff
zi / za / zr   Zoxide helpers
```

## Repository Layout

```text
dotfiles/
├── zshrc                  # Public Zsh entrypoint
├── aliases.conf           # Public aliases and shell helpers
├── init.sh                # Cross-platform initializer
├── dotlink/               # Symlink manager and link manifest
├── config/
│   ├── nvim/              # Neovim lazy.nvim configuration
│   ├── tmux/              # Public Tmux baseline
│   ├── ranger/            # Ranger configuration
│   ├── vifm/              # Vifm configuration
│   ├── ghostty/           # Ghostty configuration
│   ├── atuin/             # Atuin configuration
│   └── starship/           # Starship configuration
├── plugins/               # Public Zsh/plugin helpers
├── scripts/               # Public installation and utility scripts
└── tools/                 # Public standalone tools
```

Kitty, Yazi, and Zellij are deliberately absent here because they are maintained as separate public repositories and embedded as submodules in the private Chezmoi repository:

- https://github.com/iamcheyan/kitty
- https://github.com/iamcheyan/yazi
- https://github.com/iamcheyan/zellij

## Customization

### Add a public alias

Edit `aliases.conf`:

```bash
alias mycommand="original-command"
```

Then recreate links and reload Zsh:

```bash
bash dotlink/dotlink link
exec zsh
```

### Add a Neovim plugin

Create a Lua file under `config/nvim/lua/plugins/`:

```lua
return {
  {
    "author/plugin-name",
    config = function()
      -- plugin configuration
    end,
  },
}
```

### Keep machine-specific configuration private

Put personal aliases, API-related wrappers, private paths, and provider configuration in your private Chezmoi repository instead of adding them here.

## Checks Before Publishing

```bash
zsh -n zshrc
bash -n init.sh
bash -n aliases.conf
git diff --check
git status
```

Do not publish `.env`, credentials, private keys, tokens, personal absolute paths, or private network details.

## License

MIT License
