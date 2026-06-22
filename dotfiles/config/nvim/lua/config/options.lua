local opt = vim.opt

-- General Options
opt.inccommand = "nosplit"
opt.swapfile = false
opt.exrc = true
opt.background = "dark"
opt.ttimeoutlen = 10
opt.shortmess:append("filmnrxoOtTI")
opt.history = 1000
opt.spell = false
opt.hidden = true
opt.lazyredraw = true
opt.linebreak = true

-- Hybrid line numbers: absolute on the cursor line, relative elsewhere
opt.number = true
opt.relativenumber = true

opt.backspace = { "indent", "eol", "start" }
opt.linespace = 0
opt.showmatch = true
opt.incsearch = true
opt.hlsearch = true
opt.wildmenu = true
opt.wildmode = "list:longest,full"
opt.scrolljump = 5
opt.list = true
opt.listchars = { tab = "› ", trail = "•", extends = "#", nbsp = "." }

-- Formatting
opt.wrap = false
opt.autoindent = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.expandtab = true
opt.matchpairs:append("<:>")
opt.comments = "sl:/*,mb:*,elx:*/"

-- File backupskip
opt.backupskip = { "/tmp/*", "/private/tmp/*" }

-- Secure
opt.secure = true

-- Host interpreters (copied from original config)
vim.g.python_host_prog = "/usr/bin/python"
vim.g.python3_host_prog = "/usr/bin/python3"

-- Autocmds
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local custom_group = augroup("CustomSettings", { clear = true })

autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.listchars = { tab = "  ", trail = "•", extends = "#", nbsp = "." }
  end,
  group = custom_group,
})

autocmd("FileType", {
  pattern = "yaml",
  callback = function()
    vim.opt_local.indentkeys:remove("<:>")
  end,
  group = custom_group,
})

autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
  group = custom_group,
})

-- Strip trailing whitespace on save, only for filetypes conform doesn't format
-- (conform's format-on-save already handles go/js/py/yaml/etc.)
local function strip_trailing_whitespace()
  local view = vim.fn.winsaveview()
  vim.cmd([[%s/\s\+$//e]])
  vim.fn.winrestview(view)
end

autocmd("BufWritePre", {
  pattern = { "*.c", "*.cpp", "*.java", "*.php", "*.rb", "*.hs", "*.twig", "*.xml" },
  callback = strip_trailing_whitespace,
  group = custom_group,
})
