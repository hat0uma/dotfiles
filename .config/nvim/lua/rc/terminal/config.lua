local config = {}

function config.setup_terminal(bufnr)
  local opts = { noremap = true, buffer = bufnr }
  vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "jj", [[<C-\><C-n>]], opts)
end
config.terminal_ft = "terminal"

return config
