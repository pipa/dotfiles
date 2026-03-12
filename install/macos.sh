#!/bin/bash

print_status() {
    printf "  %-40s ... " "$1"
}

print_done() {
    printf "%s\n" "[✓]"
}

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    print_status "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>/dev/null
    print_done
fi

# Update Homebrew
print_status "Updating Homebrew"
brew update 2>/dev/null
print_done

# Install packages from Brewfile
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/../Brewfile" ]]; then
    print_status "Installing Homebrew packages"
    brew bundle install --file="$(dirname "${BASH_SOURCE[0]}")/../Brewfile" 2>/dev/null || true
    print_done
fi