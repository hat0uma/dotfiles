local M = {}

--- call from parent
function M.setup()
  local editor = "nvim -u NONE --headless -n -c \"lua require'rc.terminal_editor'.request_edit()\""
  vim.env.EDITOR = editor
  vim.env.VISUAL = editor
  vim.env.RC_TERMINAL_EDITOR_PARENT_ADDRESS = vim.v.servername
end

--- call from child
function M.request_edit()
  local channel = vim.fn.sockconnect("pipe", vim.env.RC_TERMINAL_EDITOR_PARENT_ADDRESS, { rpc = true })
  local files = vim.tbl_map(function(file)
    return vim.fn.fnamemodify(file, ":p")
  end, vim.fn.argv())
  vim.rpcrequest(channel, "nvim_exec_lua", "return require'rc.terminal_editor'.edit(...)", { files, vim.v.servername })
end

function M.edit(files, servername)
  vim.cmd.tabnew(files)
  -- vim.cmd.edit(files)
  vim.bo.bufhidden = "wipe"
  vim.api.nvim_create_autocmd({ "BufWipeout", "VimLeave" }, {
    callback = function()
      local child = vim.fn.sockconnect("pipe", servername, { rpc = true })
      pcall(vim.rpcrequest, child, "nvim_cmd", { cmd = "quit", args = {} }, {})
    end,
    once = true,
    buffer = 0,
  })
end

return M
