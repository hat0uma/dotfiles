local M = {}

function M.test()
  local lib = "~/scoop/apps/llvm/current/bin/libclang.dll"

  local ffi = require("ffi")
  local libclang = ffi.load(vim.fs.normalize(lib))
  require("rc.toys.libclang.defs.init").setup()

  -- define the visitor function
  local function visitor(cursor, parent, client_data)
    local cursor_kind = cursor.kind
    if cursor_kind == ffi.C.CXCursor_FunctionDecl then
      local spelling = libclang.clang_getCursorSpelling(cursor)
      local name = ffi.string(libclang.clang_getCString(spelling))
      print("Function found: " .. name)
      libclang.clang_disposeString(spelling)
    end
    return ffi.C.CXChildVisit_Continue
  end

  local visitor_c = ffi.cast("CXCursorVisitor", visitor)

  local index = libclang.clang_createIndex(0, 0)
  local tu = libclang.clang_parseTranslationUnit(index, "example.c", nil, 0, nil, 0, 0)

  local cursor = libclang.clang_getTranslationUnitCursor(tu)

  libclang.clang_visitChildren(cursor, visitor_c, nil)

  -- clean up
  libclang.clang_disposeTranslationUnit(tu)
  libclang.clang_disposeIndex(index)
  visitor_c:free()
end

return M
