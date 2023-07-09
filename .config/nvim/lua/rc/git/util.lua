local M = {}
function M.list_partition(predicate, list)
  local part1 = {}
  local part2 = {}
  for _, value in ipairs(list) do
    if predicate(value) then
      table.insert(part1, value)
    else
      table.insert(part2, value)
    end
  end
  return part1, part2
end

function M.setInterval(interval, callback)
  local timer = vim.loop.new_timer()
  timer:start(interval, interval, function()
    callback()
  end)
  return timer
end

function M.clearInterval(timer)
  timer:stop()
  timer:close()
end

--- get git directory
---@param buf string
---@return string?
function M.get_git_dir(buf)
  return unpack(vim.fs.find(".git", {
    upward = true,
    type = "directory",
    stop = vim.loop.os_homedir(),
    path = buf and vim.fs.dirname(buf) or vim.loop.cwd(),
  }))
end

--- is git-svn's directory
---@param git_dir string
---@return boolean
function M.is_gitsvn_dir(git_dir)
  return vim.fn.isdirectory(vim.fs.joinpath(git_dir, "svn")) == 1
end

return M
