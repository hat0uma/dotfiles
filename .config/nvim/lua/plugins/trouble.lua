--- @type { name:string , opts:trouble.Mode }[]
local MODE_CYCLE = {
  {
    name = "document_diagnostics",
    opts = {
      mode = "diagnostics",
      --- @param items trouble.Item[]
      --- @return trouble.Item[]
      filter = function(items)
        local buf = vim.api.nvim_get_current_buf()
        return vim.tbl_filter(function(item)
          return item.buf == buf
        end, items)
      end,
    },
  },
  {
    name = "workspace_diagnostics",
    opts = {
      mode = "diagnostics",
    },
  },
  {
    name = "todo",
    opts = {
      mode = "todo",
    },
  },
}
local current_mode = MODE_CYCLE[1]

local function toggle()
  require("trouble").toggle(current_mode.opts)
end

local M = {
  "folke/trouble.nvim",
  cond = not vim.g.vscode,
  dependencies = {
    "kyazdani42/nvim-web-devicons",
    "todo-comments.nvim",
  },
  keys = {
    { "<leader>q", toggle, "n" },
  },
}

local function cycle_mode()
  for index, mode in ipairs(MODE_CYCLE) do
    if mode == current_mode then
      local next_index = (index % #MODE_CYCLE) + 1
      current_mode = MODE_CYCLE[next_index]
      break
    end
  end
  if require("trouble").is_open() then
    require("trouble").close()
  end
  require("trouble").open(current_mode.opts)
end

--- @param item WinbarItem
--- @return string
local function winbar_item(item)
  return "%#" .. item.hlgroup .. "#" .. item.text .. "%#Normal#"
end

function M.winbar()
  local items = {}
  for _, mode in ipairs(MODE_CYCLE) do
    local hl = mode == current_mode and "TroubleWinBarActiveMode" or "TroubleWinBarInactiveMode"
    table.insert(items, winbar_item({ hlgroup = hl, text = mode.name }))
  end
  return " " .. table.concat(items, " ")
end

function M.config()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "trouble",
    callback = function()
      local opts = { noremap = true, buffer = true }
      vim.keymap.set("n", "<leader><leader>", cycle_mode, opts)
    end,
  })

  require("trouble").setup({
    padding = false,
    auto_preview = false,
    warn_no_results = false,
    open_no_results = true,
    focus = true,
    modes = {
      diagnostics = {
        groups = { { "filename", format = "{file_icon} {basename} {hl:Conceal}{dirname}{hl} {count}" } },
      },
    },
  })
end
return M
