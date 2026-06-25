# dotfiles — CLAUDE.md

このリポジトリは Mac (Apple Silicon) / Linux (Ubuntu/EC2) / Windows (WSL2) とその中の DevContainer で
開発環境を統一する個人用 dotfiles です。

---

## 目的と基本方針

- **ホスト OS 単体でも開発できる**（DevContainer 必須にしない）
- **DevContainer 内でも zsh / Neovim の操作感を統一**
- **node / python のランタイムはコンテナ管理に委ねる**（ホストの mise で上書きしない）
- **ni (`@antfu/ni`) を常用**してパッケージマネージャの差分を吸収

### 想定する使い分け（host / container の用途）

この dotfiles は 2 つの用途を持ち、提供するものの性質が異なる。新しいツールの置き場やコンテナへ
入れるか否かを判断するときは、まずどちらの用途かを意識する（具体的な置き場ルールは下記「責任分解」）。

- **ホスト（`install.sh`）= プロジェクトを立てるまでもない開発者機能**:
  EC2 サーバーホストの運用・操作、macOS / WSL2 での日常のちょっとした開発・検証など、
  専用プロジェクト（プロジェクト Docker / DevContainer）を作らない範囲の作業を成立させる。
  ここには de-facto 標準ベースライン（git/curl/wget/unzip/git-secrets/**gh** 等）も含める
  ＝ホスト OS では dotfiles がベースライン提供責任を負う（コンテナではプロジェクト Docker が負う・後述）。
- **コンテナ（`install-container.sh` → `install.sh --container`）= プロジェクト内でも生産性を上げる個人ツール集**:
  プロジェクトの Docker イメージが用意するチーム共通ベースラインの**上に**、個人が慣れた操作感
  （zsh / Neovim / lazygit / bat / eza / starship 等）を重ねるためのもの。

- **非強制の原則**: 個人ツールは見た目・使い方・習熟が要るため、**プロジェクト／チームには強制しない**。
  プロジェクトの Docker イメージはチーム共通の最小ベースライン（OS lib・de-facto 標準・プロジェクト必須 CLI）
  だけを担い、個人の操作感は各自の dotfiles が bind mount で持ち込む。この非対称（チーム=最小共通 /
  個人=上乗せ）が、二重管理を避けつつ各自の生産性を保つための契約。

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
  Tier C: ni (@antfu/ni)
          → mise 環境: global mise 設定の "npm:@antfu/ni"（npm backend）で宣言。
            node 版非依存の shim になり MISE_DISABLE_TOOLS 下/別 node のディレクトリでも使える。
          → mise の無い環境: npm -g @antfu/ni でフォールバック（node 確立後）

Layer 3 — Runtime Layer（ホストのみ）
  mise: node LTS, python 3.12
  → コンテナ内では MISE_DISABLE_TOOLS="node,python" が自動設定される
```

---

## プラットフォームマトリクス

| 機能                      |       macOS        |      Linux/EC2       |      WSL2      | DevContainer |
| ------------------------- | :----------------: | :------------------: | :------------: | :----------: |
| Homebrew                  | ✅ `/opt/homebrew` | ✅ `/home/linuxbrew` |  ✅ Linuxbrew  | ✅ Linuxbrew |
| apt ripgrep/fd            |         —          |          ✅          |       ✅       |      ✅      |
| mise (runtime)            |         ✅         |          ✅          |       ✅       | ❌ (無効化)  |
| tmux / TPM                |         ✅         |          ✅          |       ✅       |      ❌      |
| OrbStack / Docker Desktop |         ✅         |          —           |       —        |      —       |
| VS Code リンク            |         ✅         |          —           | ✅ (Windows側) |      —       |
| Ghostty                   |         ✅         |          —           |       —        |      —       |
| win32yank                 |         —          |          —           |       ✅       |      —       |

---

## ファイルマップ（責務）

```
install.sh              # 統合オーケストレータ（host / container 共通・--container で分岐）
install-container.sh    # コンテナ用エントリ（薄い shim → install.sh --container）
scripts/lib.sh          # 共有ユーティリティ（install.sh から source）
Brewfile.common         # ホスト・コンテナ共通の個人ツール（stow + nvim 等）。de-facto 標準は置かない
Brewfile                # ホスト専用（common と結合）。de-facto 標準ベースライン + host-only ツール
zsh/                    # zsh 設定（Stow で ~/配下にリンク）
nvim/                   # Neovim 設定（手動リンク ~/.config/nvim へ）
git/                    # gitconfig（Stow で ~/配下にリンク・name/email は持たない）
.gitconfig.local.example # Git identity テンプレ（install.sh が ~/.gitconfig.local 無ければコピー）
claude/                 # ~/.claude の共有設定（Stow --no-folding・認証情報/履歴は除外）
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

通常リンクは `git/` と `zsh/` のみ（汎用 STOW_DIRS ループ）。それ以外の `.config` 配下は手動 symlink。
`claude/` は **`--no-folding` 付きの専用ステップ**で別扱い（後述）。
container（`install.sh --container`）は `zsh/` のみ stow し、`git/` は stow せず `install_git_config`
（lib.sh）で `~/.gitconfig` を実ファイルとして配置する（bind mount 競合回避・`.gitconfig.local` 連携）。

```
理由: stow <パッケージ> を実行すると ~/.config 全体が
      <パッケージ>/.config へのリンクになるケースがある。
      それを防ぐため .config 配下は link_config_dir() / link_config_file() で個別リンク。
```

### パッケージ直下の CLAUDE.md を $HOME へ漏らさない

stow はパッケージ直下のファイルを**すべて** `$HOME` へリンクする。`zsh/CLAUDE.md` のような
ドキュメントもそのままでは `~/CLAUDE.md` として展開されてしまう（stow の組み込み除外は
README/LICENSE/.gitignore 等のみで CLAUDE.md を含まない）。

これを防ぐため、リンクする stow 呼び出し（`--restow`）はすべて `lib.sh` の
`STOW_IGNORE_OPTS`（`--ignore='CLAUDE\.md'` `--ignore='\.DS_Store'`）を渡す。
`--ignore` は加算式なので stow 組み込みの除外も維持される。

```
- 除外パターンの単一真実源は lib.sh の STOW_IGNORE_OPTS。install.sh の host / container 両経路の
  全 --restow 呼び出しが共有する。新しい「漏らしたくないファイル名」はここに1パターン足す。
- stow が読む .stow-local-ignore は $STOW_DIR/<package>/ 直下 か ~/.stow-global-ignore のみ。
  リポジトリ root に .stow-local-ignore を置いても読まれない（過去にそれで CLAUDE.md が漏れた）。
```

### claude/（~/.claude）の特例

`~/.claude` は **共有設定（settings.json 等）と認証情報・履歴などの実行時データが同居**する混在ディレクトリ。
`.config` と同じ folding 危険があるため、汎用ループには入れず専用ステップで扱う。

```
- stow -t "$HOME" --no-folding --restow claude で個別ファイルだけリンク
  （~/.claude 自体は実ディレクトリのまま。新規マシンでも symlink に畳まれない）
- 汎用 STOW_DIRS には絶対に入れない
  （最上位 .claude を backup_if_exists が見て ~/.claude を認証情報ごと退避するため）
- 共有するのは settings.json / CLAUDE.md / commands/ / agents/ / skills/ のみ。
  .credentials.json・projects/・history.jsonl・sessions/・settings.local.json 等は
  claude/.claude/.gitignore のホワイトリストで除外（repo に入れない）
```

**やってはいけないこと:**

- `stow nvim` や `stow starship` を直接実行しない
- `~/.config` 自体をシンボリックリンクにしない
- `claude/` を汎用 STOW_DIRS に追加する / `~/.claude` 自体を symlink にする
- `check-stow.sh` が警告を出す構造を作らない
- stow の `-t "$HOME"` を外さない（install.sh の host / container 両経路で共通）
- `install-container.sh` に install ロジックを書き戻さない（薄い shim のまま・真実源は install.sh）

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
  de-facto 標準（git/curl/wget/unzip 等）→ Brewfile（host-only）。コンテナ側は入れない（下記 責任分解）
  VSCode 拡張が使う（rg, fd 相当）→ apt + brew の両方
  CLI ツール（最新版が必要）       → Homebrew (Brewfile.common か Brewfile)
  ホスト・コンテナ共通の個人ツール  → Brewfile.common（nvim 等の個人嗜好 + 機構の stow）
  ホストのみ必要                   → Brewfile
  node/python パッケージ           → ni install または npm -g（runtime 確立後）
```

### 責任分解：de-facto 標準はプラットフォーム層の責務（BHD-205）

dotfiles は **「プラットフォーム層が de-facto 標準ベースラインを提供する」** ことを前提に、その上へ
個人ツールだけを重ねる。重複（同じツールを 2 箇所で導入）とバージョンドリフトを避けるための契約。

```
プラットフォーム層（ベースライン提供責任）:
  - ホスト OS（install.sh）→ Brewfile（host-only）で git/curl/wget/unzip/git-secrets を導入
  - コンテナ → そのコンテナを提供するプロジェクトの Docker イメージが apt 等で用意する
              （例: bihada-connect docker/Dockerfile が curl/wget/git/unzip を apt 導入）

dotfiles 層（個人ツールのみ）:
  - Brewfile.common = stow（機構）+ コンテナにも欲しい個人 CLI（nvim/lazygit/bat/eza/starship 等）
  - git/curl/wget/unzip は Brewfile.common に置かない（install.sh 自身の前提ツールでもあり冗長）
```

- 前提: `install.sh` が走る時点で git/curl は既に存在する必要がある（clone・brew 取得に使う）。
  よって de-facto 標準を Brewfile.common に書くのは循環・冗長であり、ホスト用 Brewfile に集約する。
- コンテナ側でこれらが要る場合は、そのコンテナイメージ（プロジェクト Docker）が用意する。dotfiles は
  コンテナへ de-facto 標準を入れ直さない。

---

## 変更時の不変条件

1. `install.sh` は macOS でも実行できること（IS_DARWIN → CONTEXT=host-darwin）
2. `install.sh --container`（= install-container.sh shim）は sudo なし・apt なし環境でも最低限動くこと
3. `scripts/lib.sh` は `source` 専用。直接実行されることを想定しない
4. `DOTFILES_ROOT` は lib.sh を source する前に設定すること
5. Brewfile に Brewfile.common の内容を重複して書かない
6. `zsh/.zshrc` の非対話ガード（先頭の `[[ $- != *i* ]]`）は削除しない
7. `install-container.sh` は薄い shim に保つ。インストールロジックは install.sh に集約（真実源は1つ）

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
