local M = {}

---@overload fun(c:any, t:"nil"): nil
---@overload fun(c:any, t:"number"): number
---@overload fun(c:any, t:"string"): string
---@overload fun(c:any, t:"boolean"): boolean
---@overload fun(c:any, t:"table"): table
---@overload fun(c:any, t:"function"): function
---@overload fun(c:any, t:"thread"): thread
---@overload fun(c:any, t:"userdata"): userdata
local function as(c, t)
  assert(type(c) == t, string.format("expected type:%s but received:%s", t, type(c)))
  return c
end

--- Build member
---@param element XmlElement
---@return Doxygen.Index.MemberType
local function build_member(element)
  assert(element.name == "member")
  assert(#element.content == 1)

  local name_element = element.content[1]
  local name = name_element.content[1]
  assert(name_element.name == "name")
  assert(type(name) == "string")

  ---@type Doxygen.Index.MemberType
  local instance = {
    refid = assert(element.attrs["refid"]),
    kind = assert(element.attrs["kind"]),
    name = name,
  }

  return instance
end

--- Build compound
---@param element XmlElement
---@return Doxygen.Index.CompoundType
local function build_compound(element)
  assert(element.name == "compound")

  ---@type Doxygen.Index.CompoundType
  local instance = {
    refid = assert(element.attrs["refid"]),
    kind = assert(element.attrs["kind"]),
    member = {},
    name = "",
  }

  for _, child in ipairs(element.content) do
    assert(type(child) ~= "string")
    if child.name == "name" then
      instance.name = as(child.content[1], "string")
    else
      table.insert(instance.member, build_member(child))
    end
  end
  return instance
end

--- Build doxygenindex
---@param element XmlElement
---@return Doxygen.Index.DoxygenType
function M.build_doxygenindex(element)
  assert(element.name == "doxygenindex")

  ---@type Doxygen.Index.DoxygenType
  local instance = {
    version = assert(element.attrs["version"]),
    xml_lang = assert(element.attrs["xml:lang"]),
    compound = {},
  }

  for _, child in ipairs(element.content) do
    assert(type(child) ~= "string")
    table.insert(instance.compound, build_compound(child))
  end

  return instance
end

return M
