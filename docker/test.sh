#!/usr/bin/env bash
# 層1検証ラッパー: install-container.sh を素の Ubuntu イメージで build & run する。
#   - build 段階: install-container.sh を2回実行（クリーン + 冪等性）
#   - run 段階  : check-stow.sh で Stow / .config リンクの健全性を確認
#
# 使い方:
#   ./docker/test.sh                 # 24.04 でビルド & 検証
#   UBUNTU_VERSION=22.04 ./docker/test.sh
#
# 層2（devup フロー全体）の検証は .devcontainer/ を VSCode で開くか、
# `devcontainer up --workspace-folder .` で起動し、その中で devup を実行する。
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DOTFILES_ROOT"

IMAGE="dotfiles-verify:ubuntu"
UBUNTU_VERSION="${UBUNTU_VERSION:-24.04}"

echo "🔨 Building ${IMAGE} (ubuntu ${UBUNTU_VERSION})..."
DOCKER_BUILDKIT=1 docker build \
  -f docker/Dockerfile.ubuntu \
  --build-arg "UBUNTU_VERSION=${UBUNTU_VERSION}" \
  -t "${IMAGE}" \
  .

echo ""
echo "🔍 Verifying Stow / .config links inside the container..."
docker run --rm "${IMAGE}" bash scripts/check-stow.sh

echo ""
echo "✅ 層1検証 完了: install-container.sh はクリーン + 冪等で通り、リンクも健全です。"
echo "   手動で中を確認する場合: docker run --rm -it ${IMAGE} zsh"
