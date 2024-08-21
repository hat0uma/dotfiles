--- This module is intended to prevent neovim from nesting when `git commit` or `man` is executed in :terminal.

local M = {}

--- call from parent
function M.setup()
  local editor = [[nvim -u NONE --headless -n -c "lua require'rc.terminal.editor'.edit_on_parent()" -c qa!]]
  vim.env.EDITOR = editor
  vim.env.VISUAL = editor
  vim.env.MANPAGER = [[nvim -u NONE --headless -n -c "lua require'rc.terminal.editor'.man_on_parent()" -c qa! -]]
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
  exec_remote_wait("require'rc.terminal.editor'.handle_edit_request(...)", files)
end

function M.man_on_parent()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
  exec_remote_wait("return require'rc.terminal.editor'.handle_man_request(...)", { lines })
end

--------------------------------------------------------------------
-- Functions executed on parent by RPC request from child
--------------------------------------------------------------------

---@param open_action function
---@return fun(child_server_name: string, ...)
local function create_handle_request(open_action)
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

--- handle edit request
M.handle_edit_request = create_handle_request(function(files)
  vim.cmd.tabnew(files)
end)

--- handle man request
M.handle_man_request = create_handle_request(function(lines)
  vim.cmd.tabnew()
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
  vim.bo.readonly = true
  vim.cmd([[ Man! ]])
end)

return M
