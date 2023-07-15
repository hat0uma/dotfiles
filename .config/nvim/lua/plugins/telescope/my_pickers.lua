local M = {}

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

---@class EditAction
---@field name string
---@field target function

---@type Action[]
local EDIT_ACTIONS = {
  { name = 'stdpath("cache")', target = vim.fn.stdpath "cache" },
  { name = 'stdpath("config")', target = vim.fn.stdpath "config" },
  { name = 'stdpath("data")', target = vim.fn.stdpath "data" },
  { name = 'stdpath("state")', target = vim.fn.stdpath "state" },
}

-- git subcommands
M.show_paths = function(opts)
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = "paths",
      finder = finders.new_table {
        results = EDIT_ACTIONS,
        ---@param entry EditAction
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
          vim.cmd.edit(selection.value.target)
        end)
        return true
      end,
    })
    :find()
end

return M
