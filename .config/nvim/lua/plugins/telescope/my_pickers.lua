local M = {}

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

---@class GinaAction
---@field name string
---@field cmd string

---@type GinaAction[]
local GINA_ACTIONS = {
  { name = "push", cmd = "Gina push" },
  { name = "pull rebase", cmd = "Gina pull --rebase" },
  { name = "pull ff", cmd = "Gina pull --no-rebase --ff-only" },
}

-- git subcommands
M.gina_action_list = function(opts)
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = "gina actions",
      finder = finders.new_table {
        results = GINA_ACTIONS,
        ---@param entry GinaAction
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.name,
            ordinal = entry.name,
          }
        end,
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          -- print(":" .. selection.value.cmd)
          vim.cmd(selection.value.cmd)
        end)
        return true
      end,
    })
    :find()
end

return M
