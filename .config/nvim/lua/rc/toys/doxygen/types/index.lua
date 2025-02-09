---@meta

---@class Doxygen.Index.DoxygenType
---@field compound Doxygen.Index.CompoundType[]
---@field version string
---@field xml_lang string

---@class Doxygen.Index.CompoundType
---@field name string
---@field member Doxygen.Index.MemberType[]
---@field refid string
---@field kind Doxygen.Index.CompoundKind

---@class Doxygen.Index.MemberType
---@field name string
---@field refid string
---@field kind Doxygen.Index.MemberKind

---@alias Doxygen.Index.CompoundKind
---| "class"
---| "struct"
---| "union"
---| "interface"
---| "protocol"
---| "category"
---| "exception"
---| "file"
---| "namespace"
---| "group"
---| "page"
---| "example"
---| "dir"
---| "type"
---| "concept"
---| "module"

---@alias Doxygen.Index.MemberKind
---| "define"
---| "property"
---| "event"
---| "variable"
---| "typedef"
---| "enum"
---| "enumvalue"
---| "function"
---| "signal"
---| "prototype"
---| "friend"
---| "dcop"
---| "slot"
