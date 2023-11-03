local M = {}

--- call from parent
function M.setup()
  local editor = [[nvim -u NONE --headless -n -c "lua require'rc.terminal_editor'.edit_on_parent()" -c qa]]
  vim.env.EDITOR = editor
  vim.env.VISUAL = editor
  vim.env.RC_TERMINAL_EDITOR_PARENT_ADDRESS = vim.v.servername
end

--- call from child
function M.edit_on_parent()
  local files = vim.tbl_map(function(file)
    return vim.fn.fnamemodify(file, ":p")
  end, vim.fn.argv())

  local channel = vim.fn.sockconnect("pipe", vim.env.RC_TERMINAL_EDITOR_PARENT_ADDRESS, { rpc = true })
  vim.rpcrequest(channel, "nvim_exec_lua", "return require'rc.terminal_editor'.edit(...)", { files, vim.v.servername })
  vim.fn.chanclose(channel)
  while true do
    if vim.wait(10000, function()
      return vim.g.parent_nvim_edit_finished
    end) then
      break
    end
  end
end

---
---@param files string[]
---@param servername string
function M.edit(files, servername)
  local toggle_number = vim.b.toggle_number

  vim.cmd.tabnew(files)
  -- vim.cmd.edit(files)
  vim.bo.bufhidden = "wipe"
  vim.api.nvim_create_autocmd({ "BufWipeout", "VimLeave" }, {
    callback = function()
      local child = vim.fn.sockconnect("pipe", servername, { rpc = true })
      vim.rpcrequest(child, "nvim_exec_lua", "vim.g.parent_nvim_edit_finished = true", {})
      vim.fn.chanclose(child)
      if toggle_number then
        require("toggleterm").toggle(toggle_number)
      end
    end,
    once = true,
    buffer = 0,
  })
end

return M
