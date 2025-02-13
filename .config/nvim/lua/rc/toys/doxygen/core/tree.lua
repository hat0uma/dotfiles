local sax = require("rc.toys.doxygen.core.sax")
local M = {}

--- Check if the element has text content
---@param element XmlElement
---@return boolean
local function has_text(element)
  for i = 1, #element.content do
    local v = element.content[i]
    if type(v) == "string" and #vim.trim(v) ~= 0 then
      return true
    end
  end
  return false
end

--- Normalize text content
---@param element XmlElement
local function normalize_whitespace(element)
  for i = #element.content, 1, -1 do
    local v = element.content[i]
    if type(v) == "string" then
      local normalized = v:gsub("^%s+", "")
      if #normalized == 0 then
        table.remove(element.content, i)
      else
        element.content[i] = normalized
      end
    end
  end
end

---@class XmlElement
---@field name string
---@field attrs table<string,string>
---@field content (XmlElement|string)[]

--- Build Element tree
---@param filename string
---@param on_completed fun(cancelled: boolean, root?: XmlElement, err?:string )
function M.build(filename, on_completed)
  local root = nil ---@type XmlElement
  local stack = {} ---@type XmlElement[]

  sax.xml_sax_parse(filename, {
    start_element_ns = function(localname, prefix, uri, attrs)
      table.insert(stack, {
        name = prefix and string.format("%s:%s", prefix, localname) or localname,
        attrs = attrs:to_kvp(),
        content = {},
      })
    end,
    end_element_ns = function(localname, prefix, uri)
      ---@type XmlElement
      local current = table.remove(stack)
      if not has_text(current) then
        normalize_whitespace(current)
      end

      -- pop the stack and append to parent
      local parent = stack[#stack]
      if #stack > 0 then
        table.insert(parent.content, current)
      end
      root = current
    end,

    characters = function(value)
      local current = stack[#stack]
      local last_child = current.content[#current.content]
      if type(last_child) == "string" then
        current.content[#current.content] = last_child .. value
      else
        table.insert(current.content, value)
      end
    end,

    completed = function(cancelled, err)
      if cancelled then
        on_completed(true, nil, nil)
      elseif err then
        on_completed(false, nil, err)
      else
        on_completed(false, root, nil)
      end
    end,
  })
end

return M
