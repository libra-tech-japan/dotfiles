-- 移行プラグイン設定
-- 旧環境から機能漏れがないように追加するプラグイン

return {
  -- 日本語ヘルプ
  {
    "vim-jp/vimdoc-ja",
    lazy = false,
    priority = 1000,
  },

  -- 検索時のカーソル移動防止
  {
    "haya14busa/vim-asterisk",
    keys = {
      { "*", "<Plug>(asterisk-z*)", mode = { "n", "x" }, desc = "検索（カーソル移動なし）" },
      { "#", "<Plug>(asterisk-z#)", mode = { "n", "x" }, desc = "逆検索（カーソル移動なし）" },
      { "g*", "<Plug>(asterisk-gz*)", mode = { "n", "x" }, desc = "検索（部分一致、カーソル移動なし）" },
      { "g#", "<Plug>(asterisk-gz#)", mode = { "n", "x" }, desc = "逆検索（部分一致、カーソル移動なし）" },
    },
    config = function()
      vim.g["asterisk#keeppos"] = 1
    end,
  },

  -- エッジ移動
  {
    "haya14busa/vim-edgemotion",
    keys = {
      { "<C-j>", "<Plug>(edgemotion-j)", mode = { "n", "x" }, desc = "下のエッジへ移動" },
      { "<C-k>", "<Plug>(edgemotion-k)", mode = { "n", "x" }, desc = "上のエッジへ移動" },
    },
  },

  -- マルチカーソル
  {
    "mg979/vim-visual-multi",
    keys = {
      { "<C-n>", "<Plug>(VM-Find-Under)", mode = { "n", "x" }, desc = "マルチカーソル開始" },
      { "<C-n>", "<Plug>(VM-Add-Cursor-Down)", mode = "n", desc = "カーソル追加（下）" },
      { "<C-p>", "<Plug>(VM-Add-Cursor-Up)", mode = "n", desc = "カーソル追加（上）" },
    },
    init = function()
      vim.g.VM_maps = {
        ["Find Under"] = "<C-n>",
        ["Find Subword Under"] = "<C-n>",
        ["Add Cursor Down"] = "<C-n>",
        ["Add Cursor Up"] = "<C-p>",
      }
    end,
  },

  -- 拡張インクリメント
  {
    "monaqa/dial.nvim",
    keys = {
      { "<C-a>", function()
        return require("dial.map").inc_normal()
      end, expr = true, desc = "インクリメント" },
      { "<C-x>", function()
        return require("dial.map").dec_normal()
      end, expr = true, desc = "デクリメント" },
      { "<C-a>", function()
        return require("dial.map").inc_visual()
      end, expr = true, mode = "v", desc = "インクリメント（ビジュアル）" },
      { "<C-x>", function()
        return require("dial.map").dec_visual()
      end, expr = true, mode = "v", desc = "デクリメント（ビジュアル）" },
      { "g<C-a>", function()
        return require("dial.map").inc_gvisual()
      end, expr = true, mode = "v", desc = "インクリメント（gビジュアル）" },
      { "g<C-x>", function()
        return require("dial.map").dec_gvisual()
      end, expr = true, mode = "v", desc = "デクリメント（gビジュアル）" },
    },
    config = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group({
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.date.alias["%Y-%m-%d"],
          augend.constant.alias.bool,
          augend.semver.alias.semver,
        },
      })
    end,
  },
}
