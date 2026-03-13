return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ghq.nvim',
  },
  lazy = false,
  keys = {
    -- ファイル検索
    { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find Files' },
    { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Live Grep' },
    { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Buffers' },
    { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = 'Help Tags' },
    -- 最近使ったファイル
    { '<leader>fr', '<cmd>Telescope oldfiles<cr>', desc = 'Recent Files' },
    -- GHQリポジトリ検索
    {
      '<leader>fq',
      function()
        require('telescope').extensions.ghq.list({
          attach_mappings = function(prompt_bufnr, map)
            local actions = require('telescope.actions')
            local action_state = require('telescope.actions.state')

            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              vim.api.nvim_set_current_dir(selection.value)
              print('Changed directory to: ' .. selection.value)
            end)
            return true
          end,
        })
      end,
      desc = 'GHQ Repositories'
    },
    -- Worktree切り替え
    {
      '<leader>fw',
      function()
        local results = {}
        local handle = io.popen('git worktree list --porcelain 2>/dev/null')
        if handle then
          local current = vim.fn.getcwd()
          local worktree_path = nil
          for line in handle:lines() do
            local path = line:match('^worktree (.+)$')
            local branch = line:match('^branch refs/heads/(.+)$')
            if path then
              worktree_path = path
            elseif branch and worktree_path then
              table.insert(results, { path = worktree_path, branch = branch, is_current = worktree_path == current })
              worktree_path = nil
            elseif line == '' then
              worktree_path = nil
            end
          end
          handle:close()
        end

        if #results == 0 then
          print('No worktrees found')
          return
        end

        local pickers = require('telescope.pickers')
        local finders = require('telescope.finders')
        local conf = require('telescope.config').values
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')

        pickers.new({}, {
          prompt_title = 'Git Worktrees',
          finder = finders.new_table({
            results = results,
            entry_maker = function(entry)
              local display = (entry.is_current and '* ' or '  ') .. entry.branch .. '  ' .. entry.path
              return { value = entry.path, display = display, ordinal = entry.branch .. entry.path }
            end,
          }),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              vim.api.nvim_set_current_dir(selection.value)
              print('Changed directory to: ' .. selection.value)
            end)
            return true
          end,
        }):find()
      end,
      desc = 'Git Worktrees'
    },
    -- Git関連
    { '<leader>gc', '<cmd>Telescope git_commits<cr>', desc = 'Git Commits' },
    { '<leader>gs', '<cmd>Telescope git_status<cr>', desc = 'Git Status' },
    -- LSP関連
    { '<leader>lr', '<cmd>Telescope lsp_references<cr>', desc = 'LSP References' },
    { '<leader>ld', '<cmd>Telescope lsp_definitions<cr>', desc = 'LSP Definitions' },
    { '<leader>ls', '<cmd>Telescope lsp_document_symbols<cr>', desc = 'Document Symbols' },
  },
  config = function()
    local actions = require('telescope.actions')
    require('telescope').setup({
      defaults = {
        mappings = {
          i = {
            -- Ctrl+jでプレビュー下スクロール
            ['<C-j>'] = actions.preview_scrolling_down,
            -- Ctrl+kでプレビュー上スクロール
            ['<C-k>'] = actions.preview_scrolling_up,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true, -- 隠しファイルを表示
          find_command = {
            "rg",
            "--files",
            "--hidden",
            "--glob", "!.git/*",
            "--glob", "!.worktrees/*",
          },
        },
      },
    })
    -- GHQ拡張を読み込み
    require('telescope').load_extension('ghq')
  end,
}
