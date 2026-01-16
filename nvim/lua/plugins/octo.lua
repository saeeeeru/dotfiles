return {
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Octo",
  keys = {
    { "<leader>oi", "<cmd>Octo issue list<cr>", desc = "List Issues" },
    { "<leader>oia", "<cmd>Octo search is:issue assignee:@me<cr>", desc = "List My Issues" },
    { "<leader>op", "<cmd>Octo pr list<cr>", desc = "List PRs" },
    { "<leader>opa", "<cmd>Octo search is:pr assignee:@me<cr>", desc = "List My PRs" },
  },
  opts = {
    mappings = {
      issue = {
        close_issue = { lhs = "<leader>ic", desc = "close issue" },
        reopen_issue = { lhs = "<leader>io", desc = "reopen issue" },
        add_comment = { lhs = "<leader>ca", desc = "add comment" },
        delete_comment = { lhs = "<leader>cd", desc = "delete comment" },
        next_comment = { lhs = "]c", desc = "go to next comment" },
        prev_comment = { lhs = "[c", desc = "go to previous comment" },
        open_in_browser = { lhs = "<C-b>", desc = "open issue in browser" },
      },
      pull_request = {
        checkout_pr = { lhs = "<leader>po", desc = "checkout PR" },
        merge_pr = { lhs = "<leader>pm", desc = "merge PR" },
        close_issue = { lhs = "<leader>ic", desc = "close PR" },
        reopen_issue = { lhs = "<leader>io", desc = "reopen PR" },
        add_comment = { lhs = "<leader>ca", desc = "add comment" },
        delete_comment = { lhs = "<leader>cd", desc = "delete comment" },
        next_comment = { lhs = "]c", desc = "go to next comment" },
        prev_comment = { lhs = "[c", desc = "go to previous comment" },
        open_in_browser = { lhs = "<C-b>", desc = "open PR in browser" },
      },
    },
  },
}
