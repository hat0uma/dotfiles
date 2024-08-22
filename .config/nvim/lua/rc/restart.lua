local M = {}

local SESSION_DIR = vim.fn.stdpath("cache") .. "/sessions"
local SESSION_PATH = SESSION_DIR .. "/last.vim"

local function save_current_session()
  if vim.fn.isdirectory(SESSION_DIR) ~= 1 then
    vim.uv.fs_mkdir(SESSION_DIR, 493) -- 755
  end
  vim.cmd.mksession({ SESSION_PATH, bang = true })
end

local function restart()
  local group = vim.api.nvim_create_augroup("my_restart_settings", {})
  vim.api.nvim_create_autocmd("VimLeave", { callback = save_current_session, group = group })
  vim.cmd.cquit()
end

local function restore_session()
  vim.cmd.source(SESSION_PATH)
end

function M.setup()
  if vim.env.NVIM_RESTART_ENABLE ~= "1" then
    -- print "Restart is not enabled."
    return
  end

  -- :h 'sessionoptions'
  local sessionoptions = {
    "blank", --empty windows
    "buffers", --hidden and unloaded buffers, not just those in windows
    "curdir", --the current directory
    "folds", --manually created folds, opened/closed folds and local fold options
    -- "globals", --global variables that start with an uppercase letter and contain at least one lowercase letter.  Only String and Number types are stored.
    "help", --the help window
    -- "localoptions", --options and mappings local to a window or buffer (not global values for local options)
    -- "options", --all options and mappings (also global values for local options)
    -- "skiprtp", --exclude 'runtimepath' and 'packpath' from the options
    "resize", --size of the Vim window: 'lines' and 'columns'
    -- "sesdir", --the directory in which the session file is located will become the current directory (useful with projects accessed over a network from different systems)
    "tabpages", --all tab pages; without this only the current tab page is restored, so that you can make a session for each tab page separately
    "terminal", --include terminal windows where the command can be restored
    "winpos", --position of the whole Vim window
    "winsize", --window sizes
  }

  vim.o.sessionoptions = table.concat(sessionoptions, ",")
  vim.api.nvim_create_user_command("Restart", restart, { desc = "Restart neovim." })
  vim.api.nvim_create_user_command("RestoreSession", restore_session, { desc = "Restore Session." })
end

return M
