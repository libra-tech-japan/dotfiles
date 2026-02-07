#!/bin/bash
# ホスト用フルインストール。Ubuntu（EC2）をメイン、Mac/WSL はオプション分岐。
set -e

echo "🚀 Starting Libratech Lab. Dotfiles Setup (2026)..."

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_ROOT"

# 単一実行のためロックを取得（二重実行による brew のロック競合を防止）
INSTALL_LOCK="$DOTFILES_ROOT/.install.lock"
exec 200>"$INSTALL_LOCK"
if ! flock -n 200; then
  echo "⚠️  Another install is already running. Wait for it to finish or remove $INSTALL_LOCK and retry."
  exit 1
fi

# 0. コードベース内の .DS_Store を削除（Stow 競合防止）
if find "$DOTFILES_ROOT" -name '.DS_Store' -type f 2>/dev/null | grep -q .; then
  echo "🧹 Removing .DS_Store files in dotfiles..."
  find "$DOTFILES_ROOT" -name '.DS_Store' -type f -delete
fi

# プラットフォーム判定（Ubuntu/Linux をメイン、Darwin/WSL をオプション）
IS_DARWIN=false
IS_UBUNTU_OR_DEBIAN=false
IS_WSL=false
[ "$(uname)" = "Darwin" ] && IS_DARWIN=true
[ -f /etc/debian_version ] && IS_UBUNTU_OR_DEBIAN=true
[ -f /proc/version ] && grep -q microsoft /proc/version 2>/dev/null && IS_WSL=true

# ---------------------------------------------------------------------------
# Ubuntu / Linux（メイン）: Docker、Linuxbrew、brew bundle
# ---------------------------------------------------------------------------
if [ "$IS_UBUNTU_OR_DEBIAN" = true ]; then
  if ! command -v docker &> /dev/null; then
    echo "🐧 Linux detected. Installing Docker Engine..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER"
  fi
  # Linuxbrew: 既に brew が入っていても PATH に入っていないことがあるため bundle 前に確実に設定
  if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew (Linux)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
  fi
fi

# ---------------------------------------------------------------------------
# Darwin（オプション）: Homebrew、brew bundle 用に PATH 確保
# --------------------------------------------------------------------------
if [ "$IS_DARWIN" = true ]; then
  if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew (macOS)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  echo "🍎 macOS detected. Ensure OrbStack is running for Docker."
fi

# brew bundle（全プラットフォーム共通）
echo "📦 Bundling packages..."
brew bundle --file="$DOTFILES_ROOT/Brewfile" || {
  echo ""
  echo "⚠️  brew bundle failed. If you saw 'already locked' errors:"
  echo "   Another install or brew process may be running. Wait for it to finish, then run ./install.sh again."
  exit 1
}

# Git のグローバル除外ファイルを用意
if [ ! -f "$HOME/.gitignore_global" ]; then
  touch "$HOME/.gitignore_global"
fi

# ---------------------------------------------------------------------------
# WSL（オプション）: win32yank
# ---------------------------------------------------------------------------
if [ "$IS_WSL" = true ]; then
  if ! command -v win32yank.exe &> /dev/null; then
    echo "🪟 WSL2 detected. Setting up win32yank..."
    curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip
    mkdir -p "$HOME/.local/bin"
    if command -v unzip &> /dev/null; then
      unzip -p /tmp/win32yank.zip win32yank.exe > "$HOME/.local/bin/win32yank.exe"
    elif command -v bsdtar &> /dev/null; then
      bsdtar -xOf /tmp/win32yank.zip win32yank.exe > "$HOME/.local/bin/win32yank.exe"
    else
      echo "⚠️  unzip/bsdtar が無いため win32yank を展開できません"
      echo "    apt-get install unzip または brew install unzip を実行してください"
      exit 1
    fi
    chmod +x "$HOME/.local/bin/win32yank.exe"
  fi
fi

# ---------------------------------------------------------------------------
# Runtime Setup（共通）
# ---------------------------------------------------------------------------
echo "🔧 Setting up Runtimes..."
eval "$(mise activate bash)" 2>/dev/null || true
if command -v volta &> /dev/null; then
  echo "⚡ Volta detected. Skipping global Node setup via Mise to respect local environment."
else
  command -v mise &> /dev/null && mise use --global node@lts 2>/dev/null || true
fi
command -v mise &> /dev/null && mise use --global python@3.12 2>/dev/null || true

# ---------------------------------------------------------------------------
# Smart Stow Linking (with Auto-Backup)（共通）
# ---------------------------------------------------------------------------
echo "🔗 Linking dotfiles..."
# tmux は .config 直下を Stow すると ~/.config 全体が上書きされるため手動リンクにする
STOW_DIRS=("git" "lazygit" "nvim" "starship" "zsh")

