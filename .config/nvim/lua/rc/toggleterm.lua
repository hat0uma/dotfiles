local M = {}
function M.config()
  local shell = vim.fn.has "win64" == 1 and "powershell -NoLogo" or vim.o.shell
  require("toggleterm").setup {
    size = function(term)
      if term.direction == "horizontal" then
        return 10
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
    start_in_insert = false,
    shell = shell,
    persist_size = true,
    float_opts = {
      winblend = 10,
    },
    on_open = function(term)
      local opts = { noremap = true, buffer = term.bufnr }
      vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "jj", [[<C-\><C-n>]], opts)
      vim.keymap.set("n", "q", "<Cmd>close<CR>", opts)

      local direction_cycle = {
        "vertical",
        "horizontal",
        "float",
      }
      for idx, direction in pairs(direction_cycle) do
        if direction == term.direction then
          local next_idx = (idx % #direction_cycle) + 1
          local cmd = string.format("<Cmd>close | %dToggleTerm direction=%s<CR>", term.id, direction_cycle[next_idx])
          vim.keymap.set("n", "<leader><leader>", cmd, opts)
        end
      end
    end,
    direction = "float",
  }
end

return M
