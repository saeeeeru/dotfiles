return {
  "linrongbin16/gitlinker.nvim",
  version = "*",
  cmd = "GitLink",
  keys = {
    { "<leader>gy", "<cmd>GitLink<cr>", mode = { "n", "v" }, desc = "Git: yank permalink" },
    { "<leader>gY", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Git: open permalink" },
  },
  opts = {},
}
