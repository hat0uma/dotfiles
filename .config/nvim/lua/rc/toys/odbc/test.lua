local M = {}

local deferrable = require("rc.toys.odbc.deferrable")
local odbc = require("rc.toys.odbc")

deferrable.run(function(defer)
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
  defer(env.close, env)

  -- Set ODBC version
  local ok
  ok, err = env:set_version(3)
  if not ok then
    error(err)
  end

  -- Create new connection
  local conn
  conn, err = env:new_connection(conn_str)
  if not conn then
    error(err)
  end
  defer(conn.close, conn)

  -- Open connection
  local out_conn_str
  out_conn_str, err = conn:open()
  if not out_conn_str then
    error(err)
  end
  defer(conn.disconnect, conn)

  print(string.format("Connected with [%s]", out_conn_str))

  -- Execute query
  local query = "SELECT * FROM [Sheet1$]"
  local cur
  cur, err = conn:execute(query)
  if not cur then
    error(err)
  end
  defer(cur.close, cur)

  print("Executed SQL query:", query)

  -- Fetch rows
  local i = 1
  while true do
    local row
    row, err = cur:fetch()
    if err then
      error(err)
    end
    if not row then
      break
    end

    -- Print result
    print("row", i, table.concat(row, "\t"))
    i = i + 1
  end
end)

return M
