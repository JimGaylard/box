return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local has_ts, ts = pcall(require, "nvim-treesitter.configs")
      if has_ts then
        ts.setup({
          ensure_installed = { "javascript", "markdown", "html", "css", "dockerfile", "bash", "lua", "go", "python", "yaml" },
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
          indent = {
            enable = true,
          },
        })
      end
    end,
  }
}
