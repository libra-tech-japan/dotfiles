-- LazyVim のスペルチェックオートコマンドを無効化
-- （英単語以外・コード・日本語に下線が出るのを防ぐ）
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_wrap_spell")
  end,
})
