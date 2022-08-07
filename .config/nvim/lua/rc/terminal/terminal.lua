local function is_floating(winid)
  local cfg = vim.api.nvim_win_get_config(winid)
  return cfg.relative ~= "" or cfg.external
end

local function close_floating()
  if is_floating(0) then
    vim.cmd.close()
  end
end

local function edit(opts)
  close_floating()
  for _, arg in pairs(opts.fargs) do
    vim.cmd.edit(arg)
  end
end

local function vsp(opts)
  close_floating()
  vim.cmd.vsplit()
  for _, arg in pairs(opts.fargs) do
    vim.cmd.edit(arg)
  end
end

local function sp(opts)
  close_floating()
  vim.cmd.split()
  for _, arg in pairs(opts.fargs) do
    print(arg)
    vim.cmd.edit(arg)
  end
end

vim.api.nvim_create_user_command("TEdit", edit, { nargs = "*", complete = "file", bar = true })
vim.api.nvim_create_user_command("TVsplit", vsp, { nargs = "*", complete = "file", bar = true })
vim.api.nvim_create_user_command("TSplit", sp, { nargs = "*", complete = "file", bar = true })
