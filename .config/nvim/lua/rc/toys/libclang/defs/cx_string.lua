local ffi = require("ffi")

ffi.cdef([[
typedef struct {
  const void *data;
  unsigned private_flags;
} CXString;

typedef struct {
  CXString *Strings;
  unsigned Count;
} CXStringSet;

const char *clang_getCString(CXString string);

void clang_disposeString(CXString string);

void clang_disposeStringSet(CXStringSet *set);
]])
