# scripts/ — CLAUDE.md

インストールスクリプトの共有ユーティリティ。

---

## ファイル構成

```
scripts/
├── lib.sh          # 共有ユーティリティ（install.sh / install-container.sh が source）
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
run_brew_bundle "Brewfile.container"  # コンテナ: common + Brewfile.container
run_brew_bundle                       # 引数省略: common のみ
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

### `link_config_entries(include_tmux?)`

`.config` 配下のエントリをまとめてリンクする。

```bash
link_config_entries        # ホスト: tmux を含む（デフォルト true）
link_config_entries "false"  # コンテナ: tmux を含まない
```

リンク対象:
- `starship/.config/starship.toml` → `~/.config/starship.toml`
- `starship/.config/tmuxinator`   → `~/.config/tmuxinator`
- `nvim/.config/nvim`             → `~/.config/nvim`
- `lazygit/.config/lazygit`       → `~/.config/lazygit`
- `lazygit/.config/mise`          → `~/.config/mise`
- `tmux/.config/tmux`             → `~/.config/tmux`（include_tmux=true のみ）

### `install_ni()`

`@antfu/ni` をグローバルインストール。`npm` が PATH になければ何もしない。
**node が確立した後（mise activate または volta PATH 設定後）に呼ぶこと。**

---

## install.sh と install-container.sh の差分

| 処理 | install.sh | install-container.sh |
|------|:----------:|:--------------------:|
| Docker セットアップ | ✅ | ❌ |
| mise グローバル runtime | ✅ | ❌ |
| TPM (tmux plugin) | ✅ | ❌ |
| VS Code リンク | ✅ | ❌ |
| Ghostty リンク | ✅ | ❌ |
| `link_config_entries` | `"true"` (tmux含む) | `"false"` |
| `backup_if_exists` | シンプル版 | bind mount 検出あり |
| `install_git_config` | なし（stow） | あり（cp、bind mount考慮） |
| `Brewfile` | `common + Brewfile` | `common + Brewfile.container` |
| win32yank | WSL のみ | ❌ |

---

## check-stow.sh

- `~/.config` が単一 symlink になっていないかを確認
- nvim / lazygit / starship / tmux のリンク先が正しいかを確認
- 入れ子 symlink の誤生成を検出

インストール後の検証や問題調査に使う診断ツール。install.sh からは呼ばれない。
