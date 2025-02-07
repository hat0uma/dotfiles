---@class XmlSAXParser.Attribute
---@field localname string
---@field prefix? string
---@field ns_uri? string
---@field value string

---@class XmlSAXParser.AttributeSet
---@field private _raw XmlSAXParser.Attribute[]
local AttributeSet = {}

--- Create a new XmlSAXParser.AttributeSet.
---@param raw XmlSAXParser.Attribute[]
---@return XmlSAXParser.AttributeSet
function AttributeSet:new(raw)
  local obj = {}
  obj._raw = raw
  setmetatable(obj, self)
  self.__index = self
  return obj
end

---Get atribute
---
--- <test xmlns:dt="urn:datatypes" dt:type="int"/>
--- :get("dt:type")
--- :get("type", "http://www.w3.org/2000/xmlns/" )
---@param name string
---@param ns? string
---@return XmlSAXParser.Attribute?
function AttributeSet:get(name, ns)
  local function match(attr)
    if not ns then
      if attr.prefix then
        return string.format("%s:%s", attr.prefix, attr.localname) == name
      else
        return attr.localname == name
      end
    else
      return attr.ns_uri == ns and attr.localname == name
    end
  end

  for _, attr in ipairs(self._raw) do
    if match(attr) then
      return attr
    end
  end

  return nil
end

---@param name string
---@param ns? string
---@return string?
function AttributeSet:get_value(name, ns)
  local a = self:get(name, ns)
  return a and a.value or nil
end

function AttributeSet:to_kvp()
  local attrs = {} ---@type table<string,string>
  for _, attr in ipairs(self._raw) do
    local key = attr.prefix and string.format("%s:%s", attr.prefix, attr.localname) or attr.localname
    attrs[key] = attr.value
  end

  return attrs
end

function AttributeSet:raw()
  return self._raw
end

return AttributeSet
