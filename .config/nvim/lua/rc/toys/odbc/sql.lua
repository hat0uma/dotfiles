local sql = {}

local ffi = require("ffi")
local strings = require("rc.toys.odbc.strings")

ffi.cdef([[
typedef unsigned short SQLUSMALLINT;
typedef short SQLSMALLINT;
typedef int SQLINTEGER;
typedef long SQLLEN;
typedef unsigned long SQLULEN;
typedef unsigned short SQLWCHAR;
typedef SQLWCHAR* SQLWCHAR_PTR;
typedef void* SQLHANDLE;
typedef void* SQLHENV;
typedef void* SQLHDBC;
typedef void* SQLHSTMT;
typedef void* SQLPOINTER;
typedef unsigned short SQLCHAR;
typedef SQLUSMALLINT SQLRETURN;

SQLRETURN SQLAllocHandle
(
  unsigned short HandleType,
  SQLHANDLE InputHandle,
  SQLHANDLE* OutputHandle
);

SQLRETURN SQLDriverConnectW
(
  SQLHDBC hdbc,
  void* hwnd,
  SQLWCHAR_PTR szConnStrIn,
  SQLSMALLINT cbConnStrIn,
  SQLWCHAR_PTR szConnStrOut,
  SQLSMALLINT cbConnStrOutMax,
  SQLSMALLINT* pcbConnStrOut,
  unsigned long fDriverCompletion
);

SQLRETURN SQLExecDirectW
(
    SQLHSTMT StatementHandle, 
    SQLWCHAR_PTR StatementText, 
    SQLINTEGER TextLength
);

SQLRETURN SQLFetch
(
    SQLHSTMT StatementHandle
);

SQLRETURN SQLGetData
(
    SQLHSTMT StatementHandle, 
    SQLUSMALLINT ColumnNumber, 
    short TargetType,
    SQLPOINTER TargetValuePtr, 
    SQLLEN BufferLength, 
    SQLLEN* StrLen_or_Ind
);

SQLRETURN SQLFreeHandle
(
    unsigned short HandleType, 
    SQLHANDLE Handle
);

SQLRETURN SQLDisconnect
(
    SQLHDBC hdbc
);

SQLRETURN SQLGetDiagRecW
(
    SQLSMALLINT     fHandleType,
    SQLHANDLE       handle,
    SQLSMALLINT     iRecord,
    SQLWCHAR*       szSqlState,
    SQLINTEGER*     pfNativeError,
    SQLWCHAR*       szErrorMsg,
    SQLSMALLINT     cchErrorMsgMax,
    SQLSMALLINT*    pcchErrorMsg
);

SQLRETURN  SQLSetEnvAttr
(
    SQLHENV EnvironmentHandle,
    SQLINTEGER Attribute,
    SQLPOINTER Value,
    SQLINTEGER StringLength
);
]])

-- Load odbc32.dll explicitly
local odbc = ffi.load("odbc32.dll")

-----------------------
-- constants
-----------------------

---@enum ODBC.HandleType
sql.HandleType = {
  SQL_HANDLE_ENV = 1,
  SQL_HANDLE_DBC = 2,
  SQL_HANDLE_STMT = 3,
  SQL_HANDLE_DESC = 4,
}

-- SQLRETURN
sql.SQL_SUCCESS = 0
sql.SQL_SUCCESS_WITH_INFO = 1
sql.SQL_NO_DATA = 100
sql.SQL_ERROR = -1
sql.SQL_INVALID_HANDLE = -2

-- see: https://github.com/microsoft/ODBC-Specification/blob/master/Windows/inc/sql.h
sql.SQL_DRIVER_COMPLETE = 0

