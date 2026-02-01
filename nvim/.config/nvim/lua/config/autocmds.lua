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
