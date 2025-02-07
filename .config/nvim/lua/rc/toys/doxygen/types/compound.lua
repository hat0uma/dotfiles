------------------------------------------------------------
-- Simple types (aliases)
------------------------------------------------------------

--- @alias Doxygen.Compound.DoxBool
--- | "yes"
--- | "no"

--- @alias Doxygen.Compound.DoxGraphRelation
--- | "include"
--- | "usage"
--- | "template-instance"
--- | "public-inheritance"
--- | "protected-inheritance"
--- | "private-inheritance"
--- | "type-constraint"

--- @alias Doxygen.Compound.DoxRefKind
--- | "compound"
--- | "member"

--- @alias Doxygen.Compound.MemberKind
--- | "define"
--- | "property"
--- | "event"
--- | "variable"
--- | "typedef"
--- | "enum"
--- | "enumvalue"
--- | "function"
--- | "signal"
--- | "prototype"
--- | "friend"
--- | "dcop"
--- | "slot"

--- @alias Doxygen.Compound.DoxMemberKind
--- | "define"
--- | "property"
--- | "event"
--- | "variable"
--- | "typedef"
--- | "enum"
--- | "function"
--- | "signal"
--- | "prototype"
--- | "friend"
--- | "dcop"
--- | "slot"
--- | "interface"
--- | "service"

--- @alias Doxygen.Compound.DoxProtectionKind
--- | "public"
--- | "protected"
--- | "private"
--- | "package"

--- @alias Doxygen.Compound.DoxRefQualifierKind
--- | "lvalue"
--- | "rvalue"

--- @alias Doxygen.Compound.DoxLanguage
--- | "Unknown"
--- | "IDL"
--- | "Java"
--- | "C#"
--- | "D"
--- | "PHP"
--- | "Objective-C"
--- | "C++"
--- | "JavaScript"
--- | "Python"
--- | "Fortran"
--- | "VHDL"
--- | "XML"
--- | "SQL"
--- | "Markdown"
--- | "Slice"
--- | "Lex"

--- @alias Doxygen.Compound.DoxVirtualKind
--- | "non-virtual"
--- | "virtual"
--- | "pure-virtual"

--- @alias Doxygen.Compound.DoxCompoundKind
--- | "class"
--- | "struct"
--- | "union"
--- | "interface"
--- | "protocol"
--- | "category"
--- | "exception"
--- | "service"
--- | "singleton"
--- | "module"
--- | "type"
--- | "file"
--- | "namespace"
--- | "group"
--- | "page"
--- | "example"
--- | "dir"
--- | "concept"

--- @alias Doxygen.Compound.DoxSectionKind
--- | "user-defined"
--- | "public-type"
--- | "public-func"
--- | "public-attrib"
--- | "public-slot"
--- | "signal"
--- | "dcop-func"
--- | "property"
--- | "event"
--- | "public-static-func"
--- | "public-static-attrib"
--- | "protected-type"
--- | "protected-func"
--- | "protected-attrib"
--- | "protected-slot"
--- | "protected-static-func"
--- | "protected-static-attrib"
--- | "package-type"
--- | "package-func"
--- | "package-attrib"
--- | "package-static-func"
--- | "package-static-attrib"
--- | "private-type"
--- | "private-func"
--- | "private-attrib"
--- | "private-slot"
--- | "private-static-func"
--- | "private-static-attrib"
--- | "friend"
--- | "related"
--- | "define"
--- | "prototype"
--- | "typedef"
--- | "enum"
--- | "func"
--- | "var"

--- @alias Doxygen.Compound.DoxHighlightClass
--- | "comment"
--- | "normal"
--- | "preprocessor"
--- | "keyword"
--- | "keywordtype"
--- | "keywordflow"
--- | "stringliteral"
--- | "xmlcdata"
--- | "charliteral"
--- | "vhdlkeyword"
--- | "vhdllogic"
--- | "vhdlchar"
--- | "vhdldigit"

--- @alias Doxygen.Compound.DoxSimpleSectKind
--- | "see"
--- | "return"
--- | "author"
--- | "authors"
--- | "version"
--- | "since"
--- | "date"
--- | "note"
--- | "warning"
--- | "pre"
--- | "post"
--- | "copyright"
--- | "invariant"
--- | "remark"
--- | "attention"
--- | "important"
--- | "par"
--- | "rcs"