-- SQL data type codes
sql.SQL_UNKNOWN_TYPE = 0
sql.SQL_CHAR = 1
sql.SQL_NUMERIC = 2
sql.SQL_DECIMAL = 3
sql.SQL_INTEGER = 4
sql.SQL_SMALLINT = 5
sql.SQL_FLOAT = 6
sql.SQL_REAL = 7
sql.SQL_DOUBLE = 8
sql.SQL_DATETIME = 9
sql.SQL_VARCHAR = 12
sql.SQL_VARIANT_TYPE = sql.SQL_UNKNOWN_TYPE
sql.SQL_UDT = 17
sql.SQL_ROW = 19
sql.SQL_ARRAY = 50
sql.SQL_MULTISET = 55
sql.SQL_BIGINT = -5
-- SQL extended datatypes
sql.SQL_DATE = 9
sql.SQL_INTERVAL = 10
sql.SQL_TIME = 10
sql.SQL_TIMESTAMP = 11
sql.SQL_LONGVARCHAR = -1
sql.SQL_BINARY = -2
sql.SQL_VARBINARY = -3
sql.SQL_LONGVARBINARY = -4
sql.SQL_BIGINT = -5
sql.SQL_TINYINT = -6
sql.SQL_BIT = -7
sql.SQL_GUID = -11

sql.SQL_SIGNED_OFFSET = -20
sql.SQL_UNSIGNED_OFFSET = -22
sql.SQL_C_CHAR = sql.SQL_CHAR -- CHAR, VARCHAR, DECIMAL, NUMERIC
sql.SQL_C_LONG = sql.SQL_INTEGER -- INTEGER
sql.SQL_C_SHORT = sql.SQL_SMALLINT -- SMALLINT
sql.SQL_C_FLOAT = sql.SQL_REAL -- REAL
sql.SQL_C_DOUBLE = sql.SQL_DOUBLE -- FLOAT, DOUBLE
sql.SQL_C_LONG = sql.SQL_INTEGER
sql.SQL_C_SLONG = (sql.SQL_C_LONG + sql.SQL_SIGNED_OFFSET) -- SIGNED INTEGER
sql.SQL_C_SSHORT = (sql.SQL_C_SHORT + sql.SQL_SIGNED_OFFSET) -- SIGNED SMALLINT
sql.SQL_C_STINYINT = (sql.SQL_TINYINT + sql.SQL_SIGNED_OFFSET) -- SIGNED TINYINT
sql.SQL_C_ULONG = (sql.SQL_C_LONG + sql.SQL_UNSIGNED_OFFSET) -- UNSIGNED INTEGER
sql.SQL_C_USHORT = (sql.SQL_C_SHORT + sql.SQL_UNSIGNED_OFFSET) -- UNSIGNED SMALLINT
sql.SQL_C_UTINYINT = (sql.SQL_TINYINT + sql.SQL_UNSIGNED_OFFSET) -- UNSIGNED TINYINT
sql.SQL_C_SBIGINT = (sql.SQL_BIGINT + sql.SQL_SIGNED_OFFSET) -- SIGNED BIGINT
sql.SQL_C_UBIGINT = (sql.SQL_BIGINT + sql.SQL_UNSIGNED_OFFSET) -- UNSIGNED BIGINT

sql.SQL_WCHAR = -8
sql.SQL_WVARCHAR = -9

-- special length/indicator values
sql.SQL_NULL_DATA = -1
sql.SQL_DATA_AT_EXEC = -2
-- Special return values for SQLGetData
sql.SQL_NO_TOTAL = -4

-- see: https://github.com/microsoft/ODBC-Specification/blob/master/Windows/inc/sqlext.h
sql.SQL_ATTR_ODBC_VERSION = 200
sql.SQL_ATTR_CONNECTION_POOLING = 201
sql.SQL_ATTR_CP_MATCH = 202
sql.SQL_OV_ODBC2 = 2
sql.SQL_OV_ODBC3 = 3

-- env attribute
---@enum ODBC.EnvAttr
sql.EnvAttr = {
  SQL_ATTR_ODBC_VERSION = 200,
  SQL_ATTR_CONNECTION_POOLING = 201,
  SQL_ATTR_CP_MATCH = 202,
  SQL_ATTR_APPLICATION_KEY = 203,
}

-----------------------
-- wrappers
-----------------------

--- check sql success
---@param rc integer
---@return boolean
local function sql_succeeded(rc)
  return rc == sql.SQL_SUCCESS or rc == sql.SQL_SUCCESS_WITH_INFO
end

