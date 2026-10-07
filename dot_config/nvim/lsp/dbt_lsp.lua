-- dbt Fusion 同梱の LSP（`dbt lsp` サブコマンド、stdio モード）
-- 公式サポートは VS Code 拡張のみ。Neovim からの利用は非公式
-- --static-analysis off: warehouse introspection を無効化。
--   externalbrowser (SSO) 認証のプロジェクトではスキーマ取得で
--   ブロックし補完・definition が返らなくなるため必須

-- compile 自身が dbt_packages/ や target/ を書き換えるため、その変更を通知すると
-- compile が再起動し続ける。プロジェクト外扱いのパスの変更は LSP に渡さない
local ignored_prefixes = { "dbt_packages/", "target/", "logs/", ".git/", ".claude/", "package-lock.yml" }

local function is_ignored(root_dir, uri)
  local rel = vim.uri_to_fname(uri):sub(#root_dir + 2)
  for _, prefix in ipairs(ignored_prefixes) do
    if vim.startswith(rel, prefix) then
      return true
    end
  end
  return false
end

return {
  filetypes = { "sql", "yaml" },
  root_markers = { "dbt_project.yml" },
  on_init = function(client)
    local notify = client.notify
    client.notify = function(self, method, params)
      if method == "workspace/didChangeWatchedFiles" then
        local changes = vim.tbl_filter(function(change)
          return not is_ignored(self.root_dir, change.uri)
        end, params.changes)
        if #changes == 0 then
          return true
        end
        params = vim.tbl_extend("force", params, { changes = changes })
      end
      return notify(self, method, params)
    end
  end,
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