--- @alias Doxygen.Compound.DoxCheck
--- | "checked"
--- | "unchecked"

--- @alias Doxygen.Compound.DoxVersionNumber string  -- (pattern: \d+\.\d+.*)

--- @alias Doxygen.Compound.DoxImageKind
--- | "html"
--- | "latex"
--- | "docbook"
--- | "rtf"
--- | "xml"

--- @alias Doxygen.Compound.DoxPlantumlEngine
--- | "uml"
--- | "bpm"
--- | "wire"
--- | "dot"
--- | "ditaa"
--- | "salt"
--- | "math"
--- | "latex"
--- | "gantt"
--- | "mindmap"
--- | "wbs"
--- | "yaml"
--- | "creole"
--- | "json"
--- | "flow"
--- | "board"
--- | "git"
--- | "hcl"
--- | "regex"
--- | "ebnf"
--- | "files"

--- @alias Doxygen.Compound.DoxParamListKind
--- | "param"
--- | "retval"
--- | "exception"
--- | "templateparam"

--- @alias Doxygen.Compound.DoxCharRange string  -- (pattern: [aeiouncAEIOUNC])

--- @alias Doxygen.Compound.DoxParamDir
--- | "in"
--- | "out"
--- | "inout"

--- @alias Doxygen.Compound.DoxAccessor
--- | "retain"
--- | "copy"
--- | "assign"
--- | "weak"
--- | "strong"
--- | "unretained"

--- @alias Doxygen.Compound.DoxAlign
--- | "left"
--- | "right"
--- | "center"

--- @alias Doxygen.Compound.DoxVerticalAlign
--- | "bottom"
--- | "top"
--- | "middle"

--- @alias Doxygen.Compound.DoxOlType
--- | "1"
--- | "a"
--- | "A"
--- | "i"
--- | "I"

------------------------------------------------------------
-- Complex types
------------------------------------------------------------

--- DoxygenType represents the root element "doxygen"
--- @class Doxygen.Compound.DoxygenType
--- @field compounddef Doxygen.Compound.compounddefType[]  -- (0..unbounded sequence of compounddef elements)
--- @field version Doxygen.Compound.DoxVersionNumber         -- (required attribute)
--- @field xml_lang string                  -- (xml:lang attribute, required)
local DoxygenType = {}

--- @class Doxygen.Compound.compounddefType
--- @field compoundname string
--- @field title string?
--- @field basecompoundref Doxygen.Compound.compoundRefType[]      -- (minOccurs=0, maxOccurs=unbounded)
--- @field derivedcompoundref Doxygen.Compound.compoundRefType[]
--- @field includes Doxygen.Compound.incType[]
--- @field includedby Doxygen.Compound.incType[]
--- @field incdepgraph Doxygen.Compound.graphType?
--- @field invincdepgraph Doxygen.Compound.graphType?
--- @field innermodule Doxygen.Compound.refType[]
--- @field innerdir Doxygen.Compound.refType[]
--- @field innerfile Doxygen.Compound.refType[]
--- @field innerclass Doxygen.Compound.refType[]
--- @field innerconcept Doxygen.Compound.refType[]
--- @field innernamespace Doxygen.Compound.refType[]
--- @field innerpage Doxygen.Compound.refType[]
--- @field innergroup Doxygen.Compound.refType[]
--- @field qualifier string[]         -- (multiple occurrences)
--- @field templateparamlist Doxygen.Compound.templateparamlistType?
--- @field sectiondef Doxygen.Compound.sectiondefType[]
--- @field tableofcontents Doxygen.Compound.tableofcontentsType?  -- (maxOccurs=1)
--- @field requiresclause Doxygen.Compound.linkedTextType?
--- @field initializer Doxygen.Compound.linkedTextType?
--- @field briefdescription Doxygen.Compound.descriptionType?
--- @field detaileddescription Doxygen.Compound.descriptionType?
--- @field exports Doxygen.Compound.exportsType?
--- @field inheritancegraph Doxygen.Compound.graphType?
--- @field collaborationgraph Doxygen.Compound.graphType?
--- @field programlisting Doxygen.Compound.listingType?
--- @field location Doxygen.Compound.locationType?
--- @field listofallmembers Doxygen.Compound.listofallmembersType?
--- @field id string                -- (attribute "id")
--- @field kind Doxygen.Compound.DoxCompoundKind     -- (attribute "kind")
--- @field language Doxygen.Compound.DoxLanguage?     -- (optional attribute "language")
--- @field prot Doxygen.Compound.DoxProtectionKind?   -- (attribute "prot")
--- @field final Doxygen.Compound.DoxBool?            -- (optional attribute)
--- @field inline Doxygen.Compound.DoxBool?           -- (optional attribute)
--- @field sealed Doxygen.Compound.DoxBool?           -- (optional attribute)
--- @field abstract Doxygen.Compound.DoxBool?         -- (optional attribute)
local compounddefType = {}

