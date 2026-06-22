return {
  -- Flash: jump anywhere on screen with a couple keystrokes
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
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
      { "<leader>td", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
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

  -- Autopairs: auto-close brackets/quotes, integrates with nvim-cmp
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local has_ap, ap = pcall(require, "nvim-autopairs")
      if has_ap then
        ap.setup({ check_ts = true })
        -- Insert ( after selecting a function/method in completion
        local has_cmp, cmp = pcall(require, "cmp")
        local has_ci, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
        if has_cmp and has_ci then
          cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end
      end
    end,
  },
}
