-- 強制フォーマット設定 (Conform)
-- 保存時に「必ず」整形を行い、開発リズムを止めないようにします
-- Smart Fallback: biome.json があれば Biome、なければ Prettier（opts 関数内で require してロード前エラーを回避）

return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.format_on_save = opts.format_on_save or {}
      opts.format_on_save.timeout_ms = opts.format_on_save.timeout_ms or 3000
      opts.format_on_save.lsp_fallback = opts.format_on_save.lsp_fallback ~= false

      opts.formatters_by_ft = vim.tbl_extend("force", opts.formatters_by_ft or {}, {
        ["javascript"] = { "biome", "prettier", stop_after_first = true },
        ["javascriptreact"] = { "biome", "prettier", stop_after_first = true },
        ["typescript"] = { "biome", "prettier", stop_after_first = true },
        ["typescriptreact"] = { "biome", "prettier", stop_after_first = true },
        ["vue"] = { "prettier" },
        ["css"] = { "prettier" },
        ["scss"] = { "prettier" },
        ["less"] = { "prettier" },
        ["html"] = { "prettier" },
        ["json"] = { "prettier" },
        ["jsonc"] = { "prettier" },
        ["yaml"] = { "prettier" },
        ["markdown"] = { "prettier" },
        ["graphql"] = { "prettier" },
      })

      -- Biome: ctx.filename から親方向に biome.json / biome.jsonc がある場合のみ有効
      local conform = require("conform")
      local default_biome = conform.formatters.biome or {}
      opts.formatters = vim.tbl_extend("force", opts.formatters or {}, {
        biome = vim.tbl_extend("force", default_biome, {
          condition = function(self, ctx)
            return vim.fs.find({ "biome.json", "biome.jsonc" }, { path = ctx.filename, upward = true })[1]
          end,
        }),
      })

      return opts
    end,
  },
}
