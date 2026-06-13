#!/bin/bash
# 共有ユーティリティ: install.sh / install-container.sh が source して使用。
# DOTFILES_ROOT が事前に設定されていること。
#
# このファイルはトップレベルで副作用を持たない（定数・配列・関数定義のみ）。
# check-stow.sh など診断スクリプトからも安全に source できる。

# ---------------------------------------------------------------------------
# 設定エントリの単一真実源（link_config_entries / check-stow.sh が共有）
# format: "src(DOTFILES_ROOT相対):dest($HOME相対):type(file|dir):scope(all|host|darwin)"
#   scope: all    = 常時リンク（ホスト・コンテナ共通）
#          host   = container 以外（ホスト全般。tmux/tmuxinator）
#          darwin = host-darwin のみ（macOS。ghostty）
# ツールを追加する際はこの配列に1行足すだけでよい。
# ---------------------------------------------------------------------------
CONFIG_ENTRIES=(
  "starship/.config/starship.toml:.config/starship.toml:file:all"
  "nvim/.config/nvim:.config/nvim:dir:all"
  "lazygit/.config/lazygit:.config/lazygit:dir:all"
  "lazygit/.config/mise:.config/mise:dir:all"
  "tmuxinator/.config/tmuxinator:.config/tmuxinator:dir:host"
  "tmux/.config/tmux:.config/tmux:dir:host"
  "ghostty/config:.config/ghostty/config:file:darwin"
)

# 旧構造（stow starship/lazygit/nvim）の名残リンクを剥がす stow -D 対象
STOW_LEGACY_UNSTOW=(starship lazygit nvim)

# stow が $HOME へ展開してはいけない非設定ファイルの除外パターン。
# 各パッケージ直下に置く CLAUDE.md（ドキュメント）が ~/CLAUDE.md として漏れるのを防ぐ。
# --ignore は加算式で、stow 組み込みの除外（README/.gitignore/.git 等）はそのまま維持される。
# install.sh / install-container.sh の「リンクする」stow 呼び出し（--restow）が共有する。
STOW_IGNORE_OPTS=(--ignore='CLAUDE\.md' --ignore='\.DS_Store')

# ---------------------------------------------------------------------------
# 外部取得 URL（ハードコード散在を防ぐため一元管理）
# ---------------------------------------------------------------------------
HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
DOCKER_INSTALL_URL="https://get.docker.com"
TPM_REPO_URL="https://github.com/tmux-plugins/tpm"
WIN32YANK_VERSION="0.0.4"
WIN32YANK_URL="https://github.com/equalsraf/win32yank/releases/download/v${WIN32YANK_VERSION}/win32yank-x64.zip"

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

# CONFIG_ENTRIES の scope が現在の context でリンク対象かを判定。
# 引数: scope context
config_entry_in_scope() {
  local scope="$1" context="$2"
  case "$scope" in
    all) return 0 ;;
    host) [[ "$context" != "container" ]] && return 0 ;;
    darwin) [[ "$context" == "host-darwin" ]] && return 0 ;;
  esac
  return 1
}

# .config 配下の設定エントリを CONFIG_ENTRIES に従ってリンク。
# 引数: context (container | host | host-darwin, デフォルト host)
#   container   … コンテナ（scope=all のみ）
#   host        … ホスト（macOS 以外。scope=all + host）
#   host-darwin … macOS ホスト（scope=all + host + darwin）
link_config_entries() {
  local context="${1:-host}"
  local entry src dest type scope
  for entry in "${CONFIG_ENTRIES[@]}"; do
    IFS=':' read -r src dest type scope <<< "$entry"
    config_entry_in_scope "$scope" "$context" || continue
    if [[ "$type" == "file" ]]; then
      link_config_file "${DOTFILES_ROOT}/${src}" "${HOME}/${dest}"
    else
      link_config_dir "${DOTFILES_ROOT}/${src}" "${HOME}/${dest}"
    fi
  done
}

# VS Code のユーザー設定ディレクトリへ settings/keybindings/snippets をリンクし、
# extensions.txt があれば拡張をインストールする。Darwin / WSL で共有。
# 引数: VS Code User ディレクトリの絶対パス
# 戻り値: ディレクトリが存在しなければ 1
link_vscode_config() {
  local user_dir="$1"
  [[ -d "$user_dir" ]] || return 1
  ln -sf "${DOTFILES_ROOT}/vscode/settings.json" "${user_dir}/settings.json"
  ln -sf "${DOTFILES_ROOT}/vscode/keybindings.json" "${user_dir}/keybindings.json"
  if [[ -d "${DOTFILES_ROOT}/vscode/snippets" ]]; then
    rm -rf "${user_dir}/snippets"
    ln -sf "${DOTFILES_ROOT}/vscode/snippets" "${user_dir}/snippets"
  fi
  if [[ -f "${DOTFILES_ROOT}/vscode/extensions.txt" ]] && command -v code &>/dev/null; then
    echo "🧩 Installing VS Code extensions..."
    xargs -L 1 -P 4 code --install-extension < "${DOTFILES_ROOT}/vscode/extensions.txt"
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