--- @class Doxygen.Compound.listofallmembersType
--- @field member Doxygen.Compound.memberRefType[]
local listofallmembersType = {}

--- @class Doxygen.Compound.memberRefType
--- @field scope string
--- @field name string
--- @field refid string?           -- (attribute)
--- @field prot Doxygen.Compound.DoxProtectionKind? -- (attribute)
--- @field virt Doxygen.Compound.DoxVirtualKind?    -- (attribute)
--- @field ambiguityscope string?  -- (attribute)
local memberRefType = {}

--- @class Doxygen.Compound.docHtmlOnlyType
--- @field value string           -- (simple content)
--- @field block string?          -- (attribute "block")
local docHtmlOnlyType = {}

--- @class Doxygen.Compound.compoundRefType
--- @field value string           -- (simple content)
--- @field refid string?          -- (optional attribute "refid")
--- @field prot Doxygen.Compound.DoxProtectionKind? -- (attribute "prot")
--- @field virt Doxygen.Compound.DoxVirtualKind?   -- (attribute "virt")
local compoundRefType = {}

--- @class Doxygen.Compound.reimplementType
--- @field value string
--- @field refid string           -- (attribute "refid")
local reimplementType = {}

--- @class Doxygen.Compound.incType
--- @field value string
--- @field refid string?          -- (optional attribute "refid")
--- @field local Doxygen.Compound.DoxBool          -- (attribute "local")
local incType = {}

--- @class Doxygen.Compound.exportsType
--- @field export Doxygen.Compound.exportType[]      -- (sequence of export elements)
local exportsType = {}

--- @class Doxygen.Compound.exportType
--- @field value string
--- @field refid string?           -- (optional attribute "refid")
local exportType = {}

--- @class Doxygen.Compound.refType
--- @field value string
--- @field refid string           -- (attribute "refid")
--- @field prot Doxygen.Compound.DoxProtectionKind? -- (optional attribute "prot")
--- @field inline Doxygen.Compound.DoxBool?        -- (optional attribute "inline")
local refType = {}

--- @class Doxygen.Compound.refTextType
--- @field value string
--- @field refid string           -- (attribute "refid")
--- @field kindref Doxygen.Compound.DoxRefKind     -- (attribute "kindref")
--- @field external string?       -- (optional attribute "external")
--- @field tooltip string?        -- (optional attribute "tooltip")
local refTextType = {}

--- @class Doxygen.Compound.MemberType
--- @field name string
--- @field refid string           -- (required attribute)
--- @field kind Doxygen.Compound.MemberKind        -- (required attribute)
local MemberType = {}

--- @class Doxygen.Compound.sectiondefType
--- @field header string?
--- @field description Doxygen.Compound.descriptionType?
--- @field memberdef Doxygen.Compound.memberdefType[]  -- (choice: memberdef elements)
--- @field member Doxygen.Compound.MemberType[]        -- (choice: member elements)
--- @field kind Doxygen.Compound.DoxSectionKind         -- (attribute "kind")
local sectiondefType = {}

