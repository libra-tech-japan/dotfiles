#!/usr/bin/env bash
# コンテナ初回展開プリミティブ（devcontainer 非依存・生 docker / docker compose 用）。
#
# `docker exec` でコンテナに入った後、1コマンドで dotfiles を展開する:
#   - ~/dotfiles が無ければ clone（named volume 永続時は clone をスキップ）
#   - install.sh --container（フル: Linuxbrew + brew bundle + リンク）を exec で実行
#
# 冪等。再実行しても壊れない。
#
# 使い方:
#   bash scripts/container-bootstrap.sh            # 既に repo がある場合
#   curl -fsSL <raw>/scripts/container-bootstrap.sh | bash   # repo が無い環境（git 必須）
#
# 上書き可能な環境変数:
#   DOTFILES_REPO  clone 元（既定: GitHub の libra-tech-japan/dotfiles。zsh の DOTFILES_REPO と一致）
#   DOTFILES_DIR   展開先（既定: ~/dotfiles）
#
# 追加引数はそのまま install.sh へ渡る（例: container-bootstrap.sh --relink）。
set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/libra-tech-japan/dotfiles}"

if [ ! -d "$DOTFILES_DIR/.git" ]; then
  echo "📥 Cloning dotfiles: $DOTFILES_REPO -> $DOTFILES_DIR"
  command -v git >/dev/null 2>&1 || { echo "⚠️  git が必要です。"; exit 1; }
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  echo "✓ dotfiles already present at $DOTFILES_DIR (clone skipped)"
fi

exec "$DOTFILES_DIR/install.sh" --container "$@"
