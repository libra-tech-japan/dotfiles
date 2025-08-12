#!/bin/bash

# エラーが発生したらスクリプトを停止する
set -e

# このスクリプト自身のディレクトリを基準にパスを指定
BASE_DIR=$(cd "$(dirname "$0")" && pwd)

echo "--- 1. Installing applications... ---"
bash "${BASE_DIR}/bin/appinstall.sh"

echo "--- 2. Installing dotfiles (symlinks)... ---"
bash "${BASE_DIR}/bin/dotsinstall.sh"

echo "✅ All setup complete!"
