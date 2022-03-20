local M = {}
function M.config()
  local shell = vim.fn.has "win64" == 1 and "powershell -NoLogo" or vim.o.shell
  require("toggleterm").setup {
    start_in_insert = false,
    shell = shell,
    float_opts = {
      winblend = 10,
    },
    on_open = function(term)
      local opts = { noremap = true, buffer = term.bufnr }
      vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "jj", [[<C-\><C-n>]], opts)
      vim.keymap.set("n", "q", "<Cmd>close<CR>", opts)
    end,
    direction = "float",
  }
end

return M
