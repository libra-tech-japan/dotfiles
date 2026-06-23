-- Vitest 用 neotest アダプタ
--
-- 前提: lua/config/lazy.lua で `test.core`（neotest 本体）を有効化していること。
-- LazyVim 標準の neotest opts.adapters にアダプタを追記する形で登録する。
--
-- 主なキーマップ（LazyVim 既定 / test.core 由来）:
--   <leader>tt  カーソル下のファイルのテストを実行
--   <leader>tr  直近のテストを再実行
--   <leader>tT  プロジェクト全体のテストを実行
--   <leader>ts  テスト一覧（Summary）パネルを開閉
--   <leader>to  テスト結果の出力を表示
return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "marilari88/neotest-vitest",
    },
    opts = {
      adapters = {
        ["neotest-vitest"] = {},
      },
    },
  },
}
