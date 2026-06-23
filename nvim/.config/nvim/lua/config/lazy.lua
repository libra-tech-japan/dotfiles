-- Lazy プラグイン管理: spec は完全パスで定義（No specs found エラー回避）
require("lazy").setup({
  spec = {
    -- LazyVim 本体とそのプラグイン
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- LazyVim 公式 Extras（完全パス指定）
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.vue" },
    { import = "lazyvim.plugins.extras.linting.eslint" },
    { import = "lazyvim.plugins.extras.formatting.prettier" },
    -- テスト（neotest）。Vitest アダプタは lua/plugins/neotest-vitest.lua で追加
    { import = "lazyvim.plugins.extras.test.core" },
    -- アウトライン（シンボル一覧パネル / VSCode の Outline 相当）
    { import = "lazyvim.plugins.extras.editor.outline" },
    -- スティッキースクロール（関数ヘッダを上部固定 / VSCode の Sticky Scroll 相当）
    { import = "lazyvim.plugins.extras.ui.treesitter-context" },
    -- パンくず（breadcrumbs を winbar に表示 / VSCode の Breadcrumbs 相当）
    { import = "lazyvim.plugins.extras.editor.navic" },
    -- カーソル下と同じ単語をハイライト
    { import = "lazyvim.plugins.extras.editor.illuminate" },
    -- リネームのライブプレビュー（:IncRename）
    { import = "lazyvim.plugins.extras.editor.inc-rename" },
    -- 囲み（surround）操作の追加/変更/削除
    { import = "lazyvim.plugins.extras.coding.mini-surround" },
    -- カラーコード（#rrggbb 等）を実色でプレビュー
    { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
    -- Markdown のレンダリング/プレビュー
    { import = "lazyvim.plugins.extras.lang.markdown" },
    -- Tailwind CSS（クラス補完 + カラープレビュー）
    { import = "lazyvim.plugins.extras.lang.tailwind" },
    -- VSCode 風の固定パネルレイアウト（端にパネルを寄せる）
    { import = "lazyvim.plugins.extras.ui.edgy" },
    -- 公式 Extras に存在しないため一時無効化
    -- { import = "lazyvim.plugins.extras.coding.blink" },
    -- ユーザー定義プラグイン
    { import = "plugins" },
  },
  defaults = { lazy = true },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
