#!/bin/sh

# Backup existing dotfiles
backup_dir="$HOME/dotfiles-backup"
mkdir -p "$backup_dir"
mkdir -p "$HOME/.config" # Making sure .config exists
mv "$HOME/.zshrc" "$backup_dir" 2>/dev/null
mv "$HOME/.config/nvim/init.lua" "$backup_dir" 2>/dev/null
mv "$HOME/.gitconfig" "$backup_dir" 2>/dev/null
mv "$HOME/.gitmessage" "$backup_dir" 2>/dev/null

# Remove existing .bashrc and .bash_profile files
rm -f ~/.bashrc
rm -f ~/.bash_profile

# Remove dead symlinks
find -L "$HOME" -type l -delete
find -L "$HOME/.config" -type l -delete

# Create symlinks
ln -s "$HOME/dotfiles/bashrc" "$HOME/.bashrc"
ln -s "$HOME/dotfiles/bash_profile" "$HOME/.bash_profile"
ln -s "$HOME/dotfiles/zshrc" "$HOME/.zshrc"
ln -s "$HOME/dotfiles/nvim" "$HOME/.config/nvim"
ln -s "$HOME/dotfiles/gitconfig" "$HOME/.gitconfig"
ln -s "$HOME/dotfiles/gitmessage" "$HOME/.gitmessage"

# Set up the environment
export DOTFILES="$HOME/dotfiles"

# Install required tools and plugins
source "$DOTFILES/plugins.zsh"

# Load the new .zshrc
source "$HOME/.zshrc"

# We're done!
echo '****************************************************************************************************'
echo '    _            __        ____      __  _                                           __     __     '
echo '   (_)___  _____/ /_____ _/ / /___ _/ /_(_)___  ____     _________  ____ ___  ____  / /__  / /____ '
echo "  / / __ \/ ___/ __/ __ \/ / / __ \/ __/ / __ \/ __ \   / ___/ __ \/ __ \__ \/ __ \/ / _ \/ __/ _ "
echo ' / / / / (__  ) /_/ /_/ / / / /_/ / /_/ / /_/ / / / /  / /__/ /_/ / / / / / / /_/ / /  __/ /_/  __/'
echo '/_/_/ /_/____/\__/\__,_/_/_/\__,_/\__/_/\____/_/ /_/   \___/\____/_/ /_/ /_/ .___/_/\___/\__/\___/ '
echo '                                                                          /_/                      '
echo '***************************************************************************************************'
echo ''
