local factory = {}

-- TODO: xsd:choice
-- TODO: mixed content

--- @type Factory<Doxygen.Compound.compoundRefType>
factory.compundRefType = function(builder)
  return { ---@type Doxygen.Compound.compoundRefType
    refid = builder:from_attr("refid", true),
    prot = builder:from_attr("prot"),
    virt = builder:from_attr("virt"),
    value = builder:from_text_content(),
  }
end

--- @type Factory<Doxygen.Compound.incType>
factory.incType = function(builder)
  return { ---@type Doxygen.Compound.incType
    ["local"] = builder:from_attr_bool("local"),
    refid = builder:from_attr("refid", true),
    value = builder:from_text_content(),
  }
end

--- @type Factory<Doxygen.Compound.refType>
factory.refType = function(builder)
  return { ---@type Doxygen.Compound.refType
    refid = builder:from_attr("refid"),
    inline = builder:from_attr("inline", true),
    prot = builder:from_attr("prot", true),
    value = builder:from_text_content(),
  }
end

--- @type Factory<Doxygen.Compound.linkType>
factory.linkType = function(builder)
  return { ---@type Doxygen.Compound.linkType
    refid = builder:from_attr("refid"),
    external = builder:from_attr("external", true),
  }
end

--- @type Factory<Doxygen.Compound.childnodeType>
factory.childnodeType = function(builder)
  return { ---@type Doxygen.Compound.childnodeType
    refid = builder:from_attr("refid"),
    relation = builder:from_attr("relation"),
    edgelabel = builder:from_text_content_in_child_array("edgelabel"),
  }
end

--- @type Factory<Doxygen.Compound.nodeType>
factory.nodeType = function(builder)
  return { ---@type Doxygen.Compound.nodeType
    id = builder:from_attr("id"),
    label = builder:from_text_content_in_child("label"),
    link = builder:from_child_element_optional("link", factory.linkType),
    childnode = builder:from_child_element_array("childnode", factory.childnodeType),
  }
end

--- @type Factory<Doxygen.Compound.graphType>
factory.graphType = function(builder)
  return { ---@type Doxygen.Compound.graphType
    node = builder:from_child_element_array("node", factory.nodeType),
  }
end

--- @type Factory<Doxygen.Compound.refTextType>
factory.refTextType = function(builder)
  return { ---@type Doxygen.Compound.refTextType
    refid = builder:from_attr("refid"),
    kindref = builder:from_attr("kindref"),
    external = builder:from_attr("external"),
    value = builder:from_text_content(),
  }
end

--- @type Factory<Doxygen.Compound.linkedTextType>
factory.linkedTextType = function(builder)
  return { ---@type Doxygen.Compound.linkedTextType
    -- ref = builder:from_child_element_array("ref", factory.refTextType),
    -- value = builder:from_text_content(),
  }
end

--- @type Factory<Doxygen.Compound.docParaType>
factory.docParaType = function(builder)
  return builder:from_folded_text_content()
  -- return { ---@type Doxygen.Compound.docParaType
  --   -- TODO: implement
  --   value = "",
  --   cmds = {},
  -- }
end

--- @type Factory<Doxygen.Compound.docTitleType>
factory.docTitleType = function(builder)
  return { ---@type Doxygen.Compound.docTitleType
    -- TODO: implement
  }
end

--- @type Factory<Doxygen.Compound.docInternalS6Type>
factory.docInternalS6Type = function(builder)
  return { ---@type Doxygen.Compound.docInternalS6Type
    para = builder:from_child_element_array("para", factory.docParaType),
  }
end

--- @type Factory<Doxygen.Compound.docSect6Type>
factory.docSect6Type = function(builder)
  return { ---@type Doxygen.Compound.docSect6Type
    id = builder:from_attr("id"),
    title = builder:from_child_element("title", factory.docTitleType),
    para = builder:from_child_element_array("para", factory.docParaType),
    internal = builder:from_child_element_optional("internal", factory.docInternalS6Type),
  }
end

--- @type Factory<Doxygen.Compound.docInternalS5Type>
factory.docInternalS5Type = function(builder)
  return { ---@type Doxygen.Compound.docInternalS5Type
    para = builder:from_child_element_array("para", factory.docParaType),
    sect6 = builder:from_child_element_array("sect6", factory.docSect6Type),
  }
