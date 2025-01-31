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

  vim.api.nvim_create_user_command("Restart", restart, { desc = "Restart neovim." })
  vim.api.nvim_create_user_command("RestoreSession", restore_session, { desc = "Restore Session." })

  local aug = vim.api.nvim_create_augroup("my_restart_settings", {})
  vim.api.nvim_create_autocmd("VimLeave", {
    callback = save_current_session,
    group = aug,
  })
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      if vim.api.nvim_buf_get_name(0) == "" then
        vim.keymap.set("n", "<Enter>", "<Cmd>RestoreSession<CR>", { buffer = true })
      end
    end,
    group = aug,
  })
end

return M
