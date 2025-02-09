local Builder = require("rc.toys.doxygen.builder")
local factory = {}

--- @type Factory<Doxygen.Index.MemberType>
factory.MemberType = function(builder)
  return { ---@type Doxygen.Index.MemberType
    refid = builder:from_attr("refid"),
    kind = builder:from_attr("kind"),
    name = builder:from_text_content_in_child("name"),
  }
end

--- @type Factory<Doxygen.Index.CompoundType>
factory.CompoundType = function(builder)
  return { ---@type Doxygen.Index.CompoundType
    refid = builder:from_attr("refid"),
    kind = builder:from_attr("kind"),
    name = builder:from_text_content_in_child("name"),
    member = builder:from_child_element_array("member", factory.MemberType),
  }
end

--- @type Factory<Doxygen.Index.DoxygenType>
factory.DoxygenType = function(builder)
  return { ---@type Doxygen.Index.DoxygenType
    version = builder:from_attr("version"),
    xml_lang = builder:from_attr("xml:lang"),
    compound = builder:from_child_element_array("compound", factory.CompoundType),
  }
end

return factory
