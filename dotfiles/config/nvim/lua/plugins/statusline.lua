return {
  {
    -- We can execute this inside the plenary load block to set options and highlights
    "nvim-lua/plenary.nvim",
    config = function()
      -- Helper function to retrieve and format Git branch with Powerline symbol
      local function get_git_branch()
        if vim.g.loaded_fugitive == 1 then
          local branch = vim.fn.FugitiveHead()
          if branch and branch ~= "" then
            return " " .. branch .. "  "
          end
        end
        return ""
      end

      -- Expose the function globally so it can be evaluated by the statusline
      _G.statusline_git = get_git_branch

      -- Configure the statusline format string
      vim.opt.statusline = " %{%v:lua.statusline_git()%}%<%.55F %m%r%w%= %y  %l:%c  %p%% "

      -- Helper to apply transparent StatusLine overrides
      local function set_statusline_highlights()
        vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE", fg = "#bcbcbc" })
        vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE", fg = "#808080" })
      end

      -- Execute initially and bind to ColorScheme events
      set_statusline_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_statusline_highlights,
      })
    end,
  }
}
