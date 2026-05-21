#!/bin/bash
# コンテナ用: Linuxbrew 導入 + brew bundle (Brewfile.container) + Stow。mise グローバル / VS Code / Ghostty は行わない。
# neovim は含める。tmux/htop は含めない。DevContainer の installCommand で使用する想定。
set -e

echo "📦 Container: Linuxbrew + brew bundle + dotfiles link..."

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_ROOT"

# .gitignore_global が無ければ用意
if [ ! -f "$HOME/.gitignore_global" ]; then
  touch "$HOME/.gitignore_global"
fi

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

# Linuxbrew のインストールと PATH
if ! command -v brew &> /dev/null; then
  echo "🍺 Installing Homebrew (Linux)..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

# brew bundle（Brewfile.container）
echo "📦 Bundling packages (Brewfile.container)..."
brew bundle --file="$DOTFILES_ROOT/Brewfile.container" || {
  echo ""
  echo "⚠️  brew bundle failed. Check the errors above."
  exit 1
}

# Stow と .config リンク
# ファイル単体の bind マウントか（findmnt -T は ext4 上の通常ファイルでも真になるため使わない）
is_file_bind_mount() {
  local target="$1"
  [[ -e "$target" ]] || return 1
  grep -E " ${target} " /proc/self/mountinfo 2>/dev/null | grep -q ' - bind '
}

backup_if_exists() {
  local target="$1"
  if is_file_bind_mount "$target"; then
    echo "ℹ️  Skipping $target (bind mount; cannot replace)"
    return 0
  fi
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    local backup_name="${target}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "⚠️  Conflict detected: Moving existing $target to $backup_name"
    mv "$target" "$backup_name" || {
      echo "ℹ️  Skipping $target (could not move; may be in use or mounted)"
      return 0
    }
  fi
}

# DevContainer では ~/.gitconfig を stow しない（mv 競合・.gitconfig.local 連携のため）
install_git_config() {
  local template="${DOTFILES_ROOT}/git/.gitconfig"
  [[ -f "$template" ]] || return 0
  if is_file_bind_mount "${HOME}/.gitconfig"; then
    echo "ℹ️  ~/.gitconfig is bind-mounted; not modifying"
    return 0
  fi
  if [[ ! -f "${HOME}/.gitconfig" ]] || [[ ! -s "${HOME}/.gitconfig" ]]; then
    cp "$template" "${HOME}/.gitconfig"
    echo "ℹ️  Installed ~/.gitconfig from dotfiles template"
  fi
}

# ~/.config が starship パッケージ全体へのリンクになっている場合は修復
repair_config_dir() {
  if [[ -L "${HOME}/.config" ]] && [[ "$(readlink "${HOME}/.config")" == *"starship/.config"* ]]; then
    echo "🔧 Repairing ~/.config (was symlinked to starship/.config)..."
    rm "${HOME}/.config"
    mkdir -p "${HOME}/.config"
  fi
}

clean_nested_config_symlink() {
  local config_dir="$1"
  local base
  base=$(basename "$config_dir")
  if [[ -L "${config_dir}/${base}" ]]; then
    echo "🧹 Removing nested mistaken symlink: ${config_dir}/${base}"
    rm -f "${config_dir}/${base}"
  fi
}

link_config_dir() {
  local src="$1"
  local dest="$2"
  clean_nested_config_symlink "$src"
  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
}

link_config_file() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  ln -sf "$src" "$dest"
}

link_config_entries() {
  link_config_file "${DOTFILES_ROOT}/starship/.config/starship.toml" "${HOME}/.config/starship.toml"
  link_config_dir "${DOTFILES_ROOT}/starship/.config/tmuxinator" "${HOME}/.config/tmuxinator"
  link_config_dir "${DOTFILES_ROOT}/nvim/.config/nvim" "${HOME}/.config/nvim"
  link_config_dir "${DOTFILES_ROOT}/lazygit/.config/lazygit" "${HOME}/.config/lazygit"
  link_config_dir "${DOTFILES_ROOT}/lazygit/.config/mise" "${HOME}/.config/mise"
}

# .config 配下は Stow すると ~/.config 全体のバックアップ/リンク化を招くため手動リンクのみ
STOW_DIRS=("zsh")
install_git_config
repair_config_dir
stow -D starship lazygit nvim git 2>/dev/null || true

for package in "${STOW_DIRS[@]}"; do
  find "$package" -maxdepth 1 -mindepth 1 2>/dev/null | while read -r source_path; do
    relative_path=$(basename "$source_path")
    target_path="$HOME/$relative_path"
    backup_if_exists "$target_path"
  done
  stow -v --restow "$package"
done

link_config_entries


if ! command -v ni &> /dev/null; then
  if command -v npm &> /dev/null; then
    echo "Installing ni (via npm)..."
    npm install -g @antfu/ni || echo "⚠️ Failed to install ni"
  fi
else
  echo "ni is already installed, skipping"
fi

echo "✅ Container dotfiles ready. Run 'exec zsh' to reload."
