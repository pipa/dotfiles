#!/bin/bash
set -e

# Detect Linux distribution
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    DISTRO="$ID"
elif [[ -f /etc/centos-release ]]; then
    DISTRO="centos"
else
    DISTRO="unknown"
fi

echo "Setting up Linux ($DISTRO)..."

# Detect package manager
if command -v apt-get &> /dev/null; then
    PKG_MGR="apt"
    PKG_UPDATE="apt-get update"
    PKG_INSTALL="apt-get install -y"
elif command -v yum &> /dev/null; then
    PKG_MGR="yum"
    PKG_UPDATE="yum update -y"
    PKG_INSTALL="yum install -y"
elif command -v dnf &> /dev/null; then
    PKG_MGR="dnf"
    PKG_UPDATE="dnf update -y"
    PKG_INSTALL="dnf install -y"
else
    echo "No supported package manager found!"
    exit 1
fi

echo "Using package manager: $PKG_MGR"

# Update package lists
echo "Updating package lists..."
$PKG_UPDATE

# Install essential packages
echo "Installing essential packages..."
$PKG_INSTALL curl wget git zsh build-essential \
    libssl-dev libffi-dev python3 python3-pip

# Install starship
if ! command -v starship &> /dev/null; then
    echo "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Install fnm
if ! command -v fnm &> /dev/null; then
    echo "Installing fnm..."
    curl -fsSL https://fnm.vercel.app/install | bash
fi

# Install Node.js via fnm (after fnm is available)
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env)"
if ! command -v node &> /dev/null; then
    echo "Installing Node.js LTS..."
    fnm install --lts
    fnm default lts-latest
    fnm use lts-latest
fi

# Install pnpm
if ! command -v pnpm &> /dev/null; then
    echo "Installing pnpm..."
    npm install -g pnpm
fi

# Install eza (modern ls)
if ! command -v eza &> /dev/null; then
    echo "Installing eza..."
    curl -sSL https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz | tar xz -C /tmp
    mv /tmp/eza /usr/local/bin/eza
fi

# Install bat
if ! command -v bat &> /dev/null; then
    echo "Installing bat..."
    curl -sSL https://github.com/sharkdp/bat/releases/latest/download/bat-x86_64-unknown-linux-gnu.tar.gz | tar xz -C /tmp
    mv /tmp/bat-x86_64-unknown-linux-gnu/bat /usr/local/bin/bat
fi

# Install fd
if ! command -v fd &> /dev/null; then
    echo "Installing fd..."
    curl -sSL https://github.com/sharkdp/fd/releases/latest/download/fd-x86_64-unknown-linux-gnu.tar.gz | tar xz -C /tmp
    mv /tmp/fd-x86_64-unknown-linux-gnu/fd /usr/local/bin/fd
fi

# Install fzf
if ! command -v fzf &> /dev/null; then
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git /tmp/fzf
    /tmp/fzf/install --bin
    mv /tmp/fzf/bin/fzf /usr/local/bin/fzf
    rm -rf /tmp/fzf
fi

# Install ripgrep
if ! command -v rg &> /dev/null; then
    echo "Installing ripgrep..."
    curl -sSL https://github.com/ripgrep/rg/releases/latest/download/ripgrep-x86_64-unknown-linux-gnu.tar.gz | tar xz -C /tmp
    mv /tmp/rg-x86_64-unknown-linux-gnu/rg /usr/local/bin/rg
fi

