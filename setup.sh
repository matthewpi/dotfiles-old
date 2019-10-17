#!/bin/bash

print() {
    echo -e $1
}

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

get_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

# Root User Detection
if [ "$EUID" -ne 0 ]; then
    print "This script must be ran as the root user."
    exit 1
fi

if [ "$SUDO_USER" == "root" ]; then
    # Set the HOME variable to be the root directory.
    HOME="/root"
else
    # Make the HOME variable use the proper user directory
    HOME="/home/$SUDO_USER"
fi

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

# Install Curl
rpm -q "curl" &> /dev/null
if [ $? -ne 0 ]; then
    print "Installing curl"
    yum install curl -y > /dev/null
fi

# Install wget
rpm -q "wget" &> /dev/null
if [ $? -ne 0 ]; then
    print "Installing wget"
    yum install wget -y > /dev/null
fi

# Install Git
rpm -q "git" &> /dev/null
if [ $? -ne 0 ]; then
    print "Installing git"
    yum install git -y > /dev/null
fi

# Install ZSH
rpm -q "zsh" &> /dev/null
if [ $? -ne 0 ]; then
    print "Installing zsh"
    yum install zsh -y > /dev/null
fi

# Download starship
install_starship() {
    wget https://github.com/starship/starship/releases/download/${VERSION}/starship-x86_64-unknown-linux-gnu.tar.gz
    tar xvzf $HOME/starship-x86_64-unknown-linux-gnu.tar.gz
    mv $HOME/starship $HOME/.local/bin/starship
    rm $HOME/starship-x86_64-unknown-linux-gnu.tar.gz -rf
}

VERSION=`get_latest_release "starship/starship"`

if [ -f "$HOME/.local/bin/starship" ]; then
    print "Starship is already installed, checking if an update is available.."
    LATEST_VERSION="starship ${VERSION:1}"
    CURRENT_VERSION=`starship -V`

    if [ "$LATEST_VERSION" != "$CURRENT_VERSION" ]; then
        print "Updating ${CURRENT_VERSION} to ${LATEST_VERSION}"
        rm $HOME/.local/bin/starship -rf
        install_starship
    else
        print "Starship is up to date"
    fi
else
    print "Installing starship.."
    mkdir -p $HOME/.local/bin || true
    install_starship
fi

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print "Installing oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
fi

# Install zsh-autosuggestions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# Add .bashrc
mv $HOME/.bashrc $HOME/.bashrc_original || true
curl https://raw.githubusercontent.com/matthewpi/dotfiles/master/.bashrc --silent --output $HOME/.bashrc

# Add .hushlogin
touch $HOME/.hushlogin || true

# Add .zshrc
mv $HOME/.zshrc $HOME/.zshrc_original || true
curl https://raw.githubusercontent.com/matthewpi/dotfiles/master/.zshrc --silent --output $HOME/.zshrc

# Add starship.toml
mkdir $HOME/.config || true
curl https://raw.githubusercontent.com/matthewpi/dotfiles/master/.config/starship.toml --silent --output $HOME/.config/starship.toml

# Add .tmux.conf
mv $HOME/.tmux.conf $HOME/.tmux_original.conf || true
curl https://raw.githubusercontent.com/matthewpi/dotfiles/master/.tmux.conf --silent --output $HOME/.tmux.conf

# Set ZSH as the user's default shell
usermod --shell $(which zsh) $SUDO_USER
