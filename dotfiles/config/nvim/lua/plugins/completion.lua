return {
	{
		"saghen/blink.cmp",
		-- Release tag => prebuilt Rust fuzzy-matcher binary is downloaded
		version = "1.*",
		dependencies = { "folke/lazydev.nvim" },
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = {
				-- "enter": <CR>/<C-y> accept, <C-n>/<C-p> select, <C-e> hide.
				-- Tab/S-Tab added to match the old nvim-cmp navigation.
				preset = "enter",
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
			},
			-- Cmdline completion popup that auto-shows as you type (like the old
			-- nvim-cmp cmdline). Covers custom command args, e.g. ":Lazy " ->
			-- sync / install / ...  preselect=false so <CR> runs the command.
			cmdline = {
				enabled = true,
				completion = {
					menu = { auto_show = true },
					list = { selection = { preselect = false } },
				},
			},
			completion = {
				-- Auto-insert () after accepting a function (replaces the old
				-- nvim-autopairs + cmp `confirm_done` hook).
				accept = { auto_brackets = { enabled = true } },
				documentation = { auto_show = true },
			},
			sources = {
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
					-- Neovim API completion in lua files
					lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
				},
			},
		},
	},
}
