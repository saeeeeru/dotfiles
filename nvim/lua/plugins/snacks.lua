return {
"folke/snacks.nvim",
version = "*",
lazy = false, -- for dashboard
---@type snacks.Config
opts = {
scratch = { enable = true },
notifier = {
  enabled = true,
  timeout = 3000, -- default timeout in ms
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
