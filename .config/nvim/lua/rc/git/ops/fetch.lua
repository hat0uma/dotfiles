local util = require "rc.git.util"
local M = {}

--- run fetch
---@return SystemObj?
function M.run()
  local git_dir = util.get_git_dir(vim.api.nvim_buf_get_name(0))
  if git_dir == nil then
    return nil
  end

  local cmd
  if util.is_gitsvn_dir(git_dir) then
    cmd = { "git", "svn", "fetch" }
  else
    cmd = { "git", "fetch" }
  end

  ---@type fun(obj:SystemCompleted)
  local on_exit = function(obj)
    if obj.code ~= 0 then
      vim.notify("fetch failed.\n" .. obj.stderr, "WARN")
    end
  end
  return vim.system(cmd, { text = true }, on_exit)
end

return M
