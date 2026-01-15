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
