return {
  "nvim-lualine/lualine.nvim",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "lewis6991/gitsigns.nvim",
  },
  init = function()
    vim.opt.laststatus = 3
  end,
  opts = {
    options = {
      theme = "auto",
      globalstatus = true,
      component_separators = "",
      section_separators = "",
    },
    sections = {
      lualine_a = {},
      lualine_b = {
        { "branch", icon = "" },
        {
          "diff",
          symbols = { added = "+", modified = "~", removed = "-" },
        },
      },
      lualine_c = {
        { "filename", path = 1 },
      },
      lualine_x = {
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          symbols = { error = "E", warn = "W", info = "I", hint = "H" },
        },
        "filetype",
      },
      lualine_y = {},
      lualine_z = { "location" },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { { "filename", path = 1 } },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
  },
}
