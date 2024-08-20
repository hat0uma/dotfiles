local M = {}

function M.setup()
  require("rc.ctoys.libclang.defs.build_system")
  require("rc.ctoys.libclang.defs.cx_compilation_database")
  require("rc.ctoys.libclang.defs.cx_diagnostic")
  require("rc.ctoys.libclang.defs.cx_error_code")
  require("rc.ctoys.libclang.defs.cx_file")
  require("rc.ctoys.libclang.defs.cx_source_location")
  require("rc.ctoys.libclang.defs.cx_string")
  require("rc.ctoys.libclang.defs.documentation")
  require("rc.ctoys.libclang.defs.fatal_error_handler")
  require("rc.ctoys.libclang.defs.index")
  require("rc.ctoys.libclang.defs.init")
  require("rc.ctoys.libclang.defs.rewrite")
  require("rc.ctoys.libclang.defs.time")
end

return M
