# zsh/ — CLAUDE.md

`.zshrc` のランタイム戦略とプラットフォーム分岐は、読み解かずに編集すると
コンテナ内の node/python が壊れる。このファイルで構造と不変条件を説明する。

---

## ファイル構成

```
zsh/
├── .zshrc       # メイン設定（Stow で ~/.zshrc にリンク）
└── .zshenv      # 環境変数・Homebrew PATH（Stow で ~/.zshenv にリンク）
```

`.zshrc-local` は git 管理外。マシン固有のオーバーライドに使う（末尾で source される）。

---

## .zshrc の読み込み順序（順番を変えてはいけない）

```
1. 非対話ガード（AI / CI / dumb 端末では即 return）
2. 履歴・補完設定
3. Runtime Strategy（Volta / Mise / Container 判定）
4. PATH 操作ユーティリティ関数
5. mise activate / container strategy 適用
6. npm global PATH 追加
7. starship / zoxide 初期化
8. エイリアス（ツール置き換え: ls→eza, cat→bat, grep→rg, vim→nvim）
9. エイリアス（Git / Lazygit / Claude Code / Docker）
10. 関数定義（devup / t / tb / dev-start 等）
11. キーバインド（bindkey -e は ここ — ツール初期化より後に設定して上書きを防ぐ）
12. ~/.zshrc-local の読み込み
```

**キーバインドをツール初期化より前に移動しない。** starship/zoxide が bindkey を上書きする場合がある。

---

## Runtime Strategy（最重要）

3つの戦略が環境に応じて切り替わる。制御変数は `MISE_DISABLE_TOOLS`。

### 優先順位

```
Volta がある（クライアント環境）
  └→ node 管理を Volta に委譲。MISE_DISABLE_TOOLS="node"
     mise は Python 等のために起動

Volta がない（ホスト Mac / EC2）
  └→ mise がすべてを管理（デフォルト）

DevContainer 内（.dockerenv または $REMOTE_CONTAINERS がある）
  └→ _apply_mise_container_strategy が制御
     mise.toml あり → コンテナの node/python を使う（MISE_DISABLE_TOOLS unset）
     mise.toml なし → MISE_DISABLE_TOOLS="node,python"（Linuxbrew の node が勝つ）
```

### コンテナ検出

```zsh
[[ -n "$REMOTE_CONTAINERS" ]] || [[ -f "/.dockerenv" ]]
```

両方チェックする理由:
- `$REMOTE_CONTAINERS` は VS Code DevContainer が設定する
- `/.dockerenv` は Docker が作る（SSH でコンテナに入る場合も検出できる）

### `_apply_mise_container_strategy` の動作

```
コンテナ外 → 即 return（何もしない）
コンテナ内:
  カレント/親ディレクトリに mise.toml あり
    → MISE_DISABLE_TOOLS を unset → mise が node/python を管理
    → _prepend_mise_tool_bin_to_path で mise の bin を PATH 先頭へ
  mise.toml なし
    → MISE_DISABLE_TOOLS="node,python" → Linuxbrew の node/python を使う
    → Linuxbrew bin を PATH 先頭へ
```

この関数は `chpwd_functions` に登録されているため `cd` のたびに実行される。
**ディレクトリ移動で runtime が切り替わる**のが意図された動作。

### PATH 操作の契約

```
_prepend_path_dir(dir)         — 重複除去してから先頭に追加
_prepend_mise_tool_bin_to_path(tool) — MISE_DISABLE_TOOLS に含まれていれば何もしない
_linuxbrew_bin_dir()           — /home/linuxbrew or $HOME/.linuxbrew を返す
```

---

## .zshenv の役割

`.zshenv` は **すべてのシェル（非対話含む）** で読まれる。

```zsh
XDG_CONFIG_HOME, XDG_DATA_HOME, XDG_CACHE_HOME を設定
EDITOR=nvim
Homebrew の PATH を設定（Darwin: /opt/homebrew / Linux: /home/linuxbrew）
```

**副作用のあるコマンド（mise activate 等）を .zshenv に書いてはいけない。**
非対話シェル（スクリプト、CI）まで汚染される。

---

## DevContainer 関数（devcontainer コマンドがある環境のみ定義）

| 関数 | 役割 |
|------|------|
| `devup [dir]` | dotfiles 注入付きで DevContainer を起動 |
| `devbuild [dir]` | イメージビルドのみ（dotfiles 注入は up 時） |
| `devrebuild [dir]` | 既存コンテナ削除 + up |
| `devdotfiles [dir]` | コンテナ内で `git pull && ./install.sh` |
| `devsh [dir]` | コンテナ内の zsh/bash に入る |

dotfiles リポジトリ URL は `devcontainer_dotfiles_opts` 配列で一元管理されている。
URL を変更する場合は配列の値を変更する（`devup` / `devrebuild` の引数を個別に変えない）。

---

## エイリアス設計の契約

ツール置き換えエイリアスはすべて `command -v` でガードしている。
ツールがない環境でエラーにならないための設計。**ガードを外さない。**

```zsh
if command -v eza &> /dev/null; then
  alias ls='eza'
fi
```

---

## 拡張ポイント

- マシン固有の設定: `~/.zshrc-local`（git 管理外）
- EC2 開発機のタグ名変更: `WORK_DEV_MACHINE_TAG` を `.zshrc-local` で上書き
- 新しいツールの初期化追加: セクション 3（ツール初期化）の末尾へ追加
- 新しいエイリアス: 用途に応じてセクション 5 または 6 へ追加
