local M = {}
local nvim_lsp = require "lspconfig"
local lsp_installer = require "nvim-lsp-installer"

-- format
local format = function()
  vim.lsp.buf.formatting_sync({}, 7000)
end
local format_on_save = true
local on_save = function()
  if format_on_save then
    format()
  end
end
local format_on_save_setter = function(value)
  return function()
    format_on_save = value
  end
end
local format_on_save_toggle = function()
  format_on_save = not format_on_save
end

-- lsp callback
local make_on_attach = function(override_opts)
  override_opts = override_opts or {}
  return function(client, bufnr)
    if override_opts.document_formatting ~= nil then
      client.resolved_capabilities.document_formatting = override_opts.document_formatting
    end

    local lsp_document_symbols = function()
      require("telescope.builtin").lsp_document_symbols()
    end
    local lsp_workspace_symbol = function()
      require("telescope.builtin").lsp_dynamic_workspace_symbols()
    end
    local lsp_references = function()
      require("telescope.builtin").lsp_references()
    end
    local go_to_definition = function()
      require("telescope.builtin").lsp_definitions()
    end
    local lsp_rename = function()
      require("rc.lsp.rename").rename()
    end

    local map_opts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, map_opts)
    vim.keymap.set("n", "gd", override_opts.go_to_definition or go_to_definition, map_opts)
    vim.keymap.set("n", "gh", vim.lsp.buf.hover, map_opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, map_opts)
    vim.keymap.set("n", "gr", lsp_references, map_opts)
    vim.keymap.set("n", "<leader>s", lsp_document_symbols, map_opts)
    vim.keymap.set("n", "<leader>S", lsp_workspace_symbol, map_opts)
    vim.keymap.set("n", "<leader>rn", lsp_rename, map_opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, map_opts)
    vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, map_opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, map_opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, map_opts)
    vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, map_opts)

    if client.resolved_capabilities.document_formatting then
      vim.api.nvim_buf_add_user_command(bufnr, "Format", format, {})
      vim.api.nvim_create_autocmd("BufWritePre", { buffer = bufnr, callback = on_save })
    end
    require("illuminate").on_attach(client)
  end
end

-- settings for workspace/symbol
local SymbolKind = {
  File = 1,
  Module = 2,
  Namespace = 3,
  Package = 4,
  Class = 5,
  Method = 6,
  Property = 7,
  Field = 8,
  Constructor = 9,
  Enum = 10,
  Interface = 11,
  Function = 12,
  Variable = 13,
  Constant = 14,
  String = 15,
  Number = 16,
  Boolean = 17,
  Array = 18,
  Object = 19,
  Key = 20,
  Null = 21,
  EnumMember = 22,
  Struct = 23,
  Event = 24,
  Operator = 25,
  TypeParameter = 26,
}
-- default configurations for lsp
local function default_config(override_opts)
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.workspace.symbol.symbolKind.valueSet = {
    SymbolKind.Module,
    SymbolKind.Package,
    SymbolKind.Class,
    SymbolKind.Method,
    SymbolKind.Enum,
    SymbolKind.Interface,
    SymbolKind.Function,
    SymbolKind.Constant,
    SymbolKind.Struct,
  }
  return {
    on_attach = make_on_attach(override_opts),
    capabilities = capabilities,
  }
end

-- gopls
local function gopls_config()
  local config = default_config()
  config.cmd = { vim.fn.expand "~/go/bin/gopls" }
  return config
end

-- lua
local function lua_config()
  local config = default_config { document_formatting = false }
  local runtime_path = vim.split(package.path, ";")
  table.insert(runtime_path, "lua/?.lua")
  table.insert(runtime_path, "lua/?/init.lua")
  local lib = vim.api.nvim_get_runtime_file("", true)
  config.settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = runtime_path,
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = lib,
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  }
  return config
end

local function denols_config()
  local config = default_config()
  config.init_options = { enable = true, lint = true, unstable = true }
  return config
end

local function clangd_config()
  local config = default_config()
  config.cmd = { "clangd", "--background-index", "--clang-tidy" }
  return config
end

local function omnisharp_config()
  return default_config {
    go_to_definition = function()
      require("omnisharp_extended").telescope_lsp_definitions()
    end,
  }
end

M.configured_servers = {
  auto = {
    sumneko_lua = { config = lua_config() },
    vimls = { config = default_config() },
    omnisharp = { config = omnisharp_config() },
    dockerls = { config = default_config() },
    pyright = { config = default_config() },
    bashls = { config = default_config() },
    rust_analyzer = { config = default_config() },
    clangd = { config = clangd_config() },
    powershell_es = { config = default_config(), version = "v2.1.2" },
  },
  manual = {
    denols = { config = denols_config() },
    gopls = { config = gopls_config() },
  },
}

local function setup_nullls()
  local null_ls = require "null-ls"
  local sources = {
    null_ls.builtins.formatting.stylua.with {
      condition = function(utils)
        return utils.root_has_file ".stylua.toml"
      end,
    },
    null_ls.builtins.diagnostics.shellcheck,
  }
  null_ls.setup { sources = sources, on_attach = make_on_attach {} }
  local function register_my_nullls_settings()
    null_ls.register(sources)
  end

  aug("register_my_nullls_settings", {
    au("DirChanged", { pattern = "*", callback = register_my_nullls_settings }),
  })
end

function M.setup()
  vim.api.nvim_add_user_command("FormatOnSaveToggle", format_on_save_toggle, {})
  vim.api.nvim_add_user_command("FormatOnSaveDisable", format_on_save_setter(false), {})
  vim.api.nvim_add_user_command("FormatOnSaveEnable", format_on_save_setter(true), {})

  require("lsp_signature").setup()
  setup_nullls()
  lsp_installer.on_server_ready(function(server)
    if M.configured_servers.auto[server.name] == nil then
      print(server.name .. " is installed, but not setup.")
      return
    end

    local opts = M.configured_servers.auto[server.name].config
    server:setup(opts)
  end)
  for name, server in pairs(M.configured_servers.manual) do
    nvim_lsp[name].setup(server.config)
  end
end

return M
