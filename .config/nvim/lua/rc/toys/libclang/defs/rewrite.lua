local ffi = require("ffi")

require("rc.toys.libclang.defs.cx_string")
require("rc.toys.libclang.defs.index")

ffi.cdef([[

typedef void *CXRewriter;

CXRewriter clang_CXRewriter_create(CXTranslationUnit TU);

void clang_CXRewriter_insertTextBefore(CXRewriter Rew, CXSourceLocation Loc,
                                           const char *Insert);

void clang_CXRewriter_replaceText(CXRewriter Rew, CXSourceRange ToBeReplaced,
                                      const char *Replacement);

void clang_CXRewriter_removeText(CXRewriter Rew, CXSourceRange ToBeRemoved);

int clang_CXRewriter_overwriteChangedFiles(CXRewriter Rew);

void clang_CXRewriter_writeMainFileToStdOut(CXRewriter Rew);

void clang_CXRewriter_dispose(CXRewriter Rew);

]])
