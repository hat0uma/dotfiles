local M = {}

function M.setup()
  require("rc.toys.libclang.defs.build_system")
  require("rc.toys.libclang.defs.cx_compilation_database")
  require("rc.toys.libclang.defs.cx_diagnostic")
  require("rc.toys.libclang.defs.cx_error_code")
  require("rc.toys.libclang.defs.cx_file")
  require("rc.toys.libclang.defs.cx_source_location")
  require("rc.toys.libclang.defs.cx_string")
  require("rc.toys.libclang.defs.documentation")
  require("rc.toys.libclang.defs.fatal_error_handler")
  require("rc.toys.libclang.defs.index")
  require("rc.toys.libclang.defs.init")
  require("rc.toys.libclang.defs.rewrite")
  require("rc.toys.libclang.defs.time")
end

return M
