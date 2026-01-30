return {
  "petertriho/nvim-scrollbar",
  event = { "BufReadPost", "BufAdd", "BufNewFile" },
  dependencies = {
    "lewis6991/gitsigns.nvim",
  },
  opts = {
    marks = {
      Search = { color_nr = "3", color = "#f9e2af" },
      Error = { color_nr = "9", color = "#f38ba8" },
      Warn = { color_nr = "11", color = "#fab387" },
    },
    handlers = {
      cursor = true,
      diagnostic = true,
      gitsigns = true,
      handle = true,
      search = false,
    },
  },
  config = function(_, opts)
    require("scrollbar").setup(opts)
    pcall(function()
      require("scrollbar.handlers.gitsigns").setup()
    end)
  end,
}
