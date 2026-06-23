# docker/ — 検証環境

dotfiles のインストールフローを破壊せずに検証するためのサンドボックス。
検証は責務で2層に分かれる。**混ぜないこと。**

```
層1: install-container.sh 単体が通るか
     → 素の docker build（Docker デーモンへのアクセス不要・速い）
     → docker/Dockerfile.ubuntu + docker/test.sh

層2: devup フロー全体（devcontainer up + dotfiles 注入 + install）が通るか
     → 軽量 DevContainer の中から devup を実行（DinD でネストした daemon を使う）
     → .devcontainer/devcontainer.json + docker/test-workspace/
```

---

## 層1: install-container.sh の単体検証

`install-container.sh` は `exec install.sh --container` の薄い shim。よって層1は実体である
**install.sh の container 経路**を検証する（テスト手順・コマンドは従来どおり変更なし）。

```bash
./docker/test.sh                  # ubuntu 24.04 で build & 検証
UBUNTU_VERSION=22.04 ./docker/test.sh
```

`test.sh` がやること:

1. `Dockerfile.ubuntu` をビルド（build 中に `install-container.sh` を**2回**実行 = クリーン + 冪等性）
2. 出来たイメージで `scripts/check-stow.sh` を実行し、Stow / `.config` リンクの健全性を確認

手で中を触る場合:

```bash
docker run --rm -it dotfiles-verify:ubuntu zsh
```

`Dockerfile.ubuntu.dockerignore` でビルドコンテキストから `.git` 等を除外している。

---

## 層2: devup フロー全体の検証

リポジトリ直下の [.devcontainer/devcontainer.json](../.devcontainer/devcontainer.json) が
**軽量な検証用 DevContainer**。docker-in-docker (DinD) と devcontainer CLI を備える。

### 起動

- VSCode: コマンドパレット → 「Dev Containers: Reopen in Container」
- CLI:

  ```bash
  devcontainer up --workspace-folder .
  devcontainer exec --workspace-folder . zsh
  ```

### コンテナの中で devup を実行

```bash
devup ./docker/test-workspace
```

これで [docker/test-workspace/.devcontainer](test-workspace/.devcontainer/devcontainer.json)
を対象に子 DevContainer が起動し、dotfiles 注入 → `install-container.sh` まで走る。
DinD なのでネストした daemon 上にコンテナが立ち、パス整合の問題は起きない。

### ⚠️ devup が検証するのは「push 済み」の dotfiles

`devup` のオプションは GitHub URL をハードコードしている
（[zsh/.zshrc](../zsh/.zshrc) の `devcontainer_dotfiles_opts`）。
つまり **devup で検証されるのはリモートに push 済みの dotfiles であり、
ローカルの作業中（未コミット）の変更ではない。**

- ローカルの変更をそのまま試す → 層1（`./docker/test.sh`）を使う
- push 後の devup 統合を確認する → 層2を使う
- 別リポジトリ/フォークを devup で試したい → 第2引数か `DOTFILES_REPO` で上書きする

  ```bash
  devup ./docker/test-workspace https://github.com/me/fork
  DOTFILES_REPO=https://github.com/me/fork devup ./docker/test-workspace
  ```

### 軽量化メモ

`.devcontainer` の `postCreateCommand` は `install-container.sh`（Linuxbrew + brew bundle）を
含むため初回作成に数分かかる。**devup の起動確認だけ**が目的なら、
`postCreateCommand` を「devcontainer CLI 導入 + zsh のリンクのみ」に差し替えると速くなる。
ここでは production の DevContainer 挙動に忠実な構成（install-container.sh をそのまま実行）を既定にしている。
