#!/bin/bash

# Bail early if not running as root / via sudo
if [[ $EUID -ne 0 ]]; then
  echo "This script needs sudo. Run: sudo bash setup.sh"
  exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" && pwd)"
export DOTFILES_DIR

# When run via sudo, HOME becomes /root. Resolve the real user's home for dotfiles.
REAL_USER="${SUDO_USER:-$(whoami)}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
export REAL_HOME REAL_USER

OS="$(uname -s)"
LOG_FILE="/tmp/dotfiles-setup-$$.log"
STEP_FILE="/tmp/dotfiles-step-$$"
ANIM_PID=""
RESULTS=()
FAILED=false

# ═══════════════════════════════════════════
# Animation — bouncing progress bar
# ═══════════════════════════════════════════
BAR_WIDTH=30
BLOCK="████"
BLOCK_LEN=4
DIM="\033[2m"
BOLD="\033[1m"
CYAN="\033[36m"
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
RESET="\033[0m"

start_animation() {
    echo "" > "$STEP_FILE"
    (
        local pos=0 dir=1
        local max=$((BAR_WIDTH - BLOCK_LEN))
        tput civis 2>/dev/null  # hide cursor
        while true; do
            local msg
            msg=$(cat "$STEP_FILE" 2>/dev/null)
            local bar=""
            for ((i = 0; i < BAR_WIDTH; i++)); do
                if ((i >= pos && i < pos + BLOCK_LEN)); then
                    bar+="█"
                else
                    bar+="░"
                fi
            done
            printf "\r  ${DIM}${CYAN}%s${RESET}  ${BOLD}%s${RESET}" "$bar" "$msg"
            # Clear any leftover chars from previous longer messages
            printf "%-10s" ""
            pos=$((pos + dir))
            if ((pos >= max)); then dir=-1; fi
            if ((pos <= 0)); then dir=1; fi
            sleep 0.04
        done
    ) &
    ANIM_PID=$!
}

stop_animation() {
    if [[ -n "$ANIM_PID" ]]; then
        kill "$ANIM_PID" 2>/dev/null
        wait "$ANIM_PID" 2>/dev/null || true
        ANIM_PID=""
    fi
    tput cnorm 2>/dev/null  # restore cursor
    printf "\r%-80s\r" ""   # clear the line
}

set_step() {
    echo "$1" > "$STEP_FILE"
}

# ═══════════════════════════════════════════
# Step runner — captures output, handles errors
# ═══════════════════════════════════════════
run_step() {
    local label="$1"
    shift
    set_step "$label"
    echo "=== $label ===" >> "$LOG_FILE"
    if "$@" >> "$LOG_FILE" 2>&1; then
        RESULTS+=("${GREEN}✓${RESET} $label")
        return 0
    else
        local exit_code=$?
        RESULTS+=("${RED}✗${RESET} $label")
        stop_animation
        echo ""
        printf "  ${RED}${BOLD}Error:${RESET} %s failed (exit %d)\n" "$label" "$exit_code"
        echo ""
        printf "  ${DIM}Last 10 lines of output:${RESET}\n"
        tail -10 "$LOG_FILE" | while IFS= read -r line; do
            printf "  ${DIM}│${RESET} %s\n" "$line"
        done
        echo ""
        printf "  ${DIM}Full log: %s${RESET}\n" "$LOG_FILE"
        echo ""
        FAILED=true
        start_animation
        return 1
    fi
}

# ═══════════════════════════════════════════
# Detect OS
# ═══════════════════════════════════════════
DISTRO=""
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

# ═══════════════════════════════════════════
# Header
# ═══════════════════════════════════════════
clear
echo ""
printf "  ${BOLD}dotfiles${RESET} ${DIM}—${RESET} setup for "
if [[ "$OS" == "Darwin" ]]; then
    printf "macOS\n"
else
    printf "Linux ($DISTRO)\n"
fi
echo ""

: > "$LOG_FILE"
start_animation

