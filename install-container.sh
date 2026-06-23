#!/bin/bash
# コンテナ用エントリ（薄い shim）。実体は install.sh --container。
# インストールロジックの真実源は install.sh 1つ。
# DevContainer の installCommand / postCreateCommand や docker/ の層1検証から呼ばれる。
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install.sh" --container "$@"
