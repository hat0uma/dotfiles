local M = {}

---@alias rc.OilContextMenuAction async fun(entry:string,dir:string):nil

---@class rc.OilContextMenuItem
---@field entry_type oil.EntryType | "all"
---@field pattern string
---@field name string
---@field action rc.OilContextMenuAction

---@type rc.OilContextMenuItem[]
local menu_registry = {}

--- Add context menu
---@param name string
---@param entry_type oil.EntryType | "all"
---@param ext string[]|string|nil see `lua-patterns`
---@param action rc.OilContextMenuAction
local function add_action(name, entry_type, ext, action)
  if ext == nil then
    local pattern = ".*"
    table.insert(menu_registry, { entry_type = entry_type, pattern = pattern, name = name, action = action })
  else
    if type(ext) == "string" then
      ext = { ext }
    end
    for _, e in ipairs(ext) do
      local pattern = ("%." .. e .. "$")
      table.insert(menu_registry, { entry_type = entry_type, pattern = pattern, name = name, action = action })
    end
  end
end

--- Run Commands in terminal
---@param dir string
---@param cmd string[]
local function run_in_terminal(dir, cmd)
  local Terminal = require("toggleterm.terminal").Terminal
  local term = Terminal:new({
    hidden = true,
    close_on_exit = false,
    dir = dir,
    direction = "float",
    cmd = table.concat(cmd, " "),
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
end

--- Add context menu for system command
---@param name string action name
---@param entry_type oil.EntryType | "all"
---@param ext string[]|string|nil see `lua-patterns`
---@param cmd string[] command {entry} and {dir} will be replaced
local function add_system_action(name, entry_type, ext, cmd)
  add_action(name, entry_type, ext, function(entry, dir)
    local args = {}
    for _, v in ipairs(cmd) do
      local arg = v:gsub("{entry}", entry):gsub("{dir}", dir)
      table.insert(args, arg)
    end

    -- run command in terminal
    run_in_terminal(dir, args)
  end)
end

--- Open context menu
M.open = {
  desc = "Open context menu",
  callback = function()
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
      if menu.entry_type == "all" or menu.entry_type == entry.type then
        if string.match(entry.name, menu.pattern) then
          table.insert(target_menus, menu)
        end
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

      -- create action coroutine
      local thread = coroutine.create(function() --- @async
        local _, err = xpcall(choice.action, debug.traceback, entry.name, dir)
        if err then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end)

      -- resume
      local co_ok, co_err = coroutine.resume(thread)
      if not co_ok then
        vim.notify("failed to start connection coroutine: %s", co_err or "")
      end
    end)
  end,
}

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

--- Open file
---@param entry string
---@param dir string
local function open_file(entry, dir)
  vim.ui.open(vim.fs.normalize(vim.fs.joinpath(dir, entry)))
end

--- Open folder
---@param entry string
---@param dir string
local function open_folder(entry, dir)
  vim.ui.open(vim.fs.normalize(dir))
end

--- Open terminal
---@param entry string
---@param dir string
local function open_terminal(entry, dir)
  local Terminal = require("toggleterm.terminal").Terminal
  local term = Terminal:new({
    dir = dir,
    direction = "float",
  })
  term:toggle()
end

--- Open image
---@param entry string
---@param dir string
local function open_image(entry, dir)
  rc.img.open(entry, {
    cwd = dir,
    keep_focus = true,
  })
end

local function grep(entry, dir)
  require("oil").close()
  require("snacks").picker.grep({
    cwd = dir,
  })
end

local function find_files(entry, dir)
  require("oil").close()
  require("snacks").picker.files({
    cwd = dir,
  })
end

---@async
---@param entry string
---@param dir string
local function archive_folder(entry, dir)
  local thread = coroutine.running()
  vim.ui.select({ "zip", "tgz", "7zip" }, { prompt = "Archive Type" }, function(choice)
    coroutine.resume(thread, choice)
  end)

  local choice = coroutine.yield(thread) --- @type string?
  if not choice then
    return
  end

  local cmd = {
    zip = { "zip", "-r", entry .. ".zip", entry },
    tgz = { "tar", "czvf", entry .. ".tgz", entry },
    ["7zip"] = { "7zG", "-ad", "a", entry, entry }, -- open GUI dialog
  }

  run_in_terminal(dir, cmd[choice])
end

function M.setup()
  ---format menu name
  ---@overload fun(name:string):string
  ---@overload fun(category: string, name:string):string
  local function fmt(...)
    local args = { ... } --- @type string[]
    if #args == 1 then
      return args[1]
    elseif #args == 2 then
      local category, name = unpack(args)
      return string.format("%-12s - %s", "(" .. category .. ")", name)
    else
      error(string.format("invalid argument: %s", vim.inspect(args)))
    end
  end

  -------------------------------------
  -- general menu
  -------------------------------------
  add_system_action(fmt("Open"), "all", nil, rc.sys.get_open_command("{entry}"))
  add_action(fmt("Copy Path"), "all", nil, copy_absolute_path)
  -- add_action(fmt("Open File"), "all", nil, open_file)
  -- add_action(fmt("Explorer Here"), "all", nil, open_folder)
  add_system_action(fmt("Explorer Here"), "all", nil, rc.sys.get_open_command("."))
  add_action(fmt("Terminal Here"), "all", nil, open_terminal)
  add_action(fmt("Picker", "Grep Here"), "all", nil, grep)
  add_action(fmt("Picker", "Find Files Here"), "all", nil, find_files)
  add_action(fmt("System", "Archive"), "all", nil, archive_folder)

  -------------------------------------
  -- file specific menu
  -------------------------------------
  -- images
  add_action(fmt("Open Image in terminal"), "file", { "jpg", "jpeg", "png" }, open_image)

  -- archive files
  add_system_action(fmt("System", "Extract"), "file", "7z", { "7z", "x", "{entry}" })
  add_system_action(fmt("System", "Extract"), "file", "zip", { "unzip", "{entry}" })
  add_system_action(fmt("System", "Extract"), "file", { "tar", "tgz", "tar%.gz" }, { "tar", "xvf", "{entry}" })
  add_system_action(fmt("System", "7zFM"), "file", { "tar", "tgz", "tar%.gz", "zip", "7z" }, { "7zfm", "{entry}" })

  -------------------------------------
  -- folder specific menu
  -------------------------------------
  -- none
end

return M
