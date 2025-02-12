-- Utility function to get the current script path
local function get_script_path()
  local source = debug.getinfo(2, "S").source:sub(2)
  return source:match("(.*/)")
end

-- Utility: push elements of a list onto a stack in reverse order
local function push_to_stack(stack, list)
  for i = #list, 1, -1 do
    table.insert(stack, list[i])
  end
end

--- Render a range
---@param min? { value: number, inclusive: boolean }
---@param max? { value: number, inclusive: boolean }
---@return string
local function render_range(min, max)
  local min_value = min and min.value or ""
  local max_value = max and max.value or ""
  local min_symbol = min and (min.inclusive and "<=" or "<") or ""
  local max_symbol = max and (max.inclusive and "<=" or "<") or ""
  return string.format("%s%sx%s%s", min_value, min_symbol, max_symbol, max_value)
end

--- Convert XSD name to Lua name
---@param name string
---@return string
local function conver_name(name)
  return (name:gsub(":", "_"))
end

-- Conversion tables defined once for reuse
local name_conversion = {
  ["xsd:string"] = "string",
  ["string"] = "string",
  ["xsd:boolean"] = "boolean",
  ["xsd:integer"] = "integer",
  ["xsd:decimal"] = "number",
  ["DoxBool"] = "boolean",
}

local occurrence_suffixes = {
  array = "[]",
  optional = "?",
}

--- Convert XSD type name to Lua type name
---@param namespace string
---@param type_name string
---@param occurrence? Xsd.ContentOccur
---@return string
local function convert_type(namespace, type_name, occurrence)
  local body = name_conversion[type_name] or string.format("%s.%s", namespace, type_name)
  local suffix = occurrence_suffixes[occurrence] or ""
  return body .. suffix
end

---
---@param choice Xsd.Choice
---@param namespace string
---@return string
local function generate_choice(choice, namespace)
  local elements = {}
  -- Process each element in order
  for _, content in ipairs(choice.content) do
    if content.kind == "element" then
      local type = string.format(
        '{ name: "%s", value: %s }',
        conver_name(content.name),
        convert_type(namespace, content.type, content.occurs)
      )
      table.insert(elements, type)
    else
      error("unexpected content in choice: " .. vim.inspect(content))
    end
  end
  return table.concat(elements, "\n---| ")
end

---
---@param complex_type Xsd.ComplexType
---@param namespace string
---@return string
local function generate_mixed(complex_type, namespace)
  local lines = {}
  local function emit(line)
    table.insert(lines, line)
  end
  local function emitf(fmt, ...)
    emit(string.format(fmt, ...))
  end

  local stack = {}
  push_to_stack(stack, complex_type.content)

  -- Emit class definition and attribute fields first
  emitf("---@class %s.%s (mixed)", namespace, complex_type.name)
  for _, content in ipairs(complex_type.content) do
    if content.kind == "attribute" then
      emitf(
        "---@field %s %s (attribute)",
        conver_name(content.name),
        convert_type(namespace, content.type, content.occurs)
      )
    end
  end

  emitf("---@field content %s", complex_type.name)
  emitf("---| string (text content)")

  while #stack > 0 do
    local current = table.remove(stack)
    if current.kind == "attribute" then
      -- Attributes already emitted; skip.
      local _ = nil
    elseif current.kind == "element" then
      emitf(
        '---| { name: "%s", value: %s }',
        conver_name(current.name),
        convert_type(namespace, current.type, current.occurs)
      )
    elseif current.kind == "sequence" or current.kind == "choice" then
      push_to_stack(stack, current.content)
    elseif current.kind == "group" then
      emitf('---| { name: "%s", value: %s }', "group", convert_type(namespace, current.ref, current.occurs))
    elseif current.kind == "text-only-element" then
      error("text-only-element not supported: " .. vim.inspect(current))
    elseif current.kind == "text" then
      error("text content not supported: " .. vim.inspect(current))
    else
      error("unexpected content in mixed: " .. vim.inspect(current))
    end
  end

  return table.concat(lines, "\n")
end

