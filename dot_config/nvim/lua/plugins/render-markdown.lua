return {
  "MeanderingProgrammer/render-markdown.nvim",
  -- ft で遅延読み込みすると lazy.nvim が FileType を再発火し、ftplugin の undo が E31 を出す
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    heading = {
      enabled = true,
      sign = true,
      icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
    },
    code = {
      enabled = true,
      style = "full",
      border = "thin",
    },
    bullet = {
      enabled = true,
      icons = { "●", "○", "◆", "◇" },
    },
    checkbox = {
      enabled = true,
    },
    -- 表は config.markdown-table の custom handler が描く
    pipe_table = {
      enabled = false,
    },
    custom_handlers = {
      markdown = {
        extends = true,
        parse = function(ctx)
          return require("config.markdown-table").parse(ctx)
        end,
      },
    },
  },
}
