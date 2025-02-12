--- @generic T
--- @alias Factory<T> fun(builder: Builder): T

---@class Builder
---@field private _boolean_keywords table<string, boolean>
---@field private _mixed_content_replacements table<string, string>
---@field private _element XmlElement
---@field private _next_index integer
local Builder = {}

--- Create a new Builder.
---@param element XmlElement
---@return Builder
function Builder:new(element)
  local obj = {}
  obj._element = element
  obj._next_index = 1
  obj._boolean_keywords = {
    ["true"] = true,
    ["false"] = false,
    ["yes"] = true,
    ["no"] = false,
    ["1"] = true,
    ["0"] = false,
  }

  obj._mixed_content_replacements = {
    ["br"] = "\n",
    ["sp"] = " ",
    ["codeline"] = "\n",
  }

  setmetatable(obj, self)
  self.__index = self
  return obj
end

--- Get the name of the current element.
---@param name string
---@param occurence "optional" | "required"
---@param type "string" | "boolean" | "number"
---@return (string | boolean | number)?
function Builder:from_attr(name, occurence, type)
  local optional = occurence == "optional"
  if type == "string" then
    return self:_from_attr_string(name, optional)
  elseif type == "boolean" then
    return self:_from_attr_bool(name, optional)
  elseif type == "number" then
    return self:_from_attr_number(name, optional)
  else
    error(string.format("invalid type: %s", type))
  end
end

---@overload fun(self, name: string): string
---@overload fun(self, name: string, optional: boolean): string?
function Builder:_from_attr_string(name, optional)
  local element = self._element
  local value = element.attrs[name]
  if not optional then
    assert(value, string.format("required attribute <%s> is missing in %s", name, element.name))
  end

  return value
end

---@overload fun(self, name: string): boolean
---@overload fun(self, name: string, optional: boolean): boolean?
function Builder:_from_attr_bool(name, optional)
  local value = self:_from_attr_string(name, optional)
  if not value then
    return nil
  end

  local bool = self._boolean_keywords[value]
  if bool == nil then
    error(string.format("invalid boolean value: <%s> in %s", value, self._element.name))
  end
  return bool
end

---@overload fun(self, name: string): number
---@overload fun(self, name: string, optional: boolean): number?
function Builder:_from_attr_number(name, optional)
  local value = self:_from_attr_string(name, optional)
  if not value then
    return nil
  end

  local number = tonumber(value)
  if not number then
    error(string.format("invalid number value: <%s> in %s", value, self._element.name))
  end
  return number
end

---@generic T
---@param name string
---@param occurence "optional" | "required" | "array"
---@param factory Factory<T>
---@return T?
function Builder:from_element(name, occurence, factory)
  if occurence == "array" then
    return self:_from_element_array(name, factory)
  end

  local optional = occurence == "optional"
  for i = self._next_index, #self._element.content do
    local child = self._element.content[i]
    if type(child) == "string" then
      break
    end

    if child.name ~= name then
      break
    end

    self._next_index = i + 1
    local child_builder = Builder:new(child)
    return assert(factory(child_builder), string.format("factory failed for %s", name))
  end

  if not optional then
    error(string.format("required element <%s> is missing in %s", name, self._element.name))
  end

  return nil
end

---@generic T
---@param name string
---@param factory Factory<T>
---@return T[]
function Builder:_from_element_array(name, factory)
  local result = {}
  for i = self._next_index, #self._element.content do
    local child = self._element.content[i]
    assert(type(child) ~= "string", string.format("unexpected text content in %s", self._element.name))

    if child.name ~= name then
      break
    end

    self._next_index = i + 1
    local child_builder = Builder:new(child)
    table.insert(result, factory(child_builder))
  end

  return result
end

---@generic T
---@param name string
---@param factory Factory<T>
---@return T?
function Builder:from_child_element_optional(name, factory)
  for i = self._next_index, #self._element.content do
    local child = self._element.content[i]
    assert(type(child) ~= "string", "unexpected text content")

    if child.name ~= name then
      return nil
    end

    self._next_index = i + 1
    local child_builder = Builder:new(child)
    return factory(child_builder)
  end

  return nil
end