---@param element Xsd.ComplexType | Xsd.Group
---@param namespace string
---@return string
local function generate_content_fields(element, namespace)
  local lines = {}
  local function emit(line)
    table.insert(lines, line)
  end
  local function emitf(fmt, ...)
    emit(string.format(fmt, ...))
  end

  local stack = {} ---@type (Xsd.Content|fun())[]
  push_to_stack(stack, element.content)

  while #stack > 0 do
    local current = table.remove(stack)
    if type(current) == "function" then
      current()
    elseif current.kind == "sequence" then
      emit("--- start sequence")
      table.insert(stack, function()
        emit("--- end sequence")
      end)
      push_to_stack(stack, current.content)
    elseif current.kind == "choice" then
      emitf("---@field %s", "choice")
      emitf("---| %s", generate_choice(current, namespace))
    elseif current.kind == "group" then
      emitf("---@field %s %s", "group", convert_type(namespace, current.ref))
    elseif current.kind == "attribute" then
      emitf(
        "---@field %s %s (attribute)",
        conver_name(current.name),
        convert_type(namespace, current.type, current.occurs)
      )
    elseif current.kind == "element" then
      emitf(
        "---@field %s %s (element)",
        conver_name(current.name),
        convert_type(namespace, current.type, current.occurs)
      )
    elseif current.kind == "text-only-element" then
      emitf(
        "---@field %s %s (text-only-element)",
        conver_name(current.name),
        convert_type(namespace, current.type, current.occurs)
      )
    elseif current.kind == "text" then
      emitf("---@field %s %s (text content)", "text", convert_type(namespace, current.type))
    else
      error("unexpected content in fields: " .. vim.inspect(current))
    end
  end
  emit("")

  return table.concat(lines, "\n")
end

--- Generate types from schema
---@param schema Xsd.Schema
---@param namespace string
---@return string[]
local function generate_types(schema, namespace)
  local lines = {}
  local function emit(line)
    table.insert(lines, line)
  end
  local function emitf(fmt, ...)
    emit(string.format(fmt, ...))
  end

  -- File header
  emit("--")
  emit("-- GENERATED BY rc.toys.doxygen.generator.lua")
  emit("--")

  emit("--------------------------------")
  emit("-- Simple Types")
  emit("--------------------------------")
  for _, simple_type in ipairs(schema.simple_types) do
    if simple_type.kind == "enumeration" then
      emitf("---@alias %s.%s", namespace, simple_type.name)
      for _, enum in ipairs(simple_type.enumerations) do
        emitf('---| "%s"', enum)
      end
    elseif simple_type.kind == "pattern" then
      emitf("---@alias %s.%s string (pattern: %s)", namespace, simple_type.name, simple_type.pattern)
    elseif simple_type.kind == "range" then
      local range = render_range(simple_type.min, simple_type.max)
      emitf("---@alias %s.%s number (range: %s)", namespace, simple_type.name, range)
    else
      error("unexpected simple type: " .. vim.inspect(simple_type))
    end
    emit("")
  end

  emit("--------------------------------")
  emit("-- Complex Types")
  emit("--------------------------------")
  for _, complex_type in ipairs(schema.complex_types) do
    if complex_type.mixed then
      emit(generate_mixed(complex_type, namespace))
    else
      emitf("---@class %s.%s", namespace, complex_type.name)
      emit(generate_content_fields(complex_type, namespace))
    end
    emit("")
  end

  emit("--------------------------------")
  emit("-- Groups")
  emit("--------------------------------")
  for _, group in ipairs(schema.groups) do
    emitf("---@class %s.%s", namespace, group.name)
    emit(generate_content_fields(group, namespace))
    emit("")
  end

  return lines
end

-- Load XSD schema and generate type files
---@param input_filename string
---@param output_filename string
---@param namespace string
local function generate_file(input_filename, output_filename, namespace)
  local file = assert(io.open(input_filename, "r"))
  local json_str = file:read("*all")
  file:close()

  ---@type XmlElement
  local root = vim.json.decode(json_str)
  if not root then
    error("JSON decode error")
  end

  local schema = require("rc.toys.doxygen.generator.util").xsd_build_schema(root)
  require("rc.toys.doxygen.util").dump_json(schema, "schema.json", true)

  -- Generate types and write to file
  local out_lines = generate_types(schema, namespace)
  local outfile = assert(io.open(output_filename, "w"))
  outfile:write(table.concat(out_lines, "\n"))
  outfile:close()
end

-- Generate output for compound and index schema files
generate_file(
  vim.fs.normalize("~/.cache/nvim/doxygen-compound.xsd.json"),
  vim.fs.normalize(vim.fs.joinpath(get_script_path(), "../types/compound.lua")),
  "doxygen.compound"
)

generate_file(
  vim.fs.normalize("~/.cache/nvim/doxygen-index.xsd.json"),
  vim.fs.normalize(vim.fs.joinpath(get_script_path(), "../types/index.lua")),
  "doxygen.index"
)
