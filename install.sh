#!/bin/bash
# 統合インストーラ（ホスト / コンテナ共通）。
#   host       : フル装備（Docker / mise / tmux / VS Code / win32yank ...）。Ubuntu(EC2) をメイン、Mac/WSL を分岐。
#   container  : `--container` 指定時（install-container.sh が exec で渡す）。
#                mise グローバル / VS Code / Ghostty / tmux は行わない。neovim は含む。
# インストールロジックの真実源はこのファイル1つ。共通処理は scripts/lib.sh に集約。
set -e

# ---------------------------------------------------------------------------
# 実行コンテキスト判定（--container フラグで明示。自動検出はしない）
# ---------------------------------------------------------------------------
CONTEXT=host
if [ "${1:-}" = "--container" ]; then
  CONTEXT=container
  shift
fi

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_ROOT"

# shellcheck source=scripts/lib.sh
source "${DOTFILES_ROOT}/scripts/lib.sh"

if [ "$CONTEXT" = container ]; then
  echo "📦 Container: Linuxbrew + brew bundle + dotfiles link..."
else
  echo "🚀 Starting Libratech Lab. Dotfiles Setup (2026)..."
fi

# ---------------------------------------------------------------------------
# 単一実行ロック（host のみ。二重実行による brew のロック競合を防止）。
# flock は macOS に標準搭載されないため、mkdir のアトミック性で移植性を確保する。
# container は単発実行・競合しないためロックしない。
# ---------------------------------------------------------------------------
if [ "$CONTEXT" != container ]; then
  INSTALL_LOCK="$DOTFILES_ROOT/.install.lock"
  acquire_install_lock() {
    # mkdir はアトミック: 同時実行でも片方の mkdir だけが成功する
    if mkdir "$INSTALL_LOCK" 2>/dev/null; then
      echo $$ > "$INSTALL_LOCK/pid"
      return 0
    fi
    # 取得失敗。既存ロックのプロセスが生きていなければ stale とみなし奪取する
    # （旧 flock 実装が残したファイル形式のロックもこの経路で除去される）。
    local pid
    pid=$(cat "$INSTALL_LOCK/pid" 2>/dev/null || true)
    if [[ -z "$pid" ]] || ! kill -0 "$pid" 2>/dev/null; then
      rm -rf "$INSTALL_LOCK"
      if mkdir "$INSTALL_LOCK" 2>/dev/null; then
        echo $$ > "$INSTALL_LOCK/pid"
        return 0
      fi
    fi
    return 1
  }
  if ! acquire_install_lock; then
    echo "⚠️  Another install is already running. Wait for it to finish or remove $INSTALL_LOCK and retry."
    exit 1
  fi
  # 正常・異常終了いずれでもロックを解放する（flock の自動解放に相当）
  trap 'rm -rf "$INSTALL_LOCK"' EXIT

  # 0. コードベース内の .DS_Store を削除（Stow 競合防止。host のみ）
  if find "$DOTFILES_ROOT" -name '.DS_Store' -type f 2>/dev/null | grep -q .; then
    echo "🧹 Removing .DS_Store files in dotfiles..."
    find "$DOTFILES_ROOT" -name '.DS_Store' -type f -delete
  fi
fi

# プラットフォーム判定（host のみ。container は常に CONTEXT=container で分岐）
IS_DARWIN=false
IS_UBUNTU_OR_DEBIAN=false
IS_WSL=false
if [ "$CONTEXT" != container ]; then
  [ "$(uname)" = "Darwin" ] && IS_DARWIN=true
  [ -f /etc/debian_version ] && IS_UBUNTU_OR_DEBIAN=true
  [ -f /proc/version ] && grep -q microsoft /proc/version 2>/dev/null && IS_WSL=true
fi

# ---------------------------------------------------------------------------
# Homebrew / Linuxbrew セットアップ（+ VSCode 用 apt ツール）
# ---------------------------------------------------------------------------
if [ "$CONTEXT" = container ]; then
  # Linuxbrew 導入の前提: curl と git
  if ! command -v curl &> /dev/null || ! command -v git &> /dev/null; then
    if command -v apt-get &> /dev/null && command -v sudo &> /dev/null; then
      sudo apt-get update -qq 2>/dev/null || true
      sudo apt-get install -y curl git 2>/dev/null || true
    else
      echo "⚠️  curl と git が必要です。Docker イメージに含めるか、先にインストールしてください。"
      exit 1
    fi
  fi
  # VSCode 拡張が system PATH で期待するツール（ripgrep, fd）を apt でインストール
  install_apt_vscode_tools
  # Linuxbrew のインストールと PATH
  if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew (Linux)..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL "$HOMEBREW_INSTALL_URL")"
  fi
  # インストール先に応じて shellenv を評価
  if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif [[ -f "$HOME/.linuxbrew/bin/brew" ]]; then
    eval "$($HOME/.linuxbrew/bin/brew shellenv)"
  else
    command -v brew &> /dev/null || { echo "⚠️  brew が見つかりません。"; exit 1; }
    eval "$(brew shellenv)"
  fi
elif [ "$IS_UBUNTU_OR_DEBIAN" = true ]; then
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
elif [ "$IS_DARWIN" = true ]; then
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