backup_if_exists() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    local backup_name="${target}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "⚠️  Conflict detected: Moving existing $target to $backup_name"
    mv "$target" "$backup_name"
  fi
}

for package in "${STOW_DIRS[@]}"; do
  find "$package" -maxdepth 1 -mindepth 1 | while read -r source_path; do
    relative_path=$(basename "$source_path")
    target_path="$HOME/$relative_path"
    backup_if_exists "$target_path"
  done
  stow -v --restow "$package"
done

# .config 手動リンク（Stow がネストを扱わないため）
if [[ ! -e "$HOME/.config/nvim" ]]; then
  mkdir -p "$HOME/.config"
  ln -sf "$DOTFILES_ROOT/nvim/.config/nvim" "$HOME/.config/nvim"
fi
if [[ ! -e "$HOME/.config/lazygit" ]]; then
  mkdir -p "$HOME/.config"
  ln -sf "$DOTFILES_ROOT/lazygit/.config/lazygit" "$HOME/.config/lazygit"
fi
if [[ ! -e "$HOME/.config/mise" ]]; then
  mkdir -p "$HOME/.config"
  ln -sf "$DOTFILES_ROOT/lazygit/.config/mise" "$HOME/.config/mise"
fi
if [[ ! -e "$HOME/.config/tmux" ]]; then
  mkdir -p "$HOME/.config"
  ln -sf "$DOTFILES_ROOT/tmux/.config/tmux" "$HOME/.config/tmux"
fi

# TPM Setup
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# ni (npm i replacement)
if ! command -v ni &> /dev/null; then
  if command -v npm &> /dev/null; then
    echo "Installing ni (via npm)..."
    npm install -g @antfu/ni || echo "⚠️ Failed to install ni"
  fi
else
  echo "ni is already installed, skipping"
fi

# ---------------------------------------------------------------------------
# VS Code Setup: Darwin または WSL 時のみ
# ---------------------------------------------------------------------------
if [ "$IS_DARWIN" = true ] && [ -d "$HOME/Library/Application Support/Code/User" ]; then
  echo "💻 Linking VS Code settings (macOS)..."
  VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
  ln -sf "$DOTFILES_ROOT/vscode/settings.json" "$VSCODE_USER_DIR/settings.json"
  ln -sf "$DOTFILES_ROOT/vscode/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
  if [ -d "$DOTFILES_ROOT/vscode/snippets" ]; then
    rm -rf "$VSCODE_USER_DIR/snippets"
    ln -sf "$DOTFILES_ROOT/vscode/snippets" "$VSCODE_USER_DIR/snippets"
  fi
  if [ -f "$DOTFILES_ROOT/vscode/extensions.txt" ] && command -v code &> /dev/null; then
    echo "🧩 Installing VS Code extensions..."
    xargs -L 1 -P 4 code --install-extension < "$DOTFILES_ROOT/vscode/extensions.txt"
  fi
fi

if [ "$IS_WSL" = true ]; then
  echo "🪟 WSL2: Linking VS Code settings to Windows side..."
  WIN_APPDATA=$(cmd.exe /c "echo %APPDATA%" 2>/dev/null | tr -d '\r')
  VSCODE_USER_DIR=$(wslpath -u "$WIN_APPDATA")/Code/User
  if [ -d "$VSCODE_USER_DIR" ]; then
    ln -sf "$DOTFILES_ROOT/vscode/settings.json" "$VSCODE_USER_DIR/settings.json"
    ln -sf "$DOTFILES_ROOT/vscode/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
    if [ -d "$DOTFILES_ROOT/vscode/snippets" ]; then
      rm -rf "$VSCODE_USER_DIR/snippets"
      ln -sf "$DOTFILES_ROOT/vscode/snippets" "$VSCODE_USER_DIR/snippets"
    fi
    if [ -f "$DOTFILES_ROOT/vscode/extensions.txt" ] && command -v code &> /dev/null; then
      echo "🧩 Installing VS Code extensions..."
      xargs -L 1 -P 4 code --install-extension < "$DOTFILES_ROOT/vscode/extensions.txt"
    fi
    echo "✅ VS Code settings linked to Windows AppData."
  else
    echo "⚠️  VS Code User directory not found in Windows. Skipping."
  fi
fi

# ---------------------------------------------------------------------------
# Ghostty Configuration: Darwin 時のみ（Brewfile の cask も Mac のみ）
# ---------------------------------------------------------------------------
if [ "$IS_DARWIN" = true ]; then
  echo "👻 Setting up Ghostty configuration..."
  mkdir -p "$HOME/.config/ghostty"
  ln -sf "$DOTFILES_ROOT/ghostty/config" "$HOME/.config/ghostty/config"
fi

echo "🎉 Setup Complete! Run 'exec zsh' to start."
