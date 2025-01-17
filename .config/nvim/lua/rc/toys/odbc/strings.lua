local M = {}

local ffi = require("ffi")

local CP_UTF8 = 65001
ffi.cdef([[
typedef uint16_t wchar_t;
int WideCharToMultiByte(
    unsigned int CodePage,
    unsigned long dwFlags,
    const wchar_t *lpWideCharStr,
    int cchWideChar,
    char *lpMultiByteStr,
    int cbMultiByte,
    const char *lpDefaultChar,
    int *lpUsedDefaultChar
);
]])

---lua string to wchar_ptr
---@param str string
---@return ffi.cdata* ptr, integer length
function M.to_wchar_ptr(str)
  local str_utf16 = vim.iconv(str .. "\0", "UTF-8", "UTF-16LE", {})
  return ffi.cast("SQLWCHAR_PTR", str_utf16), #str_utf16
end

---wchar to lua string
---@param wchar_str ffi.cdata*
---@return string
function M.from_wchar(wchar_str)
  -- Get length
  local size = ffi.C.WideCharToMultiByte(CP_UTF8, 0, wchar_str, -1, nil, 0, nil, nil) --- @type integer
  if size == 0 then
    error("Failed to get size for UTF-8 string")
  end

  -- Create buffer
  local utf8str = ffi.new("char[?]", size)

  -- Write to buffer
  local result = ffi.C.WideCharToMultiByte(CP_UTF8, 0, wchar_str, -1, utf8str, size, nil, nil) --- @type integer
  if result == 0 then
    error("Failed to convert wchar_t to UTF-8")
  end

  return ffi.string(utf8str)
end

return M
