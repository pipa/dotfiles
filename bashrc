if [ -n "$PS1" ]; then

    export LANG=en_US.UTF-8
    export TERM=xterm-256color

    for file in $HOME/.dotfiles/includes/*.sh; do
        [ -r "$file" ] && source "$file"
    done
    unset file

    if [ -e "$HOME/.profile" ]; then
        source $HOME/.profile
    fi

fi
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
