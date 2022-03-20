-- install_servers
-- https://github.com/williamboman/nvim-lsp-installer/issues/179#issuecomment-946674767

local function install_servers_sync(servers)
  local process = require("nvim-lsp-installer.process")
  local lsp_installer_servers = require("nvim-lsp-installer.servers")

  local completed = 0
  local server_count = 0
  for name,_ in pairs(servers) do

    server_count = server_count + 1
    local ok, server = lsp_installer_servers.get_server(name)
    if not ok then
      print("Could not get server info " .. server.name)
      completed = completed + 1
      goto continue
    end

    if server:is_installed() then
      print("Server " .. server.name .. " already installed.")
      completed = completed + 1
      goto continue
    end

    server:install_attached({
      stdio_sink = process.simple_sink(),
      requested_server_version = nil },
      function (success)
        if not success then
          print("Server " .. server.name .. " failed to install.")
        else
          print("Server " .. server.name .. " install success.")
        end
        completed = completed + 1
      end
    )

    ::continue::
  end

  -- wait all server install
  vim.wait(10000, function() return completed >= server_count end )
end

local function install_configured_servers_sync()
  install_servers_sync(require("rc.lsp").configured_servers.auto)
end

return {
  install_configured_servers_sync = install_configured_servers_sync
}

