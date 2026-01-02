vim.g.mapleader = ' '

vim.opt.termguicolors = true

vim.api.nvim_set_hl(0, "Visual", {
  bg = "#3c4048", -- 少し明るめグレー
})

-- clipboard
if vim.fn.has("unnamedplus") == 1 then
  vim.opt.clipboard = "unnamed,unnamedplus"
else
  vim.opt.clipboard = "unnamed"
end

-- indent
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy") -- load plugins
require("config.highlights")

