-- Stow ベストプラクティス: ~/.config/nvim がこのリポジトリへのシンボリックリンクである前提。
-- 未 stow 時用フォールバック: このリポジトリの nvim 設定を rtp に追加する。
local function ensure_config_rtp()
  local config_dir = vim.fn.stdpath("config")
  local lazy_lua = config_dir .. "/lua/config/lazy.lua"
  if vim.loop.fs_stat(lazy_lua) then
    return -- 既にこのリポジトリの設定が config にある（Stow 済み）
  end
  local home = os.getenv("HOME") or ""
  for _, base in ipairs({ home .. "/dotfiles", home .. "/.dotfiles", os.getenv("DOTFILES") or "" }) do
    if base == "" then goto continue end
    local candidate = base .. "/nvim/.config/nvim"
    if vim.loop.fs_stat(candidate .. "/lua/config/lazy.lua") then
      vim.opt.rtp:prepend(candidate)
      return
    end
    ::continue::
  end
end
ensure_config_rtp()

-- 1. キーマップ・設定を最優先で読み込み（プラグインより先に適用）
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- 2. Lazy.nvim ブートストラップ（プラグインはその後）
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("config.lazy")
