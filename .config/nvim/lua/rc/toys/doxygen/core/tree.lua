local sax = require("rc.toys.doxygen.core.sax")
local M = {}

--- Check element is mixed
---@param element XmlElement
---@return boolean
local function is_mixed(element)
  local element_num = 0
  local text_num = 0
  for i = 1, #element.content do
    local v = element.content[i]
    if type(v) == "string" and #vim.trim(v) ~= 0 then
      text_num = text_num + 1
    else
      element_num = element_num + 1
    end

    if element_num ~= 0 and text_num ~= 0 then
      return true
    end
  end
  return false
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

      if not is_mixed(current) then
        -- normalize text content
        for i = #current.content, 1, -1 do
          local v = current.content[i]
          if type(v) == "string" then
            local normalized = v:gsub("^%s+", "")
            if #normalized == 0 then
              table.remove(current.content, i)
            else
              current.content[i] = normalized
            end
          end
        end
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
