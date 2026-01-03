return {
  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "lewis6991/gitsigns.nvim",
    },
    config = function()
      require("config.ui.incline").setup()
    end,
  },
}

