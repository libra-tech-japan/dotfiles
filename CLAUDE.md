# dotfiles — CLAUDE.md

このリポジトリは Mac (Apple Silicon) / Linux (Ubuntu/EC2) / Windows (WSL2) とその中の DevContainer で
開発環境を統一する個人用 dotfiles です。

---

## 目的と基本方針

- **ホスト OS 単体でも開発できる**（DevContainer 必須にしない）
- **DevContainer 内でも zsh / Neovim の操作感を統一**
- **node / python のランタイムはコンテナ管理に委ねる**（ホストの mise で上書きしない）
- **ni (`@antfu/ni`) を常用**してパッケージマネージャの差分を吸収

---

## レイヤー構成

```
Layer 1 — Shell Layer（全環境共通）
  zsh, neovim, git, starship, lazygit
  tmux は ホストのみ（コンテナ不要）

Layer 2 — Package Layer（環境別ルール）
  Tier A: apt (system PATH /usr/bin)
          → ripgrep, fd-find
          → 理由: VSCode extension host が Homebrew の PATH を継承しないため
  Tier B: Homebrew (CLI 最新版)
          → neovim, lazygit, bat, eza, starship ...
          → brew 版が zsh セッションで PATH 優先になる
  Tier C: npm global (node 確立後)
          → @antfu/ni

Layer 3 — Runtime Layer（ホストのみ）
  mise: node LTS, python 3.12
  → コンテナ内では MISE_DISABLE_TOOLS="node,python" が自動設定される
```

---

## プラットフォームマトリクス

| 機能 | macOS | Linux/EC2 | WSL2 | DevContainer |
|------|:-----:|:---------:|:----:|:------------:|
| Homebrew | ✅ `/opt/homebrew` | ✅ `/home/linuxbrew` | ✅ Linuxbrew | ✅ Linuxbrew |
| apt ripgrep/fd | — | ✅ | ✅ | ✅ |
| mise (runtime) | ✅ | ✅ | ✅ | ❌ (無効化) |
| tmux / TPM | ✅ | ✅ | ✅ | ❌ |
| OrbStack / Docker Desktop | ✅ | — | — | — |
| VS Code リンク | ✅ | — | ✅ (Windows側) | — |
| Ghostty | ✅ | — | — | — |
| win32yank | — | — | ✅ | — |

---

## ファイルマップ（責務）

```
install.sh              # ホスト用オーケストレータ（全プラットフォーム）
install-container.sh    # DevContainer 用オーケストレータ（mise/tmux/VSCode 除外）
scripts/lib.sh          # 共有ユーティリティ（両 install から source）
Brewfile.common         # ホスト・コンテナ共通 Homebrew パッケージ
Brewfile                # ホスト専用 Homebrew パッケージ（common と結合して実行）
Brewfile.container      # コンテナ専用追加パッケージ（現在は空）
zsh/                    # zsh 設定（Stow で ~/配下にリンク）
nvim/                   # Neovim 設定（手動リンク ~/.config/nvim へ）
git/                    # gitconfig（Stow で ~/配下にリンク）
vscode/                 # VS Code settings / keybindings（手動リンク）
starship/               # starship.toml（手動リンク ~/.config/ へ）
tmuxinator/             # tmuxinator agent.yml（手動リンク ~/.config/tmuxinator へ・ホストのみ）
lazygit/                # lazygit config + mise config（手動リンク ~/.config/ へ）
tmux/                   # tmux.conf（手動リンク ~/.config/tmux へ）
ghostty/                # Ghostty config（手動リンク ~/.config/ghostty へ）
scripts/check-stow.sh   # Stow リンク状態の確認ツール
.devcontainer/          # 層2検証用の軽量 DevContainer（DinD + devcontainer CLI）
docker/                 # 検証環境（層1: install-container.sh 単体 / 層2: devup フロー）
```

---

## Stow 戦略（不変の契約）

`git/` と `zsh/` のみ Stow でリンク。それ以外の `.config` 配下は手動 symlink。

```
理由: stow <パッケージ> を実行すると ~/.config 全体が
      <パッケージ>/.config へのリンクになるケースがある。
      それを防ぐため .config 配下は link_config_dir() / link_config_file() で個別リンク。
```

**やってはいけないこと:**
- `stow nvim` や `stow starship` を直接実行しない
- `~/.config` 自体をシンボリックリンクにしない
- `check-stow.sh` が警告を出す構造を作らない
- stow の `-t "$HOME"` を外さない（install.sh / install-container.sh 共通）

```
stow は必ず -t "$HOME" でターゲットを明示する。
省略すると既定ターゲットが「リポジトリの親ディレクトリ」になり、
リポジトリが $HOME/dotfiles 以外（例: /workspaces/dotfiles）にあると
$HOME の外へリンクを書こうとして誤配置・Permission denied になる。
```

---

## パッケージ管理の判断基準

```
新しいツールを追加するとき:
  VSCode 拡張が使う（rg, fd 相当）→ apt + brew の両方
  CLI ツール（最新版が必要）       → Homebrew (Brewfile.common か Brewfile)
  ホストのみ必要                   → Brewfile
  コンテナのみ必要                 → Brewfile.container
  node/python パッケージ           → ni install または npm -g（runtime 確立後）
```

---

## 変更時の不変条件

1. `install.sh` は macOS でも実行できること（IS_DARWIN フラグを尊重）
2. `install-container.sh` は sudo なし・apt なし環境でも最低限動くこと
3. `scripts/lib.sh` は `source` 専用。直接実行されることを想定しない
4. `DOTFILES_ROOT` は lib.sh を source する前に設定すること
5. Brewfile と Brewfile.container に Brewfile.common の内容を重複して書かない
6. `zsh/.zshrc` の非対話ガード（先頭の `[[ $- != *i* ]]`）は削除しない

---

## 検証コマンド

### 静的チェック（高速・コミット前に常時）

```bash
# 構文チェック（3スクリプト）
bash -n install.sh && bash -n install-container.sh && bash -n scripts/lib.sh

# Stow / .config リンク状態の確認（診断ツール）
bash scripts/check-stow.sh
```

### 実機検証（冪等性は再実行で確認）

```bash
# ホスト（macOS）— 再実行して冪等性を確認
./install.sh

# 層1: install-container.sh 単体を Docker で検証（クリーン+冪等+リンク確認・デーモン不要）
./docker/test.sh

# 層2: devup フロー全体を DinD で検証
#   VSCode なら .devcontainer を「Reopen in Container」、CLI なら以下:
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . zsh -ic 'devup ./docker/test-workspace'
```

検証は2層に分かれる（層1=ローカル変更の高速検証 / 層2=push 済み devup の統合確認）。
2層の使い分け・落とし穴・軽量化メモは [docker/README.md](docker/README.md) と
[docker/CLAUDE.md](docker/CLAUDE.md) を参照。
