-- j/k を表示行移動（gj/gk）に固定（LazyVim 既定キーマップの上書き）
local setup_display_line_jk = function()
  for _, mode in ipairs({ "n", "v", "x" }) do
    pcall(vim.keymap.del, mode, "j")
    pcall(vim.keymap.del, mode, "k")
    vim.keymap.set(mode, "j", "gj", { desc = "表示行で下へ移動", silent = true })
    vim.keymap.set(mode, "k", "gk", { desc = "表示行で上へ移動", silent = true })
  end
end

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  once = true,
  callback = setup_display_line_jk,
})

-- 非英語文字に波下線（スペルチェック）が出ないようにする

-- LazyVim のスペル用 augroup を削除
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_wrap_spell")
  end,
})

-- 全バッファでスペルチェックを無効化（LazyVim の ft 別有効化を上書き）
vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  callback = function()
    vim.opt_local.spell = false
  end,
})
