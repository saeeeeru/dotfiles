return {
  "hedyhli/outline.nvim",
  cmd = { "Outline", "OutlineOpen" },
  keys = {
    { "<leader>o", "<cmd>Outline<cr>", desc = "Toggle outline" },
  },
  opts = {
    outline_window = {
      position = "right",
      width = 25,
      relative_width = true,
      auto_close = false,
      -- 開いたあともカーソルは本文側に残す
      focus_on_open = false,
      show_cursorline = true,
      hide_cursor = true,
      wrap = false,
    },
    outline_items = {
      -- 本文のカーソル位置に対応する見出しをハイライトし続ける
      highlight_hovered_item = true,
      auto_set_cursor = true,
      auto_update_events = {
        follow = { "CursorMoved" },
        items = { "InsertLeave", "WinEnter", "BufEnter", "BufWinEnter", "TabEnter", "BufWritePost", "TextChanged" },
      },
    },
    guides = {
      enabled = true,
    },
    symbol_folding = {
      autofold_depth = false,
      auto_unfold = {
        hovered = true,
      },
    },
    preview_window = {
      auto_preview = false,
    },
    keymaps = {
      goto_location = "<CR>",
      peek_location = "o",
      goto_and_close = "<S-CR>",
      fold_toggle = "<Tab>",
      fold_all = "W",
      unfold_all = "E",
      close = { "<Esc>", "q" },
    },
    providers = {
      priority = { "lsp", "markdown", "norg" },
    },
  },
}
