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

  -- smart-splits: seamless C-h/j/k/l movement across nvim splits and
  -- multiplexer panes. Herdr side: the plugin's own herdr plugin plus the
  -- keys.command entries in dotfiles/config/herdr/config.toml. Tmux side:
  -- root C-h/j/k/l with is_vim detection in dotfiles/tmux.conf. Not lazy
  -- loaded so the multiplexer integration is ready before the first keypress.
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    opts = {},
    keys = {
      { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Nav left (split/pane)" },
      { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Nav down (split/pane)" },
      { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Nav up (split/pane)" },
      { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Nav right (split/pane)" },
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
