local keymap = vim.keymap.set

-- Edit vimrc shortcut
keymap("n", "<leader>v", ":tabedit $MYVIMRC<CR>", { desc = "Edit config" })

-- Note: Telescope (,ff ,fg ,fb ,fh) and the test runner ,t group (vim-test +
-- Vimux) live in their plugin specs in lua/plugins/editor.lua via `keys = {}`,
-- which also lazy-loads those plugins on first keypress.

-- LSP diagnostics navigation (jump moves the cursor and shows the float)
keymap("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
keymap("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev diagnostic" })
keymap("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Regular search corrections
keymap("n", "/", "/\\v")

-- Toggle search highlight
keymap("n", "<leader>/", ':let @/ = ""<CR>', { silent = true, desc = "Clear search highlight" })

-- Toggle hybrid line numbers on/off
keymap("n", "<leader>n", function()
	local on = not vim.wo.number
	vim.wo.number = on
	vim.wo.relativenumber = on
end, { desc = "Toggle line numbers" })

-- Yank file name / path to the system clipboard (,y = yank group)
keymap("n", ",yf", ':let @*=expand("%")<CR>', { desc = "Yank file name" })
keymap("n", ",yp", ':let @*=expand("%:p")<CR>', { desc = "Yank file path" })

-- Run ctags (moved off ,t to free that prefix for the Vimux test group)
keymap("n", ",T", ":!ctags -R .<CR>", { desc = "Run ctags" })

-- Window navigation mappings
keymap("", "<C-J>", "<C-W>j", { desc = "Window below" })
keymap("", "<C-K>", "<C-W>k", { desc = "Window above" })
keymap("", "<C-L>", "<C-W>l", { desc = "Window right" })
keymap("", "<C-H>", "<C-W>h", { desc = "Window left" })

-- Tab navigation (H/L left alone so they keep their top/bottom-of-screen motions)
keymap("n", "]t", "gt", { desc = "Next tab" })
keymap("n", "[t", "gT", { desc = "Prev tab" })

-- Visual-line movement for bare j/k, but keep counts linewise (5j = 5 real lines)
keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Command line write as sudo
keymap("c", "w!!", "w !sudo tee % >/dev/null")

-- Horizontal scroll mappings
keymap("", "zl", "zL")
keymap("", "zh", "zH")

-- Consistent Y behavior (Yank to end of line)
keymap("n", "Y", "y$")

-- Command-line abbreviations for common shift-key typos. cnoreabbrev only
-- expands at the command position, so they don't shadow real command names
-- mid-line, and bang/args (:W!, :W file) pass through naturally.
local cmd_typos = {
	E = "e",
	W = "w",
	Wq = "wq",
	WQ = "wq",
	Wa = "wa",
	WA = "wa",
	Q = "q",
	QA = "qa",
	Qa = "qa",
	Tabe = "tabe",
}
for typo, correct in pairs(cmd_typos) do
	vim.cmd(string.format("cnoreabbrev %s %s", typo, correct))
end
