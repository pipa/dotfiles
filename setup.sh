#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

# Spinner variables
SPINNER_PID=""
CURRENT_MSG=""

# Dot spinner frames
SPINNER_FRAMES=("...." "o..." ".o.." "..o." "...o" "..o." ".o.." "o...")
SPINNER_IDX=0

start_spinner() {
    CURRENT_MSG="$1"
    printf "%-45s\n" "$CURRENT_MSG"
    
    (
        while true; do
            printf "\r  [%s]\r" "${SPINNER_FRAMES[$SPINNER_IDX]}"
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
    SPINNER_IDX=0
    printf "\r  [✓]\n"
}

print_header() {
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║         Dotfiles Setup for $OS          ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""
}

print_section() {
    echo ""
    echo "━━━ $1 ━━━"
    echo ""
}

print_done() {
    printf "\r  [✓] %s\n" "$CURRENT_MSG"
    CURRENT_MSG=""
}

run_step() {
    local msg="$1"
    shift
    
    CURRENT_MSG="$msg"
    "$@" 2>/dev/null
    print_done
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

run_step "Setting up macOS..." bash "$DOTFILES_DIR/install/macos.sh"

# ═══════════════════════════════════════════
# Shell Setup
# ═══════════════════════════════════════════
print_section "Shell"

run_step "Installing Oh My Zsh..." \
    test ! -d "$HOME/.oh-my-zsh"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>/dev/null
fi
print_done

run_step "Installing zsh plugins..." \
    ZSH_CUSTOM="$HOME/.oh-my-zsh/custom" && \
    (test ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null) && \
    (test ! -d "$ZSH_CUSTOM/plugins/zsh-completions" && git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions" 2>/dev/null) && \
    (test ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null) && \
    (test ! -d "$ZSH_CUSTOM/plugins/zsh-autopair" && git clone https://github.com/hlissner/zsh-autopair "$ZSH_CUSTOM/plugins/zsh-autopair" 2>/dev/null)

run_step "Installing Starship..." \
    test ! -x "$(command -v starship)"

if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y 2>/dev/null
fi

# ═══════════════════════════════════════════
# Node.js
# ═══════════════════════════════════════════
print_section "Node.js"

run_step "Installing fnm..." \
    test ! -x "$(command -v fnm)"

if ! command -v fnm &> /dev/null; then
    curl -fsSL https://fnm.vercel.app/install | bash 2>/dev/null
fi

export PATH="$HOME/.local/share/fnm:$PATH"
if command -v fnm &> /dev/null; then
    eval "$(fnm env)"
fi

run_step "Installing Node.js LTS & pnpm..." \
    (fnm install --lts 2>/dev/null || true) && \
    (fnm default lts-latest 2>/dev/null || true) && \
    (fnm use lts-latest 2>/dev/null || true) && \
    (test -x "$(command -v pnpm)" || npm install -g pnpm 2>/dev/null)

run_step "Installing Claude Code..." \
    test -x "$(command -v claude)"

if ! command -v claude &> /dev/null; then
    npm install -g @anthropic-ai/claude-code 2>/dev/null
fi

# ═══════════════════════════════════════════
# Neovim
# ═══════════════════════════════════════════
print_section "Neovim"

run_step "Installing Neovim..." \
    (test -x "$(command -v nvim)") || \
    (brew install --cask neovim-nightly 2>/dev/null) || \
    (brew install neovim 2>/dev/null)

run_step "Installing LazyVim..." \
    NVIM_CONFIG="$HOME/.config/nvim" && \
    (test -d "$NVIM_CONFIG" && test -f "$NVIM_CONFIG/init.lua") || \
    (mkdir -p "$NVIM_CONFIG" && rm -rf "$NVIM_CONFIG/.git" && git clone --depth 1 https://github.com/LazyVim/starter "$NVIM_CONFIG" 2>/dev/null && rm -rf "$NVIM_CONFIG/.git")

# ═══════════════════════════════════════════
# Dotfiles
# ═══════════════════════════════════════════
print_section "Dotfiles"

run_step "Linking dotfiles..." bash "$DOTFILES_DIR/scripts/link.sh"

run_step "Setting zsh as default shell..." \
    ([[ "$SHELL" == *"zsh" ]]) || (sudo chsh -s /bin/zsh 2>/dev/null) || (chsh -s /bin/zsh 2>/dev/null) || true

# ═══════════════════════════════════════════
# Complete
# ═══════════════════════════════════════════
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