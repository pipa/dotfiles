# Dotfiles

My dotfiles for macOS and Linux. Contains all the configuration I need to get productive quickly on any new machine.

## What's Included

### Shell & Terminal
- **Zsh** with Oh My Zsh
- **Plugins**: autosuggestions, completions, syntax-highlighting, autopair
- **Starship** prompt
- **zoxide** for smarter cd
- **fzf** for fuzzy finding

### Development Environment
- **fnm** for Node.js management
- **pnpm** package manager
- **Neovim** (nightly) with LazyVim
  - Catppuccin colorscheme
  - nvim-ufo for code folding (foldlevel=1)
  - which-key for keybindings
  - LSPs: ts_ls, eslint, bashls, dockerls, jsonls, yamlls, marksman, html, cssls

### Tools
- **Git** with git-delta for beautiful diffs
- **lazygit** - TUI git client
- **eza** - Modern ls
- **bat** - Modern cat
- **btop** - System monitor

### Claude Code
- Configured with permissions and guardrails
- Doppler integration for API keys

## Quick Start

### Clone & Setup

```bash
# Clone the repo
git clone https://github.com/your-username/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run the setup script
./setup.sh
```

### Post-Setup

1. Restart your terminal
2. Run `nvim` to complete LazyVim setup (will install plugins)
3. Authenticate with Doppler:
   ```bash
   doppler login
   doppler config set-project vini
   ```

## Updating

```bash
cd ~/dotfiles
git pull
./setup.sh
```

## Manual Commands

### Link dotfiles manually
```bash
./scripts/link.sh
```

### Install just Homebrew packages
```bash
brew bundle install --file=Brewfile
```

## Key Aliases

| Alias | Command |
|-------|---------|
| `ll`, `la`, `l` | `eza` commands |
| `g` | `git` |
| `lg` | `lazygit` |
| `v`, `vi`, `vim` | `nvim` |
| `d` | `docker` |
| `dc` | `docker compose` |
| `pi` | `pnpm install` |
| `pr` | `pnpm run` |
| `pd` | `pnpm dev` |
| `reload` | `source ~/.zshrc` |

## Keymaps

LazyVim default keymaps plus custom ones:

| Keymap | Action |
|--------|--------|
| `<leader><space>` | Find files (Telescope) |
| `<leader>fc` | Find commits |
| `<leader>fh` | Find help |
| `<leader>fr` | Find recent files |
| `<leader>ss` | Search Grep |
| `<leader>sw` | Search word |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover |
| `<leader>la` | Code actions |
| `<leader>ld` | Type definition |
| `zf` | Fold (ufo) |
| `zR` | Open all folds |
| `zM` | Close all folds |

## Supported OS

- **macOS** (primary)
- **Linux** (Ubuntu, CentOS)

## Structure

```
.
├── setup.sh              # Main installer
├── Brewfile              # Homebrew packages
├── .zshrc               # Zsh configuration
├── .aliases             # Aliases & functions
├── .gitconfig           # Git configuration
├── install/
│   ├── macos.sh         # macOS-specific setup
│   └── linux.sh         # Linux-specific setup
├── scripts/
│   └── link.sh          # Symlink dotfiles
├── .config/
│   ├── starship.toml    # Starship prompt config
│   └── nvim/            # Neovim/LazyVim config
└── .claude/
    └── settings.json    # Claude Code settings
```

## License

MIT

---

*Last updated: 2026-03-15*