end

--- @type Factory<Doxygen.Compound.docSect5Type>
factory.docSect5Type = function(builder)
  return { ---@type Doxygen.Compound.docSect5Type
    id = builder:from_attr("id"),
    title = builder:from_child_element("title", factory.docTitleType),
    para = builder:from_child_element_array("para", factory.docParaType),
    sect6 = builder:from_child_element_array("sect6", factory.docSect6Type),
    internal = builder:from_child_element_optional("internal", factory.docInternalS5Type),
  }
end

--- @type Factory<Doxygen.Compound.docInternalS4Type>
factory.docInternalS4Type = function(builder)
  return { ---@type Doxygen.Compound.docInternalS4Type
    para = builder:from_child_element_array("para", factory.docParaType),
    sect5 = builder:from_child_element_array("sect5", factory.docSect5Type),
  }
end

--- @type Factory<Doxygen.Compound.docSect4Type>
factory.docSect4Type = function(builder)
  return { ---@type Doxygen.Compound.docSect4Type
    id = builder:from_attr("id"),
    title = builder:from_child_element("title", factory.docTitleType),
    para = builder:from_child_element_array("para", factory.docParaType),
    sect5 = builder:from_child_element_array("sect5", factory.docSect5Type),
    internal = builder:from_child_element_optional("internal", factory.docInternalS4Type),
  }
end

--- @type Factory<Doxygen.Compound.docInternalS3Type>
factory.docInternalS3Type = function(builder)
  return { ---@type Doxygen.Compound.docInternalS3Type
    para = builder:from_child_element_array("para", factory.docParaType),
    sect4 = builder:from_child_element_array("sect4", factory.docSect4Type),
  }
end

--- @type Factory<Doxygen.Compound.docSect3Type>
factory.docSect3Type = function(builder)
  return { ---@type Doxygen.Compound.docSect3Type
    id = builder:from_attr("id"),
    title = builder:from_child_element("title", factory.docTitleType),
    para = builder:from_child_element_array("para", factory.docParaType),
    sect4 = builder:from_child_element_array("sect4", factory.docSect4Type),
    internal = builder:from_child_element_optional("internal", factory.docInternalS3Type),
  }
end

--- @type Factory<Doxygen.Compound.docInternalS2Type>
factory.docInternalS2Type = function(builder)
  return { ---@type Doxygen.Compound.docInternalS2Type
    para = builder:from_child_element_array("para", factory.docParaType),
    sect3 = builder:from_child_element_array("sect3", factory.docSect3Type),
  }
end

--- @type Factory<Doxygen.Compound.docSect2Type>
factory.docSect2Type = function(builder)
  return { ---@type Doxygen.Compound.docSect2Type
    id = builder:from_attr("id"),
    title = builder:from_child_element("title", factory.docTitleType),
    para = builder:from_child_element_array("para", factory.docParaType),
    sect3 = builder:from_child_element_array("sect3", factory.docSect3Type),
    internal = builder:from_child_element_optional("internal", factory.docInternalS2Type),
  }
end

--- @type Factory<Doxygen.Compound.docInternalS1Type>
factory.docInternalS1Type = function(builder)
  return { ---@type Doxygen.Compound.docInternalS1Type
    para = builder:from_child_element_array("para", factory.docParaType),
    sect2 = builder:from_child_element_array("sect2", factory.docSect2Type),
  }
end

--- @type Factory<Doxygen.Compound.docSect1Type>
factory.docSect1Type = function(builder)
  return { ---@type Doxygen.Compound.docSect1Type
    id = builder:from_attr("id"),
    title = builder:from_child_element("title", factory.docTitleType),
    para = builder:from_child_element_array("para", factory.docParaType),
    internal = builder:from_child_element_array("internal", factory.docInternalS1Type),
    sect2 = builder:from_child_element_array("sect2", factory.docSect2Type),
  }
end

--- @type Factory<Doxygen.Compound.docInternalType>
factory.docInternalType = function(builder)
  return { ---@type Doxygen.Compound.docInternalType
    para = builder:from_child_element_array("para", factory.docParaType),
    sect1 = builder:from_child_element_array("sect1", factory.docSect1Type),
  }
