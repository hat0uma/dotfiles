--- This module provides a feature to synchronize the current directory of the terminal and the current directory(lcd) of neovim.

local M = {}

--- Setup the terminal directory feature.
function M.setup()
  vim.api.nvim_create_autocmd({ "TermRequest" }, {
    desc = "Handles OSC 7 dir change requests",
    callback = function(ev)
      local uri = string.match(ev.data.sequence, "\027]7;([^%c]+)")
      if not uri then
        return
      end

      local dir = vim.uri_to_fname(uri)
      if vim.fn.isdirectory(dir) == 0 then
        vim.notify("invalid dir: " .. dir)
        return
      end

      vim.b[ev.buf].osc7_dir = dir
      if vim.api.nvim_get_current_buf() == ev.buf then
        vim.cmd.lcd(dir)
      end
    end,
  })
end

return M
