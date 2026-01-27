-- LSP微調整 (Hybrid Mode & Inlay Hints)
-- Extrasの設定をベースにしつつ、TypeScriptとVueのハイブリッド開発における
-- 型安全性と視認性を最大化します

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- 診断表示の微調整（ノイズを減らしつつ重要情報を表示）
      diagnostics = {
        virtual_text = {
          prefix = "icons",
        },
        update_in_insert = false,
      },
      -- Inlay Hints（型推論の可視化）の強制有効化
      inlay_hints = {
        enabled = true,
      },
      servers = {
        vtsls = {
          -- vtsls固有のパフォーマンスチューニング
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
            },
          },
        },
        volar = {
          -- Vue Hybrid Mode設定
          init_options = {
            vue = {
              hybridMode = true,
            },
          },
        },
      },
    },
  },
}
