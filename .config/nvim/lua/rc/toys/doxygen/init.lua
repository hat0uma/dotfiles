-- clear package
package.loaded["rc.toys.doxygen.builder"] = nil
package.loaded["rc.toys.doxygen.core.tree"] = nil
package.loaded["rc.toys.doxygen.factory.compound"] = nil
package.loaded["rc.toys.doxygen.factory.index"] = nil
package.loaded["rc.toys.doxygen.index"] = nil
package.loaded["rc.toys.doxygen.util"] = nil

local Builder = require("rc.toys.doxygen.builder")
local compound_factory = require("rc.toys.doxygen.factory.compound")
local index_factory = require("rc.toys.doxygen.factory.index")
local tree = require("rc.toys.doxygen.core.tree")
local util = require("rc.toys.doxygen.util")

---@async
---@param filename string
---@return XmlElement? root
local function build_element_tree(filename)
  local thread = coroutine.running()
  tree.build(filename, function(cancelled, root, err)
    coroutine.resume(thread, cancelled, root, err)
  end)

  local cancelled, root, err = coroutine.yield()
  if cancelled then
    vim.notify("cancelled: ", vim.log.levels.WARN)
    return nil
  elseif err or not root then
    vim.notify("error: " .. err, vim.log.levels.ERROR)
    return nil
  end
  return root
end

---@async
local function dump_xsd(dir)
  local index = build_element_tree(vim.fs.joinpath(dir, "index.xsd"))
  if index then
    util.dump_json(index, "index.xsd", false)
  end
  local compound = build_element_tree(vim.fs.joinpath(dir, "compound.xsd"))
  if compound then
    util.dump_json(compound, "compound.xsd", false)
  end
end

---@async
local function test()
  local dir = vim.fs.normalize("~/work/doxygentest/xml")
  dump_xsd(dir)
  local index_file = vim.fs.joinpath(dir, "index.xml")
  local root = build_element_tree(index_file)
  if not root then
    return
  end

  util.dump_json(root, "root", false)
  local index = index_factory.DoxygenType(Builder:new(root))
  util.dump_json(index, "index", true)

  local compounddefs = {}
  for _, compound_element in ipairs(index.compound) do
    local compound_file = vim.fs.joinpath(dir, compound_element.refid .. ".xml")
    local compound_root = build_element_tree(compound_file)
    if compound_root then
      local compound_index = compound_factory.DoxygenType(Builder:new(compound_root))
      util.dump_json(compound_index, compound_element.refid, false)
      vim.list_extend(compounddefs, compound_index.compounddef)
    end
  end
  util.dump_json(compounddefs, "compounddefs", true)
end

local thread = coroutine.create(function()
  local _, err = xpcall(test, debug.traceback)
  if err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end)

coroutine.resume(thread)
