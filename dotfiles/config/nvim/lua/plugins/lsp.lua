return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        -- Auto-install basic servers for your languages
        ensure_installed = { "ts_ls", "gopls", "pyright", "lua_ls" },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      -- Helper function to map keys when LSP attaches to a buffer (compatible with 0.8+)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local opts = { buffer = bufnr, silent = true }
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })

      -- Configure capabilities for autocomplete support
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if has_cmp then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
      end

      -- Setup standard language servers
      local servers = { "ts_ls", "gopls", "pyright", "lua_ls" }
      for _, lsp in ipairs(servers) do
        if vim.lsp.config then
          -- Neovim 0.11+ API
          vim.lsp.config(lsp, {
            capabilities = capabilities,
          })
          vim.lsp.enable(lsp)
        else
          -- Fallback for Neovim < 0.11
          local has_lspconfig, lspconfig = pcall(require, "lspconfig")
          if has_lspconfig then
            lspconfig[lsp].setup({
              capabilities = capabilities,
            })
          end
        end
      end
    end,
  }
}
