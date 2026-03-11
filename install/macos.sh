#!/bin/bash
set -e

echo "Setting up macOS..."

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Installing Homebrew..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update Homebrew
echo "Updating Homebrew..."
brew update

# Install packages from Brewfile
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/../Brewfile" ]]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Installing Homebrew packages..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    brew bundle install --file="$(dirname "${BASH_SOURCE[0]}")/../Brewfile"
fi

echo "✓ macOS dependencies complete"