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

local function get_first_unsaved_buf()
  local bufs = vim.api.nvim_list_bufs()
  for _, bufnr in ipairs(bufs) do
    if vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
      return bufnr
    end
  end
  return nil
end

--- Get command to start new instance.
---@return string[]|nil
local function get_restart_cmd()
  local gui_cmd = nil
  if vim.g.neovide then
    gui_cmd = { "neovide", "--" }
  end

  if not gui_cmd then
    return nil
  end

  local start_cmd = vim.list_extend(gui_cmd, {
    "--cmd",
    "autocmd VimEnter * ++once lua require('rc.gui').on_startup()",
  })

  return start_cmd
end

local function can_restart()
  local unsaved_buf = get_first_unsaved_buf()
  if not unsaved_buf then
    return true
  end

  vim.api.nvim_win_set_buf(0, unsaved_buf)
  local choice = vim.fn.confirm("Save changes?", "&Yes\n&No")
  if choice == 0 then
    print("interrupted")
  elseif choice == 1 then
    -- yes
    vim.cmd.write()
    return can_restart()
  elseif choice == 2 then
    vim.cmd.bdelete({ bang = true })
    return can_restart()
  end

  return false
end

--- Restart neovim GUI.
---@param opts { force: boolean }
function M.restart(opts)
  -- get restart command
  local restart_cmd = get_restart_cmd()
  if not restart_cmd then
    vim.notify("Unsupported GUI.")
    return
  end

  -- check can restart
  if not opts.force and not can_restart() then
    return
  end

  -- create session
  vim.cmd.mksession({ SESSION_PATH, bang = true })

  -- start new instance
  vim.g.restart_completed = false
  local handle = vim.system(restart_cmd, { detach = true })

  -- wait startup completion
  local ok, kind = vim.wait(5000, function()
    return vim.g.restart_completed
  end)

  -- Check if the GUI startup was successful.
  if not ok then
    local msg = kind == -1 and "GUI startup timeout." or "GUI startup interrupted."
    vim.notify(msg, vim.log.levels.WARN)

    if not handle:is_closing() then
      handle:kill(9)
    end
    return
  end

  vim.cmd.quitall({ bang = true })
end

local default = {
  ---@type "builtin" | "resession" | { save: fun(), restore: fun() }
  session = "builtin",
}

function M.setup()
  vim.api.nvim_create_user_command("Restart", function(opts)
    M.restart({ force = opts.bang })
  end, {
    desc = "Restart neovim.",
    bang = true,
  })
end
return M
