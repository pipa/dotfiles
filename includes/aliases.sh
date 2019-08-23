# https://raw.github.com/mathiasbynens/dotfiles/master/.aliases

# dotfiles
alias dot="$HOME/.dotfiles/bin/dot-install"

# Easier navigation: .. and -
alias ..="cd .."

# Shortcuts
alias g="git"
alias dev="cd ~/Developer"
alias code="code-insiders"
alias grep='GREP_COLOR="1;37;45" LANG=C grep --color=auto'
alias zshconf="code ~/.zshrc"
alias ohmy="source ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
# alias l='colorls --group-directories-first --almost-all'
# alias ll='colorls --group-directories-first --almost-all --long' # detailed list view

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color"
    # export LS_COLORS='exfxcxdxbxegedabagacad'
else # OS X `ls`
    colorflag="-G"
    # export LSCOLORS='exfxcxdxbxegedabagacad'
fi

# List all files colorized in long format
alias l="ls -l ${colorflag}"

# List all files colorized in long format, including dot files
alias la="ls -la ${colorflag}"

# List only directories
alias lsd='ls -l ${colorflag} | grep --color=never "^d"'

# Always use color output for `ls`
alias ls="command ls ${colorflag}"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Empty the Trash on all mounted volumes and the main HDD
# Also, clear Apple’s System Logs to improve shell startup speed
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Disable Spotlight
alias spotoff="sudo mdutil -a -i off"
# Enable Spotlight
alias spoton="sudo mdutil -a -i on"

# Ring the terminal bell, and put a badge on Terminal.app’s Dock icon
# (useful when executing time-consuming commands)
alias badge="tput bel"
