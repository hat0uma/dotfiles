local M = {}

--- @param element XmlElement
--- @return string?
local function as_text(element)
  assert(#element.content == 1)
  local content = element.content[1]
  assert(type(content) == "string" or type(content) == "nil")
  return content
end

--- @param element XmlElement
--- @return string
local function as_required_text(element)
  return assert(as_text(element))
end

--- Build text element
---@param required boolean?
---@return fun(element: XmlElement): string?
local function text_element_builder(required)
  return function(element)
    return required and as_required_text(element) or as_text(element)
  end
end

--- Build compoundref
--- @param element XmlElement
--- @return Doxygen.Compound.compoundRefType
local function build_compoundref(element)
  ---@type Doxygen.Compound.compoundRefType
  local instance = {
    refid = element.attrs["refid"],
    prot = assert(element.attrs["prot"]),
    virt = assert(element.attrs["virt"]),
    value = as_required_text(element),
  }

  return instance
end

--- Build inctype
--- @param element XmlElement
--- @return Doxygen.Compound.incType
local function build_inctype(element)
  ---@type Doxygen.Compound.incType
  local instance = {
    ["local"] = element.attrs["local"],
    refid = element.attrs["refid"],
    value = as_required_text(element),
  }

  return instance
end

--- Build reftype
--- @param element XmlElement
--- @return Doxygen.Compound.refType
local function build_reftype(element)
  ---@type Doxygen.Compound.refType
  local instance = {
    refid = assert(element.attrs["refid"]),
    value = as_required_text(element),
    inline = element.attrs["inline"],
    prot = element.attrs["prot"],
  }

  return instance
end

--- Build linktype
--- @param element XmlElement
--- @return Doxygen.Compound.linkType
local function build_linktype(element)
  ---@type Doxygen.Compound.linkType
  local instance = {
    refid = assert(element.attrs["refid"]),
    external = element.attrs["external"],
  }

  return instance
end

--- Build linktype
--- @param element XmlElement
--- @return Doxygen.Compound.childnodeType
local function build_childnode(element)
  ---@type Doxygen.Compound.childnodeType
  local instance = {
    refid = assert(element.attrs["refid"]),
    relation = assert(element.attrs["relation"]),
    edgelabel = {},
  }
  for _, child in ipairs(element.content) do
    assert(type(child) ~= "string")
    assert(child.name == "edgelabel")
    table.insert(instance.edgelabel, as_required_text(child))
  end

  return instance
end

--- Build node
--- @param element XmlElement
--- @return Doxygen.Compound.nodeType
local function build_node(element)
  ---@type Doxygen.Compound.nodeType
  local instance = {
    id = assert(element.attrs["id"]),
    label = "",
    childnode = {},
  }

  for _, child in ipairs(element.content) do
    assert(type(child) ~= "string")
    if child.name == "label" then
      instance.label = as_required_text(child)
    elseif child.name == "link" then
      instance.link = build_linktype(child)
    elseif child.name == "childnode" then
      table.insert(instance.childnode, build_childnode(child))
    else
      error(string.format("unknown element <%s> occured.", child.name))
    end
  end

  return instance
end

--- Build incdepgraph
--- @param element XmlElement
--- @return Doxygen.Compound.graphType
local function build_graphtype(element)
  ---@type Doxygen.Compound.graphType
  local instance = {
    node = {},
  }

  for _, child in ipairs(element.content) do
    assert(type(child) ~= "string")
    assert(child.name == "node")
    table.insert(instance.node, build_node(child))
  end

  return instance
end

--- Build reftexttype
--- @param element XmlElement
--- @return Doxygen.Compound.refTextType
local function build_reftexttype(element)
  ---@type Doxygen.Compound.refTextType
  local instance = {
    value = as_required_text(element),
    external = element.attrs["external"],
    refid = assert(element.attrs["refid"]),
    kindref = assert(element.attrs["kindref"]),
    tooltip = element.attrs["tooltip"],
  }

  return instance
end

--- Build linkedtexttype
--- @param element XmlElement
--- @return Doxygen.Compound.linkedTextType
local function build_linkedtexttype(element)
  ---@type Doxygen.Compound.linkedTextType
  -- TODO mixed
  local instance = {
    ref = {},
    value = as_text(element),
  }

  for _, child in ipairs(element.content) do
    assert(child.name == "ref")
    table.insert(instance.ref, build_reftexttype(child))
  end

  return instance
end

--- Build docparatype
--- @param element XmlElement
--- @return Doxygen.Compound.docParaType
local function build_docparatype(element)
  ---@type Doxygen.Compound.docParaType
  local instance = {
    -- TODO other commands
    cmds = {},
    value = element.text,
  }

  for _, child in ipairs(element.content) do
  end

  return instance
end

--- Build doctitletype
--- @param element XmlElement
--- @return Doxygen.Compound.docTitleType
local function build_doctitletype(element)
  ---@type Doxygen.Compound.docTitleType
  local instance = {
    -- TODO other commands
    value = element.text,
  }

  return instance
end

--- Build docinternalS6type
--- @param element XmlElement
--- @return Doxygen.Compound.docInternalS6Type
local function build_docinternalS6type(element)
  ---@type Doxygen.Compound.docInternalS6Type
  local instance = {
    para = {},
  }

  for _, child in ipairs(element.content) do
    if element.name == "para" then
      table.insert(instance.para, build_docparatype(child))
    else
      error(string.format("unknown element <%s> occured.", child.name))
    end
  end

  return instance
end

--- Build docSect6Type
--- @param element XmlElement
--- @return Doxygen.Compound.docSect6Type
local function build_docsect6type(element)
  ---@type Doxygen.Compound.docSect6Type
  local instance = {
    para = {},
    title = nil,
    internal = nil,
    id = element.attrs["id"],
  }

  for _, child in ipairs(element.content) do
    if element.name == "para" then
      table.insert(instance.para, build_docparatype(child))
    elseif element.name == "title" then
      instance.title = build_doctitletype(child)
    elseif element.name == "internal" then
      table.insert(instance.internal, build_docinternalS6type(child))
    else
      error(string.format("unknown element <%s> occured.", child.name))
    end
  end

  return instance
end

--- Build docinternalS5type
--- @param element XmlElement
--- @return Doxygen.Compound.docInternalS5Type
local function build_docinternalS5type(element)
  ---@type Doxygen.Compound.docInternalS5Type
  local instance = {
    para = {},
    sect6 = {},
  }

  for _, child in ipairs(element.content) do
    if element.name == "para" then
      table.insert(instance.para, build_docparatype(child))
    elseif element.name == "sect6" then
      table.insert(instance.sect6, build_docsect6type(child))
    else
      error(string.format("unknown element <%s> occured.", child.name))
    end
  end

  return instance
end

--- Build docSect5Type
--- @param element XmlElement
--- @return Doxygen.Compound.docSect5Type
local function build_docsect5type(element)
  ---@type Doxygen.Compound.docSect5Type
  local instance = {
    para = {},
    title = nil,
    internal = nil,
    id = element.attrs["id"],
    sect6 = {},
  }

  for _, child in ipairs(element.content) do
    if element.name == "para" then
      table.insert(instance.para, build_docparatype(child))
    elseif element.name == "title" then
      instance.title = build_doctitletype(child)
    elseif element.name == "sect6" then
      table.insert(instance.sect6, build_docsect6type(child))
    elseif element.name == "internal" then
      table.insert(instance.internal, build_docinternalS5type(child))
    else
      error(string.format("unknown element <%s> occured.", child.name))
    end
  end

  return instance
end

--- Build docinternalS4type
--- @param element XmlElement
--- @return Doxygen.Compound.docInternalS4Type
local function build_docinternalS4type(element)
  ---@type Doxygen.Compound.docInternalS4Type
  local instance = {
    para = {},
    sect5 = {},
  }

  for _, child in ipairs(element.content) do
    if element.name == "para" then
      table.insert(instance.para, build_docparatype(child))
    elseif element.name == "sect5" then
      table.insert(instance.sect5, build_docsect5type(child))
    else
      error(string.format("unknown element <%s> occured.", child.name))
    end
  end

  return instance
end

--- Build docSect4Type
--- @param element XmlElement
--- @return Doxygen.Compound.docSect4Type
local function build_docsect4type(element)
  ---@type Doxygen.Compound.docSect4Type
  local instance = {
    para = {},
    title = nil,
    internal = nil,
    id = element.attrs["id"],
    sect5 = {},
  }

  for _, child in ipairs(element.content) do
    if element.name == "para" then
      table.insert(instance.para, build_docparatype(child))
    elseif element.name == "title" then
      instance.title = build_doctitletype(child)
    elseif element.name == "sect5" then
      table.insert(instance.sect5, build_docsect5type(child))
    elseif element.name == "internal" then
      table.insert(instance.internal, build_docinternalS4type(child))
    else
      error(string.format("unknown element <%s> occured.", child.name))
    end
  end

  return instance
end

--- Build docinternalS3type
--- @param element XmlElement
--- @return Doxygen.Compound.docInternalS3Type
local function build_docinternalS3type(element)
  ---@type Doxygen.Compound.docInternalS3Type
  local instance = {
    para = {},
    sect4 = {},
  }

  for _, child in ipairs(element.content) do
    if element.name == "para" then
      table.insert(instance.para, build_docparatype(child))
    elseif element.name == "sect4" then
      table.insert(instance.sect4, build_docsect4type(child))
    else
      error(string.format("unknown element <%s> occured.", child.name))
    end
  end

  return instance
end

--- Build docSect3Type
--- @param element XmlElement
--- @return Doxygen.Compound.docSect3Type
local function build_docsect3type(element)
  ---@type Doxygen.Compound.docSect3Type
  local instance = {
    para = {},
    title = nil,
    internal = nil,
    id = element.attrs["id"],
    sect4 = {},
  }

  for _, child in ipairs(element.content) do
    if element.name == "para" then
      table.insert(instance.para, build_docparatype(child))
    elseif element.name == "title" then
      instance.title = build_doctitletype(child)
    elseif element.name == "sect4" then
      table.insert(instance.sect4, build_docsect4type(child))
    elseif element.name == "internal" then
      table.insert(instance.internal, build_docinternalS3type(child))
    else
      error(string.format("unknown element <%s> occured.", child.name))
    end
  end

  return instance
end

--- Build docinternalS2type
--- @param element XmlElement
--- @return Doxygen.Compound.docInternalS2Type
local function build_docinternalS2type(element)
  ---@type Doxygen.Compound.docInternalS2Type
  local instance = {
    para = {},
    sect3 = {},
  }

  for _, child in ipairs(element.content) do
    if element.name == "para" then
      table.insert(instance.para, build_docparatype(child))
    elseif element.name == "sect3" then
      table.insert(instance.sect3, build_docsect3type(child))
    else
      error(string.format("unknown element <%s> occured.", child.name))
    end
  end

  return instance
end

--- Build docSect2Type
--- @param element XmlElement
--- @return Doxygen.Compound.docSect2Type
local function build_docsect2type(element)
  ---@type Doxygen.Compound.docSect2Type
  local instance = {
    para = {},
    title = nil,
    internal = nil,
    id = element.attrs["id"],
    sect3 = {},
  }

  for _, child in ipairs(element.content) do
    if element.name == "para" then
      table.insert(instance.para, build_docparatype(child))
    elseif element.name == "title" then
      instance.title = build_doctitletype(child)
    elseif element.name == "sect3" then
      table.insert(instance.sect3, build_docsect3type(child))
    elseif element.name == "internal" then
      table.insert(instance.internal, build_docinternalS2type(child))
    else
      error(string.format("unknown element <%s> occured.", child.name))
    end
  end

  return instance
end

--- Build docinternalS1type
--- @param element XmlElement
--- @return Doxygen.Compound.docInternalS1Type
local function build_docinternalS1Type(element)
  ---@type Doxygen.Compound.docInternalS1Type
  local instance = {
    para = {},
    sect2 = {},
  }

  for _, child in ipairs(element.content) do
    if element.name == "para" then
      table.insert(instance.para, build_docparatype(child))
    elseif element.name == "sect2" then
      table.insert(instance.sect2, build_docsect2type(child))
    else
      error(string.format("unknown element <%s> occured.", child.name))
    end
  end

  return instance
end

--- Build docSect1Type
--- @param element XmlElement
--- @return Doxygen.Compound.docSect1Type
local function build_docsect1type(element)
  ---@type Doxygen.Compound.docSect1Type
  local instance = {
    para = {},
    sect2 = {},
    internal = {},
    id = element.attrs["id"],
    title = nil,
  }

  for _, child in ipairs(element.content) do
    if element.name == "para" then
      table.insert(instance.para, build_docparatype(child))
    elseif element.name == "title" then
      instance.title = build_doctitletype(child)
    elseif element.name == "sect2" then
      table.insert(instance.sect2, build_docsect2type(child))
    elseif element.name == "internal" then
      table.insert(instance.internal, build_docinternalS1Type(child))
    else
      error(string.format("unknown element <%s> occured.", child.name))
    end
  end

  return instance
end

--- Build docinternaltype
--- @param element XmlElement
--- @return Doxygen.Compound.docInternalType
local function build_docinternaltype(element)
  ---@type Doxygen.Compound.docInternalType
  local instance = {
    para = {},
    sect1 = {},
  }

  for _, child in ipairs(element.content) do
    if element.name == "para" then
      table.insert(instance.para, build_docparatype(child))
    elseif element.name == "sect1" then
      table.insert(instance.sect1, build_docsect1type(child))
    else
      error(string.format("unknown element <%s> occured.", child.name))
    end
  end

  return instance
end

--- Build description
--- @param element XmlElement
--- @return Doxygen.Compound.descriptionType
local function build_description(element)
  ---@type Doxygen.Compound.descriptionType
  local instance = {
    internal = {},
    para = {},
    sect1 = {},
  }

  for _, child in ipairs(element.content) do
    if child.name == "title" then
      instance.title = child.text
    elseif child.name == "para" then
      table.insert(instance.para, build_docparatype(child))
    elseif child.name == "internal" then
      table.insert(instance.internal, build_docinternaltype(child))
    elseif child.name == "sect1" then
      table.insert(instance.sect1, build_docsect1type(child))
    else
      error(string.format("unknown element <%s> occured.", child.name))
    end
  end

  return instance
end

--- Build paramtype
--- @param element XmlElement
--- @return Doxygen.Compound.paramType
local function build_paramtype(element)
  ---@type Doxygen.Compound.paramType
  local instance = {}

  ---@type table<string,fun(element:XmlElement):any>
  local builders = {
    attributes = text_element_builder(),
    type = build_linkedtexttype,
    declname = text_element_builder(),
    defname = text_element_builder(),
    array = text_element_builder(),
    defval = build_linkedtexttype,
    typeconstraint = build_linkedtexttype,
    briefdescription = build_description,
  }

  for _, child in ipairs(element.content) do
    local builder = builders[child.name]
    if not builder then
      error(string.format("unknown element <%s> occured.", child.name))
    end
    instance[child.name] = builder(child)
  end

  return instance
end

--- Build templateparamlist
--- @param element XmlElement
--- @return Doxygen.Compound.templateparamlistType
local function build_templateparamlist(element)
  ---@type Doxygen.Compound.templateparamlistType
  local instance = {
    param = {},
  }

  for _, child in ipairs(element.content) do
    table.insert(instance.param, build_paramtype(child))
  end

  return instance
end

--- Build membertype
--- @param element XmlElement
--- @return Doxygen.Compound.MemberType
local function build_membertype(element)
  assert(#element.content == 1)
  assert(#element.content[1].name == "name")

  ---@type Doxygen.Compound.MemberType
  local instance = {
    refid = assert(element.attrs["refid"]),
    kind = assert(element.attrs["kind"]),
    name = assert(element.content[1].text),
  }

  return instance
end

--- Build reimplementtype
--- @param element XmlElement
--- @return Doxygen.Compound.reimplementType
local function build_reimplementtype(element)
  ---@type Doxygen.Compound.reimplementType
  local instance = {
    refid = element.attrs["refid"],
    value = assert(element.text),
  }

  return instance
end

--- Build enumvaluetype
--- @param element XmlElement
--- @return Doxygen.Compound.enumvalueType
local function build_enumvaluetype(element)
  ---@type Doxygen.Compound.enumvalueType
  local instance = {
    id = assert(element.attrs["id"]),
    prot = assert(element.attrs["prot"]),
    name = "",
    briefdescription = nil,
    detaileddescription = nil,
    initializer = nil,
  }

  for _, child in ipairs(element.content) do
    if child.name == "briefdescription" then
      instance.briefdescription = build_description(child)
    elseif child.name == "detaileddescription" then
      instance.detaileddescription = build_description(child)
    elseif child.name == "initializer" then
      instance.initializer = build_linkedtexttype(child)
    elseif child.name == "name" then
      instance.name = child.name
    else
      error(string.format("unknown element <%s> occured.", child.name))
    end
  end
  return instance
end

--- Build location
--- @param element XmlElement
--- @return Doxygen.Compound.locationType
local function build_location(element)
  ---@type Doxygen.Compound.locationType
  local instance = {
    file = assert(element.attrs["file"]),
    line = assert(tonumber(element.attrs["line"])),
    column = tonumber(element.attrs["column"]),
    declfile = element.attrs["declfile"],
    declline = tonumber(element.attrs["declline"]),
    declcolumn = tonumber(element.attrs["declcolumn"]),
    bodyfile = element.attrs["bodyfile"],
    bodystart = tonumber(element.attrs["bodystart"]),
    bodyend = tonumber(element.attrs["bodyend"]),
  }

  return instance
end

--- Build referencetype
--- @param element XmlElement
--- @return Doxygen.Compound.referenceType
local function build_referencetype(element)
  ---@type Doxygen.Compound.referenceType
  local instance = {
    value = assert(element.attrs["value"]),
    refid = assert(element.attrs["refid"]),
    compoundref = element.attrs["compoundref"],
    startline = assert(tonumber(element.attrs["startline"])),
    endline = assert(tonumber(element.attrs["endline"])),
  }

  return instance
end

--- Build memberdef
--- @param element XmlElement
--- @return Doxygen.Compound.memberdefType
local function build_memberdeftype(element)
  ---@type Doxygen.Compound.memberdefType
  local instance = {

    templateparamlist = nil,
    type = nil,
    definition = nil,
    argsstring = nil,
    name = "",
    qualifiedname = nil,
    read = nil,
    write = nil,
    bitfield = nil,
    reimplements = {},
    reimplementedby = {},
    qualifier = {},
    param = {},
    enumvalue = {},
    requiresclause = nil,
    initializer = nil,
    exceptions = nil,
    briefdescription = nil,
    detaileddescription = nil,
    inbodydescription = nil,
    ---@diagnostic disable-next-line: assign-type-mismatch
    location = nil,
    references = {},
    referencedby = {},

    -- attributes
    kind = assert(element.attrs["kind"]),
    id = assert(element.attrs["id"]),
    prot = assert(element.attrs["prot"]),
    static = assert(element.attrs["static"]),
    extern = element.attrs["extern"],
    strong = element.attrs["strong"],
    const = element.attrs["const"],
    explicit = element.attrs["explicit"],
    inline = element.attrs["inline"],
    refqual = element.attrs["refqual"],
    virt = element.attrs["virt"],
    volatile = element.attrs["volatile"],
    mutable = element.attrs["mutable"],
    noexcept = element.attrs["noexcept"],
    noexceptexpression = element.attrs["noexceptexpression"],
    nodiscard = element.attrs["nodiscard"],
    constexpr = element.attrs["constexpr"],
    consteval = element.attrs["consteval"],
    constinit = element.attrs["constinit"],
    -- Additional platform/language specific attributes:
    readable = element.attrs["readable"],
    writable = element.attrs["writable"],
    initonly = element.attrs["initonly"],
    settable = element.attrs["settable"],
    privatesettable = element.attrs["privatesettable"],
    protectedsettable = element.attrs["protectedsettable"],
    gettable = element.attrs["gettable"],
    privategettable = element.attrs["privategettable"],
    protectedgettable = element.attrs["protectedgettable"],
    final = element.attrs["final"],
    sealed = element.attrs["sealed"],
    new = element.attrs["new"],
    add = element.attrs["add"],
    remove = element.attrs["remove"],
    raise = element.attrs["raise"],
    optional = element.attrs["optional"],
    required = element.attrs["required"],
    accessor = element.attrs["accessor"],
    attribute = element.attrs["attribute"],
    property = element.attrs["property"],
    readonly = element.attrs["readonly"],
    bound = element.attrs["bound"],
    removable = element.attrs["removable"],
    constrained = element.attrs["constrained"],
    transient = element.attrs["transient"],
    maybevoid = element.attrs["maybevoid"],
    maybedefault = element.attrs["maybedefault"],
    maybeambiguous = element.attrs["maybeambiguous"],
  }

  ---@type table<string,fun(element:XmlElement):any>
  local builders = {
    templateparamlist = build_templateparamlist,
    type = build_linkedtexttype,
    definition = text_element_builder(),
    argsstring = text_element_builder(),
    name = text_element_builder(true),
    qualifiedname = text_element_builder(),
    read = text_element_builder(),
    write = text_element_builder(),
    bitfield = text_element_builder(),
    reimplements = build_reimplementtype,
    reimplementedby = build_reimplementtype,
    qualifier = text_element_builder(),
    param = build_paramtype,
    enumvalue = build_enumvaluetype,
    requiresclause = build_linkedtexttype,
    initializer = build_linkedtexttype,
    exceptions = build_linkedtexttype,
    briefdescription = build_description,
    detaileddescription = build_description,
    inbodydescription = build_description,
    location = build_location,
    references = build_referencetype,
    referencedby = build_referencetype,
  }

  for _, child in ipairs(element.content) do
    local builder = builders[child.name]
    if not builder then
      error(string.format("unknown element <%s> occured.", child.name))
    end

    local value = builder(child)
    local target = instance[child.name]
    if type(target) == "table" and vim.islist(target) then
      table.insert(target, value)
    else
      instance[child.name] = value
    end
  end

  assert(instance.location)
  return instance
end

--- Build sectiondef
--- @param element XmlElement
--- @return Doxygen.Compound.sectiondefType
local function build_sectiondef(element)
  ---@type Doxygen.Compound.sectiondefType
  local instance = {
    kind = element.attrs["kind"],
    member = {},
    memberdef = {},
    description = nil,
    header = nil,
  }

  for _, child in ipairs(element.content) do
    if child.name == "description" then
      instance.description = build_description(child)
    elseif child.name == "header" then
      instance.header = child.text
    elseif child.name == "member" then
      table.insert(instance.member, build_membertype(child))
    elseif child.name == "memberdef" then
      table.insert(instance.memberdef, build_memberdeftype(child))
    else
      error(string.format("unknown element <%s> occured.", child.name))
    end
  end

  return instance
end

--- Build tableofcontents
--- @param element XmlElement
--- @return Doxygen.Compound
local function build_tableofcontents(element)
  ---@type Doxygen.Compound
  local instance = {}

  return instance
end

--- Build requiresclause
--- @param element XmlElement
--- @return Doxygen.Compound
local function build_requiresclause(element)
  ---@type Doxygen.Compound
  local instance = {}

  return instance
end

--- Build initializer
--- @param element XmlElement
--- @return Doxygen.Compound
local function build_initializer(element)
  ---@type Doxygen.Compound
  local instance = {}

  return instance
end

--- Build briefdescription
--- @param element XmlElement
--- @return Doxygen.Compound
local function build_briefdescription(element)
  ---@type Doxygen.Compound
  local instance = {}

  return instance
end

--- Build detaileddescription
--- @param element XmlElement
--- @return Doxygen.Compound
local function build_detaileddescription(element)
  ---@type Doxygen.Compound
  local instance = {}

  return instance
end

--- Build exports
--- @param element XmlElement
--- @return Doxygen.Compound
local function build_exports(element)
  ---@type Doxygen.Compound
  local instance = {}

  return instance
end

--- Build inheritancegraph
--- @param element XmlElement
--- @return Doxygen.Compound
local function build_inheritancegraph(element)
  ---@type Doxygen.Compound
  local instance = {}

  return instance
end

--- Build collaborationgraph
--- @param element XmlElement
--- @return Doxygen.Compound
local function build_collaborationgraph(element)
  ---@type Doxygen.Compound
  local instance = {}

  return instance
end

--- Build programlisting
--- @param element XmlElement
--- @return Doxygen.Compound
local function build_programlisting(element)
  ---@type Doxygen.Compound
  local instance = {}

  return instance
end

--- Build location
--- @param element XmlElement
--- @return Doxygen.Compound
local function build_location(element)
  ---@type Doxygen.Compound
  local instance = {}

  return instance
end

---Build listofallmembers
---@param element XmlElement
--- @return Doxygen.Compound
local function build_listofallmembers(element)
  ---@type Doxygen.Compound
  local instance = {}

  return instance
end

--- Build compounddef
---@param element XmlElement
---@return Doxygen.Compound.compounddefType
local function build_compounddef(element)
  assert(element.name == "compounddef")

  ---@type Doxygen.Compound.compounddefType
  local instance = {
    id = assert(element.attrs["id"]), -- (attribute "id")
    kind = assert(element.attrs["kind"]), -- (attribute "kind")
    language = element.attrs["language"], -- (optional attribute "language")
    prot = element.attrs["prot"], -- (attribute "prot")
    final = element.attrs["final"], -- (optional attribute)
    inline = element.attrs["inline"], -- (optional attribute)
    sealed = element.attrs["sealed"], -- (optional attribute)
    abstract = element.attrs["abstract"], -- (optional attribute)
    compoundname = "",
    basecompoundref = {},
    derivedcompoundref = {},
    includedby = {},
    includes = {},
    innerclass = {},
    innerconcept = {},
    innerdir = {},
    innerfile = {},
    innergroup = {},
    innermodule = {},
    innernamespace = {},
    innerpage = {},
    qualifier = {},
    sectiondef = {},
  }

  ---@type table<string,fun(element:XmlElement):any>
  local builders = {
    compoundname = text_element_builder(true),
    title = text_element_builder(),
    basecompoundref = build_compoundref,
    derivedcompoundref = build_compoundref,
    includes = build_inctype,
    includedby = build_inctype,
    incdepgraph = build_graphtype,
    invincdepgraph = build_inctype,
    innermodule = build_reftype,
    innerdir = build_reftype,
    innerfile = build_reftype,
    innerclass = build_reftype,
    innerconcept = build_reftype,
    innernamespace = build_reftype,
    innerpage = build_reftype,
    innergroup = build_reftype,
    qualifier = text_element_builder(),
    templateparamlist = build_templateparamlist,
    sectiondef = build_sectiondef,
    tableofcontents = build_tableofcontents,
    requiresclause = build_requiresclause,
    initializer = build_initializer,
    briefdescription = build_briefdescription,
    detaileddescription = build_detaileddescription,
    exports = build_exports,
    inheritancegraph = build_inheritancegraph,
    collaborationgraph = build_collaborationgraph,
    programlisting = build_programlisting,
    location = build_location,
    listofallmembers = build_listofallmembers,
  }

  for _, child in ipairs(element.content) do
    assert(type(child) ~= "string")
    local builder = builders[child.name]
    if not builder then
      error(string.format("unknown element <%s> occured.", child.name))
    end

    local value = builder(child)
    local target = instance[child.name]
    if type(target) == "table" and vim.islist(target) then
      table.insert(target, value)
    else
      instance[child.name] = value
    end
  end

  return instance
end

--- Build compounddef
---@param element XmlElement
---@return Doxygen.Compound.DoxygenType
function M.build_doxygen(element)
  assert(element.name == "doxygen", element.name)
  ---@type Doxygen.Compound.DoxygenType
  local instance = {
    xml_lang = assert(element.attrs["xml:lang"]),
    version = assert(element.attrs["version"]),
    compounddef = {},
  }

  for _, child in ipairs(element.content) do
    assert(type(child) ~= "string")
    table.insert(instance.compounddef, build_compounddef(child))
  end

  return instance
end

return M
