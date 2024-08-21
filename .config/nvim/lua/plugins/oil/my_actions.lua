local M = {}

M.state = {
  filename = "",
  dir = "",
  direction = "float",
}

--- move cursor
---@param name string
local function find(name)
  local lines = vim.fn.line("$")
  for i = 1, lines, 1 do
    local entry = require("oil").get_entry_on_line(0, i)
    if entry and entry.name == name then
      vim.cmd(string.format("%d", i))
      break
    end
  end
end

local function float_select(base)
  local oil = require("oil")
  local entry = oil.get_cursor_entry()
  if entry and entry.type == "directory" then
    local current = oil.get_current_dir()
    oil.close()
    oil.open(current)
  end
  base.callback()
end

M.float_select_vsplit = function()
  float_select(require("oil.actions").select_vsplit)
end

M.float_select_split = function()
  float_select(require("oil.actions").select_split)
end

function M.home()
  vim.cmd.edit(vim.fs.normalize("~"))
end

function M.toggle_tab()
  local oil = require("oil")
  local dir = oil.get_current_dir()
  if M.state.direction == "float" then
    oil.close()
    vim.cmd.tabedit(dir)
    M.state.direction = "tab"
  elseif M.state.direction == "tab" then
    vim.cmd.tabclose()
    oil.open_float(dir)
    M.state.direction = "float"
  else
  end
end

function M.close()
  if M.state.direction == "float" then
    require("oil").close()
  elseif M.state.direction == "tab" then
    vim.cmd.tabclose()
  else
  end
end

function M.find()
  find(M.state.filename)
end

function M.open()
  local buf = vim.api.nvim_buf_get_name(0)
  if vim.fn.filereadable(buf) ~= 0 then
    M.state.filename = vim.fs.basename(buf)
    M.state.dir = vim.fs.dirname(buf)
  else
    M.state.filename = ""
    M.state.dir = vim.loop.cwd()
  end

  -- move cursor
  vim.api.nvim_create_autocmd("User", {
    pattern = "OilEnter",
    callback = vim.schedule_wrap(function()
      find(M.state.filename)
    end),
    group = vim.api.nvim_create_augroup("my-oil-settings", {}),
    once = true,
  })

  if M.state.direction == "float" then
    require("oil").open_float(M.state.dir)
  elseif M.state.direction == "tab" then
    vim.cmd.tabedit(M.state.dir)
  else
    require("oil").open_float(M.state.dir)
    M.state.direction = "float"
  end
end

function M.select_open_stdpaths()
  local stdpaths = {
    { name = 'stdpath("cache")', target = vim.fn.stdpath("cache") },
    { name = 'stdpath("config")', target = vim.fn.stdpath("config") },
    { name = 'stdpath("data")', target = vim.fn.stdpath("data") },
    { name = 'stdpath("state")', target = vim.fn.stdpath("state") },
  }
  vim.ui.select(stdpaths, {
    prompt = "Select action",
    format_item = function(item)
      return item.name
    end,
  }, function(choice)
    if not choice then
      return
    end
    vim.cmd.edit(choice.target)
  end)
end
M.preview_image = {
  desc = "preview image",
  callback = function()
    local entry = assert(require("oil").get_cursor_entry())
    local dir = assert(require("oil").get_current_dir())
    local image_exts = {
      "png",
      "jpg",
      "jpeg",
    }

    local ext = vim.fn.fnamemodify(entry.name, ":e"):lower()
    if entry.type ~= "file" or not vim.tbl_contains(image_exts, ext) then
      print("cursor entry is not image.")
      return
    end

    require("rc.img").open(entry.name, {
      cwd = dir,
      direction = "bottom",
      keep_focus = true,
    })
  end,
}

return M
