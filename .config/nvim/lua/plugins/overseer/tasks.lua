local M = {}

--- @type overseer.TemplateDefinition[]
local tasks = {
  {
    name = "Run Python Script",
    params = {},
    condition = {
      filetype = "python",
    },
    builder = function()
      --- @type overseer.TaskDefinition
      return {
        cmd = { "python" },
        args = { vim.fn.expand "%:t" },
        cwd = vim.fn.expand "%:h",
      }
    end,
  },
}

function M.setup()
  for _, task in ipairs(tasks) do
    require("overseer").register_template(task)
  end
  require "overseer.component"
end

return M
