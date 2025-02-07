local tree = require("rc.toys.doxygen.core.tree")

local function dump(tbl)
  local bufnr = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, vim.split(vim.inspect(tbl), "\n"))
  vim.api.nvim_win_set_buf(0, bufnr)
  return bufnr
end

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
local function test()
  local dir = vim.fs.normalize("~/work/doxygentest/xml")
  local index_file = vim.fs.joinpath(dir, "index.xml")
  local root = build_element_tree(index_file)
  if not root then
    return
  end

  local index = require("rc.toys.doxygen.index").build_doxygenindex(root)
  -- dump(index)

  local compounddefs = {}
  for _, compound_element in ipairs(index.compound) do
    local compound_file = vim.fs.joinpath(dir, compound_element.refid .. ".xml")
    local compound_root = build_element_tree(compound_file)
    if compound_root then
      local compound_index = require("rc.toys.doxygen.compound").build_doxygen(compound_root)
      vim.list_extend(compounddefs, compound_index.compounddef)
    end
  end
  dump(compounddefs)
end

local thread = coroutine.create(function()
  local _, err = xpcall(test, debug.traceback)
  if err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end)

coroutine.resume(thread)