# Install shellcheck
if ! command -v shellcheck &> /dev/null; then
    echo "Installing shellcheck..."
    if [[ "$DISTRO" == "ubuntu" ]] || [[ "$DISTRO" == "debian" ]]; then
        $PKG_INSTALL shellcheck
    else
        # Try to install from source or alternative
        SC_VERSION=$(curl -sSL https://api.github.com/repos/koalaman/shellcheck/releases/latest | grep -oP '"tag_name": "\K[^"]+')
        curl -sSL "https://github.com/koalaman/shellcheck/releases/download/${SC_VERSION}/shellcheck-${SC_VERSION}.linux.x86_64.tar.xz" | tar xJ -C /tmp
        mv /tmp/shellcheck-${SC_VERSION}/shellcheck /usr/local/bin/shellcheck
    fi
fi

# Install yamllint
if ! command -v yamllint &> /dev/null; then
    echo "Installing yamllint..."
    $PKG_INSTALL yamllint || pip3 install yamllint
fi

# Install jq
if ! command -v jq &> /dev/null; then
    echo "Installing jq..."
    $PKG_INSTALL jq
fi

# Install lazygit
if ! command -v lazygit &> /dev/null; then
    echo "Installing lazygit..."
    LG_VERSION=$(curl -sSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -oP '"tag_name": "\K[^"]+')
    curl -sSL "https://github.com/jesseduffield/lazygit/releases/download/${LG_VERSION}/lazygit_${LG_VERSION#v}_Linux_x86_64.tar.gz" | tar xz -C /tmp
    mv /tmp/lazygit /usr/local/bin/lazygit
fi

# Install btop
if ! command -v btop &> /dev/null; then
    echo "Installing btop..."
    BTOP_VERSION=$(curl -sSL https://api.github.com/repos/aristocratos/btop/releases/latest | grep -oP '"tag_name": "\K[^"]+')
    curl -sSL "https://github.com/aristocratos/btop/releases/download/${BTOP_VERSION}/btop-x86_64-linux-musl.tbz" | tar xj -C /tmp
    mv /tmp/btop/bin/btop /usr/local/bin/btop
fi

# Install zoxide
if ! command -v zoxide &> /dev/null; then
    echo "Installing zoxide..."
    curl -sSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# Install tldr
if ! command -v tldr &> /dev/null; then
    echo "Installing tldr..."
    $PKG_INSTALL tldr || pip3 install tldr
fi

# Install git-delta
if ! command -v delta &> /dev/null; then
    echo "Installing git-delta..."
    DELTA_VERSION=$(curl -sSL https://api.github.com/repos/dandavison/delta/releases/latest | grep -oP '"tag_name": "\K[^"]+')
    curl -sSL "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION#v}-x86_64-unknown-linux-musl.tar.gz" | tar xz -C /tmp
    mv /tmp/delta-* /usr/local/bin/delta
fi

# Install hadolint
if ! command -v hadolint &> /dev/null; then
    echo "Installing hadolint..."
    HADOLINT_VERSION=$(curl -sSL https://api.github.com/repos/hadolint/hadolint/releases/latest | grep -oP '"tag_name": "\K[^"]+')
    curl -sSL "https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-x86_64-linux" -o /usr/local/bin/hadolint
    chmod +x /usr/local/bin/hadolint
fi

# Install Docker (if not present)
if ! command -v docker &> /dev/null; then
    echo "Docker not installed. Install manually from https://docs.docker.com/get-docker/"
fi

# Install Neovim nightly
if ! command -v nvim &> /dev/null; then
    echo "Installing Neovim nightly..."
    NVIM_VERSION=$(curl -sSL https://api.github.com/repos/neovim/neovim/releases/nightly/latest | grep -oP '"tag_name": "\K[^"]+')
    curl -sSL "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux64.tar.gz" | tar xz -C /tmp
    mv /tmp/nvim-linux64 /usr/local/nvim
    ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim
fi

# Install Claude Code
if ! command -v claude &> /dev/null; then
    echo "Installing Claude Code..."
    curl -sSL https://github.com/anthropics/anthropic-sdk-cli/releases/latest/download/anthropic-sdk-cli-linux-x64.tar.gz | tar xz -C /tmp
    sudo mv /tmp/anthropic-sdk-cli /usr/local/bin/claude
fi

# Install Doppler CLI
if ! command -v doppler &> /dev/null; then
    echo "Installing Doppler CLI..."
    curl -fsSL https://doppler.com/install.sh | sh
fi

echo "Linux setup complete!"