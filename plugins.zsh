# Install required tools
if [ "$(uname)" = "Darwin" ]; then
    # macOS specific tools
    command -v brew >/dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install git neovim zsh zsh-completions
elif [ "$(uname)" = "Linux" ]; then
    # Linux specific tools
    if command -v apt >/dev/null 2>&1; then
      sudo apt update
      sudo apt install -y git neovim zsh zsh-completions
    elif command -v pacman >/dev/null 2>&1; then
      sudo pacman -Syu --noconfirm git neovim zsh zsh-completions
    fi
fi

# Install Lazygit
command -v lazygit >/dev/null 2>&1 || {
    curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep "browser_download_url.*Linux_x86_64.tar.gz" | cut -d : -f 2,3 | tr -d \" | wget -qi - -O lazygit.tar.gz
    tar -xvf lazygit.tar.gz
    sudo mv lazygit /usr/local/bin
    rm lazygit.tar.gz
}

# Install Oh My Zsh
[ -d "$HOME/.oh-my-zsh" ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install zsh-autosuggestions
[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ] || git clone https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

# Install zsh-syntax-highlighting
[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

# Install Spaceship theme
git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

# Install NVM
command -v nvm >/dev/null 2>&1 || {
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
}

# Install the latest version of Node.js and set it as the default
command -v node >/dev/null 2>&1 || {
  nvm install --lts
  nvm alias default "$(nvm current)"
}
