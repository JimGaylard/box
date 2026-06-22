return {
  -- Telescope Fuzzy Finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      -- Native C sorter for much faster fuzzy matching
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local has_actions, actions = pcall(require, "telescope.actions")
      local has_telescope, telescope = pcall(require, "telescope")
      if has_actions and has_telescope then
        telescope.setup({
          defaults = {
            mappings = {
              i = {
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
              },
            },
          },
        })
        -- Load fzf-native if it's available
        pcall(telescope.load_extension, "fzf")
      end
    end,
  },

  -- Gitsigns (Git indicators in gutter)
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local has_gitsigns, gitsigns = pcall(require, "gitsigns")
      if has_gitsigns then
        gitsigns.setup()
      end
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
      local has_wk, wk = pcall(require, "which-key")
      if has_wk then
        wk.setup()
      end
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
