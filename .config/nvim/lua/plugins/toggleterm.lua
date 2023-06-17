local M = {
  "akinsho/toggleterm.nvim",
  cmd = { "ToggleTerm" },
}

--- check buffer is terminal
---@param bufname string
---@return boolean
local function is_term(bufname)
  local prefix = "term://"
  return bufname:sub(1, #prefix) == prefix
end

--- check buffer is visible
---@param bufname string
---@return boolean
local function is_visible(bufname)
  return #vim.fn.win_findbuf(vim.fn.bufnr(bufname)) > 0
end

M.init = function()
  for i = 1, 5 do
    local key = string.format("<leader>%d", i)
    local cmd = string.format("<Cmd>exe %d . 'ToggleTerm'<CR>", i)
    vim.keymap.set("n", key, cmd, { noremap = true, silent = true })
  end
end

M.config = function()
  local util = require "rc.utils"
  local shells = require "rc.terminal.shells"
  local shell = vim.fn.has "win64" == 1 and shells.pwsh or shells.zsh
  local KeyCode = {
    Up = "\x1b[A",
    Down = "\x1b[B",
    Right = "\x1b[C",
    Left = "\x1b[D",
  }
  -- lock terminal buffer's window
  local group = vim.api.nvim_create_augroup("my-toggleterm-settings", {})
  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
      local bufname = vim.api.nvim_buf_get_name(0)
      if is_term(bufname) then
        return
      end
      local winid = vim.api.nvim_get_current_win()
      local terms = require("toggleterm.terminal").get_all()
      for _, term in ipairs(terms) do
        if winid == term.window then
          -- back to terminal buffer and reopen another window
          vim.cmd.buffer "#"
          vim.api.nvim_win_close(winid, false)
          vim.cmd.edit(bufname)
          vim.wo.number = true
          vim.wo.relativenumber = true
          break
        end
      end
    end,
    group = group,
  })

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
        local cfile = vim.fn.expand "<cfile>"
        local path = util.rel_or_abs(vim.b.terminal_cwd, cfile)
        if util.accessable(path) then
          vim.cmd("close | e " .. path)
        else
          vim.notify(string.format("%s is not found on path", path), vim.log.levels.ERROR)
        end
      end, opts)

      -- reload
      local reload = string.format("<Cmd>bdelete! | %dToggleTerm direction=%s<CR>", term.id, term.direction)
      vim.keymap.set("n", "<C-r>", reload, opts)

      -- cycle direction
      local direction_cycle = { "vertical", "horizontal", "float" }
      for idx, direction in pairs(direction_cycle) do
        if direction == term.direction then
          local next_idx = (idx % #direction_cycle) + 1
          local cmd = string.format("<Cmd>close | %dToggleTerm direction=%s<CR>", term.id, direction_cycle[next_idx])
          vim.keymap.set("n", "<leader><leader>", cmd, opts)
        end
      end

      -- direction and float toggle
      vim.keymap.set("n", "<C-t>", function()
        vim.cmd.close()
        local direction = term.direction == "tab" and "float" or "tab"
        require("toggleterm").toggle(term.id, nil, nil, direction)
      end, opts)
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
