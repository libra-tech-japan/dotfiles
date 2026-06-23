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
3. dotfiles self-heal（コンテナ・対話のみ。~/.config/nvim の symlink 欠落時だけ
   install.sh --container --relink で高速再リンク。非対話ガードの後・starship 初期化の前）
4. Runtime Strategy（Volta / Mise / Container 判定）
5. PATH 操作ユーティリティ関数
6. mise activate / container strategy 適用
7. npm global PATH 追加
8. starship / zoxide 初期化
9. エイリアス（ツール置き換え: ls→eza, cat→bat, grep→rg, vim→nvim）
10. エイリアス（Git / Lazygit / Claude Code / Docker）
11. 関数定義（devup / t / tb / dev-start 等）
12. キーバインド（bindkey -e は ここ — ツール初期化より後に設定して上書きを防ぐ）
13. ~/.zshrc-local の読み込み
```

self-heal は**非対話ガードより後**に置く（AI / CI では走らせない）。starship 初期化より前に置くのは、
復元した `~/.config/starship.toml` をその起動で使えるようにするため。`DOTFILES_NO_SELF_HEAL=1` で無効化。
初回展開（clone + フル install）は `scripts/container-bootstrap.sh` を使う（self-heal は復旧専用）。

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
| `devup [dir] [repo]` | dotfiles 注入付きで DevContainer を起動 |
| `devbuild [dir]` | イメージビルドのみ（dotfiles 注入は up 時） |
| `devrebuild [dir] [repo]` | 既存コンテナ削除 + up |
| `devdotfiles [dir]` | コンテナ内で `git pull && ./install.sh` |
| `devsh [dir]` | コンテナ内の zsh/bash に入る |

dotfiles リポジトリ URL は `_build_dotfiles_opts` ヘルパで一元生成される
（`--dotfiles-*` オプションの唯一の組み立て点。`devup` / `devrebuild` が共用）。

リポジトリの上書き優先度は **引数 `[repo]` > 環境変数 `DOTFILES_REPO` > 既定の GitHub URL**。
既定値そのものを変える場合は `: ${DOTFILES_REPO:=...}` の行を編集する。

```zsh
devup .                                  # 既定リポジトリ
devup . https://github.com/me/fork       # 第2引数で上書き
DOTFILES_REPO=https://github.com/me/fork devup .   # 環境変数で上書き
```

注: `devup` は git リポジトリを clone するため、検証されるのは push 済みの状態。
ローカルの未コミット変更を試すなら `docker/` の層1検証（`./docker/test.sh`）を使う。

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

## starship のホスト/コンテナ色分け

ホストとコンテナで**表示要素は共通・色だけ変える**。実体は starship のパレット機能。

```
starship/.config/starship.toml
  palette = 'tokyo'        ← ホスト既定（既存の配色）
  [palettes.tokyo]         ← 色名 → hex（ホスト）
  [palettes.green]         ← 色名 → hex（コンテナ・緑系）
  format / 各モジュールは色を「名前」で参照（hex 直書きしない）
```

コンテナ内では `.zshrc` の starship 初期化が、`~/.config/starship.toml` の
`palette` 行だけを `green` に差し替えた派生ファイルを
`${XDG_CACHE_HOME}/starship/container.toml` に生成し、`STARSHIP_CONFIG` で指す。
ソースは単一（重複なし）。元ファイルが新しければ `-nt` 判定で自動再生成される。

**不変条件:**
- format / モジュールの色は**必ずパレット色名**で書く（hex 直書きすると green に追従しない）
- 2つのパレットは**同じ色名キー集合**を持つ（一方に増やしたら他方にも追加）
- `palette = '...'` は行頭に置く（zsh の sed 差し替えが `^palette = ` を前提にしている）
- powerline グリフ（U+E0B4 等の不可視文字）を含む行は**打ち直さず**機械置換で編集する

---

## 拡張ポイント

- マシン固有の設定: `~/.zshrc-local`（git 管理外）
- EC2 開発機のタグ名変更: `WORK_DEV_MACHINE_TAG` を `.zshrc-local` で上書き
- 新しいツールの初期化追加: セクション 3（ツール初期化）の末尾へ追加
- 新しいエイリアス: 用途に応じてセクション 5 または 6 へ追加
