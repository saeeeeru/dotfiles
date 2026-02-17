-- statusline is handled by lualine.nvim
vim.opt.laststatus = 3

-- スクロール高速化設定
vim.opt.lazyredraw = true        -- マクロ実行中などに再描画を遅延させる
vim.opt.ttyfast = true            -- 高速ターミナル接続を前提とした描画
vim.opt.updatetime = 100          -- スワップファイル書き込みとCursorHoldイベントの遅延(デフォルト4000ms)
vim.opt.timeoutlen = 300          -- キーマッピングのタイムアウト(デフォルト1000ms)
vim.opt.ttimeoutlen = 10          -- キーコードのタイムアウト
vim.opt.redrawtime = 1500         -- 構文ハイライトのタイムアウト
vim.opt.regexpengine = 1          -- 旧正規表現エンジンを使用(場合によっては高速)

-- スクロール時のコンテキスト行数
vim.opt.scrolloff = 8             -- カーソル上下に常に8行表示
vim.opt.sidescrolloff = 8         -- カーソル左右に常に8列表示

-- カーソル行のハイライトを無効化(重い場合)
-- vim.opt.cursorline = false
