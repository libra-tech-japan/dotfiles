-- オプション設定

-- 行番号
vim.opt.relativenumber = true
vim.opt.number = true

-- タブ設定
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- ターミナルカラー
vim.opt.termguicolors = true

-- 検索設定
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- クリップボード設定（環境に応じて調整）
local function setup_clipboard()
  -- WSL 環境の検出
  if vim.fn.has("wsl") == 1 then
    -- WSL 環境では win32yank.exe を使用
    vim.g.clipboard = {
      name = "win32yank-wsl",
      copy = {
        ["+"] = "win32yank.exe -i --crlf",
        ["*"] = "win32yank.exe -i --crlf",
      },
      paste = {
        ["+"] = "win32yank.exe -o --lf",
        ["*"] = "win32yank.exe -o --lf",
      },
      cache_enabled = 0,
    }
  elseif vim.env.SSH_TTY then
    -- SSH 環境では OSC52 を使用
    vim.opt.clipboard = "unnamedplus"
    -- OSC52 サポート（Neovim 0.9+ の vim.ui.clipboard を使用）
    -- 実際の OSC52 実装は osc52.nvim プラグインや
    -- ターミナルエミュレータの OSC52 サポートに依存
    -- ここでは基本的な設定のみ行う
  else
    -- デフォルト（unnamedplus）
    vim.opt.clipboard = "unnamedplus"
  end
end

setup_clipboard()
