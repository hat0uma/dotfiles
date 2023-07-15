local M = {}
local exrc_files = {
  { file = ".nvim.lua", ft = "lua" },
  { file = ".nvimrc", ft = "vim" },
  { file = ".exrc", ft = "vim" },
}
local loader = {
  lua = vim.cmd.luado,
  vim = vim.cmd,
}

local function find_exrc(dir)
  for _, exrc in ipairs(exrc_files) do
    local f = vim.fs.joinpath(dir, exrc.file)
    if vim.loop.fs_stat(f) then
      return exrc
    end
  end
  return nil
end

local function load()
  local cwd = vim.loop.cwd()
  local exrc = find_exrc(cwd)
  if not exrc then
    return
  end

  local f = vim.fs.joinpath(cwd, exrc.file)
  local content = vim.secure.read(f)
  if content == nil then
    print(f .. " is not trusted.")
  else
    print("load " .. f)
    loader[exrc.ft](content)
  end
end

function M.setup()
  vim.o.exrc = true
  vim.api.nvim_create_autocmd("DirChanged", {
    callback = vim.schedule_wrap(load),
    group = vim.api.nvim_create_augroup("load_exrc", {}),
  })
  vim.api.nvim_create_user_command("LoadProjectrc", load, {})
end

return M
