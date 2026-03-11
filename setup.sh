#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

echo "=========================================="
echo "  Dotfiles Setup for $OS"
echo "=========================================="

# Detect Linux distribution
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

# Check if running in CI/non-interactive mode
if [[ "$CI" == "true" ]]; then
    INTERACTIVE=false
else
    INTERACTIVE=true
fi

# Run OS-specific setup
case "$OS" in
    Darwin)
        echo "Running macOS setup..."
        bash "$DOTFILES_DIR/install/macos.sh"
        ;;
    Linux)
        echo "Running Linux setup..."
        bash "$DOTFILES_DIR/install/linux.sh"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Install Oh My Zsh if not present
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install zsh plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# zsh-autosuggestions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# zsh-completions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
    echo "Installing zsh-completions..."
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
fi

# zsh-syntax-highlighting
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# zsh-autopair
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autopair" ]]; then
    echo "Installing zsh-autopair..."
    git clone https://github.com/hlissner/zsh-autopair "$ZSH_CUSTOM/plugins/zsh-autopair"
fi

# Install Starship prompt
if ! command -v starship &> /dev/null; then
    echo "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Install fnm
if ! command -v fnm &> /dev/null; then
    echo "Installing fnm..."
    curl -fsSL https://fnm.vercel.app/install | bash
fi

# Source fnm
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env)"

# Install Node.js LTS
echo "Installing Node.js LTS..."
fnm install --lts
fnm default lts-latest
fnm use lts-latest

# Install pnpm
if ! command -v pnpm &> /dev/null; then
    echo "Installing pnpm..."
    npm install -g pnpm
fi

# Install Neovim nightly
if [[ "$OS" == "Darwin" ]]; then
    if ! command -v nvim &> /dev/null; then
        echo "Installing Neovim..."
        # Try nightly first, fallback to stable
        if brew install --cask neovim-nightly 2>/dev/null; then
            echo "Installed Neovim nightly"
        else
            echo "Falling back to stable Neovim..."
            brew install neovim
        fi
    elif [[ "$(nvim --version | head -1)" != *"0.10"* ]] && [[ "$(nvim --version | head -1)" != *"nightly"* ]]; then
        echo "Upgrading Neovim..."
        brew install --cask neovim-nightly 2>/dev/null || brew upgrade neovim
    fi
fi

# Install LazyVim
NVIM_CONFIG="$HOME/.config/nvim"
if [[ ! -d "$NVIM_CONFIG" ]] || [[ ! -f "$NVIM_CONFIG/init.lua" ]]; then
    echo "Installing LazyVim..."
    mkdir -p "$NVIM_CONFIG"
    git clone https://github.com/LazyVim/starter "$NVIM_CONFIG"
    rm -rf "$NVIM_CONFIG/.git"
fi

# Install Claude Code
if ! command -v claude &> /dev/null; then
    echo "Installing Claude Code..."
    if [[ "$OS" == "Darwin" ]]; then
        brew install anthropic-sdk-cli
    else
        curl -sSL https://github.com/anthropics/anthropic-sdk-cli/releases/latest/download/anthropic-sdk-cli-linux-x64.tar.gz | tar xz -C /tmp
        sudo mv /tmp/anthropic-sdk-cli /usr/local/bin/claude
    fi
fi

# Install Doppler CLI
if ! command -v doppler &> /dev/null; then
    echo "Installing Doppler CLI..."
    if [[ "$OS" == "Darwin" ]]; then
        brew install dopplerhq/cli/doppler
    else
        curl -fsSL https://doppler.com/install.sh | sh
    fi
fi

# Link dotfiles
echo "Linking dotfiles..."
bash "$DOTFILES_DIR/scripts/link.sh"

# Set zsh as default shell
if [[ "$SHELL" != *"zsh" ]]; then
    echo "Setting zsh as default shell..."
    if [[ "$OS" == "Darwin" ]]; then
        sudo chsh -s /bin/zsh
    else
        chsh -s /bin/zsh
    fi
fi

echo ""
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Restart your terminal"
echo "2. Run 'nvim' to complete LazyVim setup"
echo "3. Authenticate with Doppler: doppler login"
echo "4. Select Doppler project: doppler config set-project vini"
echo ""