--- @class Doxygen.Compound.memberdefType
--- @field templateparamlist Doxygen.Compound.templateparamlistType?
--- @field type Doxygen.Compound.linkedTextType?
--- @field definition string?
--- @field argsstring string?
--- @field name string
--- @field qualifiedname string?
--- @field read string?
--- @field write string?
--- @field bitfield string?
--- @field reimplements Doxygen.Compound.reimplementType[]
--- @field reimplementedby Doxygen.Compound.reimplementType[]
--- @field qualifier string[]
--- @field param Doxygen.Compound.paramType[]
--- @field enumvalue Doxygen.Compound.enumvalueType[]
--- @field requiresclause Doxygen.Compound.linkedTextType?
--- @field initializer Doxygen.Compound.linkedTextType?
--- @field exceptions Doxygen.Compound.linkedTextType?
--- @field briefdescription Doxygen.Compound.descriptionType?
--- @field detaileddescription Doxygen.Compound.descriptionType?
--- @field inbodydescription Doxygen.Compound.descriptionType?
--- @field location Doxygen.Compound.locationType
--- @field references Doxygen.Compound.referenceType[]
--- @field referencedby Doxygen.Compound.referenceType[]
--- @field kind Doxygen.Compound.DoxMemberKind            -- (attribute "kind")
--- @field id string                     -- (attribute "id")
--- @field prot Doxygen.Compound.DoxProtectionKind         -- (attribute "prot")
--- @field static Doxygen.Compound.DoxBool                -- (attribute "static")
--- @field extern Doxygen.Compound.DoxBool?                -- (optional attribute "extern")
--- @field strong Doxygen.Compound.DoxBool?                -- (optional attribute "strong")
--- @field const Doxygen.Compound.DoxBool?                 -- (optional attribute "const")
--- @field explicit Doxygen.Compound.DoxBool?              -- (optional attribute "explicit")
--- @field inline Doxygen.Compound.DoxBool?                -- (optional attribute "inline")
--- @field refqual Doxygen.Compound.DoxRefQualifierKind?   -- (optional attribute "refqual")
--- @field virt Doxygen.Compound.DoxVirtualKind?           -- (optional attribute "virt")
--- @field volatile Doxygen.Compound.DoxBool?              -- (optional attribute "volatile")
--- @field mutable Doxygen.Compound.DoxBool?               -- (optional attribute "mutable")
--- @field noexcept Doxygen.Compound.DoxBool?              -- (optional attribute "noexcept")
--- @field noexceptexpression string?     -- (optional attribute "noexceptexpression")
--- @field nodiscard Doxygen.Compound.DoxBool?             -- (optional attribute "nodiscard")
--- @field constexpr Doxygen.Compound.DoxBool?             -- (optional attribute "constexpr")
--- @field consteval Doxygen.Compound.DoxBool?             -- (optional attribute "consteval")
--- @field constinit Doxygen.Compound.DoxBool?             -- (optional attribute "constinit")
--- -- Additional platform/language specific attributes:
--- @field readable Doxygen.Compound.DoxBool?
--- @field writable Doxygen.Compound.DoxBool?
--- @field initonly Doxygen.Compound.DoxBool?
--- @field settable Doxygen.Compound.DoxBool?
--- @field privatesettable Doxygen.Compound.DoxBool?
--- @field protectedsettable Doxygen.Compound.DoxBool?
--- @field gettable Doxygen.Compound.DoxBool?
--- @field privategettable Doxygen.Compound.DoxBool?
--- @field protectedgettable Doxygen.Compound.DoxBool?
--- @field final Doxygen.Compound.DoxBool?
--- @field sealed Doxygen.Compound.DoxBool?
--- @field new Doxygen.Compound.DoxBool?
--- @field add Doxygen.Compound.DoxBool?
--- @field remove Doxygen.Compound.DoxBool?
--- @field raise Doxygen.Compound.DoxBool?
--- @field optional Doxygen.Compound.DoxBool?
--- @field required Doxygen.Compound.DoxBool?
--- @field accessor Doxygen.Compound.DoxAccessor?
--- @field attribute Doxygen.Compound.DoxBool?
--- @field property Doxygen.Compound.DoxBool?
--- @field readonly Doxygen.Compound.DoxBool?
--- @field bound Doxygen.Compound.DoxBool?
--- @field removable Doxygen.Compound.DoxBool?
--- @field constrained Doxygen.Compound.DoxBool?
--- @field transient Doxygen.Compound.DoxBool?
--- @field maybevoid Doxygen.Compound.DoxBool?
--- @field maybedefault Doxygen.Compound.DoxBool?
--- @field maybeambiguous Doxygen.Compound.DoxBool?
local memberdefType = {}

--- @class Doxygen.Compound.descriptionType
--- @field title string?
--- @field para Doxygen.Compound.docParaType[]
--- @field internal Doxygen.Compound.docInternalType[]
--- @field sect1 Doxygen.Compound.docSect1Type[]
local descriptionType = {}

