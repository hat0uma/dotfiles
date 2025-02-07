local sax = require("rc.toys.doxygen.core.sax")
local M = {}

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
        name = localname,
        attrs = attrs:to_kvp(),
        children = {},
      })
    end,
    end_element_ns = function(localname, prefix, uri)
      local element = table.remove(stack)
      if #stack > 0 then
        table.insert(stack[#stack].content, element)
      end
      root = element
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
