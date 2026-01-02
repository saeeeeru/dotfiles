return {
  'nvim-telescope/telescope.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    -- ファイル検索
    { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find Files' },
    { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Live Grep' },
    { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Buffers' },
    { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = 'Help Tags' },
    
    -- 最近使ったファイル
    { '<leader>fr', '<cmd>Telescope oldfiles<cr>', desc = 'Recent Files' },
    
    -- Git関連
    { '<leader>gc', '<cmd>Telescope git_commits<cr>', desc = 'Git Commits' },
    { '<leader>gs', '<cmd>Telescope git_status<cr>', desc = 'Git Status' },
    
    -- LSP関連
    { '<leader>lr', '<cmd>Telescope lsp_references<cr>', desc = 'LSP References' },
    { '<leader>ld', '<cmd>Telescope lsp_definitions<cr>', desc = 'LSP Definitions' },
    { '<leader>ls', '<cmd>Telescope lsp_document_symbols<cr>', desc = 'Document Symbols' },
  },
  opts = {
    defaults = {
      mappings = {
        i = {
          -- Ctrl+jでプレビュー下スクロール
          ['<C-j>'] = require('telescope.actions').preview_scrolling_down,
          -- Ctrl+kでプレビュー上スクロール
          ['<C-k>'] = require('telescope.actions').preview_scrolling_up,
        },
      },
    },
  },
}
