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

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print "Installing oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended

    # Spaceship Prompt
    git clone https://github.com/denysdovhan/spaceship-prompt.git "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt"
    ln -s "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme"

    # Setup the .zshrc config
    rm $HOME/.zshrc -f
    curl https://raw.githubusercontent.com/matthewpi/dotfiles/master/.zshrc --silent --output $HOME/.zshrc

    # Set ZSH as user's shell
    chsh -s $(which zsh)
fi

# Install NGINX
rpm -q "nginx" &> /dev/null
if [ $? -ne 0 ]; then
    print "Installing NGINX"

    # Add the NGINX Repo File
    printf "[nginx-mainline]\nname=NGINX Mainline Repo\nbaseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/\ngpgcheck=1\nenabled=1\ngpgkey=https://nginx.org/keys/nginx_signing.key\n" > /etc/yum.repos.d/nginx-mainline.repo

    yum update -y
    yum install nginx -y
fi
