# Matthew's .zshrc (oh my zsh)

# Environment Variables
PATH="/usr/local/go/bin:$HOME/.local/bin:$HOME/bin:$HOME/.bin:/usr/bin:$PATH"
EDITOR=nano
GOPATH=$HOME/.golang
GOBIN=$GOPATH/bin
PATH=$PATH:$GOBIN

# Exports
export SHELL
export EDITOR
export GOPATH
export GOBIN
export PATH

# Aliases
alias ll="ls -lsa"
alias please="sudo "
alias sudo="sudo "
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# https://starship.rs
eval "$(starship init zsh)"
