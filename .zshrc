# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set ZSH theme
ZSH_THEME="robbyrussell"

# Set history settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Enable plugins
plugins=(
    git
    docker
    docker-compose
    zsh-autosuggestions
    zsh-completions
    zsh-syntax-highlighting
    zsh-autopair
)

# Load Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Source Oh My Zsh (keep this at the bottom)
source $ZSH/oh-my-zsh.sh

# Load aliases
if [[ -f ~/.aliases ]]; then
    source ~/.aliases
fi

# Starship prompt
export STARSHIP_CONFIG=~/.config/starship.toml
eval "$(starship init zsh)"

# fnm
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env)"

# zoxide
eval "$(zoxide init zsh)"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Set default editor
export EDITOR="nvim"
export VISUAL="nvim"

# Less colors
export LESS='-R'
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;44;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'

# Doppler - load ANTHROPIC_API_KEY
if command -v doppler &> /dev/null; then
    eval "$(doppler enclave run --print-env -- nop)"
fi

# Set default language
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"

# Enable color support
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Enable fuzzy completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Auto correct
setopt CORRECT
setopt CORRECT_ALL

# Auto cd
setopt AUTO_CD

# Share history between sessions
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY

# Enable vi mode
bindkey -v

# Use emacs keybindings for incremental search (default)
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

# Better backward-kill-word
bindkey '^W' backward-kill-word
bindkey '^U' kill-line

# Enable 256 colors
export TERM="xterm-256color"