# ═══════════════════════════════════════════
# Backup existing dotfiles
# ═══════════════════════════════════════════
set_step "Checking existing dotfiles"
BACKUP_DIR="$REAL_HOME/.dotfiles-backup-$(date +%Y%m%d%H%M%S)"
NEED_BACKUP=false
for f in "$REAL_HOME/.zshrc" "$REAL_HOME/.aliases" "$REAL_HOME/.gitconfig" "$REAL_HOME/.config/starship.toml"; do
    if [[ -f "$f" && ! -L "$f" ]]; then
        NEED_BACKUP=true
        break
    fi
done
if $NEED_BACKUP; then
    mkdir -p "$BACKUP_DIR"
    for f in "$REAL_HOME/.zshrc" "$REAL_HOME/.aliases" "$REAL_HOME/.gitconfig" "$REAL_HOME/.config/starship.toml"; do
        if [[ -f "$f" && ! -L "$f" ]]; then
            cp "$f" "$BACKUP_DIR/" 2>/dev/null || true
        fi
    done
    RESULTS+=("${YELLOW}↗${RESET} Backed up dotfiles to $BACKUP_DIR")
fi

# Clean up existing dotfile symlinks
rm -f "$REAL_HOME/.zshrc" "$REAL_HOME/.aliases" "$REAL_HOME/.gitconfig" 2>/dev/null
rm -f "$REAL_HOME/.config/starship.toml" 2>/dev/null
rm -f "$REAL_HOME/.claude/settings.json" 2>/dev/null
[[ -L "$REAL_HOME/.config/nvim" ]] && rm -f "$REAL_HOME/.config/nvim" 2>/dev/null
rm -rf "$REAL_HOME/.local/share/nvim" 2>/dev/null
rm -rf "$REAL_HOME/.cache/nvim" 2>/dev/null

# ═══════════════════════════════════════════
# OS Dependencies
# ═══════════════════════════════════════════
if [[ "$OS" == "Darwin" ]]; then
    run_step "Installing macOS dependencies" bash "$DOTFILES_DIR/install/macos.sh"
elif [[ "$OS" == "Linux" ]]; then
    run_step "Installing Linux dependencies" bash "$DOTFILES_DIR/install/linux.sh"
fi

# ═══════════════════════════════════════════
# Shell — Oh My Zsh
# ═══════════════════════════════════════════
if [[ -d "$REAL_HOME/.oh-my-zsh" ]]; then
    RESULTS+=("${GREEN}✓${RESET} Oh My Zsh ${DIM}(already installed)${RESET}")
else
    run_step "Installing Oh My Zsh" \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ═══════════════════════════════════════════
# Shell — Zsh plugins
# ═══════════════════════════════════════════
ZSH_CUSTOM="$REAL_HOME/.oh-my-zsh/custom"
install_zsh_plugins() {
    local changed=false
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        changed=true
    fi
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
        git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
        changed=true
    fi
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        changed=true
    fi
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autopair" ]]; then
        git clone https://github.com/hlissner/zsh-autopair "$ZSH_CUSTOM/plugins/zsh-autopair"
        changed=true
    fi
    $changed || return 0
}

if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" && \
      -d "$ZSH_CUSTOM/plugins/zsh-completions" && \
      -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" && \
      -d "$ZSH_CUSTOM/plugins/zsh-autopair" ]]; then
    RESULTS+=("${GREEN}✓${RESET} Zsh plugins ${DIM}(already installed)${RESET}")
else
    run_step "Installing zsh plugins" install_zsh_plugins
fi

# ═══════════════════════════════════════════
# Shell — Starship
# ═══════════════════════════════════════════
if command -v starship &> /dev/null; then
    RESULTS+=("${GREEN}✓${RESET} Starship ${DIM}(already installed)${RESET}")
else
    run_step "Installing Starship" \
        sh -c "curl -sS https://starship.rs/install.sh | sh -s -- -y"
fi

# ═══════════════════════════════════════════
# Node.js — fnm
# ═══════════════════════════════════════════
if command -v fnm &> /dev/null; then
    RESULTS+=("${GREEN}✓${RESET} fnm ${DIM}(already installed)${RESET}")
else
    run_step "Installing fnm" \
        sh -c "curl -fsSL https://fnm.vercel.app/install | bash"
fi

export PATH="$REAL_HOME/.local/share/fnm:$PATH"
if command -v fnm &> /dev/null; then
    eval "$(fnm env --shell bash)"
fi

