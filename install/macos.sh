#!/bin/bash
set -e

print_status() {
    printf "\r%-40s ...\n" "$1"
}

print_done() {
    printf "\r%-40s ✓\n" "$1"
}

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    print_status "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>/dev/null
    print_done "Installing Homebrew"
fi

# Update Homebrew
print_status "Updating Homebrew"
brew update 2>/dev/null
print_done "Updating Homebrew"

# Install packages from Brewfile
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/../Brewfile" ]]; then
    print_status "Installing Homebrew packages"
    brew bundle install --file="$(dirname "${BASH_SOURCE[0]}")/../Brewfile" 2>/dev/null || true
    print_done "Installing Homebrew packages"
fi