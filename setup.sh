#!/bin/bash

# Root User Detection
if [ "$EUID" -ne 0 ]; then
    echo -e "This script must be ran as the root user."
    exit 1
fi

# OS Detection
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "Unable to detect operating system."
    exit 1
fi

# Because I'm a stuck-up asshole who only supports RHEL based OSes
if [ "$OS" != "rhel" ] && [ "$OS" != "fedora" ] && [ "$OS" != "centos" ]; then
    echo -e "You must be on a RHEL based operating system to use this."
    exit 1
fi

# Update any packages
yum update -y

# Install EPEL Release
yum install epel-release

# Install HTOP
yum install htop

# Install ZSH
yum install zsh

# Install NGINX if it is not installed
if rpm -q "nginx" &> /dev/null; then
    echo -e "Installing NGINX"
	NGINX_REPO=`[nginx-mainline]
name=NGINX Mainline Repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key`
	echo $NGINX_REPO > /etc/yum.repos.d/nginx-mainline.repo

	yum install nginx -y
fi
