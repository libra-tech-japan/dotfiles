#!/bin/bash
# コンテナ用軽量インストール: Stow による設定リンクのみ。brew / mise グローバル / VS Code / Ghostty は行わない。
# DevContainer の installCommand で使用する想定。
set -e

echo "📦 Container: Linking dotfiles only (no brew/mise)..."

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_ROOT"

# .gitignore_global が無ければ用意
if [ ! -f "$HOME/.gitignore_global" ]; then
  touch "$HOME/.gitignore_global"
fi

# Stow が無い場合は案内して終了
if ! command -v stow &> /dev/null; then
  echo "⚠️  stow がインストールされていません。Docker イメージに stow を追加するか、apt-get install -y stow を実行してください。"
  exit 1
fi

# バックアップ関数（既存ファイルがシンボリックリンクでない場合のみ退避）
backup_if_exists() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    local backup_name="${target}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "⚠️  Conflict detected: Moving existing $target to $backup_name"
    mv "$target" "$backup_name"
  fi
}

STOW_DIRS=("git" "lazygit" "nvim" "starship" "tmux" "zsh")
for package in "${STOW_DIRS[@]}"; do
  find "$package" -maxdepth 1 -mindepth 1 2>/dev/null | while read -r source_path; do
    relative_path=$(basename "$source_path")
    target_path="$HOME/$relative_path"
    backup_if_exists "$target_path"
  done
  stow -v --restow "$package"
done

# .config 配下の手動リンク（Stow がネストを扱わないため）
mkdir -p "$HOME/.config"
if [[ ! -e "$HOME/.config/nvim" ]]; then
  ln -sf "$DOTFILES_ROOT/nvim/.config/nvim" "$HOME/.config/nvim"
fi
if [[ ! -e "$HOME/.config/lazygit" ]]; then
  ln -sf "$DOTFILES_ROOT/lazygit/.config/lazygit" "$HOME/.config/lazygit"
fi
if [[ ! -e "$HOME/.config/mise" ]]; then
  ln -sf "$DOTFILES_ROOT/lazygit/.config/mise" "$HOME/.config/mise"
fi

# TPM（コンテナで tmux を使う場合用）
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 2>/dev/null || true
fi

echo "✅ Container dotfiles linked. Run 'exec zsh' to reload."
