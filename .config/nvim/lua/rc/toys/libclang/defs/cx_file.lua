local ffi = require("ffi")

require("rc.ctoys.libclang.defs.time")
require("rc.ctoys.libclang.defs.cx_string")

ffi.cdef([[
typedef void *CXFile;

CXString clang_getFileName(CXFile SFile);

time_t clang_getFileTime(CXFile SFile);

typedef struct {
  unsigned long long data[3];
} CXFileUniqueID;

int clang_getFileUniqueID(CXFile file, CXFileUniqueID *outID);

int clang_File_isEqual(CXFile file1, CXFile file2);

CXString clang_File_tryGetRealPathName(CXFile file);
]])
