#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

# Spinner functions
SPINNER_PID=""
CURRENT_MSG=""

start_spinner() {
    CURRENT_MSG="$1"
    printf "%-40s " "$CURRENT_MSG"
    
    # Start spinner in background
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

fail_spinner() {
    if [[ -n "$SPINNER_PID" ]]; then
        kill $SPINNER_PID 2>/dev/null
        wait $SPINNER_PID 2>/dev/null
        SPINNER_PID=""
    fi
    printf "\r%-40s [✗]\n" "$CURRENT_MSG"
    exit 1
}

run_step() {
    local msg="$1"
    shift
    
    start_spinner "$msg"
    if "$@" 2>/dev/null; then
        stop_spinner
    else
        fail_spinner
    fi
}

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║         Dotfiles Setup for $OS          ║"
echo "╚══════════════════════════════════════════╝"
echo ""

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
echo ""

# Run OS-specific setup
case "$OS" in
    Darwin)
        run_step "Setting up macOS dependencies..." bash "$DOTFILES_DIR/install/macos.sh"
        ;;
    Linux)
        run_step "Setting up Linux dependencies..." bash "$DOTFILES_DIR/install/linux.sh"
        ;;
    *)
        echo "✗ Unsupported OS: $OS"
        exit 1
        ;;
esac

# Install Oh My Zsh
run_step "Installing Oh My Zsh..." \
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

# Install zsh plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

run_step "Installing zsh plugins..." \
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null
    fi && \
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
        git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions" 2>/dev/null
    fi && \
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null
    fi && \
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autopair" ]]; then
        git clone https://github.com/hlissner/zsh-autopair "$ZSH_CUSTOM/plugins/zsh-autopair" 2>/dev/null
    fi

# Install Starship prompt
run_step "Installing Starship prompt..." \
    if ! command -v starship &> /dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

# Install fnm
run_step "Installing fnm..." \
    if ! command -v fnm &> /dev/null; then
        curl -fsSL https://fnm.vercel.app/install | bash
    fi

# Source fnm and install Node.js
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env)"

run_step "Installing Node.js LTS, pnpm, Claude..." \
    fnm install --lts 2>/dev/null || true && \
    fnm default lts-latest 2>/dev/null || true && \
    fnm use lts-latest 2>/dev/null || true && \
    if ! command -v pnpm &> /dev/null; then
        npm install -g pnpm 2>/dev/null
    fi && \
    if ! command -v claude &> /dev/null; then
        npm install -g @anthropic-ai/claude-code 2>/dev/null
    fi

# Install Neovim
run_step "Installing Neovim..." \
    if [[ "$OS" == "Darwin" ]]; then
        if ! command -v nvim &> /dev/null; then
            if ! brew install --cask neovim-nightly 2>/dev/null; then
                brew install neovim 2>/dev/null || true
            fi
        fi
    fi

# Install LazyVim
NVIM_CONFIG="$HOME/.config/nvim"
run_step "Installing LazyVim..." \
    if [[ ! -d "$NVIM_CONFIG" ]] || [[ ! -f "$NVIM_CONFIG/init.lua" ]]; then
        mkdir -p "$NVIM_CONFIG"
        rm -rf "$NVIM_CONFIG/.git"
        git clone --depth 1 https://github.com/LazyVim/starter "$NVIM_CONFIG" 2>/dev/null
        rm -rf "$NVIM_CONFIG/.git"
    fi

# Link dotfiles
run_step "Linking dotfiles..." bash "$DOTFILES_DIR/scripts/link.sh"

# Set zsh as default shell
if [[ "$SHELL" != *"zsh" ]]; then
    run_step "Setting zsh as default shell..." \
        if [[ "$OS" == "Darwin" ]]; then
            sudo chsh -s /bin/zsh 2>/dev/null || true
        else
            chsh -s /bin/zsh 2>/dev/null || true
        fi
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