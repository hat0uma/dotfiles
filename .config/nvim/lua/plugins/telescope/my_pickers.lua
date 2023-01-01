local M = {}

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

-- git subcommands
M.gina_action_list = function(opts)
  local p_action_list = {
    { name = "push", cmd = "Gina push" },
    { name = "pull rebase", cmd = "Gina pull --rebase" },
    { name = "pull ff", cmd = "Gina pull --no-rebase --ff-only" },
  }

  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = "gina actions",
      finder = finders.new_table {
        results = p_action_list,
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
