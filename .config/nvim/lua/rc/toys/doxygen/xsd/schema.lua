local M = {}

---@class Xsd.Schema
---@field complex_types Xsd.ComplexType[]
---@field simple_types Xsd.SimpleType[]
---@field groups Xsd.Group[]

---@alias Xsd.ContentOccur "required"|"optional"|"array"

---@class Xsd.Attribute
---@field kind "attribute"
---@field name string
---@field type string
---@field occurs "required" | "optional"
---@field note? string

---@class Xsd.TextContent
---@field kind "text"
---@field type string
---@field note? string

---@class Xsd.Element
---@field kind "element"
---@field name string
---@field type string
---@field occurs Xsd.ContentOccur
---@field note? string

---@class Xsd.GroupRef
---@field kind "group"
---@field ref string
---@field occurs Xsd.ContentOccur
---@field note? string

---@class Xsd.Sequence
---@field kind "sequence"
---@field content Xsd.Content[]
---@field occurs Xsd.ContentOccur
---@field note? string

---@class Xsd.Choice
---@field kind "choice"
---@field content Xsd.Content[]
---@field occurs Xsd.ContentOccur
---@field note? string

---@alias Xsd.Content
--- | Xsd.Sequence
--- | Xsd.Choice
--- | Xsd.GroupRef
--- | Xsd.Attribute
--- | Xsd.Element
--- | Xsd.TextContent

---@class Xsd.ComplexType
---@field name string
---@field mixed boolean
---@field content Xsd.Sequence|Xsd.Choice|Xsd.GroupRef|Xsd.Attribute[]
---@field note? string

---@alias Xsd.SimpleType
--- | Xsd.SimpleType.Enum
--- | Xsd.SimpleType.Pattern
--- | Xsd.SimpleType.Range

---@class Xsd.SimpleType.Enum
---@field kind "enumeration"
---@field name string
---@field base string
---@field enumerations string[]
---@field note? string

---@class Xsd.SimpleType.Pattern
---@field kind "pattern"
---@field name string
---@field base string
---@field pattern string
---@field note? string

---@class Xsd.SimpleType.Range
---@field kind "range"
---@field name string
---@field base string
---@field min? { value: number, inclusive: boolean }
---@field max? { value: number, inclusive: boolean }
---@field note? string

---@class Xsd.Group
---@field name string
---@field content Xsd.Content[]
---@field note? string

--- Detect occurs from min and max
---@param min string?
---@param max string?
---@return Xsd.ContentOccur
local function detect_occurs(min, max)
  min = min or "1"
  max = max or "1"
  if max == "unbounded" then
    return "array"
  elseif min == "0" and max == "1" then
    return "optional"
  elseif min == "1" and max == "1" then
    return "required"
  else
    return "array"
  end
end

--- Build content from xsd:sequence or xsd:choice node
---@param node XmlElement
---@return Xsd.Content[]
local function xsd_build_content(node)
  local content = {} ---@type Xsd.Content[]
  local stack = {} ---@type { element: XmlElement, push_to: Xsd.Content[] }[]
  for i = #node.content, 1, -1 do
    table.insert(stack, { element = node.content[i], push_to = content })
  end

  while #stack > 0 do
    local c = table.remove(stack) ---@type { element: XmlElement, push_to: Xsd.Content[] }
    local current = c.element
    local push_to = c.push_to
    assert(type(current) ~= "string", "unexpected text content in complexType or group")

    if current.name == "xsd:sequence" or current.name == "xsd:choice" then
      local sequence = { ---@type Xsd.Sequence | Xsd.Choice
        kind = current.name == "xsd:sequence" and "sequence" or "choice",
        content = {},
        occurs = detect_occurs(current.attrs.minOccurs, current.attrs.maxOccurs),
      }
      table.insert(push_to, sequence)
      for i = #current.content, 1, -1 do
        table.insert(stack, {
          element = current.content[i],
          push_to = sequence.content,
        })
      end
    elseif current.name == "xsd:element" then
      local element = { ---@type Xsd.Element
        kind = "element",
        name = current.attrs.name,
        type = current.attrs.type or "string",
        occurs = detect_occurs(current.attrs.minOccurs, current.attrs.maxOccurs),
      }
      table.insert(push_to, element)
    elseif current.name == "xsd:attribute" then
      local attribute = { ---@type Xsd.Attribute
        kind = "attribute",
        name = current.attrs.name or current.attrs.ref,
        type = current.attrs.type or "string",
        occurs = current.attrs.use or "optional",
      }
      table.insert(push_to, attribute)
    elseif current.name == "xsd:anyAttribute" then
      -- ignore
    elseif current.name == "xsd:group" then
      local group = { ---@type Xsd.GroupRef
        kind = "group",
        ref = current.attrs.ref,
        occurs = detect_occurs(current.attrs.minOccurs, current.attrs.maxOccurs),
      }
      table.insert(push_to, group)
    elseif current.name == "xsd:simpleContent" then
      local child = current.content[1]
      if child.name == "xsd:extension" then
        local base = child.attrs.base
        if base then
          local element = { ---@type Xsd.TextContent
            kind = "text",
            type = base,
            note = "(text content)",
          }
          table.insert(push_to, element)
        end
      else
        error("unexpected element in simpleContent: " .. child.name)
      end
      for i = #child.content, 1, -1 do
        table.insert(stack, {
          element = child.content[i],
          push_to = push_to,
        })
      end
    elseif current.name == "xsd:complexType" or current.name == "xsd:simpleType" then
      error("anonymous complexType or simpleType is not supported")
    else
      error("unexpected element in complexType or group: " .. current.name)
    end
  end

  return content
