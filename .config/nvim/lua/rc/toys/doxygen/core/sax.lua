local AttributeSet = require("rc.toys.doxygen.core.attribute_set")
local ffi = require("ffi")
local libxml2 = require("rc.toys.doxygen.core.libxml2")
local M = {}

--- to string between 2 ptr nil safely
---@param ptr1 ffi.cdata*
---@param ptr2 ffi.cdata*
---@return string?
local function str_between(ptr1, ptr2)
  return ptr1 ~= nil and ffi.string(ptr1, ptr2 - ptr1) or nil
end

--- to string nil safely
---@param ptr ffi.cdata*
---@param len? integer
---@return string?
local function str(ptr, len)
  return ptr ~= nil and ffi.string(ptr, len) or nil
end

--- Call fn if not nil
---@param fn fun(...)
---@param ... any
local function call_optional(fn, ...)
  if fn then
    fn(...)
  end
end

--- Create error group object
---@return ErrorGroup
local function new_error_group()
  local errors = {}

  ---@class ErrorGroup
  local instance = {
    --- get combined error
    ---@return string?
    get = function()
      return #errors ~= 0 and table.concat(errors, "\n") or nil
    end,

    --- add error to group
    ---@param err string
    add = function(err)
      table.insert(errors, err)
    end,

    has_err = function()
      return #errors ~= 0
    end,
  }
  return instance
end

---Create sax handler ptr
---@return XmlSaxHandlerPtr
local function new_sax2_handler()
  ---@diagnostic disable-next-line: assign-type-mismatch
  local handler = ffi.new("xmlSAXHandler[1]") --- @type XmlSaxHandlerPtr
  handler[0].initialized = libxml2.XML_SAX2_MAGIC
  return handler
end

---@class XmlSAXParser.Callbacks
---@field start_element_ns? fun(localname: string, prefix?: string, uri?: string, attributes: XmlSAXParser.AttributeSet)
---@field end_element_ns? fun(localname: string, prefix?: string, uri?: string)
---@field characters? fun(value: string)
---@field completed? fun(cancelled: boolean, err?:string)

---@class XmlSAXParser.Opts
---@field chunk_size? integer
local default_opts = {
  chunk_size = 4096,
}

---@class XmlSAXParser.Obj
---@field cancel fun()

--- Register callbacks to sax handle
---@param sax_handle_ptr XmlSaxHandlerPtr
---@param callbacks XmlSAXParser.Callbacks
---@param eg ErrorGroup
local function register_callbacks(sax_handle_ptr, callbacks, eg)
  local function safe_call_wrap(fn)
    return function(...)
      -- check error occurrences in current chunk
      if eg.has_err() then
        return
      end

      -- fire callback
      local ok, err = xpcall(fn, debug.traceback, ...) ---@diagnostic disable-line: no-unknown

      -- record error in callback
      if not ok then
        eg.add(err)
      end
    end
  end

  if callbacks.start_element_ns then
    local startElementNs = safe_call_wrap(
      ---@param ctx ffi.cdata*
      ---@param localname ffi.cdata*
      ---@param prefix ffi.cdata*
      ---@param URI ffi.cdata*
      ---@param nb_namespaces integer
      ---@param namespaces ffi.cdata*
      ---@param nb_attributes integer
      ---@param nb_defaulted integer
      ---@param attributes ffi.cdata*
      function(ctx, localname, prefix, URI, nb_namespaces, namespaces, nb_attributes, nb_defaulted, attributes)
        local raw_attrs = {}
        local i = 0
        for _ = 1, nb_attributes do
          table.insert(raw_attrs, {
            localname = str(attributes[i]),
            prefix = str(attributes[i + 1]),
            nsURI = str(attributes[i + 2]),
            value = str_between(attributes[i + 3], attributes[i + 4]),
          })
          i = i + 5
        end

        callbacks.start_element_ns(ffi.string(localname), str(prefix), str(URI), AttributeSet:new(raw_attrs))
      end
    )

    ---@diagnostic disable-next-line: assign-type-mismatch
    sax_handle_ptr[0].startElementNs = ffi.cast("startElementNsSAX2Func", startElementNs)
  end

  if callbacks.end_element_ns then
    ---@param ctx ffi.cdata*
    ---@param localname ffi.cdata*
    ---@param prefix ffi.cdata*
    ---@param URI ffi.cdata*
    local endElementNs = safe_call_wrap(function(ctx, localname, prefix, URI)
      callbacks.end_element_ns(ffi.string(localname), str(prefix), str(URI))
    end)

    ---@diagnostic disable-next-line: assign-type-mismatch
    sax_handle_ptr[0].endElementNs = ffi.cast("endElementNsSAX2Func", endElementNs)
  end

  if callbacks.characters then
    local characters = safe_call_wrap(
      --- @param ctx ffi.cdata*
      ---@param ch ffi.cdata*
      ---@param len integer
      function(ctx, ch, len)
        callbacks.characters(ffi.string(ch, len))
      end
    )

    ---@diagnostic disable-next-line: assign-type-mismatch
    sax_handle_ptr[0].characters = ffi.cast("charactersSAXFunc", characters)
  end

  --- @param user_data ffi.cdata*
  ---@param err ffi.cdata*
  local serror = function(user_data, err)
    eg.add(ffi.string(err[0].message))
  end

  ---@diagnostic disable-next-line: assign-type-mismatch
  sax_handle_ptr[0].serror = ffi.cast("xmlStructuredErrorFunc", serror)
