local M = {}

--- call from parent
function M.setup()
  local editor = [[nvim -u NONE --headless -n -c "lua require'rc.terminal_editor'.edit_on_parent()" -c qa!]]
  vim.env.EDITOR = editor
  vim.env.VISUAL = editor
  vim.env.MANPAGER = [[nvim -u NONE --headless -n -c "lua require'rc.terminal_editor'.man_on_parent()" -c qa! -]]
  vim.env.RC_TERMINAL_EDITOR_PARENT_ADDRESS = vim.v.servername
end

--------------------------------------------------------------------
-- functions called from child nvim
--------------------------------------------------------------------

--- exec lua code on parent and wait for finish notification
--- this function is called from child nvim
---@param code string
---@param args any[]
local function exec_remote_wait(code, args)
  table.insert(args, 1, vim.v.servername)
  local channel = vim.fn.sockconnect("pipe", vim.env.RC_TERMINAL_EDITOR_PARENT_ADDRESS, { rpc = true })
  vim.rpcrequest(channel, "nvim_exec_lua", code, args)
  vim.fn.chanclose(channel)
  while true do
    if
      vim.wait(10000, function()
        -- this variable is set by parent nvim
        return vim.g.parent_nvim_edit_finished
      end)
    then
      break
    end
  end
end

function M.edit_on_parent()
  local files = vim.tbl_map(function(file)
    return vim.fn.fnamemodify(file, ":p")
  end, vim.fn.argv())
  exec_remote_wait("require'rc.terminal_editor'.edit(...)", files)
end

function M.man_on_parent()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
  exec_remote_wait("return require'rc.terminal_editor'.man(...)", { lines })
end

--------------------------------------------------------------------
-- functions called from parent nvim
--------------------------------------------------------------------

---@param open_action function
---@return fun(child_server_name: string, ...)
local function remote_edit(open_action)
  return function(child_server_name, ...)
    local toggle_number = vim.b.toggle_number

    open_action(...)

    vim.bo.bufhidden = "wipe"
    vim.api.nvim_create_autocmd({ "BufWipeout", "VimLeave" }, {
      callback = function()
        local child = vim.fn.sockconnect("pipe", child_server_name, { rpc = true })
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
end

--- open files on parent nvim
M.edit = remote_edit(function(files)
  vim.cmd.tabnew(files)
end)

--- man on parent nvim
M.man = remote_edit(function(lines)
  vim.cmd.tabnew()
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
  vim.bo.readonly = true
  vim.cmd [[ Man! ]]
end)

return M