--- @class Doxygen.Compound.enumvalueType
--- @field name string
--- @field initializer Doxygen.Compound.linkedTextType?
--- @field briefdescription Doxygen.Compound.descriptionType?
--- @field detaileddescription Doxygen.Compound.descriptionType?
--- @field id string           -- (attribute "id")
--- @field prot Doxygen.Compound.DoxProtectionKind -- (attribute "prot")
local enumvalueType = {}

--- @class Doxygen.Compound.templateparamlistType
--- @field param Doxygen.Compound.paramType[]
local templateparamlistType = {}

--- @class Doxygen.Compound.paramType
--- @field attributes string?
--- @field type Doxygen.Compound.linkedTextType?
--- @field declname string?
--- @field defname string?
--- @field array string?
--- @field defval Doxygen.Compound.linkedTextType?
--- @field typeconstraint Doxygen.Compound.linkedTextType?
--- @field briefdescription Doxygen.Compound.descriptionType?
local paramType = {}

--- @class Doxygen.Compound.linkedTextType
--- @field value string?         -- (mixed content text)
--- @field ref Doxygen.Compound.refTextType[]   -- (child ref elements)
local linkedTextType = {}

--- @class Doxygen.Compound.graphType
--- @field node Doxygen.Compound.nodeType[]
local graphType = {}

--- @class Doxygen.Compound.nodeType
--- @field label string
--- @field link Doxygen.Compound.linkType?
--- @field childnode Doxygen.Compound.childnodeType[]
--- @field id string   -- (attribute "id")
local nodeType = {}

--- @class Doxygen.Compound.childnodeType
--- @field edgelabel string[]   -- (multiple child edgelabel elements)
--- @field refid string          -- (attribute "refid")
--- @field relation Doxygen.Compound.DoxGraphRelation -- (attribute "relation")
local childnodeType = {}

--- @class Doxygen.Compound.linkType
--- @field refid string          -- (attribute "refid")
--- @field external string?      -- (optional attribute "external")
local linkType = {}

--- @class Doxygen.Compound.listingType
--- @field codeline Doxygen.Compound.codelineType[]
--- @field filename string?      -- (optional attribute "filename")
local listingType = {}

--- @class Doxygen.Compound.codelineType
--- @field highlight Doxygen.Compound.highlightType[]
--- @field lineno number         -- (attribute "lineno", integer)
--- @field refid string          -- (attribute "refid")
--- @field refkind Doxygen.Compound.DoxRefKind    -- (attribute "refkind")
--- @field external Doxygen.Compound.DoxBool      -- (attribute "external")
local codelineType = {}

--- @class Doxygen.Compound.highlightType
--- @field value string          -- (mixed content)
--- @field sp Doxygen.Compound.spType[]          -- (child sp elements)
--- @field ref Doxygen.Compound.refTextType[]    -- (child ref elements)
--- @field class Doxygen.Compound.DoxHighlightClass? -- (attribute "class")
local highlightType = {}

--- @class Doxygen.Compound.spType
--- @field value string          -- (mixed content text)
--- @field attr_value number?    -- (optional attribute "value")
local spType = {}

--- @class Doxygen.Compound.referenceType
--- @field value string?         -- (mixed content, if any)
--- @field refid string          -- (attribute "refid")
--- @field compoundref string?   -- (optional attribute "compoundref")
--- @field startline number      -- (attribute "startline", integer)
--- @field endline number        -- (attribute "endline", integer)
local referenceType = {}

--- @class Doxygen.Compound.locationType
--- @field file string?           -- (attribute "file")
--- @field line number?           -- (attribute "line")
--- @field column number?        -- (optional attribute "column")
--- @field declfile string?      -- (optional attribute "declfile")
--- @field declline number?      -- (optional attribute "declline")
--- @field declcolumn number?    -- (optional attribute "declcolumn")
--- @field bodyfile string?       -- (attribute "bodyfile")
--- @field bodystart number?      -- (attribute "bodystart")
--- @field bodyend number?        -- (attribute "bodyend")
local locationType = {}

--- @class Doxygen.Compound.docSect1Type
--- @field title Doxygen.Compound.docTitleType?
--- @field para Doxygen.Compound.docParaType[]
--- @field internal Doxygen.Compound.docInternalS1Type[]
--- @field sect2 Doxygen.Compound.docSect2Type[]
--- @field id string            -- (attribute "id")
local docSect1Type = {}

