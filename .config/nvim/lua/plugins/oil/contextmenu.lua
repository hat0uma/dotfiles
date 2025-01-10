local M = {}

---@alias rc.OilContextMenuAction fun(entry:string,dir:string)

---@class rc.OilContextMenuItem
---@field entry_type oil.EntryType | "all"
---@field pattern string
---@field name string
---@field action rc.OilContextMenuAction

---@type rc.OilContextMenuItem[]
local menu_registry = {}

--- Add context menu
---@param entry_type oil.EntryType | "all"
---@param ext string[]|string|nil see `lua-patterns`
---@param name string
---@param action rc.OilContextMenuAction
local function add_action(entry_type, ext, name, action)
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

--- Add context menu for system command
---@param entry_type oil.EntryType | "all"
---@param ext string[]|string|nil see `lua-patterns`
---@param name string action name
---@param cmd string[] command {entry} and {dir} will be replaced
local function add_system_action(entry_type, ext, name, cmd)
  add_action(entry_type, ext, name, function(entry, dir)
    local args = {}
    for i, v in ipairs(cmd) do
      local arg = v:gsub("{entry}", entry):gsub("{dir}", dir)
      table.insert(args, arg)
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
      choice.action(entry.name, dir)
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
  require("telescope").extensions.live_grep_args.live_grep_args({
    cwd = dir,
    preview = { hide_on_startup = true },
  })
end

local function find_files(entry, dir)
  require("oil").close()
  require("telescope.builtin").find_files({
    cwd = dir,
  })
end

function M.setup()
  -------------------------------------
  -- general menu
  -------------------------------------
  add_action("all", nil, "Copy Path", copy_absolute_path)
  -- add_action("all", nil, "Open File", open_file)
  -- add_action("all", nil, "Open Explorer Here", open_folder)
  add_system_action("all", nil, "Open File", rc.sys.get_open_command("{entry}"))
  add_system_action("all", nil, "Open Explorer Here", rc.sys.get_open_command("."))
  add_action("all", nil, "Open Terminal Here", open_terminal)
  add_action("all", nil, "(Telescope)Grep Here", grep)
  add_action("all", nil, "(Telescope)Find Files Here", find_files)

  -------------------------------------
  -- file specific menu
  -------------------------------------
  add_action("file", { "jpg", "jpeg", "png" }, "Open Image in terminal", open_image)
  add_system_action("file", "zip", "(System)Extract", { "unzip", "{entry}" })
  add_system_action("file", { "tar", "tgz", "tar%.gz" }, "(System)Extract", { "tar", "xvf", "{entry}" })

  -------------------------------------
  -- folder specific menu
  -------------------------------------
  add_system_action("directory", nil, "Archive Folder .tgz", { "tar", "czvf", "{entry}.tgz", "{entry}" })
  add_system_action("directory", nil, "Archive Folder .zip", { "zip", "-r", "{entry}.zip", "{entry}" })
end

return M
