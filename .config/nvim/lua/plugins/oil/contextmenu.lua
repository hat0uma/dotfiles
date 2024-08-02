local M = {}

---@alias rc.OilContextMenuAction fun(entry:string,dir:string)

---@class rc.OilContextMenuItem
---@field pattern string
---@field name string
---@field action rc.OilContextMenuAction

---@type rc.OilContextMenuItem[]
local menus = {}

--- Add context menu
---@param ext string|nil see `lua-patterns`
---@param name string
---@param action rc.OilContextMenuAction
local function add_action(ext, name, action)
  local pattern = not ext and ".*" or ("%." .. ext .. "$")
  table.insert(menus, { pattern = pattern, name = name, action = action })
end

--- Add context menu to a system command
---@param ext string|nil see `lua-patterns`
---@param name string
---@param cmd string[]
local function add_system(ext, name, cmd)
  add_action(ext, name, function(entry, dir)
    local args = {}
    for i, v in ipairs(cmd) do
      table.insert(args, vim.fn.shellescape((v:gsub("{file}", entry):gsub("{dir}", dir))))
    end

    local Terminal = require("toggleterm.terminal").Terminal
    local term = Terminal:new {
      hidden = true,
      close_on_exit = false,
      dir = dir,
      direction = "float",
      cmd = table.concat(args, " "),
      on_exit = function(t, job, exit_code, name)
        if exit_code == 0 then
          t:close()
        end
      end,
      on_close = vim.schedule_wrap(function()
        vim.cmd.edit()
      end),
    }
    term:toggle()
  end)
end

function M.open()
  local entry = require("oil").get_cursor_entry()
  if not entry then
    return
  end
  local dir = require("oil").get_current_dir()
  if not dir then
    return
  end

  ---@type rc.OilContextMenuItem[]
  local target_actions = {}
  for _, menu in ipairs(menus) do
    if string.match(entry.name, menu.pattern) then
      table.insert(target_actions, menu)
    end
  end

  if vim.tbl_isempty(target_actions) then
    print("no actins for:" .. entry.name)
    return
  end

  vim.ui.select(target_actions, {
    prompt = "Select file actions",
    format_item = function(item)
      return item.name
    end,
  }, function(choice) --- @param choice rc.OilContextMenuItem
    if not choice then
      return
    end

    choice.action(entry.name, dir)
  end)
end

add_system(nil, "Open", { "explorer", "{file}" })
add_system("zip", "Extract", { "unzip", "{file}" })
add_system("tar", "Extract", { "tar", "xvf", "{file}" })
add_system("tgz", "Extract", { "tar", "xvf", "{file}" })
add_system("tar%.gz", "Extract", { "tar", "xvf", "{file}" })

return M
