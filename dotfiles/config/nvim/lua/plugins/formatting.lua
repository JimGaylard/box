return {
  -- Conform: lightweight formatter runner with format-on-save
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    config = function()
      local has_conform, conform = pcall(require, "conform")
      if has_conform then
        conform.setup({
          formatters_by_ft = {
            lua = { "stylua" },
            python = { "ruff_format", "black", stop_after_first = true },
            javascript = { "prettierd", "prettier", stop_after_first = true },
            typescript = { "prettierd", "prettier", stop_after_first = true },
            javascriptreact = { "prettierd", "prettier", stop_after_first = true },
            typescriptreact = { "prettierd", "prettier", stop_after_first = true },
            json = { "prettierd", "prettier", stop_after_first = true },
            yaml = { "prettierd", "prettier", stop_after_first = true },
            html = { "prettierd", "prettier", stop_after_first = true },
            css = { "prettierd", "prettier", stop_after_first = true },
            markdown = { "prettierd", "prettier", stop_after_first = true },
            go = { "gofmt" },
            sh = { "shfmt" },
          },
          format_on_save = {
            timeout_ms = 1000,
            lsp_format = "fallback",
          },
        })
      end
    end,
  },
}
