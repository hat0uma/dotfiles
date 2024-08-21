local ffi = require("ffi")

require("rc.ctoys.libclang.defs.cx_error_code")
require("rc.ctoys.libclang.defs.index")

ffi.cdef([[
typedef struct {
  const void *ASTNode;
  CXTranslationUnit TranslationUnit;
} CXComment;

CXComment clang_Cursor_getParsedComment(CXCursor C);

enum CXCommentKind {
  CXComment_Null = 0,
  CXComment_Text = 1,
  CXComment_InlineCommand = 2,
  CXComment_HTMLStartTag = 3,
  CXComment_HTMLEndTag = 4,
  CXComment_Paragraph = 5,
  CXComment_BlockCommand = 6,
  CXComment_ParamCommand = 7,
  CXComment_TParamCommand = 8,
  CXComment_VerbatimBlockCommand = 9,
  CXComment_VerbatimBlockLine = 10,
  CXComment_VerbatimLine = 11,
  CXComment_FullComment = 12
};


enum CXCommentInlineCommandRenderKind {
  CXCommentInlineCommandRenderKind_Normal,
  CXCommentInlineCommandRenderKind_Bold,
  CXCommentInlineCommandRenderKind_Monospaced,
  CXCommentInlineCommandRenderKind_Emphasized,
  CXCommentInlineCommandRenderKind_Anchor
};


enum CXCommentParamPassDirection {
  CXCommentParamPassDirection_In,
  CXCommentParamPassDirection_Out,
  CXCommentParamPassDirection_InOut
};


enum CXCommentKind clang_Comment_getKind(CXComment Comment);

unsigned clang_Comment_getNumChildren(CXComment Comment);

CXComment clang_Comment_getChild(CXComment Comment, unsigned ChildIdx);

unsigned clang_Comment_isWhitespace(CXComment Comment);

unsigned clang_InlineContentComment_hasTrailingNewline(CXComment Comment);

CXString clang_TextComment_getText(CXComment Comment);

CXString clang_InlineCommandComment_getCommandName(CXComment Comment);

enum CXCommentInlineCommandRenderKind
clang_InlineCommandComment_getRenderKind(CXComment Comment);

unsigned clang_InlineCommandComment_getNumArgs(CXComment Comment);

CXString clang_InlineCommandComment_getArgText(CXComment Comment,
                                               unsigned ArgIdx);

CXString clang_HTMLTagComment_getTagName(CXComment Comment);

unsigned clang_HTMLStartTagComment_isSelfClosing(CXComment Comment);

unsigned clang_HTMLStartTag_getNumAttrs(CXComment Comment);

CXString clang_HTMLStartTag_getAttrName(CXComment Comment, unsigned AttrIdx);

CXString clang_HTMLStartTag_getAttrValue(CXComment Comment, unsigned AttrIdx);

CXString clang_BlockCommandComment_getCommandName(CXComment Comment);

unsigned clang_BlockCommandComment_getNumArgs(CXComment Comment);

CXString clang_BlockCommandComment_getArgText(CXComment Comment, unsigned ArgIdx);

CXComment clang_BlockCommandComment_getParagraph(CXComment Comment);

CXString clang_ParamCommandComment_getParamName(CXComment Comment);

unsigned clang_ParamCommandComment_isParamIndexValid(CXComment Comment);

unsigned clang_ParamCommandComment_getParamIndex(CXComment Comment);

unsigned clang_ParamCommandComment_isDirectionExplicit(CXComment Comment);

enum CXCommentParamPassDirection clang_ParamCommandComment_getDirection(
                                                            CXComment Comment);

CXString clang_TParamCommandComment_getParamName(CXComment Comment);

unsigned clang_TParamCommandComment_isParamPositionValid(CXComment Comment);

unsigned clang_TParamCommandComment_getDepth(CXComment Comment);

unsigned clang_TParamCommandComment_getIndex(CXComment Comment, unsigned Depth);

CXString clang_VerbatimBlockLineComment_getText(CXComment Comment);

CXString clang_VerbatimLineComment_getText(CXComment Comment);

CXString clang_HTMLTagComment_getAsString(CXComment Comment);

CXString clang_FullComment_getAsHTML(CXComment Comment);

CXString clang_FullComment_getAsXML(CXComment Comment);

typedef struct CXAPISetImpl *CXAPISet;

enum CXErrorCode clang_createAPISet(CXTranslationUnit tu,
                                                   CXAPISet *out_api);

void clang_disposeAPISet(CXAPISet api);

CXString clang_getSymbolGraphForUSR(const char *usr,
                                                   CXAPISet api);

CXString clang_getSymbolGraphForCursor(CXCursor cursor);

]])
