#!/bin/bash

# ===============================================================
# Local Development Environment Setup Script (macOS / Ubuntu)
#
# Sets up a development environment using Homebrew as the primary
# package manager. Installs Docker, asdf, and other essential tools.
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

# --- Prerequisite installation for Homebrew on Linux ---
if [ "$ISLINUX" = true ]; then
    echo "Installing prerequisites for Homebrew on Linux..."
    sudo apt-get update
    sudo apt-get install -y build-essential curl file git procps
fi

# --- Homebrew Installation ---
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# --- Add Homebrew to PATH (for this script's session) ---
if [ "$ISLINUX" = true ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else # macOS
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- Install packages via a single Brewfile ---
BASE_DIR=$(cd "$(dirname "$0")/.." && pwd)
BREWFILE_PATH="${BASE_DIR}/Brewfile"

if [ -f "$BREWFILE_PATH" ]; then
    echo "Installing packages from unified Brewfile..."
    brew bundle --file="$BREWFILE_PATH"
else
    echo "Warning: Brewfile not found at $BREWFILE_PATH. Skipping package installation."
fi

if [ -f "$BREWFILE_PATH" ]; then
    brew bundle --file="$BREWFILE_PATH"
else
    echo "Warning: Brewfile not found at $BREWFILE_PATH. Skipping package installation."
    echo "Please create a Brewfile with your required packages (e.g., asdf, git-secrets, neovim)."
fi

# --- git-secrets Setup (Global AWS Hooks) ---
# Assumes git-secrets is installed via Homebrew
if command -v git-secrets &> /dev/null; then
    echo "Registering AWS git-secrets hooks..."
    git secrets --register-aws --global
fi

# --- Zsh (Prezto) Setup ---
if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
    echo "Installing Prezto for Zsh..."
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
fi

# --- Docker Setup for Linux (Host only, e.g., WSL2) ---
if [ "$ISLINUX" = true ] && [ -z "$REMOTE_CONTAINERS" ] && ! command -v docker &> /dev/null; then
    echo "Setting up Docker for Host Linux..."
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

# --- Add Homebrew Zsh to /etc/shells and set as default ---
if [ "$ISLINUX" = true ]; then
    ZSH_PATH="/home/linuxbrew/.linuxbrew/bin/zsh"
else # macOS
    ZSH_PATH="/opt/homebrew/bin/zsh"
fi

if [ -f "$ZSH_PATH" ]; then
    if ! grep -qFx "$ZSH_PATH" /etc/shells; then
        echo "Adding $ZSH_PATH to /etc/shells..."
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi

    if [ "$SHELL" != "$ZSH_PATH" ]; then
        echo "Changing default shell to Zsh ($ZSH_PATH)..."
        chsh -s "$ZSH_PATH"
        echo "Default shell changed. Please log out and log back in to apply the changes."
    fi
else
    echo "Warning: Zsh not found at $ZSH_PATH. Shell not changed."
fi

echo -e "\n✅ Local environment setup complete!"
