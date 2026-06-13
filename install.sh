#!/bin/bash
# ホスト用フルインストール。Ubuntu（EC2）をメイン、Mac/WSL はオプション分岐。
set -e

echo "🚀 Starting Libratech Lab. Dotfiles Setup (2026)..."

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_ROOT"

# shellcheck source=scripts/lib.sh
source "${DOTFILES_ROOT}/scripts/lib.sh"

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
    curl -fsSL "$DOCKER_INSTALL_URL" | sh
    sudo usermod -aG docker "$USER"
  fi
  # Linuxbrew: 既に brew が入っていても PATH に入っていないことがあるため bundle 前に確実に設定
  if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew (Linux)..."
    /bin/bash -c "$(curl -fsSL "$HOMEBREW_INSTALL_URL")"
    if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
  fi
  # VSCode 拡張が system PATH で期待するツール（ripgrep, fd）を apt でインストール
  install_apt_vscode_tools
fi

# ---------------------------------------------------------------------------
# Darwin（オプション）: Homebrew、brew bundle 用に PATH 確保
# ---------------------------------------------------------------------------
if [ "$IS_DARWIN" = true ]; then
  if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew (macOS)..."
    /bin/bash -c "$(curl -fsSL "$HOMEBREW_INSTALL_URL")"
  fi
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  echo "🍎 macOS detected. Ensure OrbStack is running for Docker."
fi

# brew bundle（全プラットフォーム共通: Brewfile.common + Brewfile）
echo "📦 Bundling packages..."
run_brew_bundle "Brewfile" || {
  echo ""
  echo "⚠️  brew bundle failed. If you saw 'already locked' errors:"
  echo "   Another install or brew process may be running. Wait for it to finish, then run ./install.sh again."
  exit 1
}

# Git のグローバル除外ファイルを用意
if [ ! -f "$HOME/.gitignore_global" ]; then
  touch "$HOME/.gitignore_global"
fi

# Git の個人情報（user.name/email）は公開リポジトリに載せず ~/.gitconfig.local に分離する。
# 無い場合のみテンプレートから作成（既存ファイルは絶対に上書きしない＝再実行で冪等、
# 開発サーバー等に既にある ~/.gitconfig.local をマージ/破壊しない）。
if [ ! -f "$HOME/.gitconfig.local" ]; then
  cp "$DOTFILES_ROOT/.gitconfig.local.example" "$HOME/.gitconfig.local"
  echo "📝 Created ~/.gitconfig.local from template. Edit it with your name/email (commits are blocked until set)."
fi

# ---------------------------------------------------------------------------
# WSL（オプション）: win32yank
# ---------------------------------------------------------------------------
if [ "$IS_WSL" = true ]; then
  if ! command -v win32yank.exe &> /dev/null; then
    echo "🪟 WSL2 detected. Setting up win32yank..."
    curl -sLo /tmp/win32yank.zip "$WIN32YANK_URL"
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
# .config 配下（starship / nvim / lazygit / tmux）は手動リンクのみ（Stow すると ~/.config 全体のバックアップ/リンク化を招く）
STOW_DIRS=("git" "zsh")

backup_if_exists() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    local backup_name="${target}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "⚠️  Conflict detected: Moving existing $target to $backup_name"
    mv "$target" "$backup_name"
  fi
}

repair_config_dir
# stow の対象は常に $HOME を明示する（既定の target はリポジトリの親になり、
# リポジトリが $HOME 直下以外にあると $HOME 外へ書こうとして失敗するため）。
stow -t "$HOME" -D "${STOW_LEGACY_UNSTOW[@]}" 2>/dev/null || true

for package in "${STOW_DIRS[@]}"; do
  find "$package" -maxdepth 1 -mindepth 1 | while read -r source_path; do
    relative_path=$(basename "$source_path")
    target_path="$HOME/$relative_path"
    backup_if_exists "$target_path"
  done
  stow -t "$HOME" -v --restow "$package"
done

# macOS は darwin scope（ghostty）も含めてリンク。それ以外のホストは host scope まで。
link_config_entries "$([ "$IS_DARWIN" = true ] && echo host-darwin || echo host)"

# TPM Setup
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone "$TPM_REPO_URL" ~/.tmux/plugins/tpm
fi

install_ni

# ---------------------------------------------------------------------------
# VS Code Setup: Darwin または WSL 時のみ（リンク処理は lib.sh に集約）
# ---------------------------------------------------------------------------
if [ "$IS_DARWIN" = true ]; then
  echo "💻 Linking VS Code settings (macOS)..."
  link_vscode_config "$HOME/Library/Application Support/Code/User" || true
fi

if [ "$IS_WSL" = true ]; then
  echo "🪟 WSL2: Linking VS Code settings to Windows side..."
  WIN_APPDATA=$(cmd.exe /c "echo %APPDATA%" 2>/dev/null | tr -d '\r')
  if link_vscode_config "$(wslpath -u "$WIN_APPDATA")/Code/User"; then
    echo "✅ VS Code settings linked to Windows AppData."
  else
    echo "⚠️  VS Code User directory not found in Windows. Skipping."
  fi
fi

# Ghostty 設定（macOS のみ）は link_config_entries の darwin scope でリンク済み。

echo "🎉 Setup Complete! Run 'exec zsh' to start."
