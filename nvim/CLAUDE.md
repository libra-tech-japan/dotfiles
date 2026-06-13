# nvim/ — CLAUDE.md

LazyVim をベースにした Neovim 設定。プラグインの追加・修正は特定のパターンに従う必要がある。

---

## ディレクトリ構成

```
nvim/.config/nvim/
├── init.lua                    # エントリポイント（Stow フォールバック + 読み込み順定義）
└── lua/
    ├── config/
    │   ├── lazy.lua            # Lazy.nvim セットアップ（LazyVim Extras の宣言）
    │   ├── options.lua         # vim.opt 設定
    │   ├── keymaps.lua         # カスタムキーマップ
    │   └── autocmds.lua        # AutoCommands
    └── plugins/
        ├── lsp.lua             # LSP 微調整（vtsls, volar）
        ├── conform.lua         # フォーマッタ設定（Biome / Prettier）
        └── migration.lua       # 非推奨プラグインの移行ブリッジ
```

`lua/config/` は設定のみ。プラグイン追加は `lua/plugins/` に新しいファイルを作る。

---

## 読み込み順序（init.lua が保証する）

```
1. ensure_config_rtp()  — Stow 未実施時に dotfiles を rtp に追加するフォールバック
2. config.options       — vim.opt（プラグインより先に適用）
3. config.keymaps       — キーマップ（プラグインの上書きを受けない位置）
4. config.autocmds      — AutoCommands
5. config.lazy → lazy.setup() — LazyVim + 公式 Extras + lua/plugins/ 以下
```

**この順を変えると LazyVim のデフォルトキーマップがカスタムキーマップを上書きする。**

---

## LazyVim Extras（lazy.lua）

有効にしている公式 Extras:

| Extra | 役割 |
|-------|------|
| `lang.typescript` | vtsls LSP, TypeScript 補完 |
| `lang.json` | JSON スキーマ補完 |
| `lang.vue` | Volar LSP, Vue SFC |
| `linting.eslint` | ESLint 連携 |
| `formatting.prettier` | Prettier フォーマッタ |

Extras の追加は `lazy.lua` の spec 配列に `{ import = "lazyvim.plugins.extras.XXX" }` を追記。
公式リストにない Extra を追加すると起動時エラーになる（`No specs found` になるケースがある）。

---

## フォーマッタ（conform.lua）の契約

**Smart Fallback: プロジェクトに biome.json があれば Biome、なければ Prettier。**

```
JS / TS / JSX / TSX:
  → biome.json または biome.jsonc がファイルの親方向に存在する → Biome
  → なければ → Prettier
  → stop_after_first = true（両方走らない）

Vue / CSS / SCSS / HTML / JSON / YAML / Markdown:
  → 常に Prettier
```

`condition` 関数で `vim.fs.find` を使い、プロジェクト単位で自動切り替えする。
**formatters_by_ft を直接上書きしない。** `vim.tbl_extend("force", opts.formatters_by_ft, {...})` で拡張すること。

---

## LSP 設定（lsp.lua）の契約

### vtsls（TypeScript）

- `autoUseWorkspaceTsdk = true` — プロジェクトの tsconfig を自動検出
- Inlay Hints 全種類を有効化（パラメータ名、型、戻り値型など）
- `update_in_insert = false` — 入力中に診断を更新しない（パフォーマンス）

### volar（Vue Hybrid Mode）

- `hybridMode = true` — TypeScript の処理を vtsls に委譲
- Hybrid Mode では **vtsls と volar を同時に起動する必要がある**
- volar を単独でフル TypeScript モードにしてはいけない（vtsls と競合する）

### LSP を追加するとき

`lsp.lua` の `servers` テーブルに追記。ただし LazyVim Extras で既に設定されているサーバ
（例: `tsserver` → Extras が `vtsls` に置き換え済み）を重複定義しない。

---

## カスタムキーマップ（keymaps.lua）

LazyVim のデフォルトと衝突している箇所（意図的な上書き）:

| キー | LazyVim デフォルト | カスタム動作 |
|------|------------------|------------|
| `<C-j>` | — | 同じインデントの下の行へジャンプ |
| `<C-k>` | — | 同じインデントの上の行へジャンプ |
| `<Tab>` | — | 対となる括弧へジャンプ（`%`） |
| `x` | delete char (レジスタ汚染) | `"_x`（レジスタを汚さない） |
| `<leader>p/P` | — | レジスタ0 からペースト |

**`<Tab>` は補完プラグイン（blink.cmp 等）と競合する可能性がある。**
補完プラグインを追加する場合はキーマップの衝突を確認すること。

---

## プラグインの追加方法

`lua/plugins/` に新しい `.lua` ファイルを作成し、テーブルを return する:

```lua
-- lua/plugins/my-plugin.lua
return {
  {
    "author/plugin-name",
    -- LazyVim のデフォルトプラグインを上書きする場合は同じ名前で opts を拡張
    opts = function(_, opts)
      -- opts を変更して return
      return opts
    end,
  },
}
```

`lua/config/lazy.lua` を直接編集してプラグインを追加しない。

---

## Stow フォールバック（init.lua の ensure_config_rtp）

`~/.config/nvim` が dotfiles へのシンボリックリンクでない場合（Stow 未実施）、
`~/dotfiles/nvim/.config/nvim`, `~/.dotfiles/nvim/.config/nvim`, `$DOTFILES/nvim/.config/nvim`
の順にフォールバックを探す。DevContainer で dotfiles を clone 直後に neovim を起動しても動く。

**この関数を削除するとシンボリックリンク未作成の環境で nvim が起動できなくなる。**
