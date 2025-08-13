#!/bin/bash
# =================================================================
# Universal Installer
#
# Detects the environment (Container or Local) and runs the
# appropriate application installer before setting up dotfiles.
# =================================================================

# エラーが発生したらスクリプトを停止する
set -e

# このスクリプト自身のディレクトリを基準にパスを指定
BASE_DIR=$(cd "$(dirname "$0")" && pwd)

echo "--- 1. Detecting environment and installing applications... ---"

# コンテナ環境かどうかを判別
# - VSCode Dev Containers/Codespacesの環境変数、または /.dockerenv ファイルの存在を確認
if [ -n "$REMOTE_CONTAINERS" ] || [ -n "$CODESPACES" ] || [ -f /.dockerenv ]; then
    echo "Container environment detected. Running app-container.sh..."
    bash "${BASE_DIR}/bin/app-container.sh"
else
    echo "Local environment detected. Running app-local.sh..."
    bash "${BASE_DIR}/bin/app-local.sh"
fi

echo ""
echo "--- 2. Installing dotfiles (symlinks)... ---"
bash "${BASE_DIR}/bin/dotsinstall.sh"

echo ""
echo "✅ All setup complete!"
