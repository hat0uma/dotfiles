local M = {}

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

M.float_select_vsplit = {
  desc = "Select and open in vsplit",
  callback = function()
    float_select(require("oil.actions").select_vsplit)
  end,
}

M.float_select_split = {
  desc = "Select and open in split",
  callback = function()
    float_select(require("oil.actions").select_split)
  end,
}

M.home = {
  desc = "Go to home directory",
  callback = function()
    vim.cmd.edit(vim.uv.os_homedir())
  end,
}

M.toggle_tab = {
  desc = "Toggle view direction between tab and float",
  callback = function()
    local oil = require("oil")
    local state = require("plugins.oil.state")
    local dir = oil.get_current_dir()
    if state.direction == "float" then
      oil.close()
      vim.cmd.tabedit(dir)
      state.direction = "tab"
    elseif state.direction == "tab" then
      vim.cmd.tabclose()
      oil.open_float(dir)
      state.direction = "float"
    else
    end
  end,
}

M.close = {
  desc = "Close Oil",
  callback = function()
    local state = require("plugins.oil.state")
    if state.direction == "float" then
      require("oil").close()
    elseif state.direction == "tab" then
      vim.cmd.tabclose()
    else
    end
  end,
}

M.back_first_opened = {
  desc = "Back to first opened",
  callback = function()
    vim.cmd.edit(require("plugins.oil.state").dir)
  end,
}

M.select_open_stdpaths = {
  desc = "Select and open stdpaths",
  callback = function()
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
  end,
}
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

    rc.img.open(entry.name, {
      cwd = dir,
      direction = "bottom",
      keep_focus = true,
    })
  end,
}

return M