---@param element XmlElement
---@return string?
local function get_text_content(element)
  if #element.content == 0 then
    return nil
  end

  assert(#element.content == 1, string.format("unexpected content in %s", vim.inspect(element, { depth = 2 })))
  local text = element.content[1]
  assert(type(text) == "string", string.format("unexpected content in %s", element.name))
  return text
end

---@return string
function Builder:from_text()
  return assert(
    get_text_content(self._element),
    string.format("required text content in %s is missing", self._element.name)
  )
end

---@param name string
---@param occurence "required" | "optional" | "array"
---@return string | string[] | nil
function Builder:from_text_only_element(name, occurence)
  if occurence == "array" then
    return self:from_text_only_element_array(name)
  end

  local value = self:from_text_only_element_optional(name)
  if not value and occurence == "required" then
    error(string.format("required element %s is missing", name))
  end

  return value
end

---@param name string
---@return string?
function Builder:from_text_only_element_optional(name)
  for i = self._next_index, #self._element.content do
    local child = self._element.content[i]
    if type(child) == "string" then
      break
    end

    if child.name ~= name then
      break
    end

    self._next_index = i + 1
    return get_text_content(child)
  end

  return nil
end

---@return (string | { name: string, value: string })[]
function Builder:from_element_mixed()
  return self:from_folded_text_content()
  -- TODO: should handle mixed content with child factories
  -- local result = {}
  -- for i = self._next_index, #self._element.content do
  --   local child = self._element.content[i]
  --   if type(child) == "string" then
  --     table.insert(result, child)
  --   else
  --     table.insert(result, { name = child.name })
  --   end
  -- end
  -- return result
end

---@param choices { name: string, factory: Factory<any> }[]
---@param occurence "required"
---@return { name: string, value: any }
---@overload fun(choices: { name: string, factory: Factory<any> }[], occurence: "optional"): { name: string, value: any }?
---@overload fun(choices: { name: string, factory: Factory<any> }[], occurence: "array"): { name: string, value: any }[]
function Builder:choice(choices, occurence)
  if occurence == "array" then
    return self:choice_array(choices)
  end

  local optional = occurence == "optional"
  local result = self:choice_optional(choices)
  if not result and not optional then
    error(string.format("required choice is missing in %s", self._element.name))
  end

  return result
end

---@param choices { name: string, factory: Factory<any> }[]
---@return { name: string, value: any }[]
function Builder:choice_array(choices)
  local result = {}
  for i = self._next_index, #self._element.content do
    local child = self._element.content[i]
    assert(type(child) ~= "string", string.format("unexpected text content in %s", self._element.name))

    for _, choice in ipairs(choices) do
      if child.name == choice.name then
        self._next_index = i + 1
        local child_builder = Builder:new(child)
        table.insert(result, { name = child.name, value = choice.factory(child_builder) })
        break
      end
    end
  end
  return result
end

---
---@param choices { name: string, factory: Factory<any> }[]
---@return { name: string, value: any }?
function Builder:choice_optional(choices)
  for i = self._next_index, #self._element.content do
    local child = self._element.content[i]
    assert(type(child) ~= "string", string.format("unexpected text content in %s", self._element.name))

    for _, choice in ipairs(choices) do
      if child.name == choice.name then
        self._next_index = i + 1
        local child_builder = Builder:new(child)
        return { name = child.name, value = choice.factory(child_builder) }
      end
    end
  end
  return nil
end

---@param name string
---@return string[]
function Builder:from_text_only_element_array(name)
  local result = {}
  for i = self._next_index, #self._element.content do
    local child = self._element.content[i]
    assert(type(child) ~= "string", string.format("unexpected text content in %s", self._element.name))
    if child.name ~= name then
      break
    end

    self._next_index = i + 1
    table.insert(result, get_text_content(child))
  end

  return result
end

function Builder:from_folded_text_content()
  self._next_index = self._next_index + 1

  local text_buffer = {}
  local stack = { self._element }
  while #stack > 0 do
    local current = table.remove(stack) ---@type string | XmlElement
    if type(current) == "string" then
      table.insert(text_buffer, current)
    else
      if self._mixed_content_replacements[current.name] then
        table.insert(text_buffer, self._mixed_content_replacements[current.name])
      end

      for i = #current.content, 1, -1 do
        table.insert(stack, current.content[i])
      end
    end
  end

  return vim.split(table.concat(text_buffer, ""), "\n")
end

return Builder
