local shells = require("rc.terminal.shells")

---@class TermConfig
local config = {
  terminal_ft = "terminal",
  start_in_insert = true,
  shell = vim.fn.has("win64") == 1 and shells.pwsh or shells.zsh,
  on_open = function(bufnr)
    local opts = { noremap = true, buffer = bufnr }
    vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
    vim.keymap.set("t", "jj", [[<C-\><C-n>]], opts)
  end,
}
return config
