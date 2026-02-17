return {
	"preservim/vim-markdown",
	ft = { "markdown" },
	dependencies = {
		"godlygeek/tabular", -- Required for table formatting
	},
	init = function()
		-- Disable default key mappings (we'll use the navigation ones)
		vim.g.vim_markdown_no_default_key_mappings = 0

		-- Enable TOC window auto-fit
		vim.g.vim_markdown_toc_autofit = 1

		-- Highlight YAML front matter
		vim.g.vim_markdown_frontmatter = 1

		-- Highlight TOML front matter
		vim.g.vim_markdown_toml_frontmatter = 1

		-- Highlight JSON front matter
		vim.g.vim_markdown_json_frontmatter = 1

		-- Enable strikethrough
		vim.g.vim_markdown_strikethrough = 1

		-- Disable folding (optional, uncomment if you want folding)
		vim.g.vim_markdown_folding_disabled = 1

		-- Set header folding level (if folding is enabled)
		-- vim.g.vim_markdown_folding_level = 2

		-- Follow anchor links
		vim.g.vim_markdown_follow_anchor = 1

		-- Enable auto write when following links
		vim.g.vim_markdown_autowrite = 1

		-- Conceal for links and emphasis
		vim.g.vim_markdown_conceal = 2
		vim.g.vim_markdown_conceal_code_blocks = 0

		-- Math support
		vim.g.vim_markdown_math = 1
	end,
}
