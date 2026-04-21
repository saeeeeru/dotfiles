-- IME auto-switch for better command mode experience (for US keyboard)
-- Using osascript (macOS built-in) - no external dependencies required
vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
	pattern = "*",
	callback = function()
		-- Send key code 102 (Eisu/English key) to disable IME
		-- Using JavaScript for AppleScript is more reliable than AppleScript syntax
		vim.fn.system([[osascript -l JavaScript -e 'Application("System Events").keyCode(102)']])
	end,
	desc = "Auto-disable IME when leaving insert mode",
})

-- Python / SQL はデフォルトで全折りたたみ
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python", "sql" },
	callback = function()
		vim.opt_local.foldlevel = 1
	end,
	desc = "Fold all on open for python/sql",
})

-- Autocmds for markdown files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		-- Enable mouse support for markdown files
		vim.opt_local.mouse = "a"

		-- Optional: set wrap for better reading experience
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
	end,
	desc = "Markdown file settings",
})
