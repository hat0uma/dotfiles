local on_edit = {
  filename = "",
  dir = "",
}
local function open()
  local buf = vim.fn.expand "%:p"
  if vim.fn.filereadable(buf) ~= 0 then
    on_edit.filename = vim.fn.expand "%:p:t"
    on_edit.dir = vim.fn.expand "%:p:h"
  else
    on_edit.filename = ""
    on_edit.dir = vim.loop.cwd()
  end
  -- vim.cmd.tabnew()
  -- require("oil").open(on_edit.dir)
  require("oil").open_float(on_edit.dir)
end

local function select_for_float(base)
  return {
    desc = base.desc .. " for float",
    callback = function()
      local oil = require "oil"
      local entry = oil.get_cursor_entry()
      if entry and entry.type == "directory" then
        local current = oil.get_current_dir()
        oil.close()
        oil.open(current)
      end
      base.callback()
    end,
  }
end

return {
  "stevearc/oil.nvim",
  init = function()
    vim.keymap.set("n", "<leader>e", open, { desc = "Open current file directory" })
  end,
  config = function()
    require("oil").setup {
      columns = {
        "icon",
        -- "permissions",
        -- "size",
        -- "mtime",
      },
      use_default_keymaps = false,
      keymaps = {
        ["g?"] = require("oil.actions").show_help,
        ["q"] = require("oil.actions").close,
        ["<leader>e"] = require("oil.actions").close,

        ["L"] = require("oil.actions").select,
        ["H"] = require("oil.actions").parent,
        ["gv"] = select_for_float(require("oil.actions").select_vsplit),
        ["gs"] = select_for_float(require("oil.actions").select_split),
        ["g."] = require("oil.actions").toggle_hidden,
        ["gp"] = require("oil.actions").preview,
        ["~"] = function()
          vim.cmd.edit(vim.fn.fnamemodify("~", ":p"))
        end,
      },
      float = {
        padding = 2,
        max_width = math.floor(vim.o.columns * 0.7),
        max_height = math.floor(vim.o.lines * 0.7),
        border = "rounded",
        win_options = {
          winblend = 10,
        },
      },
      view_options = {
        show_hidden = true,
      },
    }
  end,
  cmd = { "Oil" },
}
