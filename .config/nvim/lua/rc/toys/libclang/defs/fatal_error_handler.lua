local ffi = require("ffi")

ffi.cdef([[

void clang_install_aborting_llvm_fatal_error_handler(void);

void clang_uninstall_llvm_fatal_error_handler(void);
]])
