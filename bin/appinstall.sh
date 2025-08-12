#!/bin/bash

# ===============================================================
# Universal Dev Environment Setup Script (2025)
# Target OS: macOS / WSL2 (Ubuntu)
# ===============================================================

set -e # Exit immediately if a command exits with a non-zero status.

# --- Keep sudo alive ---
# Ask for the administrator password upfront and run a loop to keep it alive.
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# --- OS Detection ---
ISMAC=false
ISLINUX=false
if [ "$(uname)" == "Darwin" ]; then
    ISMAC=true
    echo "macOS detected."
elif [ "$(uname)" == "Linux" ]; then
    ISLINUX=true
    echo "Linux detected."
else
    echo "Unsupported OS."
    exit 1
fi

# --- Linux Environment Setup ---
if [ "$ISLINUX" = true ]; then
    echo "Setting up Linux environment..."
    # /etc/alpine-releaseファイルの存在でAlpine Linuxか判定
    if [ -f /etc/alpine-release ]; then
        echo "Alpine Linux detected. Using apk."
        # Alpineでは 'build-essential' の代わりに 'build-base' を使う
        # また、manpages-jaはないため、基本的なmanをインストール
        sudo apk add --no-cache \
            build-base \
            curl \
            file \
            git \
            unzip \
            man-db \
            man-pages \
            ruby \
            ruby-dev
    # それ以外のLinux (Debian/Ubuntu系を想定)
    else
        echo "Debian/Ubuntu based Linux detected. Using apt-get."
        sudo apt-get update
        sudo apt-get install -y \
            build-essential \
            curl \
            file \
            git \
            unzip \
            manpages-ja \
            manpages-ja-dev \
            ruby \
            ruby-dev
    fi
fi

# --- Homebrew Installation ---
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# --- Add Homebrew to PATH ---
# Detects the correct path for both macOS and Linuxbrew
if [ "$ISLINUX" = true ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- Install packages via Brewfile ---
# Assumes your Brewfile is in a dotfiles repo cloned to ~/.dotfiles
BREWFILE_PATH="${HOME}/.dotfiles/Brewfile"
if [ -f "$BREWFILE_PATH" ]; then
    echo "Installing packages from Brewfile..."
    brew bundle --file="$BREWFILE_PATH"
else
    echo "Warning: Brewfile not found at $BREWFILE_PATH. Skipping package installation."
fi

# --- asdf Setup (Language Version Manager) ---
# Add plugins and install default language versions
if command -v asdf &> /dev/null; then
    echo "Setting up asdf plugins..."

    # Node.js
    if ! asdf plugin list | grep -q "nodejs"; then
        asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    fi
    asdf install nodejs latest

    # You can add other languages here
    # Example for Go
    # if ! asdf plugin list | grep -q "golang"; then
    #   asdf plugin add golang https://github.com/asdf-community/asdf-golang.git
    # fi
    # asdf install golang latest
fi

# --- git-secrets Setup ---
if [ ! -d ~/.git-secrets ]; then
    echo "Installing git-secrets..."
    git clone https://github.com/awslabs/git-secrets.git ~/.git-secrets
    (cd ~/.git-secrets && sudo make install)
fi
# Register AWS hooks globally for all repositories
git secrets --register-aws --global

# --- Zsh (Prezto) Setup ---
if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
    echo "Installing Prezto for Zsh..."
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    # Note: You need to manually link your .zshrc, .zpreztorc etc. from your dotfiles
fi

# --- Docker Setup for Linux ---
# On macOS, Docker Desktop is installed via Brewfile (cask)
if [ "$ISLINUX" = true ] && ! command -v docker &> /dev/null; then
    echo "Setting up Docker for Linux..."
    sudo apt-get update
    sudo apt-get install ca-certificates curl gnupg -y
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    # Add user to the docker group to run docker without sudo
    sudo usermod -aG docker "$USER"
    echo "Docker for Linux installed. You may need to log out and log back in for group changes to take effect."
fi

# --- Add Zsh to /etc/shells ---
# Set path to Homebrew Zsh
if [ "$ISLINUX" = true ]; then
    ZSH_PATH="/home/linuxbrew/.linuxbrew/bin/zsh"
else # macOS
    ZSH_PATH="/opt/homebrew/bin/zsh"
fi

# Add the Zsh path to /etc/shells if it's not already there
if ! grep -qFx "$ZSH_PATH" /etc/shells; then
    echo "Adding $ZSH_PATH to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
fi

# --- Set Zsh as Default Shell ---
# Change shell only if it's not already Zsh
if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "Changing default shell to Zsh..."
    chsh -s "$ZSH_PATH"
    echo "Default shell changed to Zsh. Please log out and log back in to apply the changes."
fi

echo -e "\n✅ Setup complete!"
