#!/bin/bash

# ===================================================================
# Container Development Environment Setup Script (Ubuntu)
#
# Sets up a lightweight environment for container-based development
# (e.g., VS Code Dev Containers, GitHub Codespaces).
# Uses apt as the package manager.
# ===================================================================

set -e # Exit immediately if a command exits with a non-zero status.

# --- Keep sudo alive (if user has sudo privileges) ---
if command -v sudo &> /dev/null; then
    sudo -v
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

# --- Environment Check ---
if [ "$(uname)" != "Linux" ]; then
    echo "This script is intended for Linux containers." >&2
    exit 1
fi
if [ ! -f /etc/debian_version ]; then
    echo "This script is designed for Debian/Ubuntu-based containers." >&2
    exit 1
fi

# --- Ubuntu Setup using apt-get ---
export DEBIAN_FRONTEND=noninteractive
echo "Setting up Ubuntu container environment..."
sudo apt-get update

# Install wget if not present (for fetching keys)
if ! command -v wget &> /dev/null; then
    sudo apt-get install -y wget
fi
# Install gpg if not present
if ! command -v gpg &> /dev/null; then
    sudo apt-get install -y gpg
fi

# --- Add External Repositories ---

# GitHub CLI repository
if ! command -v gh &> /dev/null; then
    echo "Adding GitHub CLI repository..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update
fi

# eza repository
if ! command -v eza &> /dev/null; then
    echo "Adding eza repository..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt-get update
fi

# --- Install Packages via apt-get ---
echo "Installing core packages..."
sudo apt-get install -y \
    build-essential \
    curl \
    file \
    git \
    unzip \
    man-db \
    manpages \
    manpages-ja \
    manpages-ja-dev \
    zsh \
    jq \
    gh \
    fzf \
    tig \
    bat \
    ripgrep \
    fd-find \
    eza \
    neovim \
    sudo

# --- Create Symlinks for fd and bat ---
if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
    sudo ln -s $(which fdfind) /usr/local/bin/fd
fi
if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
    sudo ln -s $(which batcat) /usr/local/bin/bat
fi


# --- git-secrets Setup ---
if [ ! -d ~/.git-secrets ]; then
    echo "Installing git-secrets..."
    git clone https://github.com/awslabs/git-secrets.git ~/.git-secrets
    (cd ~/.git-secrets && sudo make install)
fi
git secrets --register-aws --global


# --- Zsh (Prezto) Setup ---
if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
    echo "Installing Prezto for Zsh..."
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
fi

# --- Set Zsh as Default Shell ---
ZSH_PATH=$(which zsh)
if [ -n "$ZSH_PATH" ] && [ -f "$ZSH_PATH" ]; then
    # Add Zsh to /etc/shells if it's not there
    if ! grep -qFx "$ZSH_PATH" /etc/shells; then
        echo "Adding $ZSH_PATH to /etc/shells..."
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi

    # Change shell if not already Zsh
    if [ "$SHELL" != "$ZSH_PATH" ]; then
        echo "Changing default shell to Zsh for user $USER..."
        sudo chsh -s "$ZSH_PATH" "$USER"
        echo "Default shell changed. Changes will apply on the next login/session."
    fi
else
    echo "Warning: Zsh not found. Could not set default shell." >&2
fi

echo -e "\n✅ Container environment setup complete!"