end

--- Register callbacks to sax handle
---@param sax_handle_ptr XmlSaxHandlerPtr
local function free_callbacks(sax_handle_ptr)
  if sax_handle_ptr[0].startElementNs then
    sax_handle_ptr[0].startElementNs:free()
  end
  if sax_handle_ptr[0].endElementNs then
    sax_handle_ptr[0].endElementNs:free()
  end
  if sax_handle_ptr[0].characters then
    sax_handle_ptr[0].characters:free()
  end
  if sax_handle_ptr[0].serror then
    sax_handle_ptr[0].serror:free()
  end
end

--- xml sax parse async
---@param filename string
---@param callbacks XmlSAXParser.Callbacks
---@param opts? XmlSAXParser.Opts
---@return XmlSAXParser.Obj
function M.xml_sax_parse(filename, callbacks, opts)
  opts = vim.tbl_extend("keep", opts or {}, default_opts) --- @type XmlSAXParser.Opts

  -- create error handler
  local eg = new_error_group()

  -- initialize handle
  local sax_handle_ptr = new_sax2_handler()
  register_callbacks(sax_handle_ptr, callbacks, eg)

  -- open
  local file = io.open(filename, "rb")
  if not file then
    free_callbacks(sax_handle_ptr)
    error("Failed to open file: " .. filename)
  end

  -- create context
  local context = libxml2.xmlCreatePushParserCtxt(sax_handle_ptr, nil, nil, 0, nil)
  if context == nil then
    free_callbacks(sax_handle_ptr)
    error("Failed to create parser context")
  end

  local cleanup = function()
    file:close()
    free_callbacks(sax_handle_ptr)
    libxml2.xmlFreeParserCtxt(context)
  end

  local cancelled = false
  local function iter()
    -- check cancellation.
    if cancelled then
      cleanup()
      call_optional(callbacks.completed, true, nil)
      return
    end

    -- read next chunk and check parsing completion
    local chunk = file:read(opts.chunk_size)
    if not chunk then
      libxml2.xmlParseChunk(context, nil, 0, 1) -- terminate
      cleanup()
      call_optional(callbacks.completed, false, eg.get())
      return
    end

    -- push chunk
    local result = libxml2.xmlParseChunk(context, chunk, #chunk, 0)

    -- check error
    if result ~= 0 then
      cleanup()
      eg.add(string.format("error: xmlParseChunk return %d", result))
      call_optional(callbacks.completed, false, eg.get())
      return
    end

    -- check error in `xmlSAXHandler` callbacks.
    if eg.has_err() then
      cleanup()
      call_optional(callbacks.completed, false, eg.get())
      return
    end

    -- next step
    vim.schedule(iter)
  end

  -- start iterations
  vim.schedule(iter)

  return { --- @type XmlSAXParser.Obj
    cancel = function()
      cancelled = true
    end,
  }
end

return M
