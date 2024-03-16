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

--- check window used by terminal
---@param winid integer
---@return boolean
local function used_by_term(winid)
  local terms = require("toggleterm.terminal").get_all()
  return vim.tbl_contains(terms, function(term)
    return term.window == winid
  end, { predicate = true })
end

--- toggle terminal
---@param count number
local function toggle(count)
  local cwd = vim.uv.cwd()
  local buf = vim.api.nvim_buf_get_name(0)
  local dir = buf:find(cwd) ~= nil and cwd or vim.fn.fnamemodify(cwd, ":p:h")
  local size = nil
  local direction = nil
  local name = nil
  require("toggleterm").toggle(count, size, dir, direction, name)
end

M.init = function()
  for i = 1, 5 do
    local key = string.format("<leader>%d", i)
    vim.keymap.set("n", key, function()
      toggle(i)
    end, { noremap = true, silent = true })
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
      local winid = vim.api.nvim_get_current_win()
      if used_by_term(winid) and not is_term(bufname) then
        -- back to terminal buffer and reopen another window
        vim.cmd.buffer "#"
        vim.api.nvim_win_close(winid, false)
        vim.cmd.edit(bufname)
        vim.wo.number = true
        vim.wo.relativenumber = true
      end
    end,
    group = group,
  })

  require("toggleterm").setup {
    size = function(term)
      if term.direction == "horizontal" then
        return vim.o.lines * 0.4
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
