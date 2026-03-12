#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

# Spinner
SPINNER_PID=""
SPINNER_FRAMES=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
SPINNER_IDX=0

print_header() {
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║         Dotfiles Setup for $OS          ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""
}

start_spinner() {
    local msg="$1"
    printf "  %-40s " "$msg"
    
    (
        while true; do
            printf "\r  %-40s [%s]" "$msg" "${SPINNER_FRAMES[$SPINNER_IDX]}"
            SPINNER_IDX=$(( (SPINNER_IDX + 1) % ${#SPINNER_FRAMES[@]} ))
            sleep 0.1
        done
    ) &
    SPINNER_PID=$!
}

stop_spinner() {
    if [[ -n "$SPINNER_PID" ]]; then
        kill "$SPINNER_PID" 2>/dev/null
        wait "$SPINNER_PID" 2>/dev/null || true
        SPINNER_PID=""
    fi
    printf "\r  %-40s [✓]\n" "$CURRENT_MSG"
    CURRENT_MSG=""
}

run_silent() {
    local msg="$1"
    shift
    CURRENT_MSG="$msg"
    start_spinner "$msg"
    "$@" >/dev/null 2>&1
    stop_spinner
}

print_section() {
    echo ""
    echo "━━━ $1 ━━━"
    echo ""
}

print_summary() {
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║           Setup Complete! 🎉             ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""
}

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

print_header
echo "Detected: $OS ($DISTRO)"
echo ""

# ═══════════════════════════════════════════
# OS Setup
# ═══════════════════════════════════════════
print_section "OS Dependencies"
run_silent "Setting up macOS..." bash "$DOTFILES_DIR/install/macos.sh"

# ═══════════════════════════════════════════
# Shell Setup
# ═══════════════════════════════════════════
print_section "Shell"

run_silent "Installing Oh My Zsh..." \
    test ! -d "$HOME/.oh-my-zsh"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

run_silent "Installing zsh plugins..." \
    ZSH_CUSTOM="$HOME/.oh-my-zsh/custom" && \
    (test ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions") && \
    (test ! -d "$ZSH_CUSTOM/plugins/zsh-completions" && git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions") && \
    (test ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting") && \
    (test ! -d "$ZSH_CUSTOM/plugins/zsh-autopair" && git clone https://github.com/hlissner/zsh-autopair "$ZSH_CUSTOM/plugins/zsh-autopair")

run_silent "Installing Starship..." \
    test ! -x "$(command -v starship)"

if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# ═══════════════════════════════════════════
# Node.js
# ═══════════════════════════════════════════
print_section "Node.js"

run_silent "Installing fnm..." \
    test ! -x "$(command -v fnm)"

if ! command -v fnm &> /dev/null; then
    curl -fsSL https://fnm.vercel.app/install | bash
fi

export PATH="$HOME/.local/share/fnm:$PATH"
if command -v fnm &> /dev/null; then
    eval "$(fnm env)"
fi

run_silent "Installing Node.js & pnpm..." \
    (fnm install --lts) && \
    (fnm default lts-latest) && \
    (fnm use lts-latest) && \
    (test -x "$(command -v pnpm)" || npm install -g pnpm)

run_silent "Installing Claude Code..." \
    test -x "$(command -v claude)"

if ! command -v claude &> /dev/null; then
    npm install -g @anthropic-ai/claude-code
fi

# ═══════════════════════════════════════════
# Neovim
# ═══════════════════════════════════════════
print_section "Neovim"

run_silent "Installing Neovim..." \
    (test -x "$(command -v nvim)") || \
    (brew install --cask neovim-nightly) || \
    (brew install neovim)

run_silent "Installing LazyVim..." \
    NVIM_CONFIG="$HOME/.config/nvim" && \
    (test -d "$NVIM_CONFIG" && test -f "$NVIM_CONFIG/init.lua") || \
    (mkdir -p "$NVIM_CONFIG" && rm -rf "$NVIM_CONFIG/.git" && git clone --depth 1 https://github.com/LazyVim/starter "$NVIM_CONFIG" && rm -rf "$NVIM_CONFIG/.git")

# ═══════════════════════════════════════════
# Dotfiles
# ═══════════════════════════════════════════
print_section "Dotfiles"

run_silent "Linking dotfiles..." bash "$DOTFILES_DIR/scripts/link.sh"

run_silent "Setting zsh as default shell..." \
    ([[ "$SHELL" == *"zsh" ]]) || (sudo chsh -s /bin/zsh) || (chsh -s /bin/zsh) || true

# ═══════════════════════════════════════════
# Complete
# ═══════════════════════════════════════════
print_summary
echo "Next steps:"
echo "  1. Restart your terminal"
echo "  2. Run 'nvim' to complete LazyVim setup"
echo "  3. Authenticate with Doppler: doppler login"
echo "  4. Select project: doppler config set-project vini"
echo ""