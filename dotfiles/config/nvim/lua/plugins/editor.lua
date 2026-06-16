return {
  -- Telescope Fuzzy Finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local actions = require("telescope.actions")
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
          },
        },
      })
    end,
  },

  -- Gitsigns (Git indicators in gutter)
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Which-Key (Keybinding popups helper)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    config = function()
      require("which-key").setup()
    end,
  },

  -- Undotree
  {
    "mbbill/undotree",
    config = function()
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },

  -- Vimux
  { "benmills/vimux" }
}
