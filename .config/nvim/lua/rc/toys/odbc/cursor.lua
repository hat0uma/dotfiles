local sql = require("rc.toys.odbc.sql")

---@class ODBCCursor
---@field private _hstmt ODBC.Handle
local ODBCCursor = {}

--- Create a new ODBCCursor.
---@param hstmt ODBC.Handle
---@return ODBCCursor
function ODBCCursor:new(hstmt)
  local obj = {}
  obj._hstmt = hstmt

  setmetatable(obj, self)
  self.__index = self
  return obj
end

function ODBCCursor:fetch()
  -- Fetch row
  local count, err_msg, err_name = sql.fetch(self._hstmt)
  if not count then
    return nil, err_msg, err_name
  end

  if count == 0 then
    return nil -- NO_DATA
  end

  -- Get all fields in row
  local row = {}
  for i = 1, 2 do
    local data
    data, err_msg, err_name = sql.get_string_data(self._hstmt, i)
    if not data then
      return nil, err_msg, err_name
    end

    table.insert(row, data)
  end
  return row
end

function ODBCCursor:close()
  return sql.free_handle(self._hstmt)
end

return ODBCCursor
