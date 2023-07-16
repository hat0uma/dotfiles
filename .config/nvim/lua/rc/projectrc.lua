local M = {}
local projectrc_files = {
  { file = ".nvim.lua", ft = "lua" },
  { file = ".nvimrc", ft = "vim" },
  { file = ".exrc", ft = "vim" },
}
local loader = {
  lua = function(content)
    if content ~= "" then
      vim.cmd.luado(content)
    end
  end,
  vim = function(content)
    if content ~= "" then
      vim.cmd(content)
    end
  end,
}

local old_cwd = vim.loop.cwd()
local loaded_hash = {}

local function find_projectrc(dir)
  for _, projectrc in ipairs(projectrc_files) do
    local f = vim.fs.joinpath(dir, projectrc.file)
    if vim.loop.fs_stat(f) then
      return projectrc
    end
  end
  return nil
end

local function load()
  local cwd = vim.loop.cwd()
  local projectrc = find_projectrc(cwd)
  if not projectrc then
    return
  end

  local f = vim.fs.joinpath(cwd, projectrc.file)
  local content = vim.secure.read(f)
  if content == nil then
    print(f .. " is not trusted.")
  else
    local loaded = loaded_hash[f]
    local hash = vim.fn.sha256(content)
    if not loaded or hash ~= loaded then
      loaded_hash[f] = hash
      print("load " .. f)
      loader[projectrc.ft](content)
    else
      -- print(f .. " is already loaded.")
    end
  end
end

local on_dirchanged = function()
  local cwd = vim.loop.cwd()
  if cwd ~= old_cwd then
    old_cwd = cwd
    load()
  end
end

function M.setup()
  vim.o.exrc = true
  vim.api.nvim_create_autocmd("DirChanged", {
    callback = vim.schedule_wrap(on_dirchanged),
    group = vim.api.nvim_create_augroup("LoadProjectrc", {}),
  })
  vim.api.nvim_create_user_command("LoadProjectrc", load, {})
end

return M