end

--- @type Factory<Doxygen.Compound.descriptionType>
factory.descriptionType = function(builder)
  return { ---@type Doxygen.Compound.descriptionType
    title = builder:from_child_element_optional("title", factory.docTitleType),
    para = builder:from_child_element_array("para", factory.docParaType),
    internal = builder:from_child_element_array("internal", factory.docInternalType),
    sect1 = builder:from_child_element_array("sect1", factory.docSect1Type),
  }
end

--- @type Factory<Doxygen.Compound.paramType>
factory.paramType = function(builder)
  return { ---@type Doxygen.Compound.paramType
    attributes = builder:from_text_content_in_child_optional("attributes"),
    type = builder:from_child_element_array("type", factory.linkedTextType),
    declname = builder:from_text_content_in_child_optional("declname"),
    defname = builder:from_text_content_in_child_optional("defname"),
    array = builder:from_text_content_in_child_optional("array"),
    defval = builder:from_child_element_optional("defval", factory.linkedTextType),
    typeconstraint = builder:from_child_element_optional("typeconstraint", factory.linkedTextType),
    briefdescription = builder:from_child_element_optional("briefdescription", factory.descriptionType),
  }
end

--- @type Factory<Doxygen.Compound.templateparamlistType>
factory.templateparamlistType = function(builder)
  return { ---@type Doxygen.Compound.templateparamlistType
    param = builder:from_child_element_array("param", factory.paramType),
  }
end

--- @type Factory<Doxygen.Compound.MemberType>
factory.MemberType = function(builder)
  return { ---@type Doxygen.Compound.MemberType
    refid = builder:from_attr("refid"),
    kind = builder:from_attr("kind"),
    name = builder:from_text_content_in_child("name"),
  }
end

--- @type Factory<Doxygen.Compound.reimplementType>
factory.reimplementType = function(builder)
  return { ---@type Doxygen.Compound.reimplementType
    refid = builder:from_attr("refid"),
    value = builder:from_text_content(),
  }
end

--- @type Factory<Doxygen.Compound.enumvalueType>
factory.enumvalueType = function(builder)
  return { ---@type Doxygen.Compound.enumvalueType
    id = builder:from_attr("id"),
    prot = builder:from_attr("prot"),
    name = builder:from_text_content_in_child("name"),
    initializer = builder:from_child_element_optional("initializer", factory.linkedTextType),
    briefdescription = builder:from_child_element_optional("briefdescription", factory.descriptionType),
    detaileddescription = builder:from_child_element_optional("detaileddescription", factory.descriptionType),
  }
end

--- @type Factory<Doxygen.Compound.locationType>
factory.locationType = function(builder)
  return { ---@type Doxygen.Compound.locationType
    file = builder:from_attr("file", true),
    line = builder:from_attr_number("line", true),
    column = builder:from_attr_number("column", true),
    declfile = builder:from_attr("declfile", true),
    declline = builder:from_attr_number("declline", true),
    declcolumn = builder:from_attr_number("declcolumn", true),
    bodyfile = builder:from_attr("bodyfile", true),
    bodystart = builder:from_attr_number("bodystart", true),
    bodyend = builder:from_attr_number("bodyend", true),
  }
end

--- @type Factory<Doxygen.Compound.referenceType>
factory.referenceType = function(builder)
  return { ---@type Doxygen.Compound.referenceType
    value = builder:from_text_content(),
    refid = builder:from_attr("refid"),
    endline = builder:from_attr_number("endline", true),
    startline = builder:from_attr_number("startline", true),
    compoundref = builder:from_attr("compoundref", true),
  }
end