--- @class Doxygen.Compound.docSect2Type
--- @field title Doxygen.Compound.docTitleType?
--- @field para Doxygen.Compound.docParaType[]
--- @field sect3 Doxygen.Compound.docSect3Type[]
--- @field internal Doxygen.Compound.docInternalS2Type?
--- @field id string
local docSect2Type = {}

--- @class Doxygen.Compound.docSect3Type
--- @field title Doxygen.Compound.docTitleType?
--- @field para Doxygen.Compound.docParaType[]
--- @field sect4 Doxygen.Compound.docSect4Type[]
--- @field internal Doxygen.Compound.docInternalS3Type?
--- @field id string
local docSect3Type = {}

--- @class Doxygen.Compound.docSect4Type
--- @field title Doxygen.Compound.docTitleType?
--- @field para Doxygen.Compound.docParaType[]
--- @field sect5 Doxygen.Compound.docSect5Type[]
--- @field internal Doxygen.Compound.docInternalS4Type?
--- @field id string
local docSect4Type = {}

--- @class Doxygen.Compound.docSect5Type
--- @field title Doxygen.Compound.docTitleType?
--- @field para Doxygen.Compound.docParaType[]
--- @field sect6 Doxygen.Compound.docSect6Type[]
--- @field internal Doxygen.Compound.docInternalS5Type?
--- @field id string
local docSect5Type = {}

--- @class Doxygen.Compound.docSect6Type
--- @field title Doxygen.Compound.docTitleType?
--- @field para Doxygen.Compound.docParaType[]
--- @field internal Doxygen.Compound.docInternalS6Type?
--- @field id string
local docSect6Type = {}

--- @class Doxygen.Compound.docInternalType
--- @field para Doxygen.Compound.docParaType[]
--- @field sect1 Doxygen.Compound.docSect1Type[]
local docInternalType = {}

--- @class Doxygen.Compound.docInternalS1Type
--- @field para Doxygen.Compound.docParaType[]
--- @field sect2 Doxygen.Compound.docSect2Type[]
local docInternalS1Type = {}

--- @class Doxygen.Compound.docInternalS2Type
--- @field para Doxygen.Compound.docParaType[]
--- @field sect3 Doxygen.Compound.docSect3Type[]
local docInternalS2Type = {}

--- @class Doxygen.Compound.docInternalS3Type
--- @field para Doxygen.Compound.docParaType[]
--- @field sect4 Doxygen.Compound.docSect4Type[]
local docInternalS3Type = {}

--- @class Doxygen.Compound.docInternalS4Type
--- @field para Doxygen.Compound.docParaType[]
--- @field sect5 Doxygen.Compound.docSect5Type[]
local docInternalS4Type = {}

--- @class Doxygen.Compound.docInternalS5Type
--- @field para Doxygen.Compound.docParaType[]
--- @field sect6 Doxygen.Compound.docSect6Type[]
local docInternalS5Type = {}

--- @class Doxygen.Compound.docInternalS6Type
--- @field para Doxygen.Compound.docParaType[]
local docInternalS6Type = {}

--- @class Doxygen.Compound.docTitleType
--- @field value string?    -- (mixed content; may include inline commands)
local docTitleType = {}

--- @class Doxygen.Compound.docSummaryType
--- @field value string?
local docSummaryType = {}

--- @class Doxygen.Compound.docParaType
--- @field value string
--- @field cmds any[]      -- (contents defined by the "docCmdGroup")
local docParaType = {}

--- @class Doxygen.Compound.docMarkupType
--- @field cmds any[]
local docMarkupType = {}

--- @class Doxygen.Compound.docURLLink
--- @field cmds any[]
--- @field url string       -- (attribute "url")
local docURLLink = {}

--- @class Doxygen.Compound.docAnchorType
--- @field id string?       -- (attribute "id")
local docAnchorType = {}

--- @class Doxygen.Compound.docFormulaType
--- @field id string?       -- (attribute "id")
local docFormulaType = {}

--- @class Doxygen.Compound.docIndexEntryType
--- @field primaryie string
--- @field secondaryie string
local docIndexEntryType = {}

