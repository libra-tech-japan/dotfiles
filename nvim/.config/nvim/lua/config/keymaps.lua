-- キーマップ設定
-- LazyVim の標準キーマップに加えて、独自のキーマップを定義

-- コマンドモードのショートカット
vim.keymap.set("n", ";", ":", { desc = "コマンドモード", remap = true })

-- レジスタを汚さない削除
vim.keymap.set("n", "x", '"_x', { desc = "レジスタを汚さない削除" })
vim.keymap.set("v", "x", '"_x', { desc = "レジスタを汚さない削除" })

-- レジスタ0からのペースト
vim.keymap.set("n", "<leader>p", '"0p', { desc = "レジスタ0からペースト" })
vim.keymap.set("n", "<leader>P", '"0P', { desc = "レジスタ0からペースト（前）" })

-- ウィンドウ分割
vim.keymap.set("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "縦分割" })
vim.keymap.set("n", "<leader>-", "<cmd>split<cr>", { desc = "横分割" })

-- バッファ移動
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "前のバッファ" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "次のバッファ" })
vim.keymap.set("n", "[B", "<cmd>bfirst<cr>", { desc = "最初のバッファ" })
vim.keymap.set("n", "]B", "<cmd>blast<cr>", { desc = "最後のバッファ" })

-- 表示行移動（j, k を gj, gk にマッピング）
vim.keymap.set("n", "j", "gj", { desc = "表示行で下へ移動" })
vim.keymap.set("n", "k", "gk", { desc = "表示行で上へ移動" })
vim.keymap.set("v", "j", "gj", { desc = "表示行で下へ移動" })
vim.keymap.set("v", "k", "gk", { desc = "表示行で上へ移動" })

-- ハイライト解除
vim.keymap.set("n", "<Esc><Esc>", "<cmd>nohlsearch<cr>", { desc = "ハイライト解除" })

-- JSON整形
vim.keymap.set("n", "<leader>jq", ":%!jq '.'<cr>", { desc = "JSON整形" })

-- Normal mode で 'vv' を押すと 'VG' (Visual Line + Go to End) が走ります
vim.keymap.set("n", "vv", "VG", { desc = "Select to end of file" })

-- 選択行のインデント維持（<, > をそのまま使用、LazyVim のデフォルト動作を維持）
