-- Leader mapping
vim.g.mapleader = ","

local keymap = vim.keymap.set

-- Edit vimrc shortcut
keymap("n", "<leader>v", ":tabedit $MYVIMRC<CR>")
keymap("n", "<leader>map", ":TBrowseOutput map<CR>")

-- Regular search corrections
keymap("n", "/", "/\\v")

-- Toggle search highlight
keymap("n", "<leader>/", ':let @/ = ""<CR>', { silent = true })

-- Format / Strip trailing whitespace manually
keymap("n", "<leader>w", "mp:%s/\\s\\+$/<CR>'p")

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

-- Page visual scroll mappings (gj / gk)
keymap("", "j", "gj")
keymap("", "k", "gk")

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
