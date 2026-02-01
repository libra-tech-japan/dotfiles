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