--- @class Doxygen.Compound.docListType
--- @field listitem Doxygen.Compound.docListItemType[]
--- @field type Doxygen.Compound.DoxOlType?   -- (attribute "type")
--- @field start number?     -- (attribute "start")
local docListType = {}

--- @class Doxygen.Compound.docListItemType
--- @field para Doxygen.Compound.docParaType[]
--- @field override Doxygen.Compound.DoxCheck? -- (attribute "override")
--- @field value number?     -- (attribute "value")
local docListItemType = {}

--- @class Doxygen.Compound.docSimpleSectType
--- @field title Doxygen.Compound.docTitleType?
--- @field para Doxygen.Compound.docParaType[]   -- (one or more "para" elements)
--- @field kind Doxygen.Compound.DoxSimpleSectKind -- (attribute "kind")
local docSimpleSectType = {}

--- @class Doxygen.Compound.docVarListEntryType
--- @field term Doxygen.Compound.docTitleType
local docVarListEntryType = {}

--- @class Doxygen.Compound.docVariableListEntry
--- @field varlistentry Doxygen.Compound.docVarListEntryType
--- @field listitem Doxygen.Compound.docListItemType
local docVariableListEntry = {}

--- @class Doxygen.Compound.docVariableListType
--- @field entries Doxygen.Compound.docVariableListEntry[]
local docVariableListType = {}

--- @class Doxygen.Compound.docRefTextType
--- @field cmds any[]
--- @field refid string?      -- (attribute "refid")
--- @field kindref Doxygen.Compound.DoxRefKind? -- (attribute "kindref")
--- @field external string?   -- (attribute "external")
local docRefTextType = {}

--- @class Doxygen.Compound.docTableType
--- @field caption Doxygen.Compound.docCaptionType?
--- @field row Doxygen.Compound.docRowType[]
--- @field rows number?       -- (attribute "rows")
--- @field cols number?       -- (attribute "cols")
--- @field width string?      -- (attribute "width")
local docTableType = {}

--- @class Doxygen.Compound.docRowType
--- @field entry Doxygen.Compound.docEntryType[]
local docRowType = {}

--- @class Doxygen.Compound.docEntryType
--- @field para Doxygen.Compound.docParaType[]
--- @field thead Doxygen.Compound.DoxBool?          -- (attribute "thead")
--- @field colspan number?         -- (attribute "colspan")
--- @field rowspan number?         -- (attribute "rowspan")
--- @field align Doxygen.Compound.DoxAlign?         -- (attribute "align")
--- @field valign Doxygen.Compound.DoxVerticalAlign?-- (attribute "valign")
--- @field width string?           -- (attribute "width")
--- @field class string?           -- (attribute "class")
local docEntryType = {}

--- @class Doxygen.Compound.docCaptionType
--- @field cmds any[]
--- @field id string?             -- (attribute "id")
local docCaptionType = {}

--- @alias Doxygen.Compound.range_1_6 number   -- (integer value in the range 1 to 6)

--- @class Doxygen.Compound.docHeadingType
--- @field cmds any[]
--- @field level Doxygen.Compound.range_1_6      -- (attribute "level")
local docHeadingType = {}

--- @class Doxygen.Compound.docImageType
--- @field cmds any[]
--- @field type Doxygen.Compound.DoxImageKind?     -- (optional attribute "type")
--- @field name string?           -- (optional attribute "name")
--- @field width string?          -- (optional attribute "width")
--- @field height string?         -- (optional attribute "height")
--- @field alt string?            -- (optional attribute "alt")
--- @field inline Doxygen.Compound.DoxBool?        -- (optional attribute "inline")
--- @field caption string?        -- (optional attribute "caption")
local docImageType = {}

--- @class Doxygen.Compound.docDotMscType
--- @field cmds any[]
--- @field name string?           -- (optional attribute "name")
--- @field width string?          -- (optional attribute "width")
--- @field height string?         -- (optional attribute "height")
--- @field caption string?        -- (optional attribute "caption")
local docDotMscType = {}

--- @class Doxygen.Compound.docImageFileType
--- @field cmds any[]
--- @field name string?           -- (optional attribute "name")
--- @field width string?          -- (optional attribute "width")
--- @field height string?         -- (optional attribute "height")
local docImageFileType = {}

