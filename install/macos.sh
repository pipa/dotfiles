#!/bin/bash
set -e

# Spinner functions
SPINNER_PID=""
CURRENT_MSG=""

start_spinner() {
    CURRENT_MSG="$1"
    printf "%-40s " "$CURRENT_MSG"
    
    (
        while true; do
            printf "\r%-40s " "$CURRENT_MSG"
            for s in ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ ▇ ▆ ▅ ▄ ▃ ▂ ▁; do
                printf "\r%-40s [%s]" "$CURRENT_MSG" "$s"
                sleep 0.08
            done
        done
    ) &
    SPINNER_PID=$!
}

stop_spinner() {
    if [[ -n "$SPINNER_PID" ]]; then
        kill $SPINNER_PID 2>/dev/null
        wait $SPINNER_PID 2>/dev/null
        SPINNER_PID=""
    fi
    printf "\r%-40s [✓]\n" "$CURRENT_MSG"
}

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    start_spinner "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>/dev/null
    stop_spinner
fi

# Update Homebrew
start_spinner "Updating Homebrew..."
brew update 2>/dev/null
stop_spinner

# Install packages from Brewfile
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/../Brewfile" ]]; then
    start_spinner "Installing Homebrew packages..."
    brew bundle install --file="$(dirname "${BASH_SOURCE[0]}")/../Brewfile" 2>/dev/null
    stop_spinner
fi