return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- Load this colorscheme first
    config = function()
      local has_cat, cat = pcall(require, "catppuccin")
      if has_cat then
        cat.setup({
          transparent_background = true, -- Matches your terminal background
          integrations = {
            cmp = true,
            gitsigns = true,
            telescope = {
              enabled = true,
            },
            treesitter = true,
            which_key = true,
          }
        })
        vim.cmd.colorscheme("catppuccin-mocha")
      end
    end,
  },
  { "vim-scripts/xoria256.vim" } -- Keep legacy colorscheme available
}
