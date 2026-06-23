# scripts/ — CLAUDE.md

インストールスクリプトの共有ユーティリティ。

---

## ファイル構成

```
scripts/
├── lib.sh          # 共有ユーティリティ（install.sh が source。install-container.sh は install.sh の shim）
└── check-stow.sh   # Stow リンク状態の確認ツール（診断用、インストールには不使用）
```

---

## lib.sh の使い方

**直接実行しない。必ず `source` すること。**

```bash
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${DOTFILES_ROOT}/scripts/lib.sh"
```

`DOTFILES_ROOT` が未設定だと lib.sh 内の全パス参照が壊れる。
source する前に必ず設定すること。

lib.sh はトップレベルで副作用を持たない（定数・配列・関数定義のみ）。
そのため `check-stow.sh` のような診断スクリプトからも安全に source できる。

---

## 定数・配列（単一真実源）

### `CONFIG_ENTRIES`

`.config` 配下のリンク対象を定義する**唯一の場所**。`link_config_entries`（リンク実行）と
`check-stow.sh`（リンク状態・入れ子検出）の両方がここから導出する。
**新しい設定ツールを追加するときはこの配列に1行足すだけでよい。**

```
format: "src(DOTFILES_ROOT相対):dest($HOME相対):type(file|dir):scope(all|host|darwin)"
  scope: all    = 常時（ホスト・コンテナ共通）
         host   = container 以外（tmux / tmuxinator）
         darwin = host-darwin のみ（ghostty）
```

### `STOW_LEGACY_UNSTOW`

旧構造（`stow starship/lazygit/nvim`）の名残リンクを剥がす `stow -D` 対象の配列。
install.sh の host / container 両経路で共有する。

### URL 定数

`HOMEBREW_INSTALL_URL` / `DOCKER_INSTALL_URL` / `TPM_REPO_URL` /
`WIN32YANK_VERSION` / `WIN32YANK_URL` を一元管理。スクリプト側にハードコードしない。

---

## 関数一覧と契約

### `install_apt_vscode_tools()`

VSCode の extension host が `/usr/bin/rg` と `/usr/bin/fd` を期待するため、
Homebrew に加えて apt でも ripgrep / fd-find をインストールする。

```
- apt-get がなければ（macOS等）即 return（エラーにしない）
- sudo がなければ即 return
- apt の fd は fdfind として入るため /usr/local/bin/fd へ symlink を作成
- apt install が失敗してもスクリプトは継続（|| true）
```

**apt + brew の二重インストールは意図的。** brew 版が zsh では PATH 優先で使われ、
VSCode には apt 版の `/usr/bin/rg` が見える。

### `run_brew_bundle(specific?)`

`Brewfile.common` と引数で指定した環境固有ファイルを `/tmp` に結合し、
`brew bundle` を実行する。

```bash
run_brew_bundle "Brewfile"            # ホスト: common + Brewfile
run_brew_bundle                       # コンテナ（引数省略）: common のみ
```

- `brew` が PATH にない状態で呼ぶと失敗する。Homebrew セットアップ後に呼ぶこと。
- 一時ファイルは処理後に削除される。
- 戻り値: `brew bundle` の exit code をそのまま返す。

### `repair_config_dir()`

`~/.config` が `starship/.config` へのシンボリックリンクになっている壊れた状態を修復。
旧バージョンの install.sh で発生した問題への対処。現在は発生しないが冪等性のため維持。

### `clean_nested_config_symlink(config_dir)`

`ln -sf` の誤用で `<config_dir>/<basename>` という入れ子シンボリックリンクが作られた場合に削除。
`link_config_dir` の中で自動的に呼ばれる。直接呼ぶ必要はない。

### `link_config_dir(src, dest)` / `link_config_file(src, dest)`

```bash
link_config_dir  "$DOTFILES_ROOT/nvim/.config/nvim"     "$HOME/.config/nvim"
link_config_file "$DOTFILES_ROOT/starship/.config/starship.toml" "$HOME/.config/starship.toml"
```

- `link_config_dir`: ディレクトリを `-sfn` でリンク（clean_nested チェック付き）
- `link_config_file`: ファイルを `-sf` でリンク
- いずれも `mkdir -p "$(dirname "$dest")"` を先に実行する

### `link_config_entries(context?)`

`CONFIG_ENTRIES` をループし、`context` の scope に該当するエントリをリンクする。
リンク対象は `CONFIG_ENTRIES`（上記）が単一の真実源。

```bash
link_config_entries host-darwin  # macOS ホスト: all + host + darwin（ghostty 含む）
link_config_entries host         # macOS 以外のホスト: all + host（tmux/tmuxinator 含む）
link_config_entries container    # コンテナ: all のみ（tmux/tmuxinator/ghostty 除外）
```

