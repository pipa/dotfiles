#!/bin/bash
set -e

# Detect Linux distribution
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    DISTRO="$ID"
elif [[ -f /etc/centos-release ]]; then
    DISTRO="centos"
else
    DISTRO="unknown"
fi

echo "Setting up Linux ($DISTRO)..."

# Detect package manager
if command -v apt-get &> /dev/null; then
    PKG_MGR="apt"
    PKG_UPDATE="sudo apt-get update"
    PKG_INSTALL="sudo apt-get install -y"
elif command -v dnf &> /dev/null; then
    PKG_MGR="dnf"
    PKG_UPDATE="sudo dnf update -y"
    PKG_INSTALL="sudo dnf install -y"
elif command -v yum &> /dev/null; then
    PKG_MGR="yum"
    PKG_UPDATE="sudo yum update -y"
    PKG_INSTALL="sudo yum install -y"
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
if [[ "$PKG_MGR" == "apt" ]]; then
    $PKG_INSTALL curl wget git zsh build-essential libssl-dev libffi-dev python3 python3-pip unzip
else
    $PKG_INSTALL curl wget git zsh gcc gcc-c++ make openssl-devel libffi-devel python3 python3-pip unzip
fi

echo "✓ Linux dependencies complete"