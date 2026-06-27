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
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Live grep" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Buffers" },
      { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Help tags" },
    },
    config = function()
      local has_actions, actions = pcall(require, "telescope.actions")
      local has_telescope, telescope = pcall(require, "telescope")
      if has_actions and has_telescope then
        telescope.setup({
          defaults = {
            -- Use ripgrep for live_grep and (with -g flags) find_files
            vimgrep_arguments = {
              "rg",
              "--color=never",
              "--no-heading",
              "--with-filename",
              "--line-number",
              "--column",
              "--smart-case",
              "--hidden",
              "--glob=!**/.git/*",
            },
            mappings = {
              i = {
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
              },
            },
          },
          pickers = {
            find_files = {
              find_command = { "rg", "--files", "--hidden", "--glob=!**/.git/*" },
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
    cmd = "UndotreeToggle",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle undotree" },
    },
    config = function()
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },

  -- Vimux
  {
    "benmills/vimux",
    init = function()
      -- Test runner lives in a tmux pane (not a separate window)
      vim.g.VimuxRunnerType = "pane"
      -- "v" => `tmux split-window -v` => runner opens in the pane *below* nvim
      vim.g.VimuxOrientation = "v"
      -- Runner pane takes 30% of the height
      vim.g.VimuxHeight = "30"
      -- Never hijack an existing sibling pane; always split a fresh one below
      vim.g.VimuxUseNearest = 0
    end,
  },

  -- vim-test: language-aware :TestNearest/:TestFile/:TestSuite/:TestLast.
  -- Routed through Vimux so output lands in the pane below (see Vimux config above).
  {
    "vim-test/vim-test",
    dependencies = { "benmills/vimux" },
    cmd = { "TestNearest", "TestFile", "TestSuite", "TestLast", "TestVisit" },
    -- The whole ,t group lives here so it stays cohesive. The Vimux runner
    -- controls (zoom/interrupt/close/scroll) only matter once vim-test has
    -- spawned a runner, and vimux loads as a dependency, so they belong here too.
    keys = {
      { "<leader>ts", "<cmd>TestSuite<cr>", desc = "Test suite (e.g. cargo test)" },
      { "<leader>tn", "<cmd>TestNearest<cr>", desc = "Test nearest (fn under cursor)" },
      { "<leader>tf", "<cmd>TestFile<cr>", desc = "Test current file" },
      { "<leader>tt", "<cmd>TestLast<cr>", desc = "Re-run last test" },
      { "<leader>tz", "<cmd>VimuxZoomRunner<cr>", desc = "Zoom runner pane" },
      { "<leader>tx", "<cmd>VimuxInterruptRunner<cr>", desc = "Interrupt runner" },
      { "<leader>tc", "<cmd>VimuxCloseRunner<cr>", desc = "Close runner pane" },
      { "˚", "<cmd>VimuxScrollUpInspect<cr>", desc = "Scroll runner up" },
      { "∆", "<cmd>VimuxScrollDownInspect<cr>", desc = "Scroll runner down" },
    },
    init = function()
      vim.g["test#strategy"] = "vimux"
    end,
  },
}