- 引数省略時のデフォルトは `host`。
- 補助関数 `config_entry_in_scope(scope, context)` が scope 判定を行う。
- file 型は `link_config_file`、dir 型は `link_config_dir` を再利用。

### `link_vscode_config(user_dir)`

VS Code の User ディレクトリへ settings / keybindings / snippets をリンクし、
`vscode/extensions.txt` があれば拡張をインストールする。Darwin / WSL で共有。

```bash
link_vscode_config "$HOME/Library/Application Support/Code/User"   # macOS
link_vscode_config "$(wslpath -u "$WIN_APPDATA")/Code/User"        # WSL
```

- `user_dir` が存在しなければ何もせず戻り値 1（呼び出し側でスキップ判定に使う）。
- `code` が PATH になければ拡張インストールはスキップ。

### `is_file_bind_mount(target)`

`target` が**ファイル単体の bind マウント**かを `/proc/self/mountinfo` で判定。
DevContainer ではホストの `~/.gitconfig` 等が bind mount されることがあり、それを置換しないために使う。

- `findmnt -T` は ext4 上の通常ファイルでも真になるため使わない。
- host では該当が無く即 false（安価な no-op）。

### `backup_if_exists(target)`

既存の実ファイル/ディレクトリが stow/リンクの邪魔になる場合に `*.backup.<timestamp>` へ退避する。
**host / container 共通の唯一の実装**（以前は両スクリプトに別実装があったのを統合）。

- bind mount（`is_file_bind_mount`）はスキップ（置換不能）。
- `mv` 失敗時も `return 0` で続行（マウント/使用中ファイルで止めない）。
- host では bind mount が無いので従来のシンプル退避と同じ挙動になる。

### `install_git_config()`

**container でのみ呼ぶ。** `git/.gitconfig` テンプレートを `~/.gitconfig` へ**実ファイルとして cp**する
（host は git/ を stow するため呼ばない）。

- `~/.gitconfig` が bind mount なら何もしない。
- 旧 stow 管理の名残 symlink（`… git/.gitconfig` 指し）と dangling link は除去して実ファイル管理へ寄せる。
- 既存の非空ファイルは上書きしない（冪等）。

### `install_ni()`

`@antfu/ni` をインストール。`ni` が既にあれば skip。
- **mise がある環境**: `mise install npm:@antfu/ni@latest`（npm backend）で入れる。
  global mise 設定の `"npm:@antfu/ni"` 宣言とあわせ、node 版非依存の shim になる。
- **mise の無い環境**（base image / node feature の node）: `npm -g @antfu/ni` でフォールバック。
- どちらも無ければ何もしない。

**node が確立した後（mise activate または volta PATH 設定後）に呼ぶこと。**

---

## install.sh の host / container 分岐

install.sh は `CONTEXT`（`host` / `host-darwin` / `container`）で分岐する単一スクリプト。
`install-container.sh` は `exec install.sh --container` の薄い shim。各ステップの差分:

| 処理 | host / host-darwin | container（`--container`） |
|------|:----------:|:--------------------:|
| 実行ロック / `.DS_Store` 掃除 | ✅ | ❌ |
| Docker セットアップ | ✅（Ubuntu） | ❌ |
| mise グローバル runtime | ✅ | ❌ |
| TPM (tmux plugin) | ✅ | ❌ |
| VS Code リンク | ✅（Darwin/WSL） | ❌ |
| Ghostty リンク | ✅（darwin scope） | ❌ |
| `link_config_entries` | `host-darwin` / `host` | `container` |
| tmuxinator リンク | ✅（host scope） | ❌ |
| git 設定 | `git/` を stow + `.gitconfig.local` テンプレ | `install_git_config`（cp 実ファイル） |
| `claude/` stow | ✅（`--no-folding`） | ❌ |
| `Brewfile` | `common + Brewfile` | `common` のみ |
| win32yank | WSL のみ | ❌ |

`backup_if_exists` / `is_file_bind_mount` / `install_git_config` は lib.sh に集約され host/container 共通
（bind mount 対応版に一本化）。

---

## check-stow.sh

- lib.sh を source し、`CONFIG_ENTRIES` からリンク対象・入れ子検出リストを導出（ハードコードしない）
- `~/.config` が単一 symlink になっていないかを確認
- `CONFIG_ENTRIES` の各 dest のリンク先が正しいかを確認
- 入れ子 symlink の誤生成を検出

インストール後の検証や問題調査に使う診断ツール。install.sh からは呼ばれない。
ホスト前提の診断のため、コンテナで実行すると host/darwin scope のエントリ
（tmuxinator / tmux / ghostty）は `(なし)` と表示される（正常）。