---Retrieve error message
---@param handle ODBC.Handle
---@return string err_msg, string err_name
local function get_odbc_error(handle)
  local SQL_STATE_SIZE = 5
  local BUFFER_SIZE = 256

  local record = 1
  local sql_state = ffi.new("SQLWCHAR[?]", SQL_STATE_SIZE + 1)
  local native_error = ffi.new("SQLINTEGER[1]")
  local error_message = ffi.new("SQLWCHAR[?]", BUFFER_SIZE + 1)
  local error_message_max = BUFFER_SIZE
  local error_message_length = ffi.new("SQLSMALLINT[1]")
  local ret = odbc.SQLGetDiagRecW( --- @type integer
    handle.type,
    handle.cdata[0],
    record,
    sql_state,
    native_error,
    error_message,
    error_message_max,
    error_message_length
  )

  local state, message --- @type string,string
  if sql_succeeded(ret) then
    state = strings.from_wchar(sql_state)
    message = strings.from_wchar(error_message)
  else
    state = "UNKNOWN"
    message = "Failed to get ODBC error message."
  end
  return string.format("%s: %s", state, message), state ---luv like
end

--- @class ODBC.Handle
--- @field type ODBC.HandleType
--- @field cdata ffi.cdata*

---@param handle_type ODBC.HandleType
---@param input_handle? ODBC.Handle
---@return ODBC.Handle? handle, string? err_msg, string? err_msg
function sql.alloc_handle(handle_type, input_handle)
  -- validation
  if handle_type == sql.HandleType.SQL_HANDLE_ENV then
    assert(input_handle == nil)
  else
    assert(input_handle)
    if handle_type == sql.HandleType.SQL_HANDLE_DBC then
      assert(input_handle.type == sql.HandleType.SQL_HANDLE_ENV)
    else
      assert(input_handle.type == sql.HandleType.SQL_HANDLE_DBC)
    end
  end

  local ctypes = {
    [sql.HandleType.SQL_HANDLE_ENV] = "SQLHENV[1]",
    [sql.HandleType.SQL_HANDLE_DBC] = "SQLHDBC[1]",
    [sql.HandleType.SQL_HANDLE_DESC] = "SQLHDESC[1]",
    [sql.HandleType.SQL_HANDLE_STMT] = "SQLHSTMT[1]",
  }

  -- allocate
  local cdata = ffi.new(ctypes[handle_type])
  local ret = odbc.SQLAllocHandle(handle_type, input_handle and input_handle.cdata[0], cdata) ---@type integer
  if not sql_succeeded(ret) and input_handle then
    if input_handle then
      return nil, get_odbc_error(input_handle)
    else
      return nil, string.format("Failed to alloc Env handle with %d", ret), ""
    end
  end

  return { --- @type ODBC.Handle
    type = handle_type,
    cdata = cdata,
  }
end

---@param hdbc ODBC.Handle
---@param hwnd? ffi.cdata*
---@param conn_str string
---@param driver_completion integer
---@return string? out_connection_string, string? err_msg, string? err_name
function sql.driver_connect(hdbc, hwnd, conn_str, driver_completion)
  local conn_str_w, conn_str_w_len = strings.to_wchar_ptr(conn_str)

  local CONN_STR_OUT_BUFLEN = 1024
  local conn_str_out = ffi.new("SQLWCHAR[?]", CONN_STR_OUT_BUFLEN)
  local conn_str_out_len = ffi.new("SQLSMALLINT[1]")
  local ret = odbc.SQLDriverConnectW( --- @type integer
    hdbc.cdata[0],
    hwnd,
    conn_str_w,
    conn_str_w_len,
    conn_str_out,
    CONN_STR_OUT_BUFLEN,
    conn_str_out_len,
    driver_completion
  )
  if not sql_succeeded(ret) then
    return nil, get_odbc_error(hdbc)
  end

  return strings.from_wchar(conn_str_w)
end

---@param hstmt ODBC.Handle
---@param stmt_text string
---@return boolean? ok, string? err_msg, string? err_name
function sql.exec_direct(hstmt, stmt_text)
  local text_w, text_w_len = strings.to_wchar_ptr(stmt_text)
  local ret = odbc.SQLExecDirectW(hstmt.cdata[0], text_w, text_w_len) --- @type integer
  if not sql_succeeded(ret) then
    return nil, get_odbc_error(hstmt)
  end

  return true
end

---@param hstmt ODBC.Handle
---@return integer? count, string? err_msg, string? err_name
function sql.fetch(hstmt)
  local ret = odbc.SQLFetch(hstmt.cdata[0]) --- @type integer
  if ret == sql.SQL_NO_DATA then
    return 0
  elseif not sql_succeeded(ret) then
    return nil, get_odbc_error(hstmt)
  end
  return 1