--- @class Doxygen.Compound.docPlantumlType
--- @field cmds any[]
--- @field name string?           -- (optional attribute "name")
--- @field width string?          -- (optional attribute "width")
--- @field height string?         -- (optional attribute "height")
--- @field caption string?        -- (optional attribute "caption")
--- @field engine Doxygen.Compound.DoxPlantumlEngine? -- (optional attribute "engine")
local docPlantumlType = {}

--- @class Doxygen.Compound.docTocItemType
--- @field cmds any[]
--- @field id string?             -- (attribute "id")
local docTocItemType = {}

--- @class Doxygen.Compound.docTocListType
--- @field tocitem Doxygen.Compound.docTocItemType[]
local docTocListType = {}

--- @class Doxygen.Compound.docLanguageType
--- @field para Doxygen.Compound.docParaType[]
--- @field langid string         -- (attribute "langid")
local docLanguageType = {}

--- @class Doxygen.Compound.docParamListType
--- @field parameteritem Doxygen.Compound.docParamListItem[]
--- @field kind Doxygen.Compound.DoxParamListKind   -- (attribute "kind")
local docParamListType = {}

--- @class Doxygen.Compound.docParamListItem
--- @field parameternamelist Doxygen.Compound.docParamNameList[]
--- @field parameterdescription Doxygen.Compound.descriptionType
local docParamListItem = {}

--- @class Doxygen.Compound.docParamNameList
--- @field parametertype Doxygen.Compound.docParamType[]
--- @field parametername Doxygen.Compound.docParamName[]
local docParamNameList = {}

--- @class Doxygen.Compound.docParamType
--- @field cmds any[]
--- @field ref Doxygen.Compound.refTextType?        -- (optional child "ref" element)
local docParamType = {}

--- @class Doxygen.Compound.docParamName
--- @field cmds any[]
--- @field ref Doxygen.Compound.refTextType?        -- (optional child "ref" element)
--- @field direction Doxygen.Compound.DoxParamDir?   -- (optional attribute "direction")
local docParamName = {}

--- @class Doxygen.Compound.docXRefSectType
--- @field xreftitle string[]
--- @field xrefdescription Doxygen.Compound.descriptionType
--- @field id string?             -- (attribute "id")
local docXRefSectType = {}

--- @class Doxygen.Compound.docCopyType
--- @field para Doxygen.Compound.docParaType[]
--- @field sect1 Doxygen.Compound.docSect1Type[]
--- @field internal Doxygen.Compound.docInternalType?
--- @field link string?           -- (attribute "link")
local docCopyType = {}

--- @class Doxygen.Compound.docDetailsType
--- @field summary Doxygen.Compound.docSummaryType?
--- @field para Doxygen.Compound.docParaType[]
local docDetailsType = {}

--- @class Doxygen.Compound.docBlockQuoteType
--- @field para Doxygen.Compound.docParaType[]
local docBlockQuoteType = {}

--- @class Doxygen.Compound.docParBlockType
--- @field para Doxygen.Compound.docParaType[]
local docParBlockType = {}

--- @class Doxygen.Compound.docEmptyType
local docEmptyType = {}

--- @class Doxygen.Compound.tableofcontentsType
--- @field tocsect Doxygen.Compound.tableofcontentsKindType[]         -- (choice: "tocsect" elements)
--- @field tableofcontents Doxygen.Compound.tableofcontentsType[]       -- (nested tableofcontents elements)
local tableofcontentsType = {}

--- @class Doxygen.Compound.tableofcontentsKindType
--- @field name string
--- @field reference string
--- @field tableofcontents Doxygen.Compound.tableofcontentsType[]
local tableofcontentsKindType = {}

--- @class Doxygen.Compound.docEmojiType
--- @field name string?           -- (attribute "name")
--- @field unicode string?        -- (attribute "unicode")
local docEmojiType = {}

------------------------------------------------------------
-- End of Lua type definitions corresponding to the XSD
------------------------------------------------------------

-- Example usage:
-- A document parsed from a "doxygen" XML element might be represented as follows:
--
-- local doc = {
--     version = "1.8.17",
--     xml_lang = "en",
--     compounddef = {
--         {
--             compoundname = "MyClass",
--             kind = "class",
--             prot = "public",
--             -- other fields...
--         },
--         -- possibly more compounddef entries...
--     }
-- }
--
-- These definitions can assist Lua Language Server (luals) with autocompletion and type checking.
