local ffi = require("ffi")

require("rc.ctoys.libclang.defs.cx_source_location")
require("rc.ctoys.libclang.defs.cx_string")

ffi.cdef([[
enum CXDiagnosticSeverity {
  CXDiagnostic_Ignored = 0,
  CXDiagnostic_Note = 1,
  CXDiagnostic_Warning = 2,
  CXDiagnostic_Error = 3,
  CXDiagnostic_Fatal = 4
};

typedef void *CXDiagnostic;
typedef void *CXDiagnosticSet;

unsigned clang_getNumDiagnosticsInSet(CXDiagnosticSet Diags);

CXDiagnostic clang_getDiagnosticInSet(CXDiagnosticSet Diags,
                                                     unsigned Index);
enum CXLoadDiag_Error {
  CXLoadDiag_None = 0,
  CXLoadDiag_Unknown = 1,
  CXLoadDiag_CannotLoad = 2,
  CXLoadDiag_InvalidFile = 3
};

CXDiagnosticSet clang_loadDiagnostics(
    const char *file, enum CXLoadDiag_Error *error, CXString *errorString);

void clang_disposeDiagnosticSet(CXDiagnosticSet Diags);

CXDiagnosticSet clang_getChildDiagnostics(CXDiagnostic D);

void clang_disposeDiagnostic(CXDiagnostic Diagnostic);

enum CXDiagnosticDisplayOptions {
  CXDiagnostic_DisplaySourceLocation = 0x01,
  CXDiagnostic_DisplayColumn = 0x02,
  CXDiagnostic_DisplaySourceRanges = 0x04,
  CXDiagnostic_DisplayOption = 0x08,
  CXDiagnostic_DisplayCategoryId = 0x10,
  CXDiagnostic_DisplayCategoryName = 0x20
};

CXString clang_formatDiagnostic(CXDiagnostic Diagnostic,
                                               unsigned Options);

unsigned clang_defaultDiagnosticDisplayOptions(void);

enum CXDiagnosticSeverity
    clang_getDiagnosticSeverity(CXDiagnostic);

CXSourceLocation clang_getDiagnosticLocation(CXDiagnostic);

CXString clang_getDiagnosticSpelling(CXDiagnostic);

CXString clang_getDiagnosticOption(CXDiagnostic Diag,
                                                  CXString *Disable);

unsigned clang_getDiagnosticCategory(CXDiagnostic);

CXString
clang_getDiagnosticCategoryName(unsigned Category);

CXString clang_getDiagnosticCategoryText(CXDiagnostic);

unsigned clang_getDiagnosticNumRanges(CXDiagnostic);

CXSourceRange clang_getDiagnosticRange(CXDiagnostic Diagnostic,
                                                      unsigned Range);

unsigned clang_getDiagnosticNumFixIts(CXDiagnostic Diagnostic);

CXString clang_getDiagnosticFixIt(
    CXDiagnostic Diagnostic, unsigned FixIt, CXSourceRange *ReplacementRange);

]])
