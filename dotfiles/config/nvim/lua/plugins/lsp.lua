return {
	{
		-- Teaches lua_ls the full Neovim API (fixes "Undefined global vim",
		-- adds completion for vim.* and plugin modules)
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		"williamboman/mason.nvim",
		config = function()
			local has_mason, mason = pcall(require, "mason")
			if has_mason then
				mason.setup()
			end
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			local has_mlsp, mlsp = pcall(require, "mason-lspconfig")
			if has_mlsp then
				mlsp.setup({
					-- Auto-install basic servers for your languages
					ensure_installed = { "ts_ls", "gopls", "pyright", "lua_ls" },
				})
			end
		end,
	},
	{
		-- Auto-install formatters/linters used by conform.nvim via Mason
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			local has_mti, mti = pcall(require, "mason-tool-installer")
			if has_mti then
				mti.setup({
					ensure_installed = {
						"stylua",
						"shfmt",
						"ruff",
						"black",
						-- prettierd is installed globally via npm (mason can't see nvm's npm
						-- on PATH); install with: npm install -g @fsouza/prettierd
					},
				})
			end
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
			local servers = { "ts_ls", "gopls", "pyright", "lua_ls", "rust-analyzer" }
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
	},
}
