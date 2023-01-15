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
  -- require("oil").open_float(on_edit.dir)
  -- vim.cmd.tabnew()
  require("oil").open(on_edit.dir)
end

return {
  "stevearc/oil.nvim",
  init = function()
    vim.keymap.set("n", "-", open, { desc = "Open parent directory" })
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
        ["-"] = require("oil.actions").close,

        ["L"] = require("oil.actions").select,
        ["H"] = require("oil.actions").parent,
        ["S"] = require("oil.actions").select_split,
        ["V"] = require("oil.actions").select_vsplit,
        ["g."] = require("oil.actions").toggle_hidden,
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
