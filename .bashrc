# ~/.bashrc

# Include global bashrc file.
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
PATH="$HOME/.local/bin:$PATH"
export PATH

SHELL=`which zsh`
exec $(which zsh) -l
