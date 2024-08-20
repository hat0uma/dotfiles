local ffi = require("ffi")

require("rc.ctoys.libclang.defs.cx_string")

ffi.cdef([[
typedef void * CXCompilationDatabase;
typedef void * CXCompileCommands;
typedef void * CXCompileCommand;
typedef enum  {
  CXCompilationDatabase_NoError = 0,
  CXCompilationDatabase_CanNotLoadDatabase = 1
} CXCompilationDatabase_Error;

CXCompilationDatabase
clang_CompilationDatabase_fromDirectory(const char *BuildDir,
                                        CXCompilationDatabase_Error *ErrorCode);

void
clang_CompilationDatabase_dispose(CXCompilationDatabase);

CXCompileCommands
clang_CompilationDatabase_getCompileCommands(CXCompilationDatabase,
                                             const char *CompleteFileName);

CXCompileCommands
clang_CompilationDatabase_getAllCompileCommands(CXCompilationDatabase);

void clang_CompileCommands_dispose(CXCompileCommands);

unsigned
clang_CompileCommands_getSize(CXCompileCommands);

CXCompileCommand
clang_CompileCommands_getCommand(CXCompileCommands, unsigned I);

CXString
clang_CompileCommand_getDirectory(CXCompileCommand);

CXString
clang_CompileCommand_getFilename(CXCompileCommand);

unsigned
clang_CompileCommand_getNumArgs(CXCompileCommand);

CXString
clang_CompileCommand_getArg(CXCompileCommand, unsigned I);

unsigned
clang_CompileCommand_getNumMappedSources(CXCompileCommand);

CXString
clang_CompileCommand_getMappedSourcePath(CXCompileCommand, unsigned I);

CXString
clang_CompileCommand_getMappedSourceContent(CXCompileCommand, unsigned I);

]])
