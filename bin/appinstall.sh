#!/bin/bash

# ===============================================================
# Universal Dev Environment Setup Script (2025) - Final Version
# Target OS: macOS / WSL2 (Ubuntu) / Alpine Linux
# ===============================================================

set -e # Exit immediately if a command exits with a non-zero status.

# --- Keep sudo alive ---
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
    if [ -f /etc/alpine-release ]; then
        echo "Alpine Linux detected. Using apk."
        sudo apk add --no-cache \
            shadow \
            build-base \
            curl \
            file \
            git \
            unzip \
            man-db \
            man-pages
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
            manpages-ja-dev
    fi
fi

# --- Homebrew Installation ---
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# --- Add Homebrew to PATH (for this script's session) ---
if [ "$ISLINUX" = true ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else # macOS
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- Install packages via Brewfile ---
# Use a script-relative path for robustness
BASE_DIR=$(cd "$(dirname "$0")/.." && pwd)
BREWFILE_PATH="${BASE_DIR}/Brewfile"
if [ -f "$BREWFILE_PATH" ]; then
    echo "Installing packages from Brewfile..."
    brew bundle --file="$BREWFILE_PATH"
else
    echo "Warning: Brewfile not found at $BREWFILE_PATH. Skipping package installation."
fi

# --- asdf Setup (Language Version Manager) ---
if command -v asdf &> /dev/null; then
    echo "Setting up asdf plugins..."
    if ! asdf plugin list | grep -q "nodejs"; then
        asdf plugin add nodejs
    fi
    echo "Installing latest Node.js via asdf..."
    asdf install nodejs latest
    LATEST_NODE_VERSION=$(asdf latest nodejs)
    echo "Setting global Node.js version to $LATEST_NODE_VERSION..."
    # asdf global nodejs "$LATEST_NODE_VERSION"
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

# --- Docker Setup for Linux (Host only) ---
# Skips this step if inside a Dev Container
if [ "$ISLINUX" = true ] && [ -z "$REMOTE_CONTAINERS" ] && ! command -v docker &> /dev/null; then
    echo "Setting up Docker for Host Linux (e.g. WSL2)..."
    if [ -f /etc/debian_version ]; then
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        sudo usermod -aG docker "$USER"
        echo "Docker for Linux installed. You may need to log out and log back in for group changes to take effect."
    fi
fi

# --- Add Zsh to /etc/shells ---
if [ "$ISLINUX" = true ]; then
    ZSH_PATH="/home/linuxbrew/.linuxbrew/bin/zsh"
else # macOS
    ZSH_PATH="/opt/homebrew/bin/zsh"
fi

if ! grep -qFx "$ZSH_PATH" /etc/shells; then
    echo "Adding $ZSH_PATH to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
fi

# --- Set Zsh as Default Shell ---
if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "Changing default shell to Zsh..."
    chsh -s "$ZSH_PATH"
    echo "Default shell changed to Zsh. Please log out and log back in to apply the changes."
fi

echo -e "\n✅ Setup complete!"
