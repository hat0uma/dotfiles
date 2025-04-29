local M = {}

--- Create new ODBC.Env object
---@return ODBC.Env? env, string? err_msg, string? err_name
function M.new_env()
  local ODBCEnv = require("rc.toys.odbc.env")
  local sql = require("rc.toys.odbc.sql")

  local henv, err_msg, err_name = sql.alloc_handle(sql.HandleType.SQL_HANDLE_ENV)
  if not henv then
    return nil, err_msg, err_name
  end

  local env = ODBCEnv:new(henv)
  return env
end

return M
