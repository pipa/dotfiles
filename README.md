# Luis Matute's Dotfiles

This repository contains my personal dotfiles for macOS and Linux environments. It is designed to set up and configure my preferred tools and settings for the terminal, shell, and text editor.

## Features

- Zsh as the main shell with plugins and a minimal configuration
- Neovim with LazyVim and custom Lua configurations
- Git configurations, aliases, and a custom commit message template with Gitmoji
- Separate files for aliases, exports, and functions

## Installation

1. Clone this repository to your home directory:

```sh
git clone https://github.com/pipa/dotfiles.git ~/dotfiles
```

2. Run the install.sh script to backup existing dotfiles, remove dead symlinks, create new symlinks, and set up your environment:

```sh
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

The script will create a dotfiles-backup directory in your home folder with backups of any existing dotfiles that conflict with this setup. If you need to revert to your original configuration, simply move the files from the backup directory back to their original locations.

3. Restart your terminal or run source ~/.zshrc to start using your new configuration.

## Customization
Feel free to fork this repository and customize it to your own preferences. Be sure to update the gitconfig file with your own name and email address, and modify the aliases, exports, and other configurations as needed.

## License
[MIT](https://luis-matute.mit-license.org)

