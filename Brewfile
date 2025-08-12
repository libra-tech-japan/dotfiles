# ===============================================================
# Brewfile for Universal Dev Environment (macOS / Linux)
#
# Install all packages:
# brew bundle --file /path/to/this/Brewfile
# ===============================================================

# Homebrew Taps (if necessary)
# tap "homebrew/bundle"
# tap "homebrew/cask-fonts" # For fonts

# --- Core CLI Tools ---
# Shell & System
brew "zsh"
brew "tree"
brew "wget"

# Development & Build
brew "go"
brew "jq"
brew "rustup-init" # Recommended way to install Rust toolchain
brew "doxygen"
brew "cmake"
brew "pkg-config"

# Git & GitHub
brew "gh"      # GitHub CLI
brew "ghq"     # Local repository management
brew "fzf"     # Command-line fuzzy finder
brew "tig"     # Text-mode interface for git
brew "lazygit" # Simple terminal UI for git commands

# Modern CLI Alternatives (DX Improvement)
brew "eza"       # A modern replacement for 'ls'
brew "bat"       # A cat(1) clone with wings
brew "ripgrep"   # A line-oriented search tool that recursively searches (grep alternative)
brew "fd"        # A simple, fast and user-friendly alternative to 'find'

# Utilities
brew "imagemagick"
brew "glow"        # Render markdown on the CLI
brew "neovim"
brew "direnv"      # Unclutter your .profile

# Cloud & Infra
brew "cfn-lint"

# --- Language Version Manager ---
brew "asdf"

# --- Languages (can be managed by asdf) ---
brew "deno" # Or manage via asdf-deno plugin

# ===============================================================
# macOS Specific Packages (Casks for GUI Apps & Fonts)
# These will be skipped on Linux.
# ===============================================================
cask "docker-desktop"
cask "visual-studio-code"
cask "font-hack-nerd-font" # Powerline/Nerd Fonts for better terminal UI
