local nvim_lsp = require "lspconfig"
local lsp_installer = require "nvim-lsp-installer"

-- format
local format = function()
  vim.lsp.buf.formatting_sync({}, 7000)
end
--- format on save
vim.g.lsp_format_on_save = true
local on_save = function()
  if vim.g.lsp_format_on_save then
    format()
  end
end

-- lsp callback
local my_document_symbols = function()
  require("telescope.builtin").lsp_document_symbols()
end
local my_workspace_symbols = function()
  require("telescope.builtin").lsp_dynamic_workspace_symbols()
end
local my_references = function()
  require("telescope.builtin").lsp_references()
end
local my_rename = function()
  require("rc.lsp.rename").rename()
end

local on_attach = function(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gh", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gr", my_references, opts)
  vim.keymap.set("n", "<leader>s", my_document_symbols, opts)
  vim.keymap.set("n", "<leader>S", my_workspace_symbols, opts)
  vim.keymap.set("n", "<leader>rn", my_rename, { silent = true })
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
  -- vim.keymap.set("n", "<leader>e", vim.lsp.diagnostic.show_line_diagnostics, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)

  if client.resolved_capabilities.document_formatting then
    vim.keymap.set("n", "<leader><leader>f", format, opts)
    vim.api.nvim_create_autocmd("BufWritePre", { buffer = 0, callback = on_save })
  end
  require("illuminate").on_attach(client)
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
local function default_config()
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
    on_attach = on_attach,
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
  local config = default_config()
  config.on_attach = function(client, bufnr)
    client.resolved_capabilities.document_formatting = false
    on_attach(client, bufnr)
  end
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

local configured_servers = {
  auto = {
    sumneko_lua = { config = lua_config() },
    vimls = { config = default_config() },
    omnisharp = { config = default_config() },
    dockerls = { config = default_config() },
    pyright = { config = default_config() },
    bashls = { config = default_config() },
    rust_analyzer = { config = default_config() },
    clangd = { config = clangd_config() },
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
  null_ls.setup { sources = sources, on_attach = on_attach }
  local function register_my_nullls_settings()
    null_ls.register(sources)
  end

  aug("register_my_nullls_settings", {
    au("DirChanged", { pattern = "*", callback = register_my_nullls_settings }),
  })
end

local function setup()
  require("lsp_signature").setup()
  setup_nullls()
  lsp_installer.on_server_ready(function(server)
    if configured_servers.auto[server.name] == nil then
      print(server.name .. " is installed, but not setup.")
      return
    end

    local opts = configured_servers.auto[server.name].config
    server:setup(opts)
  end)
  for name, config in pairs(configured_servers.manual) do
    nvim_lsp[name].setup(config)
  end
end

return {
  configured_servers = configured_servers,
  setup = setup,
}
