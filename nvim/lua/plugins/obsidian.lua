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
  end,
}