end

--- Build complex type from xsd:complexType node
---@param node XmlElement
---@return Xsd.ComplexType
local function xsd_build_complex_type(node)
  local type_name = node.attrs.name
  if not type_name then
    error("complexType must have a name")
  end
  return { ---@type Xsd.ComplexType
    name = type_name,
    mixed = node.attrs.mixed == "true",
    content = xsd_build_content(node),
  }
end

--- Build group from xsd:group node
---@param node XmlElement
---@return Xsd.Group
local function xsd_build_group(node)
  local name = node.attrs.name
  if not name then
    error("group must have a name")
  end
  return { ---@type Xsd.Group
    name = name,
    content = xsd_build_content(node),
  }
end

---Build simple type from xsd:simpleType node
---@param node XmlElement
---@return Xsd.SimpleType
local function xsd_build_simple_type(node)
  local alias_name = node.attrs.name
  if not alias_name then
    error("simpleType must have a name")
  end

  local enumerations = {} ---@type string[]
  local min = nil
  local max = nil
  local pattern = nil
  for _, child in ipairs(node.content or {}) do
    if child.name == "xsd:restriction" then
      for _, enum in ipairs(child.content or {}) do
        if enum.name == "xsd:enumeration" then
          table.insert(enumerations, enum.attrs.value)
        elseif enum.name == "xsd:minInclusive" then
          min = { value = tonumber(enum.attrs.value), inclusive = true }
        elseif enum.name == "xsd:maxInclusive" then
          max = { value = tonumber(enum.attrs.value), inclusive = true }
        elseif enum.name == "xsd:minExclusive" then
          min = { value = tonumber(enum.attrs.value), inclusive = false }
        elseif enum.name == "xsd:maxExclusive" then
          max = { value = tonumber(enum.attrs.value), inclusive = false }
        elseif enum.name == "xsd:pattern" then
          pattern = enum.attrs.value
        else
          error("unexpected element in restriction: " .. enum.name)
        end
      end
    elseif child.name == "xsd:union" or child.name == "xsd:list" then
      error("union or list is not supported")
    else
      error("unexpected element in simpleType: " .. child.name)
    end
  end

  if #enumerations > 0 then
    return { ---@type Xsd.SimpleType.Enum
      kind = "enumeration",
      name = alias_name,
      base = "string",
      enumerations = enumerations,
    }
  elseif pattern then
    return { ---@type Xsd.SimpleType.Pattern
      kind = "pattern",
      name = alias_name,
      base = "string",
      pattern = pattern,
    }
  elseif min or max then
    return { ---@type Xsd.SimpleType.Range
      kind = "range",
      name = alias_name,
      base = "number",
      min = min,
      max = max,
    }
  else
    error("unsupported simpleType")
  end
end

--- Build XSD schema from node
---@param node XmlElement
---@return Xsd.Schema
function M.xsd_build_schema(node)
  local schema = { ---@type Xsd.Schema
    complex_types = {},
    simple_types = {},
    groups = {},
  }

  for _, child in ipairs(node.content) do
    assert(type(child) ~= "string", "unexpected text content in schema")
    if child.name == "xsd:complexType" then
      table.insert(schema.complex_types, xsd_build_complex_type(child))
    elseif child.name == "xsd:simpleType" then
      table.insert(schema.simple_types, xsd_build_simple_type(child))
    elseif child.name == "xsd:group" then
      table.insert(schema.groups, xsd_build_group(child))
    end
  end

  return schema
end

return M
