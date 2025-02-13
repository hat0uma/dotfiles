--
-- GENERATED BY factory_generator.lua
--
local factory = {}

--- @param builder eeeBuilder
--- @return string
function factory.string(builder)
  return builder:from_text()
end

--------------------------------
-- Complex Types
--------------------------------
--- @param builder eeeBuilder
--- @return doxygen.index.DoxygenType
function factory.DoxygenType(builder)
  return { --- @type doxygen.index.DoxygenType
    ["compound"] = builder:from_element("compound", "array", factory.CompoundType),
    ["version"] = builder:from_attr("version", "required", "string"),
    ["xml_lang"] = builder:from_attr("xml:lang", "required", "string"),
  }
end

--- @param builder eeeBuilder
--- @return doxygen.index.CompoundType
function factory.CompoundType(builder)
  return { --- @type doxygen.index.CompoundType
    ["name"] = builder:from_element("name", "required", factory.string),
    ["member"] = builder:from_element("member", "array", factory.MemberType),
    ["refid"] = builder:from_attr("refid", "required", "string"),
    ["kind"] = builder:from_attr("kind", "required", "string"),
  }
end

--- @param builder eeeBuilder
--- @return doxygen.index.MemberType
function factory.MemberType(builder)
  return { --- @type doxygen.index.MemberType
    ["name"] = builder:from_element("name", "required", factory.string),
    ["refid"] = builder:from_attr("refid", "required", "string"),
    ["kind"] = builder:from_attr("kind", "required", "string"),
  }
end

return factory

