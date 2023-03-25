# Load Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="spaceship"

# Load plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)

source $ZSH/oh-my-zsh.sh

# Load aliases, exports, and functions
source "$DOTFILES/includes/aliases.zsh"  # Load custom aliases
source "$DOTFILES/includes/exports.zsh"  # Load custom environment variables
source "$DOTFILES/includes/functions.zsh"  # Load custom functions

# Spaceship theme options
SPACESHIP_PROMPT_ORDER=(
  user          # Username section
  dir           # Current directory section
  git           # Git section (git_branch + git_status)
  exec_time     # Execution time
  line_sep      # Line break
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)

# Show current Node.js version in the prompt
SPACESHIP_NODE_SHOW=true

# Set up key bindings for history search
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
