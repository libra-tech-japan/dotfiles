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

# Development & Build
brew "jq"

# Git & GitHub
brew "gh"      # GitHub CLI
brew "ghq"     # Local repository management
brew "fzf"     # Command-line fuzzy finder
brew "tig"     # Text-mode interface for git

# Modern CLI Alternatives (DX Improvement)
brew "eza"       # A modern replacement for 'ls'
brew "bat"       # A cat(1) clone with wings
brew "ripgrep"   # A line-oriented search tool that recursively searches (grep alternative)
brew "fd"        # A simple, fast and user-friendly alternative to 'find'

# Utilities
brew "neovim"

# --- Language Version Manager ---
brew "asdf"

# ===============================================================
# macOS Specific Packages (Casks for GUI Apps & Fonts)
# These will be skipped on Linux.
# ===============================================================
cask "docker-desktop"
cask "visual-studio-code"
cask "font-hack-nerd-font" # Powerline/Nerd Fonts for better terminal UI
