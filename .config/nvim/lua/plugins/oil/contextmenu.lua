local Menu = require("nui.menu")

local M = {}

---@alias rc.OilContextMenuAction fun(entry:string,dir:string)

---@class rc.OilContextMenuItem
---@field pattern string
---@field name string
---@field action rc.OilContextMenuAction

---@type rc.OilContextMenuItem[]
local menu_registry = {}

--- Add context menu
---@param ext string|nil see `lua-patterns`
---@param name string
---@param action rc.OilContextMenuAction
local function add_action(ext, name, action)
  local pattern = not ext and ".*" or ("%." .. ext .. "$")
  table.insert(menu_registry, { pattern = pattern, name = name, action = action })
end

--- Add context menu for system command
---@param ext string|nil see `lua-patterns`
---@param name string action name
---@param cmd string[] command {file} and {dir} will be replaced
local function add_system_action(ext, name, cmd)
  add_action(ext, name, function(entry, dir)
    local args = {}
    for i, v in ipairs(cmd) do
      table.insert(args, vim.fn.shellescape((v:gsub("{file}", entry):gsub("{dir}", dir))))
    end

    local Terminal = require("toggleterm.terminal").Terminal
    local term = Terminal:new({
      hidden = true,
      close_on_exit = false,
      dir = dir,
      direction = "float",
      cmd = table.concat(args, " "),
      on_exit = function(t, job, exit_code, _name)
        if exit_code == 0 then
          t:close()
        end
      end,
      on_close = vim.schedule_wrap(function()
        -- refresh
        vim.cmd.edit()
      end),
    })
    term:toggle()
  end)
end

--- Open context menu
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
  local target_menus = {}
  for _, menu in ipairs(menu_registry) do
    if string.match(entry.name, menu.pattern) then
      table.insert(target_menus, menu)
    end
  end

  if vim.tbl_isempty(target_menus) then
    print("no actins for:" .. entry.name)
    return
  end

  vim.ui.select(target_menus, {
    prompt = "Select action",
    --- Format item
    ---@param item rc.OilContextMenuItem
    ---@return string
    format_item = function(item)
      return item.name
    end,
  }, function(choice) --- @param choice rc.OilContextMenuItem?
    if not choice then
      return
    end
    choice.action(entry.name, dir)
  end)
end

--- Copy entry absolute path
---@param entry string
---@param dir string
local function copy_absolute_path(entry, dir)
  local p = vim.fs.joinpath(dir, entry)
  local abspath, err = vim.uv.fs_realpath(p)
  if not abspath then
    error(string.format("Failed to get absolute path: %s", err))
  end

  -- yank and copy
  vim.fn.setreg('"0', abspath)
  vim.fn.setreg("+", abspath)
end

function M.setup()
  add_action(nil, "Copy path", copy_absolute_path)
  add_system_action(nil, "Open", { "explorer", "{file}" })
  add_system_action("zip", "Extract", { "unzip", "{file}" })
  add_system_action("tar", "Extract", { "tar", "xvf", "{file}" })
  add_system_action("tgz", "Extract", { "tar", "xvf", "{file}" })
  add_system_action("tar%.gz", "Extract", { "tar", "xvf", "{file}" })
end

return M
