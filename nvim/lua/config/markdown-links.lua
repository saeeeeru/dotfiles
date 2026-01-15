-- Markdown link handling module
local M = {}

-- Extract link under cursor
function M.get_link_under_cursor()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]

	-- Pattern for markdown links: [text](url)
	-- Also support obsidian-style [[wiki-links]]
	local patterns = {
		{ pattern = "%[.-%]%((.-)%)", type = "markdown" }, -- [text](url)
		{ pattern = "%[%[(.-)%]%]", type = "obsidian" }, -- [[wiki-link]]
	}

	for _, p in ipairs(patterns) do
		for match_start, link, match_end in line:gmatch("()" .. p.pattern .. "()") do
			-- Check if cursor is within the link
			if col >= match_start - 1 and col < match_end then
				return link, p.type
			end
		end
	end

	-- If no link found in standard format, try to extract URL directly
	-- Pattern for bare URLs
	local url_pattern = "https?://[%w-_%.%?%.:/%+=&]+"
	for url in line:gmatch(url_pattern) do
		local url_start, url_end = line:find(url, 1, true)
		if url_start and col >= url_start - 1 and col < url_end then
			return url, "url"
		end
	end

	return nil, nil
end

-- Determine if link is external URL
function M.is_external_url(link)
	return link:match("^https?://") ~= nil
end

-- Open external URL in browser
function M.open_external_url(url)
	local cmd
	if vim.fn.has("mac") == 1 then
		cmd = "open"
	elseif vim.fn.has("unix") == 1 then
		cmd = "xdg-open"
	elseif vim.fn.has("win32") == 1 then
		cmd = "start"
	else
		vim.notify("Unsupported platform for opening URLs", vim.log.levels.ERROR)
		return
	end

	vim.fn.jobstart({ cmd, url }, { detach = true })
	vim.notify("Opening URL: " .. url, vim.log.levels.INFO)
end

-- Resolve markdown file path
function M.resolve_markdown_path(link, link_type)
	local current_file = vim.api.nvim_buf_get_name(0)
	local current_dir = vim.fn.fnamemodify(current_file, ":h")
	local target_path

	if link_type == "obsidian" then
		-- For obsidian links, search in vault directory
		-- Get obsidian vault path from plugin config if available
		local vault_path = vim.fn.expand("~/ghq/github.com/saeeeeru/obsidian")
		target_path = vault_path .. "/" .. link .. ".md"
	else
		-- For standard markdown links, handle relative and absolute paths
		if link:match("^/") then
			-- Absolute path
			target_path = link
		else
			-- Relative path
			target_path = current_dir .. "/" .. link
		end

		-- Add .md extension if not present
		if not target_path:match("%.md$") then
			target_path = target_path .. ".md"
		end
	end

	-- Normalize path
	target_path = vim.fn.fnamemodify(target_path, ":p")

	return target_path
end

-- Open markdown file in new tab
function M.open_markdown_file(filepath)
	-- Check if file exists
	if vim.fn.filereadable(filepath) == 1 then
		vim.cmd("tabnew " .. vim.fn.fnameescape(filepath))
		vim.notify("Opened: " .. filepath, vim.log.levels.INFO)
	else
		vim.notify("File not found: " .. filepath, vim.log.levels.WARN)
	end
end

-- Main function to open link under cursor
function M.open_link()
	local link, link_type = M.get_link_under_cursor()

	if not link then
		vim.notify("No link found under cursor", vim.log.levels.WARN)
		return
	end

	if M.is_external_url(link) then
		M.open_external_url(link)
	else
		local filepath = M.resolve_markdown_path(link, link_type)
		M.open_markdown_file(filepath)
	end
end

return M
