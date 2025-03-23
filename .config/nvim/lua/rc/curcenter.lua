local M = {}

M.enabled = true

---
---@param ev vim.api.keyset.create_autocmd.callback_args
local function curcenter(ev)
  if not M.enabled then
    return
  end

  local curr_win = vim.api.nvim_win_get_config(0)
  if curr_win.relative ~= "" then
    return -- floating window, do nothing
  end

  if vim.o.buftype == "nofile" or vim.o.buftype == "terminal" then
    return -- scratch buffer, do nothing
  end

  if vim.api.nvim_get_option_value("scrolloff", { scope = "local", win = 0 }) ~= -1 then
    return -- scrolloff is set locally, do nothing
  end

  if ev.event == "CursorMoved" then
    vim.cmd("normal! zz")
  else -- TextChanged, TextChangedI
    local at_eol = vim.fn.charcol(".") == vim.fn.charcol("$")
    vim.cmd("normal! zz")
    if at_eol then
      local row, col, offset = unpack(vim.fn.getcursorcharpos(), 2) ---@type integer, integer, integer
      vim.fn.setcursorcharpos(row, col + 1, offset)
    end
  end
end

function M.toggle()
  if M.enabled then
    M.disable()
  else
    M.enable()
  end
end

function M.enable()
  M.enabled = true
  vim.notify("CurCenter enabled")
end

function M.disable()
  M.enabled = false
  vim.notify("CurCenter disabled")
end

function M.setup()
  vim.o.scrolloff = 0
  vim.api.nvim_create_augroup("rc.curcenter", { clear = true })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "CursorMoved" }, {
    group = "rc.curcenter",
    pattern = "*",
    callback = curcenter,
  })

  vim.api.nvim_create_user_command("CurCenterEnable", M.enable, {})
  vim.api.nvim_create_user_command("CurCenterDisable", M.disable, {})
  vim.api.nvim_create_user_command("CurCenterToggle", M.toggle, {})
end

return M
