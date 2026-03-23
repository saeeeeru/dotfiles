-- statusline is handled by lualine.nvim
vim.opt.laststatus = 3

-- スクロール高速化設定
-- vim.opt.lazyredraw = true     -- Neovimでは非推奨: visual modeでのフリーズを引き起こす
vim.opt.ttyfast = true            -- 高速ターミナル接続を前提とした描画
vim.opt.updatetime = 100          -- スワップファイル書き込みとCursorHoldイベントの遅延(デフォルト4000ms)
vim.opt.timeoutlen = 300          -- キーマッピングのタイムアウト(デフォルト1000ms)
vim.opt.ttimeoutlen = 10          -- キーコードのタイムアウト
vim.opt.redrawtime = 1500         -- 構文ハイライトのタイムアウト
vim.opt.regexpengine = 1          -- 旧正規表現エンジンを使用(場合によっては高速)

-- 行末の1文字先まで移動可能にする
vim.opt.virtualedit = "onemore"

-- スクロール時のコンテキスト行数
vim.opt.scrolloff = 8             -- カーソル上下に常に8行表示
vim.opt.sidescrolloff = 8         -- カーソル左右に常に8列表示

-- カーソル行のハイライトを無効化(重い場合)
-- vim.opt.cursorline = false

-- fold (nvim-ufo で管理)
vim.opt.foldcolumn = "1"      -- fold の深さを左端に表示
