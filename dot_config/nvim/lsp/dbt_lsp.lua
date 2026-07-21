-- dbt Fusion 同梱の LSP（`dbt lsp` サブコマンド、stdio モード）
-- 公式サポートは VS Code 拡張のみ。Neovim からの利用は非公式
-- --static-analysis off: warehouse introspection を無効化。
--   externalbrowser (SSO) 認証のプロジェクトではスキーマ取得で
--   ブロックし補完・definition が返らなくなるため必須
return {
  filetypes = { "sql", "yaml" },
  root_markers = { "dbt_project.yml" },
  -- compile 完了までリクエストはキューされ応答されないため、状態を通知で可視化する
  handlers = {
    ["dbt/lspCompileStart"] = function()
      vim.notify("dbt: compile 開始（初回は数分かかる）", vim.log.levels.INFO)
    end,
    ["dbt/lspCompileComplete"] = function()
      vim.notify("dbt: compile 完了 — 補完/gd が使えます", vim.log.levels.INFO)
    end,
  },
  cmd = function(dispatchers, config)
    return vim.lsp.rpc.start({
      "dbt", "lsp",
      "--project-dir", config.root_dir,
      "--static-analysis", "off",
    }, dispatchers, {
      cwd = config.root_dir,
      env = { DBT_PROJECT_DIR = config.root_dir },
    })
  end,
}
