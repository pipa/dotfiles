#!/bin/bash

run_step() {
    local msg="$1"
    shift
    printf "  %-40s ... " "$msg"
    "$@" >/dev/null 2>&1
    echo "[✓]"
}

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    run_step "Installing Homebrew" \
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

run_step "Updating Homebrew" \
    brew update

# Install packages from Brewfile
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/../Brewfile" ]]; then
    run_step "Installing Homebrew packages" \
        brew bundle install --file="$(dirname "${BASH_SOURCE[0]}")/../Brewfile"
fi