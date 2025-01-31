local M = {}

local SESSION_DIR = vim.fn.stdpath("cache") .. "/sessions"
local SESSION_PATH = SESSION_DIR .. "/last.vim"

--- startup handler for new gui instance.
function M.on_startup()
  -- notify startup completion to old instance
  local channel = vim.fn.sockconnect("pipe", vim.env.NVIM, { rpc = true })
  vim.rpcrequest(channel, "nvim_exec_lua", "vim.g.restart_completed = true", {})
  vim.fn.chanclose(channel)

  -- restore session
  vim.cmd.source(SESSION_PATH)
end

local function can_quit()
  local bufs = vim.api.nvim_list_bufs()
  for _, bufnr in ipairs(bufs) do
    if vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
      return false
    end
  end
  return true
end

function M.restart(start_cmd)
  if not can_quit() then
    vim.notify("Unsaved changes exists.", vim.log.levels.WARN)
    return
  end
  -- create session
  vim.cmd.mksession({ SESSION_PATH, bang = true })

  -- start new instance
  vim.g.restart_completed = false
  local handle = vim.system(start_cmd, { detach = true })

  -- wait startup completion
  local ok, kind = vim.wait(5000, function()
    return vim.g.restart_completed
  end)

  if ok then
    vim.cmd.quitall()
    return
  end

  if kind == -1 then
    vim.notify("timeout.")
  elseif kind == -2 then
    vim.notify("interrupted.")
  end

  if not handle:is_closing() then
    handle:kill(9)
  end
end

function M.setup()
  local gui_cmd = nil
  if vim.g.neovide then
    gui_cmd = { "neovide", "--" }
  end

  if not gui_cmd then
    return
  end

  local start_cmd = vim.list_extend(gui_cmd, {
    "--cmd",
    "autocmd VimEnter * ++once lua require('rc.gui').on_startup()",
  })

  vim.api.nvim_create_user_command("Restart", function()
    M.restart(start_cmd)
  end, { desc = "Restart neovim." })
end
return M
