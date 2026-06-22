local keymap = vim.keymap.set

-- Edit vimrc shortcut
keymap("n", "<leader>v", ":tabedit $MYVIMRC<CR>")
keymap("n", "<leader>map", ":TBrowseOutput map<CR>")

-- Telescope fuzzy finder (loaded lazily on first use)
keymap("n", "<leader>ff", function() require("telescope.builtin").find_files() end, { desc = "Find files" })
keymap("n", "<leader>fg", function() require("telescope.builtin").live_grep() end, { desc = "Live grep" })
keymap("n", "<leader>fb", function() require("telescope.builtin").buffers() end, { desc = "Buffers" })
keymap("n", "<leader>fh", function() require("telescope.builtin").help_tags() end, { desc = "Help tags" })

-- LSP diagnostics navigation (jump moves the cursor and shows the float)
keymap("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
keymap("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev diagnostic" })
keymap("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Regular search corrections
keymap("n", "/", "/\\v")

-- Toggle search highlight
keymap("n", "<leader>/", ':let @/ = ""<CR>', { silent = true })

-- File info copy mappings
keymap("n", ",cf", ':let @*=expand("%")<CR>')
keymap("n", ",cp", ':let @*=expand("%:p")<CR>')

-- Run ctags
keymap("n", ",t", ":!ctags -R .<CR>")

-- Window navigation mappings
keymap("", "<C-J>", "<C-W>j")
keymap("", "<C-K>", "<C-W>k")
keymap("", "<C-L>", "<C-W>l")
keymap("", "<C-H>", "<C-W>h")
keymap("", "<S-H>", "gT")
keymap("", "<S-L>", "gt")

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

-- Format JSON shortcut
keymap("n", "<leader>jt", "<Esc>:%!python -m json.tool<CR><Esc>:set filetype=json<CR>")

-- Vimux Mappings
keymap("n", "<leader>r", ":VimuxRunLastCommand<CR>")
keymap("n", "<leader>s", ":VimuxRunCommand ''<left>")
keymap("n", "<leader>z", ":VimuxZoomRunner<CR>")
keymap("n", "<Leader>x", ":VimuxInterruptRunner<CR>")
keymap("n", "˚", ":VimuxScrollUpInspect<CR>")
keymap("n", "∆", ":VimuxScrollDownInspect<CR>")

-- Command corrections for typos (stupid shift key fixes)
local function create_cmd(name, target)
	vim.api.nvim_create_user_command(name, function(opts)
		local bang = opts.bang and "!" or ""
		vim.cmd(target .. bang .. " " .. opts.args)
	end, { bang = true, nargs = "*", complete = "file" })
end

create_cmd("E", "e")
create_cmd("W", "w")
create_cmd("Wq", "wq")
create_cmd("WQ", "wq")
create_cmd("Wa", "wa")
create_cmd("WA", "wa")
create_cmd("Q", "q")
create_cmd("QA", "qa")
create_cmd("Qa", "qa")

keymap("c", "Tabe", "tabe")
