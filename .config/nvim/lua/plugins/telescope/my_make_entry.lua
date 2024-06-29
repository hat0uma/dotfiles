local M = {}

local Path = require "plenary.path"
local devicons = require "nvim-web-devicons"
local entry_display = require "telescope.pickers.entry_display"

local lookup_keys = {
  ordinal = 1,
  value = 1,
  filename = 1,
  cwd = 2,
}
function M.gen_from_files_prioritize_basename(opts)
  opts = opts or {}

  local cwd = vim.fn.expand(opts.cwd or vim.loop.cwd())
  local mt_file_entry = {}
  mt_file_entry.cwd = cwd

  local displayer = entry_display.create {
    separator = " ",
    items = {
      {}, -- devicon
      {}, -- filename
      {}, -- dirname
    },
  }

  mt_file_entry.display = function(entry)
    local icon, highlight = devicons.get_icon(entry.value, string.match(entry.value, "%a+$"), { default = true })
    entry.value = vim.fs.normalize(entry.value)
    local dir_name = vim.fn.fnamemodify(entry.value, ":p:~:.:h")
    local file_name = vim.fn.fnamemodify(entry.value, ":p:t")
    return displayer {
      { icon, highlight },
      file_name,
      { dir_name, "Comment" },
    }
  end

  mt_file_entry.__index = function(t, k)
    local raw = rawget(mt_file_entry, k)
    if raw then
      return raw
    end

    if k == "path" then
      return t.value
    end

    return rawget(t, rawget(lookup_keys, k))
  end

  return function(line)
    return setmetatable({ line }, mt_file_entry)
  end
end

return M
