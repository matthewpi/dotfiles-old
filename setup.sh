#!/bin/bash

print() {
    echo -e $1
}

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

# Root User Detection
if [ "$EUID" -ne 0 ]; then
    print "This script must be ran as the root user."
    exit 1
fi

# Make the HOME variable use the proper user directory
HOME="/home/$SUDO_USER"

# OS Detection
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    print "Unable to detect operating system."
    exit 1
fi

# Because I'm a stuck-up asshole who only supports RHEL based OSes
if [ "$OS" != "rhel" ] && [ "$OS" != "fedora" ] && [ "$OS" != "centos" ]; then
    print "You must be on a RHEL based operating system to use this."
    exit 1
fi

# Update any packages
yum update -y

# Install EPEL Release
rpm -q "epel-release" &> /dev/null
if [ $? -ne 0 ]; then
    print "Installing epel-release"
    yum install epel-release -y > /dev/null
fi

# Update any packages
yum update -y

# Install Git
rpm -q "git" &> /dev/null
if [ $? -ne 0 ]; then
    print "Installing git"
    yum install git -y > /dev/null
fi

# Install htop
rpm -q "htop" &> /dev/null
if [ $? -ne 0 ]; then
    print "Installing htop"
    yum install htop -y > /dev/null
fi

# Install ZSH
rpm -q "zsh" &> /dev/null
if [ $? -ne 0 ]; then
    print "Installing zsh"
    yum install zsh -y > /dev/null
fi

# Add .bashrc
mv $HOME/.bashrc $HOME/.bashrc_original
curl https://raw.githubusercontent.com/matthewpi/dotfiles/master/.bashrc --silent --output $HOME/.bashrc

# Add .hushlogin
touch $HOME/.hushlogin

# Add .zshrc
mv $HOME/.zshrc $HOME/.zshrc_original
curl https://raw.githubusercontent.com/matthewpi/dotfiles/master/.zshrc --silent --output $HOME/.zshrc

# Add starship.toml
mkdir $HOME/.config
curl https://raw.githubusercontent.com/matthewpi/dotfiles/master/.config/starship.toml --silent --output $HOME/.config/starship.toml

# Add .tmux.conf
mv $HOME/.tmux.conf $HOME/.tmux_original.conf
curl https://raw.githubusercontent.com/matthewpi/dotfiles/master/.tmux.conf --silent --output $HOME/.tmux.conf

# Set ZSH as the user's default shell
usermod --shell $(which zsh) $SUDO_USER
