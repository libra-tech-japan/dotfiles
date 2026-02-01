#!/usr/bin/env bash
# install.sh 実行後のホームディレクトリ・Stow 状態を確認するスクリプト
# 実行: ./scripts/check-stow.sh または bash scripts/check-stow.sh
# 出力をそのまま報告すればよい

set -e
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "=== Dotfiles root ==="
echo "$DOTFILES_ROOT"
echo ""

echo "=== Stow でリンクされるはずのパス（存在・リンク先） ==="
for name in .gitconfig .zshrc .zshenv .config/nvim .config/lazygit .config/starship.toml .config/tmux .config/mise; do
  path="$HOME/$name"
  if [[ -e "$path" ]]; then
    if [[ -L "$path" ]]; then
      echo "$name -> $(readlink "$path")"
    else
      echo "$name (実体・ディレクトリ)"
    fi
  else
    echo "$name (なし)"
  fi
done
echo ""

echo "=== ~/.config 直下 ==="
ls -la "$HOME/.config" 2>/dev/null || echo "(~/.config が存在しません)"
echo ""

echo "=== Neovim 設定パス確認用（nvim 起動後 :lua print(vim.fn.stdpath(\"config\")) でも確認可） ==="
if [[ -L "$HOME/.config/nvim" ]]; then
  echo ".config/nvim -> $(readlink -f "$HOME/.config/nvim" 2>/dev/null || readlink "$HOME/.config/nvim")"
else
  echo ".config/nvim はシンボリックリンクではありません"
fi
