return {
  -- Tree-sitter parser for Justfiles (AST syntax highlighting, folds, and injections)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "just" })
      end
    end,
  },

  -- LSP configuration for just-lsp
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        just = {},
      },
    },
  },

  -- Auto-formatting via `just --fmt`
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.just = { "just" }
    end,
  },
}
