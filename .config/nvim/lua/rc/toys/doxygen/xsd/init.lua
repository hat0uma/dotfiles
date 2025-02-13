local M = {}

---@class DoxygenGeneratorOpts
---@field text_foldings string[]
---@field namespace? string
---@field name_converter? fun(name: string):string
---@field type_mappings table<string,string>

local DoxygenFactoryGenerator = require("rc.toys.doxygen.xsd.factory_generator")
local DoxygenTypeGenerator = require("rc.toys.doxygen.xsd.type_generator")
local tree = require("rc.toys.doxygen.core.tree")

-- Utility function to get the current script path
local function get_script_path()
  local source = debug.getinfo(2, "S").source:sub(2)
  return source:match("(.*/)")
end

---@param path string
---@return string
local function stem(path)
  local base = vim.fs.basename(path)
  return (string.gsub(base, "%.xsd$", ""))
end

--- Write lines to file.
---@param path string
---@param lines string[]
local function dump(path, lines)
  local dir = vim.fs.dirname(path)
  if vim.fn.isdirectory(dir) ~= 1 then
    assert(vim.uv.fs_mkdir(dir, 493)) -- 755
  end

  local outfile = assert(io.open(path, "w"))
  outfile:write(table.concat(lines, "\n"))
  outfile:close()
end

--- Generate lua types and parsers from xsd
---@param xsd_path string xsd file path
---@param output_dir string output directory
---@param opts DoxygenGeneratorOpts
function M.generate_lua(xsd_path, output_dir, opts)
  local type_generator = DoxygenTypeGenerator:new(opts)
  local factory_generator = DoxygenFactoryGenerator:new(opts)

  tree.build(xsd_path, function(cancelled, root, err)
    if cancelled then
      vim.notify("building xsd element tree was cancelled.", vim.log.levels.WARN)
      return
    end

    if err then
      vim.notify("building xsd element tree was terminated with following errors:\n" .. err, vim.log.levels.ERROR)
    end

    local schema = require("rc.toys.doxygen.xsd.schema").xsd_build_schema(root)
    local lua_basename = stem(xsd_path) .. ".lua"

    local types = type_generator:generate(schema)
    local types_path = vim.fs.joinpath(output_dir, "types", lua_basename)
    dump(types_path, types)

    local factories = factory_generator:generate(schema)
    local factories_path = vim.fs.joinpath(output_dir, "factory", lua_basename)
    dump(factories_path, factories)
    vim.notify("generate lua to " .. output_dir)
  end)
end
local type_mappings = {
  ["xsd:string"] = "string",
  ["xsd:boolean"] = "boolean",
  ["xsd:integer"] = "integer",
  ["xsd:decimal"] = "number",
  ["string"] = "string",
  ["DoxBool"] = "boolean",
}
--- Convert XSD name to Lua name
---@param name string
---@return string
local function name_converter(name)
  return (name:gsub(":", "_"))
end

M.generate_lua(
  vim.fs.normalize("~/work/doxygentest/xml/index.xsd"),
  vim.fs.normalize(vim.fs.joinpath(get_script_path(), "../")),
  {
    name_converter = name_converter,
    type_mappings = type_mappings,
    namespace = "doxygen.index",
    text_foldings = { "listingType", "linkedTextType" },
  }
)

M.generate_lua(
  vim.fs.normalize("~/work/doxygentest/xml/compound.xsd"),
  vim.fs.normalize(vim.fs.joinpath(get_script_path(), "../")),
  {
    name_converter = name_converter,
    type_mappings = type_mappings,
    namespace = "doxygen.compound",
    text_foldings = { "listingType", "linkedTextType" },
  }
)

return M
