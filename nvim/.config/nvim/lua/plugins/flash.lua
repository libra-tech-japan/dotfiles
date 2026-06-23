-- flash.nvim の f/t モーション挙動を上書き
--
-- 背景:
--   keymaps.lua で `;` を `:`（コマンドモード）に再マップしているため、
--   flash 標準の「`;` = 次候補」が無効化されている（flash は `;`/`,` が
--   ユーザー定義済みなら上書きしない仕様）。
--   そこで `f`/`t` 自身を「次候補」キーにする。
--
-- 挙動:
--   `f<char>` で最初の一致へジャンプ後、
--     f / t 連打 → 常に【行末方向】の次候補へ
--     F / T 連打 → 常に【行頭方向】の次候補へ
--     ,         → 行頭方向（`;` は `:` に取られているため代替）
--   ("right"/"left" は直前のモーション方向に依存せず常に右/左)
return {
  {
    "folke/flash.nvim",
    opts = {
      modes = {
        char = {
          char_actions = function(motion)
            return {
              [","] = "left",
              [motion:lower()] = "right", -- f / t → 行末方向
              [motion:upper()] = "left", -- F / T → 行頭方向
            }
          end,
        },
      },
    },
  },
}
