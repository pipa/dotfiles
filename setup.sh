#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

print_status() {
    printf "\r%-40s ...\n" "$1"
}

print_done() {
    printf "\r%-40s ✓\n" "$1"
}

print_fail() {
    printf "\r%-40s ✗\n" "$1"
    exit 1
}

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║         Dotfiles Setup for $OS          ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Detect OS
if [[ "$OS" == "Linux" ]]; then
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        DISTRO="$ID"
    elif [[ -f /etc/centos-release ]]; then
        DISTRO="centos"
    else
        DISTRO="unknown"
    fi
fi

echo "Detected: $OS ($DISTRO)"
echo ""

# Run OS-specific setup
case "$OS" in
    Darwin)
        print_status "Setting up macOS dependencies"
        bash "$DOTFILES_DIR/install/macos.sh" 2>/dev/null && print_done "Setting up macOS dependencies" || print_fail "Setting up macOS dependencies"
        ;;
    Linux)
        print_status "Setting up Linux dependencies"
        bash "$DOTFILES_DIR/install/linux.sh" 2>/dev/null && print_done "Setting up Linux dependencies" || print_fail "Setting up Linux dependencies"
        ;;
    *)
        echo "✗ Unsupported OS: $OS"
        exit 1
        ;;
esac

# Install Oh My Zsh
print_status "Installing Oh My Zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>/dev/null
fi
print_done "Installing Oh My Zsh"

# Install zsh plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
print_status "Installing zsh plugins"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null
fi
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions" 2>/dev/null
fi
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null
fi
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autopair" ]]; then
    git clone https://github.com/hlissner/zsh-autopair "$ZSH_CUSTOM/plugins/zsh-autopair" 2>/dev/null
fi
print_done "Installing zsh plugins"

# Install Starship
print_status "Installing Starship"
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y 2>/dev/null
fi
print_done "Installing Starship"

# Install fnm
print_status "Installing fnm"
if ! command -v fnm &> /dev/null; then
    curl -fsSL https://fnm.vercel.app/install | bash 2>/dev/null
fi
print_done "Installing fnm"

# Install Node.js
print_status "Installing Node.js LTS"
export PATH="$HOME/.local/share/fnm:$PATH"
if command -v fnm &> /dev/null; then
    eval "$(fnm env)"
    fnm install --lts 2>/dev/null || true
    fnm default lts-latest 2>/dev/null || true
    fnm use lts-latest 2>/dev/null || true
fi
print_done "Installing Node.js LTS"

# Install pnpm
print_status "Installing pnpm"
if ! command -v pnpm &> /dev/null; then
    npm install -g pnpm 2>/dev/null
fi
print_done "Installing pnpm"

# Install Claude Code
print_status "Installing Claude Code"
if ! command -v claude &> /dev/null; then
    npm install -g @anthropic-ai/claude-code 2>/dev/null
fi
print_done "Installing Claude Code"

# Install Neovim
print_status "Installing Neovim"
if [[ "$OS" == "Darwin" ]]; then
    if ! command -v nvim &> /dev/null; then
        brew install --cask neovim-nightly 2>/dev/null || brew install neovim 2>/dev/null || true
    fi
fi
print_done "Installing Neovim"

# Install LazyVim
print_status "Installing LazyVim"
NVIM_CONFIG="$HOME/.config/nvim"
if [[ ! -d "$NVIM_CONFIG" ]] || [[ ! -f "$NVIM_CONFIG/init.lua" ]]; then
    mkdir -p "$NVIM_CONFIG"
    rm -rf "$NVIM_CONFIG/.git"
    git clone --depth 1 https://github.com/LazyVim/starter "$NVIM_CONFIG" 2>/dev/null
    rm -rf "$NVIM_CONFIG/.git"
fi
print_done "Installing LazyVim"

# Link dotfiles
print_status "Linking dotfiles"
bash "$DOTFILES_DIR/scripts/link.sh" 2>/dev/null
print_done "Linking dotfiles"

# Set zsh as default shell
if [[ "$SHELL" != *"zsh" ]]; then
    print_status "Setting zsh as default shell"
    sudo chsh -s /bin/zsh 2>/dev/null || chsh -s /bin/zsh 2>/dev/null || true
    print_done "Setting zsh as default shell"
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║           Setup Complete! 🎉             ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal"
echo "  2. Run 'nvim' to complete LazyVim setup"
echo "  3. Authenticate with Doppler: doppler login"
echo "  4. Select project: doppler config set-project vini"
echo ""