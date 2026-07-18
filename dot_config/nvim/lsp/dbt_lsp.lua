-- dbt Fusion 同梱の LSP（`dbt lsp` サブコマンド、stdio モード）
-- 公式サポートは VS Code 拡張のみ。Neovim からの利用は非公式
-- --static-analysis off: warehouse introspection を無効化。
--   externalbrowser (SSO) 認証のプロジェクトではスキーマ取得で
--   ブロックし補完・definition が返らなくなるため必須
return {
  filetypes = { "sql", "yaml" },
  root_markers = { "dbt_project.yml" },
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
