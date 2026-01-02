return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      theme = 'auto',  -- カラースキームに自動適応
      component_separators = { left = '|', right = '|'},
      section_separators = { left = '', right = ''},
      globalstatus = true,  -- 分割ウィンドウで1つのステータスライン
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', 'diff', 'diagnostics'},
      lualine_c = {'filename'},
      lualine_x = {'encoding', 'fileformat', 'filetype'},
      lualine_y = {'progress'},
      lualine_z = {'location'}
    },
  },
}