# ---------------------------------------------------------------------------
# brew bundle（host: Brewfile.common + Brewfile / container: Brewfile.common のみ）
# ---------------------------------------------------------------------------
echo "📦 Bundling packages..."
if [ "$CONTEXT" = container ]; then
  run_brew_bundle || {
    echo ""
    echo "⚠️  brew bundle failed. Check the errors above."
    exit 1
  }
else
  run_brew_bundle "Brewfile" || {
    echo ""
    echo "⚠️  brew bundle failed. If you saw 'already locked' errors:"
    echo "   Another install or brew process may be running. Wait for it to finish, then run ./install.sh again."
    exit 1
  }
fi

# Git のグローバル除外ファイルを用意（共通）
if [ ! -f "$HOME/.gitignore_global" ]; then
  touch "$HOME/.gitignore_global"
fi

# Git の個人情報（user.name/email）は公開リポジトリに載せず ~/.gitconfig.local に分離する。
# host のみ: 無い場合のみテンプレートから作成（既存は絶対に上書きしない＝再実行で冪等）。
# container: git/.gitconfig を実ファイルとして配置（install_git_config。stow セクションで実行）。
if [ "$CONTEXT" != container ] && [ ! -f "$HOME/.gitconfig.local" ]; then
  cp "$DOTFILES_ROOT/.gitconfig.local.example" "$HOME/.gitconfig.local"
  echo "📝 Created ~/.gitconfig.local from template. Edit it with your name/email (commits are blocked until set)."
fi

# ---------------------------------------------------------------------------
# WSL（host・オプション）: win32yank
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
# Runtime Setup（host のみ。container は mise を使わない＝MISE_DISABLE_TOOLS）
# ---------------------------------------------------------------------------
if [ "$CONTEXT" != container ]; then
  echo "🔧 Setting up Runtimes..."
  eval "$(mise activate bash)" 2>/dev/null || true
  if command -v volta &> /dev/null; then
    echo "⚡ Volta detected. Skipping global Node setup via Mise to respect local environment."
  else
    command -v mise &> /dev/null && mise use --global node@lts 2>/dev/null || true
  fi
  command -v mise &> /dev/null && mise use --global python@3.12 2>/dev/null || true
fi

# ---------------------------------------------------------------------------
# Smart Stow Linking (with Auto-Backup)（共通）
# .config 配下（starship / nvim / lazygit / tmux）は手動リンクのみ
# （Stow すると ~/.config 全体のバックアップ/リンク化を招く）。
# backup_if_exists / is_file_bind_mount / install_git_config は lib.sh に集約。
# ---------------------------------------------------------------------------
echo "🔗 Linking dotfiles..."
if [ "$CONTEXT" = container ]; then
  # container は git を stow しない（bind mount 競合・.gitconfig.local 連携のため実ファイル管理）
  STOW_DIRS=("zsh")
  install_git_config
else
  STOW_DIRS=("git" "zsh")
fi

repair_config_dir
# stow の対象は常に $HOME を明示する（既定の target はリポジトリの親になり、
# リポジトリが $HOME 直下以外にあると $HOME 外へ書こうとして失敗するため）。
stow -t "$HOME" -D "${STOW_LEGACY_UNSTOW[@]}" 2>/dev/null || true

for package in "${STOW_DIRS[@]}"; do
  find "$package" -maxdepth 1 -mindepth 1 2>/dev/null | while read -r source_path; do
    relative_path=$(basename "$source_path")
    target_path="$HOME/$relative_path"
    backup_if_exists "$target_path"
  done
  stow -t "$HOME" "${STOW_IGNORE_OPTS[@]}" -v --restow "$package"
done

# claude（~/.claude）は混在ディレクトリ — 共有設定 + 認証情報/履歴などの実行時データが同居する（host のみ）。
# 汎用 STOW_DIRS ループに入れてはいけない（最上位 .claude を backup_if_exists が見て
# ~/.claude を認証情報ごと退避してしまう）。--no-folding で ~/.claude を実ディレクトリのまま
# 維持し、共有設定ファイルだけを個別リンクする。実行時データ・秘密は repo に入らない。
if [ "$CONTEXT" != container ] && [ -d "claude" ]; then
  backup_if_exists "$HOME/.claude/settings.json"
  stow -t "$HOME" --no-folding "${STOW_IGNORE_OPTS[@]}" -v --restow claude
fi

# .config 配下のリンク。scope は context で決まる:
#   container … all のみ / host … all + host / host-darwin … all + host + darwin(ghostty)
if [ "$CONTEXT" = container ]; then
  LINK_CONTEXT=container
elif [ "$IS_DARWIN" = true ]; then
  LINK_CONTEXT=host-darwin
else
  LINK_CONTEXT=host
fi
link_config_entries "$LINK_CONTEXT"

# TPM Setup（host のみ。container に tmux は無い）
if [ "$CONTEXT" != container ] && [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone "$TPM_REPO_URL" ~/.tmux/plugins/tpm
fi

install_ni

# ---------------------------------------------------------------------------
# VS Code Setup: host の Darwin または WSL 時のみ（リンク処理は lib.sh に集約）。
# container では行わない（IS_DARWIN/IS_WSL は false のまま）。
# Ghostty 設定（macOS のみ）は link_config_entries の darwin scope でリンク済み。
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

if [ "$CONTEXT" = container ]; then
  echo "✅ Container dotfiles ready. Run 'exec zsh' to reload."
else
  echo "🎉 Setup Complete! Run 'exec zsh' to start."
fi
