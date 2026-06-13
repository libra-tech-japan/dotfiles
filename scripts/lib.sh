#!/bin/bash
# 共有ユーティリティ: install.sh / install-container.sh が source して使用。
# DOTFILES_ROOT が事前に設定されていること。

# VSCode 拡張が /usr/bin (system PATH) で要求するツールを apt でインストール。
# Homebrew 版と並存させることで、VSCode 拡張と zsh CLI の両方で動作を保証する。
# 背景: VSCode の extension host は Homebrew の PATH を継承しないため、
#       ripgrep/fd を brew だけで入れると VSCode 拡張がバイナリを見つけられない。
install_apt_vscode_tools() {
  command -v apt-get &>/dev/null || return 0
  command -v sudo &>/dev/null || return 0
  echo "📎 Installing system packages for VSCode compatibility (apt)..."
  sudo apt-get update -qq 2>/dev/null || true
  sudo apt-get install -y ripgrep fd-find 2>/dev/null || {
    echo "⚠️  apt install failed. Continuing..."
    return 0
  }
  # apt の fd は fdfind として入るため /usr/local/bin/fd へ symlink
  if command -v fdfind &>/dev/null && [[ ! -e /usr/local/bin/fd ]]; then
    sudo mkdir -p /usr/local/bin
    sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
  fi
}

# Brewfile.common と環境固有の Brewfile を結合して brew bundle を実行。
# 引数: 環境固有ファイル名（省略可; 省略時は Brewfile.common のみ）
run_brew_bundle() {
  local specific="${1:-}"
  local tmp
  tmp=$(mktemp /tmp/Brewfile.XXXXX)

  cat "${DOTFILES_ROOT}/Brewfile.common" > "$tmp"
  if [[ -n "$specific" && -f "${DOTFILES_ROOT}/${specific}" ]]; then
    echo "" >> "$tmp"
    cat "${DOTFILES_ROOT}/${specific}" >> "$tmp"
  fi

  brew bundle --file="$tmp"
  local exit_code=$?
  rm -f "$tmp"
  return $exit_code
}

# ~/.config が starship へのシンボリックリンクになっている場合の修復
repair_config_dir() {
  if [[ -L "${HOME}/.config" ]] && [[ "$(readlink "${HOME}/.config")" == *"starship/.config"* ]]; then
    echo "🔧 Repairing ~/.config (was symlinked to starship/.config)..."
    rm "${HOME}/.config"
    mkdir -p "${HOME}/.config"
  fi
}

# config ディレクトリ内に同名の入れ子 symlink が誤生成されている場合を削除
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

# .config 配下の設定エントリをリンク。
# 引数: include_tmux (true/false, デフォルト true) — コンテナでは false を渡す
link_config_entries() {
  local include_tmux="${1:-true}"
  link_config_file "${DOTFILES_ROOT}/starship/.config/starship.toml" "${HOME}/.config/starship.toml"
  link_config_dir "${DOTFILES_ROOT}/starship/.config/tmuxinator" "${HOME}/.config/tmuxinator"
  link_config_dir "${DOTFILES_ROOT}/nvim/.config/nvim" "${HOME}/.config/nvim"
  link_config_dir "${DOTFILES_ROOT}/lazygit/.config/lazygit" "${HOME}/.config/lazygit"
  link_config_dir "${DOTFILES_ROOT}/lazygit/.config/mise" "${HOME}/.config/mise"
  if [[ "$include_tmux" == "true" ]]; then
    link_config_dir "${DOTFILES_ROOT}/tmux/.config/tmux" "${HOME}/.config/tmux"
  fi
}

# ni (@antfu/ni) のインストール: パッケージマネージャ差分を吸収するツール
install_ni() {
  if ! command -v ni &>/dev/null; then
    if command -v npm &>/dev/null; then
      echo "Installing ni (via npm)..."
      npm install -g @antfu/ni || echo "⚠️ Failed to install ni"
    fi
  else
    echo "ni is already installed, skipping"
  fi
}
