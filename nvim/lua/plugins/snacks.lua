return {
"folke/snacks.nvim",
version = "*",
lazy = false, -- for dashboard
keys = {
  { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues" },
  { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub PRs" },
  { "<leader>gia", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (All)" },
  { "<leader>gpa", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub PRs (All)" },
},
---@type snacks.Config
opts = {
scratch = { enable = true },
notifier = {
  enabled = true,
  timeout = 3000, -- default timeout in ms
},
gh = {
  enabled = true,
},
styles = {
scratch = {
  wo = {
    winhighlight = "", -- use usual NormalFloat
  },
},
terminal = {
  keys = {
    term_normal = false, -- disable <ESC><ESC> for claudecode
  },
},
},
},
config = function(_, opts)
for _, fn in ipairs(opts._inits or {}) do
pcall(fn)
end
require("snacks").setup(opts)
end,
}
