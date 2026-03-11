#!/bin/bash
set -e

# Detect Linux distribution
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    DISTRO="$ID"
elif [[ -f /etc/centos-release ]]; ]]; then
    DISTRO="centos"
else
    DISTRO="unknown"
fi

echo "Setting up Linux ($DISTRO)..."

# Detect package manager
if command -v apt-get &> /dev/null; then
    PKG_MGR="apt"
    PKG_UPDATE="apt-get update"
    PKG_INSTALL="apt-get install -y"
elif command -v yum &> /dev/null; then
    PKG_MGR="yum"
    PKG_UPDATE="yum update -y"
    PKG_INSTALL="yum install -y"
elif command -v dnf &> /dev/null; then
    PKG_MGR="dnf"
    PKG_UPDATE="dnf update -y"
    PKG_INSTALL="dnf install -y"
else
    echo "No supported package manager found!"
    exit 1
fi

echo "Using package manager: $PKG_MGR"

# Update package lists
echo "Updating package lists..."
$PKG_UPDATE

# Install essential packages
echo "Installing essential packages..."
$PKG_INSTALL curl wget git zsh build-essential libssl-dev libffi-dev python3 python3-pip

echo "✓ Linux dependencies complete"