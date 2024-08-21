-- BuildSystem.h from libclang

local ffi = require("ffi")

require("rc.ctoys.libclang.defs.cx_error_code")
require("rc.ctoys.libclang.defs.cx_string")

ffi.cdef([[
unsigned long long clang_getBuildSessionTimestamp(void);

typedef struct CXVirtualFileOverlayImpl *CXVirtualFileOverlay;

CXVirtualFileOverlay clang_VirtualFileOverlay_create(unsigned options);

enum CXErrorCode
clang_VirtualFileOverlay_addFileMapping(CXVirtualFileOverlay,
                                        const char *virtualPath,
                                        const char *realPath);

enum CXErrorCode
clang_VirtualFileOverlay_setCaseSensitivity(CXVirtualFileOverlay,
                                            int caseSensitive);

enum CXErrorCode
clang_VirtualFileOverlay_writeToBuffer(CXVirtualFileOverlay, unsigned options,
                                       char **out_buffer_ptr,
                                       unsigned *out_buffer_size);

void clang_free(void *buffer);

void clang_VirtualFileOverlay_dispose(CXVirtualFileOverlay);

typedef struct CXModuleMapDescriptorImpl *CXModuleMapDescriptor;

CXModuleMapDescriptor clang_ModuleMapDescriptor_create(unsigned options);

enum CXErrorCode
clang_ModuleMapDescriptor_setFrameworkModuleName(CXModuleMapDescriptor,
                                                 const char *name);

enum CXErrorCode
clang_ModuleMapDescriptor_setUmbrellaHeader(CXModuleMapDescriptor,
                                            const char *name);

enum CXErrorCode
clang_ModuleMapDescriptor_writeToBuffer(CXModuleMapDescriptor, unsigned options,
                                       char **out_buffer_ptr,
                                       unsigned *out_buffer_size);

void clang_ModuleMapDescriptor_dispose(CXModuleMapDescriptor);
]])
