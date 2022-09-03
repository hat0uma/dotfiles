local dap = require "dap"
local mason_registry = require "mason-registry"
local uv = vim.loop

local function read_file_sync(path)
  local fd = assert(uv.fs_open(path, "r", 438))
  local stat = assert(uv.fs_fstat(fd))
  local data = assert(uv.fs_read(fd, stat.size, 0))
  assert(uv.fs_close(fd))
  return data
end

local function get_pid_of_unity_editor()
  local path_to_editor_instance_json = uv.cwd() .. "/Library/EditorInstance.json"
  local editor_instance_json = vim.json.decode(read_file_sync(path_to_editor_instance_json))
  return editor_instance_json.process_id
end

dap.adapters.coreclr = {
  type = "executable",
  command = mason_registry.get_package("netcoredbg"):get_install_path() .. "/netcoredbg",
  args = { "--interpreter=vscode" },
}
dap.configurations.cs = {
  {
    type = "coreclr",
    name = "unity-netcoredbg",
    request = "attach",
    processId = get_pid_of_unity_editor,
  },
}
