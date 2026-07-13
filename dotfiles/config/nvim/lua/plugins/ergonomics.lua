return {
  -- Flash: jump anywhere on screen with a couple keystrokes
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    -- char mode off: keep vanilla f/F/t/T/;/, — flash only on s/S/r
    opts = { modes = { char = { enabled = false } } },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    },
  },

  -- Todo Comments: highlight and search TODO / FIXME / HACK
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
    },
    config = function()
      local has_tc, tc = pcall(require, "todo-comments")
      if has_tc then
        tc.setup()
      end
    end,
  },

  -- Trouble: pretty panel for diagnostics / quickfix
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
  },

  -- Tmux Navigator: seamless C-h/j/k/l movement across nvim splits and tmux
  -- panes. The tmux side (root C-h/j/k/l with is_vim detection) lives in
  -- dotfiles/tmux.conf; both halves are required.
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Nav left (split/pane)" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Nav down (split/pane)" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Nav up (split/pane)" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Nav right (split/pane)" },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Nav to previous (split/pane)" },
    },
  },

  -- Autopairs: auto-close brackets/quotes, integrates with nvim-cmp
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local has_ap, ap = pcall(require, "nvim-autopairs")
      if has_ap then
        -- Function-call () insertion on accept is handled by blink.cmp
        -- (completion.accept.auto_brackets), so no completion hook here.
        ap.setup({ check_ts = true })
      end
    end,
  },
}
