local ODBCCursor = require("rc.toys.odbc.cursor")
local sql = require("rc.toys.odbc.sql")

---@class rc.ODBCConnection
---@field private _conn_str string
---@field private _henv ODBC.Handle
---@field private _hdbc ODBC.Handle
local ODBCConnection = {}

---Create a new rc.ODBCConnection.
---@param hdbc ODBC.Handle
---@param conn_str string
---@return rc.ODBCConnection
function ODBCConnection:new(hdbc, conn_str)
  local obj = {}
  obj._hdbc = hdbc
  obj._conn_str = conn_str

  setmetatable(obj, self)
  self.__index = self
  return obj
end

-- https://docs.oracle.com/cd/G11854_01/odbcd/basic-programming-oracle-odbc.html
function ODBCConnection:open()
  return sql.driver_connect(self._hdbc, nil, self._conn_str, sql.SQL_DRIVER_COMPLETE)
end

function ODBCConnection:disconnect()
  return sql.disconnect(self._hdbc)
end

function ODBCConnection:close()
  return sql.free_handle(self._hdbc)
end

function ODBCConnection:execute(query)
  -- Create statement handle
  local hstmt, err_msg, err_name = sql.alloc_handle(sql.HandleType.SQL_HANDLE_STMT, self._hdbc)
  if not hstmt then
    return nil, err_msg, err_name
  end

  -- Execute query
  local ok
  ok, err_msg, err_name = sql.exec_direct(hstmt, query)
  if not ok then
    return nil, err_msg, err_name
  end

  -- Create cursor object
  return ODBCCursor:new(hstmt)
end
return ODBCConnection