end

---@param hstmt ODBC.Handle
---@param col_no integer
---@return string? data, string? err_msg, string? err_name
function sql.get_string_data(hstmt, col_no)
  -- Alloc Fixed length buffer
  local FIRSTBUF_LEN = 256
  local firstBuf = ffi.new("SQLWCHAR[?]", FIRSTBUF_LEN)

  -- Get data with fixed length buffer
  local strlen_or_ind = ffi.new("SQLLEN[1]")
  local ret = odbc.SQLGetData(hstmt.cdata[0], col_no, sql.SQL_WCHAR, firstBuf, FIRSTBUF_LEN, strlen_or_ind) --- @type integer
  if not sql_succeeded(ret) then
    return nil, get_odbc_error(hstmt)
  end

  -- Check null data
  if strlen_or_ind[0] == sql.SQL_NULL_DATA then
    return nil
  end

  if strlen_or_ind[0] == sql.SQL_NO_TOTAL then
    return nil, "Failed to get field length", ""
  end

  if strlen_or_ind[0] < FIRSTBUF_LEN - 1 then
    return strings.from_wchar(firstBuf)
  end

  local buflen = strlen_or_ind[0] + 1 --- @type integer
  local buffer = ffi.new("SQLWCHAR[?]", buflen)
  ret = odbc.SQLGetData(hstmt.cdata[0], col_no, sql.SQL_WCHAR, buffer, buflen, strlen_or_ind) --- @type integer

  -- error
  if not sql_succeeded(ret) then
    return nil, get_odbc_error(hstmt)
  end

  return strings.from_wchar(buffer)
end

---@param hstmt ODBC.Handle
---@param col_no integer
---@param target_type integer
---@param buffer ffi.cdata*
---@return number? data, string? err_msg, string? err_name
local function get_numeric_data(hstmt, col_no, target_type, buffer)
  local strlen_or_ind = ffi.new("SQLLEN[1]")
  local ret = odbc.SQLGetData(hstmt.cdata[0], col_no, target_type, nil, 0, strlen_or_ind) --- @type integer

  -- error
  if not sql_succeeded(ret) then
    return nil, get_odbc_error(hstmt)
  end

  -- check null data
  if strlen_or_ind[0] == sql.SQL_NULL_DATA then
    return nil
  end

  return buffer[0]
end

---@param hstmt ODBC.Handle
---@param col_no integer
---@return number? data, string? err_msg, string? err_name
function sql.get_float_data(hstmt, col_no)
  local buffer = ffi.new("double[1]")
  return get_numeric_data(hstmt, col_no, sql.SQL_C_DOUBLE, buffer)
end

---@param hstmt ODBC.Handle
---@param col_no integer
---@return integer? data, string? err_msg, string? err_name
function sql.get_int_data(hstmt, col_no)
  local buffer = ffi.new("SQLINTEGER[1]")
  return get_numeric_data(hstmt, col_no, sql.SQL_C_SLONG, buffer)
end

---@param handle ODBC.Handle
---@return boolean? ok, string? err_msg, string? err_name
function sql.free_handle(handle)
  local ret = odbc.SQLFreeHandle(handle.type, handle.cdata[0]) --- @type integer

  -- error
  if not sql_succeeded(ret) then
    return nil, get_odbc_error(handle)
  end

  return true
end

---@param hdbc ODBC.Handle
---@return boolean? ok, string? err_msg, string? err_name
function sql.disconnect(hdbc)
  local ret = odbc.SQLDisconnect(hdbc.cdata[0]) --- @type integer

  -- error
  if not sql_succeeded(ret) then
    return nil, get_odbc_error(hdbc)
  end

  return true
end

---@param henv ODBC.Handle
---@param attribute ODBC.EnvAttr
---@param value integer
---@return boolean? ok, string? err_msg, string? err_name
function sql.set_env_attr(henv, attribute, value)
  assert(type(value) == "number")

  local ret = odbc.SQLSetEnvAttr(henv.cdata[0], attribute, ffi.cast("SQLPOINTER", value), 0) --- @type integer

  -- error
  if not sql_succeeded(ret) then
    return nil, get_odbc_error(henv)
  end

  return true
end

return sql
