return {
"folke/snacks.nvim",
version = "*",
lazy = false, -- for dashboard
---@type snacks.Config
opts = {
scratch = { enable = true },
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