--- @type Factory<Doxygen.Compound.memberdefType>
factory.memberdefType = function(builder)
  return { ---@type Doxygen.Compound.memberdefType
    kind = builder:from_attr("kind"),
    id = builder:from_attr("id"),
    prot = builder:from_attr("prot"),
    static = builder:from_attr_bool("static"),
    extern = builder:from_attr_bool("extern", true),
    strong = builder:from_attr_bool("strong", true),
    const = builder:from_attr_bool("const", true),
    explicit = builder:from_attr_bool("explicit", true),
    inline = builder:from_attr_bool("inline", true),
    refqual = builder:from_attr("refqual", true),
    virt = builder:from_attr("virt", true),
    volatile = builder:from_attr_bool("volatile", true),
    mutable = builder:from_attr_bool("mutable", true),
    noexcept = builder:from_attr_bool("noexcept", true),
    noexceptexpression = builder:from_attr("noexceptexpression", true),
    nodiscard = builder:from_attr_bool("nodiscard", true),
    constexpr = builder:from_attr_bool("constexpr", true),
    consteval = builder:from_attr_bool("consteval", true),
    constinit = builder:from_attr_bool("constinit", true),
    readable = builder:from_attr_bool("readable", true),
    writable = builder:from_attr_bool("writable", true),
    initonly = builder:from_attr_bool("initonly", true),
    settable = builder:from_attr_bool("settable", true),
    privatesettable = builder:from_attr_bool("privatesettable", true),
    protectedsettable = builder:from_attr_bool("protectedsettable", true),
    gettable = builder:from_attr_bool("gettable", true),
    privategettable = builder:from_attr_bool("privategettable", true),
    protectedgettable = builder:from_attr_bool("protectedgettable", true),
    final = builder:from_attr_bool("final", true),
    sealed = builder:from_attr_bool("sealed", true),
    new = builder:from_attr_bool("new", true),
    add = builder:from_attr_bool("add", true),
    remove = builder:from_attr_bool("remove", true),
    raise = builder:from_attr_bool("raise", true),
    optional = builder:from_attr_bool("optional", true),
    required = builder:from_attr_bool("required", true),
    accessor = builder:from_attr("accessor", true),
    attribute = builder:from_attr_bool("attribute", true),
    property = builder:from_attr_bool("property", true),
    readonly = builder:from_attr_bool("readonly", true),
    bound = builder:from_attr_bool("bound", true),
    removable = builder:from_attr_bool("removable", true),
    constrained = builder:from_attr_bool("constrained", true),
    transient = builder:from_attr_bool("transient", true),
    maybevoid = builder:from_attr_bool("maybevoid", true),
    maybedefault = builder:from_attr_bool("maybedefault", true),
    maybeambiguous = builder:from_attr_bool("maybeambiguous", true),
    -- childs
    templateparamlist = builder:from_child_element_optional("templateparamlist", factory.templateparamlistType),
    type = builder:from_child_element_optional("type", factory.linkedTextType),
    definition = builder:from_text_content_in_child_optional("definition"),
    argsstring = builder:from_text_content_in_child_optional("argsstring"),
    name = builder:from_text_content_in_child("name"),
    qualifiedname = builder:from_text_content_in_child_optional("qualifiedname"),
    read = builder:from_text_content_in_child_optional("read"),
    write = builder:from_text_content_in_child_optional("write"),
    bitfield = builder:from_text_content_in_child_optional("bitfield"),
    reimplements = builder:from_child_element_array("reimplements", factory.reimplementType),
    reimplementedby = builder:from_child_element_array("reimplementedby", factory.reimplementType),
    qualifier = builder:from_text_content_in_child_array("qualifier"),
    param = builder:from_child_element_array("param", factory.paramType),
    enumvalue = builder:from_child_element_array("enumvalue", factory.enumvalueType),
    requiresclause = builder:from_child_element_optional("requiresclause", factory.linkedTextType),
    initializer = builder:from_child_element_optional("initializer", factory.linkedTextType),
    exceptions = builder:from_child_element_optional("exceptions", factory.linkedTextType),
    briefdescription = builder:from_child_element_optional("briefdescription", factory.descriptionType),
    detaileddescription = builder:from_child_element_optional("detaileddescription", factory.descriptionType),
    inbodydescription = builder:from_child_element_optional("inbodydescription", factory.descriptionType),
    location = builder:from_child_element("location", factory.locationType),
    references = builder:from_child_element_array("references", factory.referenceType),
    referencedby = builder:from_child_element_array("referencedby", factory.referenceType),
  }
end

--- @type Factory<Doxygen.Compound.sectiondefType>
factory.sectiondefType = function(builder)
  return { ---@type Doxygen.Compound.sectiondefType
    kind = builder:from_attr("kind"),
    header = builder:from_text_content_in_child_optional("header"),
    description = builder:from_child_element_optional("description", factory.descriptionType),
    memberdef = builder:from_child_element_array("memberdef", factory.memberdefType),
    member = builder:from_child_element_array("member", factory.MemberType),
  }
