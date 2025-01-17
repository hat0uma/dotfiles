local M = {}

local odbc = require("rc.toys.odbc")

-- https://stackoverflow.com/questions/49506048/odbc-xlsx-driver-connectionstring-without-header/49555650#49555650
local driver = "Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)"
local excel_file = vim.fs.normalize("~/work/test.xlsx")
local conn_str = string.format("Driver={%s};DBQ=%s;ReadOnly=1", driver, excel_file)

local err

-- Create Env
local env
env, err = odbc.new_env()
if not env then
  error(err)
end

-- Set ODBC version
local ok
ok, err = env:set_version(3)
if not ok then
  env:close()
  error(err)
end

-- Create new connection
local conn
conn, err = env:new_connection(conn_str)
if not conn then
  env:close()
  error(err)
end

-- Open connection
local out_conn_str
out_conn_str, err = conn:open()
if not out_conn_str then
  conn:close()
  env:close()
  error(err)
end

print(string.format("Connected with [%s]", out_conn_str))

-- Execute query
local query = "SELECT * FROM [Sheet1$]"
local cur
cur, err = conn:execute(query)
if not cur then
  conn:disconnect()
  conn:close()
  env:close()
  error(err)
end

print("Executed SQL query:", query)

-- Fetch rows
local i = 1
while true do
  local row
  row, err = cur:fetch()
  if not row then
    break
  end

  -- Print result
  print("row", i, table.concat(row, "\t"))
  i = i + 1
end

cur:close()
conn:disconnect()
conn:close()
env:close()

if err then
  error(err)
end
print("Disconnected and cleaned up ODBC handles")

return M
