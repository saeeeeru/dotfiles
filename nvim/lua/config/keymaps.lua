-- lua/keymaps.lua
vim.keymap.set("n", "q", function()
  local win = vim.api.nvim_get_current_win()
  local cfg = vim.api.nvim_win_get_config(win)
  if cfg.relative ~= "" then
    vim.api.nvim_win_close(win, true)
  end
end, { silent = true })

