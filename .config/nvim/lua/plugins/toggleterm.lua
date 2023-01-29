local M = {
  "akinsho/toggleterm.nvim",
  cmd = { "ToggleTerm" },
}

M.init = function()
  for i = 1, 5 do
    local key = string.format("<leader>%d", i)
    local cmd = string.format("<Cmd>exe %d . 'ToggleTerm'<CR>", i)
    vim.keymap.set("n", key, cmd, { noremap = true, silent = true })
  end
end

M.config = function()
  local shell = require("rc.terminal.config").shell
  local KeyCode = {
    Up = "\x1b[A",
    Down = "\x1b[B",
    Right = "\x1b[C",
    Left = "\x1b[D",
  }

  require("toggleterm").setup {
    size = function(term)
      if term.direction == "horizontal" then
        return 10
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
    start_in_insert = false,
    shell = shell.cmd,
    env = shell.env,
    persist_size = true,
    float_opts = {
      winblend = 10,
    },
    on_open = function(term)
      local function send_key_action(key)
        return function()
          vim.api.nvim_chan_send(term.job_id, key)
        end
      end

      local opts = { noremap = true, buffer = term.bufnr }
      vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "jj", [[<C-\><C-n>]], opts)
      vim.keymap.set("n", "q", "<Cmd>close<CR>", opts)
      vim.keymap.set("n", "K", send_key_action(KeyCode.Up), opts)
      vim.keymap.set("n", "J", send_key_action(KeyCode.Down), opts)
      vim.keymap.set("n", "<CR>", send_key_action "\r", opts)

      -- gf
      vim.keymap.set("n", "gf", function()
        print(vim.b.terminal_cwd)
        local cfile = vim.fn.expand "<cfile>"
        if not vim.loop.fs_stat(cfile) then
          cfile = vim.b.terminal_cwd .. "/" .. cfile
        end
        vim.cmd("close | e " .. cfile)
      end, opts)

      -- reload
      local reload = string.format("<Cmd>bdelete! | %dToggleTerm direction=%s<CR>", term.id, term.direction)
      vim.keymap.set("n", "<C-q>", reload, opts)

      -- cycle direction
      local direction_cycle = { "vertical", "horizontal", "float" }
      for idx, direction in pairs(direction_cycle) do
        if direction == term.direction then
          local next_idx = (idx % #direction_cycle) + 1
          local cmd = string.format("<Cmd>close | %dToggleTerm direction=%s<CR>", term.id, direction_cycle[next_idx])
          vim.keymap.set("n", "<leader>j", cmd, opts)
        end
      end
    end,
    direction = "float",
    winbar = {
      enabled = false,
      name_formatter = function(term)
        return term.name
      end,
    },
    shade_terminals = false,
  }
end

return M
