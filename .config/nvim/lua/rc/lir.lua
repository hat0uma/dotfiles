local Path = require "plenary.path"
local actions = require "lir.actions"
local mark_actions = require "lir.mark.actions"
local clipboard_actions = require "lir.clipboard.actions"

local M = {}
M.on_edit = {
  filename = "",
  dir = "",
}
--- toggle and save edtiting context.
function M.my_lir_toggle()
  local buf = vim.fn.expand "%:p"
  if vim.fn.filereadable(buf) ~= 0 then
    M.on_edit.filename = vim.fn.expand "%:p:t"
    M.on_edit.dir = vim.fn.expand "%:p:h"
  else
    M.on_edit.filename = ""
    M.on_edit.dir = vim.loop.cwd()
  end

  require("lir.float").toggle(M.on_edit.dir)
end

local my_actions = {}

--- search editing file in lir(no cd).
function my_actions.search_in_ctx_dir()
  local ctx = require("lir").get_context()
  local index = ctx:indexof(M.on_edit.filename)
  if index and index >= 1 then
    vim.cmd(string.format("%d", index))
  end
end

--- search editing file in lir(with cd).
function my_actions.search()
  vim.cmd("edit " .. M.on_edit.dir)
  my_actions.search_in_ctx_dir()
end

--- up with hold cursor.
function my_actions.up_hold()
  local ctx = require("lir").get_context()
  local dir = string.gsub(ctx.dir, Path.path.sep .. "$", "")
  dir = vim.fn.fnamemodify(dir, ":t")

  require("lir.actions").up()
  local ctx_new = require("lir").get_context()
  local index = ctx_new:indexof(dir)
  if index and index >= 1 then
    vim.cmd(string.format("%d", index))
  end
end

function M.config()
  vim.cmd [[command! MyLirOpen lua require('rc.lir').my_lir_toggle()]]
  require("lir").setup {
    show_hidden_files = true,
    devicons_enable = true,
    mappings = {
      ["i"] = function()
        vim.fn.feedkeys "/"
      end,
      ["l"] = actions.edit,
      ["v"] = actions.vsplit,
      ["h"] = my_actions.up_hold,
      ["q"] = actions.quit,
      ["s"] = my_actions.search,
      ["-"] = function()
        vim.cmd("edit " .. vim.loop.cwd())
        vim.cmd "doautocmd BufEnter"
      end,

      ["K"] = actions.mkdir,
      ["N"] = actions.newfile,
      ["r"] = actions.rename,
      ["@"] = actions.cd,
      ["y"] = actions.yank_path,
      ["."] = actions.toggle_show_hidden,
      ["d"] = actions.delete,

      ["J"] = function()
        mark_actions.toggle_mark()
        vim.cmd "normal! j"
      end,
      ["c"] = clipboard_actions.copy,
      ["x"] = clipboard_actions.cut,
      ["p"] = clipboard_actions.paste,
    },
    float = {
      winblend = 0,
      curdir_window = {
        enable = true,
        highlight_dirname = false,
      },
      win_opts = function()
        local width = math.floor(vim.o.columns * 0.7)
        local height = math.floor(vim.o.lines * 0.6)
        return {
          border = require("lir.float.helper").make_border_opts({
            "╭",
            "─",
            "╮",
            "│",
            "╯",
            "─",
            "╰",
            "│",
          }, "TelescopeBorder"),
          width = width,
          height = height,
          row = math.floor((vim.o.lines - height) / 2) - 1,
          col = math.floor((vim.o.columns - width) / 2),
        }
      end,
    },
    hide_cursor = true,
    on_init = function()
      my_actions.search_in_ctx_dir()
      vim.cmd [[ highlight! default link LirFloatCursorLine TelescopeSelection]]
    end,
  }

  -- custom folder icon
  require("nvim-web-devicons").set_icon {
    lir_folder_icon = {
      icon = "",
      color = "#7ebae4",
      name = "LirFolderNode",
    },
  }

  function _G.LirSettings() end
  aug("my-lir-settings", {
    au("Filetype", { pattern = "lir", callback = LirSettings }),
  })
end

return M
