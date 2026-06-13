# docker/ — CLAUDE.md

dotfiles のインストールフローを破壊せず検証するためのサンドボックス。
**検証は責務で2層に分かれており、層を混ぜると検証の意味が崩れる。**

---

## ファイル構成

```
docker/
├── Dockerfile.ubuntu                  # 層1: install-container.sh 単体検証イメージ
├── Dockerfile.ubuntu.dockerignore     # 層1 ビルドコンテキストの除外（BuildKit per-Dockerfile）
├── test.sh                            # 層1の build & 検証ラッパー
├── test-workspace/                    # 層2で devup の「対象」にする最小サンプル
│   └── .devcontainer/devcontainer.json
├── README.md                          # 人間向けの使い方
└── CLAUDE.md                          # このファイル

（層2の本体は リポジトリ直下の .devcontainer/devcontainer.json）
```

---

## 2層の責務（混ぜないこと）

```
層1: install-container.sh 単体が通るか
  → 素の docker build。Docker デーモンへのアクセス不要。速い。
  → ローカルの未コミット変更をそのまま検証できる（COPY . で投入するため）。
  → Dockerfile.ubuntu + test.sh

層2: devup フロー全体（devcontainer up + dotfiles 注入 + install）が通るか
  → 軽量 DevContainer の中から devup を実行。DinD でネストした daemon を使う。
  → 検証されるのは push 済みの dotfiles（後述の不変条件 4）。
  → .devcontainer/devcontainer.json + test-workspace/
```

判断基準:
- **ローカルの変更をすぐ試したい** → 層1（`./docker/test.sh`）
- **push 後の devup 統合を確認したい** → 層2

---

## 不変条件

1. **層1は Docker デーモンアクセスを前提にしない。** 単なる `docker build`。
   `install-container.sh` を build 内で**2回**実行し、2回目で冪等性を担保する。
   この「2回実行」を削らない。

2. **層1の Dockerfile は非 root ユーザーで install を流す。**
   Homebrew は root 実行を拒否し、`install_apt_vscode_tools` は sudo を使うため、
   passwordless sudo を持つ非 root ユーザーが必須。

3. **層1で stow を apt で入れない。** `stow` は Brewfile.common 由来。
   `install-container.sh` の `run_brew_bundle` → その後 `stow` の順なので、
   Dockerfile が用意するのは Linuxbrew のビルド依存（build-essential / procps / file /
   curl / git / ca-certificates）まで。

4. **層2の devup が検証するのは「push 済み」の dotfiles。**
   `devup` は git リポジトリを clone するため、ローカルの未コミット変更は層2では反映されない。
   リポジトリは `_build_dotfiles_opts` ヘルパで一元生成され、上書き優先度は
   **第2引数 `[repo]` > 環境変数 `DOTFILES_REPO` > 既定の GitHub URL**（`zsh/.zshrc`）。
   ローカルの未コミット変更を試すなら層1（`./docker/test.sh`）を使う。

5. **層2は docker-in-docker (DinD) を使う。**
   devup は内部で `devcontainer up`（= 子 DevContainer 起動）を呼ぶ。DinD なら
   ネストした daemon 上に子コンテナが立ち、ホスト/コンテナ間のパス整合問題が起きない。
   docker-outside-of-docker に変更すると、子コンテナのバインドマウントがズレる。

6. **層2は node feature を外さない。** node（npm）が無いと `@devcontainers/cli` を
   入れられず、devup 関数自体が `command -v devcontainer` ガードで未定義になる。

---

## 使い方

```bash
# 層1
./docker/test.sh                      # ubuntu 24.04 で build & 検証
UBUNTU_VERSION=22.04 ./docker/test.sh
docker run --rm -it dotfiles-verify:ubuntu zsh   # 手で中を確認

# 層2
devcontainer up --workspace-folder .             # または VSCode「Reopen in Container」
devcontainer exec --workspace-folder . zsh
#   → コンテナ内で:  devup ./docker/test-workspace
```

詳しい背景と軽量化メモは [README.md](README.md) を参照。
