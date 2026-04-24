#!/bin/bash

# If DOTFILES_DIR is already set (e.g. exported by setup.sh), use it.
# Otherwise resolve it relative to this script's location.
if [[ -z "$DOTFILES_DIR" ]]; then
  DOTFILES_DIR="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.." && pwd)"
fi

# Use REAL_HOME if exported by setup.sh, otherwise fall back to HOME
REAL_HOME="${REAL_HOME:-$HOME}"
REAL_USER="${REAL_USER:-$(whoami)}"

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

    # Fix ownership when running as root via sudo — symlink and parent dir must belong to real user
    if [[ "$(whoami)" == "root" && "$REAL_USER" != "root" ]]; then
        chown -h "$REAL_USER:$REAL_USER" "$target" 2>/dev/null || true
        chown "$REAL_USER:$REAL_USER" "$target_dir" 2>/dev/null || true
    fi
}

# Link dotfiles
link_file "$DOTFILES_DIR/.zshrc" "$REAL_HOME/.zshrc"
link_file "$DOTFILES_DIR/.aliases" "$REAL_HOME/.aliases"
link_file "$DOTFILES_DIR/.gitconfig" "$REAL_HOME/.gitconfig"
link_file "$DOTFILES_DIR/.gitconfig-macos" "$REAL_HOME/.gitconfig-macos"
link_file "$DOTFILES_DIR/.config/starship.toml" "$REAL_HOME/.config/starship.toml"
link_file "$DOTFILES_DIR/.config/nvim" "$REAL_HOME/.config/nvim"
link_file "$DOTFILES_DIR/.config/ghostty" "$REAL_HOME/.config/ghostty"
link_file "$DOTFILES_DIR/.config/tmux" "$REAL_HOME/.config/tmux"
link_file "$DOTFILES_DIR/.hammerspoon" "$REAL_HOME/.hammerspoon"
link_file "$DOTFILES_DIR/.claude/settings.json" "$REAL_HOME/.claude/settings.json"
link_file "$DOTFILES_DIR/.claude/CLAUDE.md" "$REAL_HOME/.claude/CLAUDE.md"
link_file "$DOTFILES_DIR/.claude/personas" "$REAL_HOME/.claude/personas"

echo "Dotfiles linked successfully!"
echo ""
echo "Linked files:"
echo "  ~/.zshrc"
echo "  ~/.aliases"
echo "  ~/.gitconfig"
echo "  ~/.config/starship.toml"
echo "  ~/.config/nvim"
echo "  ~/.config/ghostty"
echo "  ~/.config/tmux"
echo "  ~/.hammerspoon"
echo "  ~/.claude/settings.json"
echo "  ~/.claude/CLAUDE.md"
echo "  ~/.claude/personas"