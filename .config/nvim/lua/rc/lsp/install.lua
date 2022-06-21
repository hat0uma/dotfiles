-- install_servers
local function install_configured_servers_sync()
  local servers = vim.tbl_keys(require("rc.lsp").configured_servers.auto)
  vim.cmd("LspInstall --sync " .. table.concat(servers, " "))
end

return {
  install_configured_servers_sync = install_configured_servers_sync,
}
