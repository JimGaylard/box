return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- Load this colorscheme first
    config = function()
      require("catppuccin").setup({
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
    end,
  },
  { "vim-scripts/xoria256.vim" } -- Keep legacy colorscheme available
}
