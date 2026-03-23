return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  lazy = false,
  opts = {
    flavour = "macchiato",
    transparent_background = true,
    integrations = {
      gitsigns = true,
      indent_blankline = { enabled = true },
      render_markdown = true,
      telescope = true,
      which_key = true,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
  end,
}