end

--- @type Factory<Doxygen.Compound.tableofcontentsType>
factory.tableofcontentsType = function(builder)
  return { ---@type Doxygen.Compound.tableofcontentsType
  }
end

--- @type Factory<Doxygen.Compound.listofallmembersType>
factory.listofallmembersType = function(builder)
  return { ---@type Doxygen.Compound.listofallmembersType
  }
end

--- @type Factory<Doxygen.Compound.exportsType>
factory.exportsType = function(builder)
  return { ---@type Doxygen.Compound.exportsType
  }
end

--- @type Factory<Doxygen.Compound.listingType>
factory.listingType = function(builder)
  return { ---@type Doxygen.Compound.listingType
  }
end

--- @type Factory<Doxygen.Compound.compounddefType>
factory.compounddefType = function(builder)
  return { ---@type Doxygen.Compound.compounddefType
    -- attributes
    id = builder:from_attr("id"),
    kind = builder:from_attr("kind"),
    language = builder:from_attr("language", true),
    prot = builder:from_attr("prot", true),
    final = builder:from_attr_bool("final", true),
    inline = builder:from_attr_bool("inline", true),
    sealed = builder:from_attr_bool("sealed", true),
    abstract = builder:from_attr_bool("abstract", true),
    -- childs
    compoundname = builder:from_text_content_in_child("compoundname"),
    title = builder:from_text_content_in_child_optional("title"),
    basecompoundref = builder:from_child_element_array("basecompoundref", factory.compundRefType),
    derivedcompoundref = builder:from_child_element_array("derivedcompoundref", factory.compundRefType),
    includes = builder:from_child_element_array("includes", factory.incType),
    includedby = builder:from_child_element_array("includedby", factory.incType),
    incdepgraph = builder:from_child_element_optional("incdepgraph", factory.graphType),
    invincdepgraph = builder:from_child_element_optional("invincdepgraph", factory.graphType),
    innermodule = builder:from_child_element_array("innermodule", factory.refType),
    innerdir = builder:from_child_element_array("innerdir", factory.refType),
    innerfile = builder:from_child_element_array("innerfile", factory.refType),
    innerclass = builder:from_child_element_array("innerclass", factory.refType),
    innerconcept = builder:from_child_element_array("innerconcept", factory.refType),
    innernamespace = builder:from_child_element_array("innernamespace", factory.refType),
    innerpage = builder:from_child_element_array("innerpage", factory.refType),
    innergroup = builder:from_child_element_array("innergroup", factory.refType),
    qualifier = builder:from_text_content_in_child_array("qualifiedname"),
    templateparamlist = builder:from_child_element_optional("templateparamlist", factory.templateparamlistType),
    sectiondef = builder:from_child_element_array("sectiondef", factory.sectiondefType),
    tableofcontents = builder:from_child_element_optional("tableofcontents", factory.tableofcontentsType),
    requiresclause = builder:from_child_element_optional("requiresclause", factory.linkedTextType),
    initializer = builder:from_child_element_optional("initializer", factory.linkedTextType),
    briefdescription = builder:from_child_element_optional("briefdescription", factory.descriptionType),
    detaileddescription = builder:from_child_element_optional("detaileddescription", factory.descriptionType),
    exports = builder:from_child_element_optional("exports", factory.exportsType),
    inheritancegraph = builder:from_child_element_optional("inheritancegraph", factory.graphType),
    collaborationgraph = builder:from_child_element_optional("collaborationgraph", factory.graphType),
    programlisting = builder:from_child_element_optional("programlisting", factory.listingType),
    location = builder:from_child_element_optional("location", factory.locationType),
    listofallmembers = builder:from_child_element_optional("listofallmembers", factory.listofallmembersType),
  }
end

--- @type Factory<Doxygen.Compound.DoxygenType>
factory.DoxygenType = function(builder)
  return { ---@type Doxygen.Compound.DoxygenType
    xml_lang = builder:from_attr("xml:lang"),
    version = builder:from_attr("version"),
    compounddef = builder:from_child_element_array("compounddef", factory.compounddefType),
  }
end

return factory
