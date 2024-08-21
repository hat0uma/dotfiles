local ffi = require("ffi")

require("rc.ctoys.libclang.defs.cx_file")
require("rc.ctoys.libclang.defs.cx_string")

ffi.cdef([[
typedef struct {
  const void *ptr_data[2];
  unsigned int_data;
} CXSourceLocation;

typedef struct {
  const void *ptr_data[2];
  unsigned begin_int_data;
  unsigned end_int_data;
} CXSourceRange;

CXSourceLocation clang_getNullLocation(void);

unsigned clang_equalLocations(CXSourceLocation loc1,
                                             CXSourceLocation loc2);

unsigned clang_isBeforeInTranslationUnit(CXSourceLocation loc1,
                                                        CXSourceLocation loc2);

int clang_Location_isInSystemHeader(CXSourceLocation location);

int clang_Location_isFromMainFile(CXSourceLocation location);

CXSourceRange clang_getNullRange(void);

CXSourceRange clang_getRange(CXSourceLocation begin,
                                            CXSourceLocation end);

unsigned clang_equalRanges(CXSourceRange range1,
                                          CXSourceRange range2);

int clang_Range_isNull(CXSourceRange range);

void clang_getExpansionLocation(CXSourceLocation location,
                                               CXFile *file, unsigned *line,
                                               unsigned *column,
                                               unsigned *offset);

void clang_getPresumedLocation(CXSourceLocation location,
                                              CXString *filename,
                                              unsigned *line, unsigned *column);

void clang_getInstantiationLocation(CXSourceLocation location,
                                                   CXFile *file, unsigned *line,
                                                   unsigned *column,
                                                   unsigned *offset);
void clang_getSpellingLocation(CXSourceLocation location,
                                              CXFile *file, unsigned *line,
                                              unsigned *column,
                                              unsigned *offset);

void clang_getFileLocation(CXSourceLocation location,
                                          CXFile *file, unsigned *line,
                                          unsigned *column, unsigned *offset);

CXSourceLocation clang_getRangeStart(CXSourceRange range);

CXSourceLocation clang_getRangeEnd(CXSourceRange range);

typedef struct {
  unsigned count;
  CXSourceRange *ranges;
} CXSourceRangeList;

void clang_disposeSourceRangeList(CXSourceRangeList *ranges);

]])
