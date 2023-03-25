# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Add executables installed by Homebrew on macOS to PATH
if [ "$(uname)" = "Darwin" ]; then
  export PATH="/usr/local/bin:$PATH"
  export PATH="/usr/local/sbin:$PATH"
  export PATH="/opt/homebrew/bin:$PATH" # For M1 Macs
fi

# Add executables installed by Node Version Manager (NVM) to PATH
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Set the default editor
export EDITOR='nvim'
export VISUAL='nvim'

# Set the default language and locale
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Set less to be case-insensitive and more user-friendly
export LESS='-i -R -S'

# Highlight section titles in manual pages
export LESS_TERMCAP_md="$COLOR_YELLOW"

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X"
