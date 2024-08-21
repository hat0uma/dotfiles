local M = {}

local query_typedef_struct = [[
((type_definition
   type: (struct_specifier)
   declarator: (type_identifier) @typedef_name))
]]

local query_field = [[
((field_declaration
  type: (type_identifier) @field_type
  declarator: (_) @field_name)
(comment)* @comment)
]]

--- Get all typedef struct node
---@param target TSNode
---@return table<string,TSNode>
local function get_typedef_struct_nodes(target)
  local struct_nodes = {} --- @type table<string,TSNode>

  -- match structs
  local query_obj = vim.treesitter.query.parse("c", query_typedef_struct)
  for id, node, metadata, match in query_obj:iter_captures(target, 0) do
    local display_name = vim.treesitter.get_node_text(node, 0)
    struct_nodes[display_name] = node:parent()
  end

  return struct_nodes
end

--- Trim comment
---@param comment string
---@return string
local function trim_comment(comment)
  return vim.trim(comment:gsub("^///*", ""):gsub("^/%*", ""):gsub("%*/$", ""))
end

---@class rc.CStructField
---@field type string field type
---@field name string field name
---@field comments string[] field comment

--- Get all struct node
---@param target TSNode
---@return rc.CStructField[]
local function get_struct_fields(target)
  local fields = {} ---@type rc.CStructField[]

  -- match struct fields
  local query_obj = vim.treesitter.query.parse("c", query_field)
  for pattern, match, metadata in query_obj:iter_matches(target, 0, nil, nil, { all = true }) do
    local field_name ---@type string
    local field_type ---@type string
    local comments = {}

    -- field
    for id, nodes in pairs(match) do
      local capture_name = query_obj.captures[id]
      for _, node in ipairs(nodes) do
        print(node:type())
        local node_text = vim.treesitter.get_node_text(node, 0)
        if capture_name == "field_name" then
          field_name = node_text
        elseif capture_name == "field_type" then
          field_type = node_text
        else
          table.insert(comments, trim_comment(node_text))
        end
      end
    end

    table.insert(fields, {
      name = field_name,
      type = field_type,
      comments = comments,
    })
  end

  return fields
end

function M.list_structs()
  local parser = vim.treesitter.get_parser(0, "c")
  local tree = parser:parse()[1]
  local root = tree:root()

  --- @type table<string, rc.CStructField[]>
  local structs = {}

  -- list all struct and its fields.
  local struct_nodes = get_typedef_struct_nodes(root)
  for struct_name, struct_node in pairs(struct_nodes) do
    structs[struct_name] = get_struct_fields(struct_node)
  end
  return structs
end

return M
