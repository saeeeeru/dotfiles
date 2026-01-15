return {
  "epwalsh/obsidian.nvim",
  version = "*",  -- 最新の安定版を使用
  -- lazy = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/ghq/github.com/saeeeeru/obsidian",  -- あなたの Obsidian vault のパスに変更
      },
    },
    -- daily notes の設定
    daily_notes = {
      folder = "001_daily",  -- daily notes を保存するフォルダ
      date_format = "%Y-%m-%d",  -- ファイル名の日付フォーマット
      template = "TEMPLATE.md.md",  -- テンプレートファイルのパス
    },
    -- テンプレートの設定
    templates = {
      folder = "001_daily",  -- テンプレートフォルダ
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },
    -- UI を有効にして conceallevel を自動設定
    ui = {
      enable = true,
      checkboxes = {
        [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
        ["x"] = { char = "", hl_group = "ObsidianDone" },
      },
    },
  },
  -- markdown ファイルで conceallevel を設定
  config = function(_, opts)
    require("obsidian").setup(opts)
    vim.opt.conceallevel = 2

    -- Load markdown link handler
    local markdown_links = require("config.markdown-links")

    -- Set up keymaps for markdown files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()

        -- Keymap: gx to open link under cursor
        vim.keymap.set("n", "gx", function()
          markdown_links.open_link()
        end, { buffer = bufnr, desc = "Open link under cursor" })

        -- Keymap: <CR> (Enter) to open link under cursor
        vim.keymap.set("n", "<CR>", function()
          markdown_links.open_link()
        end, { buffer = bufnr, desc = "Open link under cursor" })

        -- Keymap: Double-click to open link
        vim.keymap.set("n", "<2-LeftMouse>", function()
          markdown_links.open_link()
        end, { buffer = bufnr, desc = "Open link with double-click" })
      end,
    })
  end,
}
