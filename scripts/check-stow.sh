#!/usr/bin/env bash
# install.sh 実行後のホームディレクトリ・Stow 状態を確認するスクリプト
# 実行: ./scripts/check-stow.sh または bash scripts/check-stow.sh
# 出力をそのまま報告すればよい

set -e
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# CONFIG_ENTRIES を単一真実源として共有（リンク対象・入れ子検出の導出に使用）
# shellcheck source=lib.sh
source "$DOTFILES_ROOT/scripts/lib.sh"
echo "=== Dotfiles root ==="
echo "$DOTFILES_ROOT"
echo ""

if [[ -L "$HOME/.config" ]]; then
  config_link="$(readlink "$HOME/.config")"
  if [[ "$config_link" == *"starship/.config"* ]]; then
    echo "⚠️  WARN: ~/.config が starship/.config への単一シンボリックリンクです。"
    echo "    ランタイム生成物が dotfiles リポジトリに混入します。./install.sh を再実行して修復してください。"
    echo "    -> $config_link"
  else
    echo "ℹ️  ~/.config はシンボリックリンク: $config_link"
  fi
  echo ""
fi

echo "=== リンクされるはずのパス（存在・リンク先） ==="
# Stow 管理ファイル + CONFIG_ENTRIES の dest（lib.sh の単一真実源から導出）
link_names=(.gitconfig .zshrc .zshenv)
for entry in "${CONFIG_ENTRIES[@]}"; do
  IFS=':' read -r _src dest _type _scope <<< "$entry"
  link_names+=("$dest")
done
for name in "${link_names[@]}"; do
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

echo "=== 入れ子 symlink の誤生成（install の ln -sf 由来。あれば ./install.sh で修復） ==="
# CONFIG_ENTRIES の dir 型エントリから <src>/<basename> を検査（lib.sh と同期）
nested_found=false
for entry in "${CONFIG_ENTRIES[@]}"; do
  IFS=':' read -r src _dest type _scope <<< "$entry"
  [[ "$type" == "dir" ]] || continue
  name="$(basename "$src")"
  path="$DOTFILES_ROOT/$src/$name"
  if [[ -L "$path" ]]; then
    echo "⚠️  $path -> $(readlink "$path")"
    nested_found=true
  fi
done
if [[ "$nested_found" = false ]]; then
  echo "(なし)"
fi
echo ""

echo "=== Neovim 設定パス確認用（nvim 起動後 :lua print(vim.fn.stdpath(\"config\")) でも確認可） ==="
if [[ -L "$HOME/.config/nvim" ]]; then
  echo ".config/nvim -> $(readlink -f "$HOME/.config/nvim" 2>/dev/null || readlink "$HOME/.config/nvim")"
else
  echo ".config/nvim はシンボリックリンクではありません"
fi
