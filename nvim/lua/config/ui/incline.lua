-- lua/config/ui/incline.lua
local M = {}

function M.setup()
  local incline = require("incline")
  local devicons = require("nvim-web-devicons")

  -- diagnostics
  local function diagnostic_labels(buf)
    local icons = {
      error = "",
      warn  = "",
      info  = "",
      hint  = "",
    }

    local res = {}
    for severity, icon in pairs(icons) do
      local n = #vim.diagnostic.get(buf, {
        severity = vim.diagnostic.severity[string.upper(severity)],
      })
      if n > 0 then
        table.insert(res, {
          icon .. n .. " ",
          group = "DiagnosticSign" .. severity,
        })
      end
    end

    if #res > 0 then
      table.insert(res, { "┊ " })
    end
    return res
  end

  -- git diff
  local function git_diff(buf)
    local icons = {
      removed = "",
      changed = "",
      added   = "",
    }

    local res = {}
    local signs = vim.b[buf].gitsigns_status_dict
    if not signs then
      return res
    end

    for name, icon in pairs(icons) do
      local count = tonumber(signs[name])
      if count and count > 0 then
        table.insert(res, {
          icon .. count .. " ",
          group = "Diff" .. name,
        })
      end
    end

    if #res > 0 then
      table.insert(res, { "┊ " })
    end
    return res
  end

  incline.setup({
    render = function(props)
      local buf = props.buf
      local res = {}

      -- diagnostics
      for _, item in ipairs(diagnostic_labels(buf)) do
        table.insert(res, item)
      end

      -- git diff
      for _, item in ipairs(git_diff(buf)) do
        table.insert(res, item)
      end

      -- filename
      local filename =
        vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
      if filename == "" then
        filename = "[No Name]"
      end

      -- icon
      local icon, color = devicons.get_icon_color(filename)
      if icon then
        table.insert(res, {
          icon .. " ",
          guifg = color,
          guibg = "none",
        })
      end

      -- filename style
      table.insert(res, {
        filename .. " ",
        gui = vim.bo[buf].modified and "bold,italic" or "bold",
      })

      -- window number
      table.insert(res, {
        "┊  " .. vim.api.nvim_win_get_number(props.win),
        group = "DevIconWindows",
      })

      return res
    end,
  })

  -- gitsigns 更新で再描画
  vim.api.nvim_create_autocmd("User", {
    pattern = "GitsignsUpdated",
    callback = function()
      require("incline").update()
    end,
  })
end

return M

