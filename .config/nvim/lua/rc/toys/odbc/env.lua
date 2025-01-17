local ODBCConnection = require("rc.toys.odbc.connection")
local sql = require("rc.toys.odbc.sql")

---@class ODBC.Env
---@field private _henv ODBC.Handle
local ODBCEnv = {}

--- Create a new ODBC.ODBCEnv.
---@param henv ODBC.Handle
---@return ODBC.Env
function ODBCEnv:new(henv)
  local obj = {}
  obj._henv = henv

  setmetatable(obj, self)
  self.__index = self
  return obj
end

--- Set ODBC version
---@param version integer 2 or 3 is expected
---@return boolean? ok, string? err_msg, string? err_name
function ODBCEnv:set_version(version)
  assert(version == 2 or version == 3)
  local value = {
    [2] = sql.SQL_OV_ODBC2,
    [3] = sql.SQL_OV_ODBC3,
  }

  return sql.set_env_attr(self._henv, sql.EnvAttr.SQL_ATTR_ODBC_VERSION, value[version])
end

--- Create new ODBC.Env object
---@return boolean? ok, string? err_msg, string? err_name
function ODBCEnv:close()
  return sql.free_handle(self._henv)
end

--- Create new connection
---@param conn_str string
---@return rc.ODBCConnection? conn, string? err_msg, string? err_name
function ODBCEnv:new_connection(conn_str)
  local hdbc, err_msg, err_name = sql.alloc_handle(sql.HandleType.SQL_HANDLE_DBC, self._henv)
  if not hdbc then
    return nil, err_msg, err_name
  end

  return ODBCConnection:new(hdbc, conn_str)
end

return ODBCEnv
