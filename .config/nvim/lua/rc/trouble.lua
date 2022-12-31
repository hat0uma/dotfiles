local M = {}
local mode_cycle = {
  "document_diagnostics",
  "workspace_diagnostics",
}
local current_mode = "document_diagnostics"
function M.toggle()
  require("trouble").toggle { mode = current_mode }
end

local function cycle_mode()
  for index, mode in ipairs(mode_cycle) do
    if mode == current_mode then
      local next_index = (index % #mode_cycle) + 1
      current_mode = mode_cycle[next_index]
      break
    end
  end
  require("trouble").open { mode = current_mode }
end

local function winbar_item(item)
  return "%#" .. item.hl .. "#" .. item.text .. "%#Normal#"
end

function _G.trouble_winbar()
  local items = {}
  for _, mode in ipairs(mode_cycle) do
    local hl = mode == current_mode and "TroubleWinBarActiveMode" or "TroubleWinBarInactiveMode"
    table.insert(items, winbar_item { hl = hl, text = mode })
  end
  return " " .. table.concat(items, " ")
end

function M.config()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "Trouble",
    callback = function()
      local opts = { noremap = true, buffer = true }
      vim.keymap.set("n", "<leader><leader>", cycle_mode, opts)
      vim.wo.winbar = "%!v:lua.trouble_winbar()"
    end,
  })

  require("trouble").setup {
    padding = false,
    auto_preview = false,
    workspace_diagnostics_severity = { min = vim.diagnostic.severity.HINT },
    document_diagnostics_severity = { min = vim.diagnostic.severity.HINT },
  }
end

return M
