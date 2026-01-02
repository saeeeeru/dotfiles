return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    { '<Tab>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
    { '<S-Tab>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Previous Buffer' },
    { '<leader>bd', '<cmd>bdelete<cr>', desc = 'Delete Buffer' },
    { '<leader>bp', '<cmd>BufferLineTogglePin<cr>', desc = 'Pin Buffer' },
  },
  opts = {
    options = {
      mode = "buffers",
      separator_style = "slant",
      always_show_bufferline = true,
      show_buffer_close_icons = true,
      show_close_icon = true,
      diagnostics = "nvim_lsp",
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          text_align = "center",
          separator = true,
        }
      },
    },
  },
}
