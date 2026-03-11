#!/bin/bash
set -e

echo "Setting up macOS..."

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update Homebrew
echo "Updating Homebrew..."
brew update

# Install packages from Brewfile if it exists
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/../Brewfile" ]]; then
    echo "Installing packages from Brewfile..."
    brew bundle install --file="$(dirname "${BASH_SOURCE[0]}")/../Brewfile"
else
    # Install essential packages
    echo "Installing essential packages..."
    brew install git curl zsh starship fnm pnpm eza bat fd fzf ripgrep \
        shellcheck yamllint hadolint jq docker docker-compose docker-buildx \
        gh lazygit btop zoxide tldr git-delta node
fi

# Install Neovim
echo "Installing Neovim..."
if ! brew install --cask neovim-nightly 2>/dev/null; then
    echo "Neovim nightly not available, installing stable..."
    brew install neovim
fi

# Install Claude Code
if ! command -v claude &> /dev/null; then
    echo "Installing Claude Code..."
    brew install claude
fi

# Install Doppler CLI
if ! command -v doppler &> /dev/null; then
    echo "Installing Doppler CLI..."
    brew install dopplerhq/cli/doppler
fi

echo "macOS setup complete!"