# ═══════════════════════════════════════════
# Node.js — LTS + pnpm
# ═══════════════════════════════════════════
install_node_and_pnpm() {
    fnm install --lts
    fnm default lts-latest
    fnm use lts-latest
    if ! command -v pnpm &> /dev/null; then
        npm install -g pnpm
    fi
}
run_step "Installing Node.js & pnpm" install_node_and_pnpm

# ═══════════════════════════════════════════
# Claude Code
# ═══════════════════════════════════════════
if command -v claude &> /dev/null; then
    RESULTS+=("${GREEN}✓${RESET} Claude Code ${DIM}(already installed)${RESET}")
else
    run_step "Installing Claude Code" npm install -g @anthropic-ai/claude-code
fi

# ═══════════════════════════════════════════
# Neovim
# ═══════════════════════════════════════════
install_neovim() {
    if [[ "$OS" == "Darwin" ]]; then
        curl -sLO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz
        sudo rm -rf /opt/nvim-macos-arm64
        sudo tar -C /opt -xzf nvim-macos-arm64.tar.gz
        rm -f nvim-macos-arm64.tar.gz
        sudo ln -sf /opt/nvim-macos-arm64/bin/nvim /usr/local/bin/nvim
    elif [[ "$OS" == "Linux" ]]; then
        curl -sLO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
        sudo rm -rf /opt/nvim-linux-x86_64
        sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
        rm -f nvim-linux-x86_64.tar.gz
        sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
    fi
}

if command -v nvim &> /dev/null; then
    RESULTS+=("${GREEN}✓${RESET} Neovim ${DIM}(already installed)${RESET}")
else
    run_step "Installing Neovim" install_neovim
fi

# ═══════════════════════════════════════════
# LazyVim
# ═══════════════════════════════════════════
install_lazyvim() {
    local nvim_config="$REAL_HOME/.config/nvim"
    mkdir -p "$nvim_config"
    rm -rf "$nvim_config/.git"
    git clone --depth 1 https://github.com/LazyVim/starter "$nvim_config"
    rm -rf "$nvim_config/.git"
}

if [[ -f "$REAL_HOME/.config/nvim/init.lua" ]]; then
    RESULTS+=("${GREEN}✓${RESET} LazyVim ${DIM}(already installed)${RESET}")
else
    run_step "Installing LazyVim" install_lazyvim
fi

# ═══════════════════════════════════════════
# Dotfiles — symlinks
# ═══════════════════════════════════════════
run_step "Linking dotfiles" bash "$DOTFILES_DIR/scripts/link.sh"

# ═══════════════════════════════════════════
# Default shell — zsh
# ═══════════════════════════════════════════
set_default_zsh() {
    local zsh_path
    zsh_path="$(command -v zsh)"
    if [[ -n "$zsh_path" ]]; then
        if ! grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
            echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
        fi
        sudo chsh -s "$zsh_path" "$REAL_USER" 2>/dev/null || chsh -s "$zsh_path" 2>/dev/null || true
    fi
}

if [[ "$SHELL" == *"zsh" ]]; then
    RESULTS+=("${GREEN}✓${RESET} Default shell ${DIM}(already zsh)${RESET}")
else
    run_step "Setting zsh as default shell" set_default_zsh
fi

# ═══════════════════════════════════════════
# Done — stop animation, print summary
# ═══════════════════════════════════════════
stop_animation

echo ""
if $FAILED; then
    printf "  ${BOLD}${YELLOW}Setup completed with errors${RESET}\n"
else
    printf "  ${BOLD}${GREEN}Setup complete${RESET}\n"
fi
echo ""

for result in "${RESULTS[@]}"; do
    printf "  %b\n" "$result"
done

echo ""
printf "  ${DIM}───────────────────────────────────────${RESET}\n"
echo ""
printf "  ${BOLD}Next steps:${RESET}\n"
printf "  ${DIM}1.${RESET} Restart your terminal\n"
printf "  ${DIM}2.${RESET} Run ${BOLD}nvim${RESET} to complete LazyVim setup\n"
printf "  ${DIM}3.${RESET} ${DIM}doppler login${RESET} → ${DIM}doppler config set-project vini${RESET}\n"
echo ""

rm -f "$STEP_FILE"
