#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Linking dotfiles to home directory..."

# Function to create symlink
link_file() {
    local source="$1"
    local target="$2"
    
    # Create parent directory if it doesn't exist
    local target_dir="$(dirname "$target")"
    mkdir -p "$target_dir"
    
    # Remove existing file/directory/symlink
    if [[ -e "$target" ]] || [[ -L "$target" ]]; then
        echo "  Removing existing: $target"
        rm -rf "$target"
    fi
    
    # Create symlink
    echo "  Linking: $source -> $target"
    ln -sf "$source" "$target"
}

# Link dotfiles
link_file "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/.aliases" "$HOME/.aliases"
link_file "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
link_file "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/.claude" "$HOME/.claude"

echo "Dotfiles linked successfully!"
echo ""
echo "Linked files:"
echo "  ~/.zshrc"
echo "  ~/.aliases"
echo "  ~/.gitconfig"
echo "  ~/.config/starship.toml"
echo "  ~/.config/nvim"
echo "  ~/.claude"