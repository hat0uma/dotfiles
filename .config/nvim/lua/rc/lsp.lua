local M = {}
local nvim_lsp = require "lspconfig"
local mason = require "mason"
local mason_lspconfig = require "mason-lspconfig"
local cmp_nvim_lsp = require "cmp_nvim_lsp"
local navic = require "nvim-navic"

-- format
local format = function()
  vim.lsp.buf.format { timeout_ms = 7000 }
end

local format_on_save = {}
format_on_save.enabled = true
format_on_save.handle = function()
  if format_on_save.enabled then
    format()
  end
end
format_on_save.toggle = function()
  format_on_save.enabled = not format_on_save.enabled
end
format_on_save.enable = function()
  format_on_save.enabled = true
end

format_on_save.disable = function()
  format_on_save.enabled = false
end

-- lsp callback
local make_on_attach = function(override_opts)
  override_opts = override_opts or {}
  return function(client, bufnr)
    if override_opts.document_formatting ~= nil then
      client.server_capabilities.documentFormattingProvider = override_opts.document_formatting
      client.server_capabilities.documentRangeFormattingProvider = override_opts.document_formatting
    end

    if client.server_capabilities.documentSymbolProvider then
      navic.attach(client, bufnr)
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
    vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, map_opts)

    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_buf_create_user_command(bufnr, "Format", format, {})
      vim.api.nvim_create_autocmd("BufWritePre", { buffer = bufnr, callback = format_on_save.handle })
    end
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

local capabilities =
  vim.tbl_extend("force", vim.lsp.protocol.make_client_capabilities(), cmp_nvim_lsp.default_capabilities())
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
-- default configurations for lsp
local function default_config(override_opts)
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
  -- runtime_pathだとlazy loadしたpluginを読み込めない
  local list_installed_plugins = function()
    local plugin_install_path = vim.fn.stdpath "data" .. "/lazy"
    local plugins = {}
    local handle = vim.loop.fs_scandir(plugin_install_path)
    while handle do
      local name, t = vim.loop.fs_scandir_next(handle)
      if not name and t ~= "directory" then
        break
      end
      table.insert(plugins, plugin_install_path .. "/" .. name)
    end
    return plugins
  end
  local lib = list_installed_plugins()
  table.insert(lib, vim.fn.stdpath "config")

  local config = default_config { document_formatting = false }
  config.settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = {
          "lua/?.lua",
          "lua/?/init.lua",
        },
        pathStrict = true,
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
  config.root_dir = nvim_lsp.util.root_pattern "deno.json"
  config.init_options = {
    enable = true,
    lint = true,
    unstable = true,
    suggest = {
      imports = {
        hosts = {
          ["https://deno.land"] = true,
          ["https://cdn.nest.land"] = true,
          ["https://crux.land"] = true,
        },
      },
    },
  }
  return config
end

local function tsserver_config()
  local config = default_config { document_formatting = false }
  config.root_dir = nvim_lsp.util.root_pattern "package.json"
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
M.servers = {
  sumneko_lua = { config = lua_config() },
  vimls = { config = default_config() },
  dockerls = { config = default_config() },
  pyright = { config = default_config() },
  rust_analyzer = { config = default_config() },
  clangd = { config = clangd_config() },
  powershell_es = { config = default_config(), version = "v2.1.2" },
  denols = { config = denols_config() },
  gopls = { config = gopls_config() },
  cssls = { config = default_config() },
  -- use typescript.nvim
  -- tsserver = { config = tsserver_config() },
}
if vim.fn.has "win64" ~= 0 then
  M.servers["omnisharp"] = { config = omnisharp_config() }
else
  -- M.servers["omnisharp"] = { config = omnisharp_mono_config() }
  M.servers["omnisharp"] = { config = omnisharp_config() }
end

local function setup_nullls()
  local null_ls = require "null-ls"
  local has_eslintrc = {
    condition = function(utils)
      return utils.root_has_file { ".eslintrc.json" }
    end,
  }
  local has_prettierrc = {
    condition = function(utils)
      return utils.root_has_file { ".prettierrc" }
    end,
  }
  local sources = {
    null_ls.builtins.formatting.stylua.with {
      condition = function(utils)
        return utils.root_has_file { ".stylua.toml", "stylua.toml" }
      end,
    },
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.diagnostics.eslint_d.with(has_eslintrc),
    null_ls.builtins.formatting.eslint_d.with(has_eslintrc),
    null_ls.builtins.formatting.prettierd.with(has_prettierrc),
  }
  null_ls.setup { sources = sources, on_attach = make_on_attach {} }
  local function register_my_nullls_settings()
    null_ls.register(sources)
  end

  local group = vim.api.nvim_create_augroup("register_my_nullls_settings", {})
  vim.api.nvim_create_autocmd("DirChanged", { pattern = "*", callback = register_my_nullls_settings, group = group })
end

function M.setup()
  vim.diagnostic.config {
    underline = {
      severity = {
        min = vim.diagnostic.severity.HINT,
      },
    },
    virtual_text = {
      severity = {
        min = vim.diagnostic.severity.WARN,
      },
    },
    signs = {
      severity = {
        min = vim.diagnostic.severity.HINT,
      },
    },
    severity_sort = true,
  }

  vim.cmd [[sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=]]
  vim.cmd [[sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=]]
  vim.cmd [[sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=]]
  vim.cmd [[sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=]]
  vim.api.nvim_create_user_command("FormatOnSaveToggle", format_on_save.toggle, {})
  vim.api.nvim_create_user_command("FormatOnSaveDisable", format_on_save.enable, {})
  vim.api.nvim_create_user_command("FormatOnSaveEnable", format_on_save.disable, {})

  mason_lspconfig.setup()
  setup_nullls()
  for name, server in pairs(M.servers) do
    nvim_lsp[name].setup(server.config)
  end
  require("typescript").setup {
    disable_commands = false,
    debug = false,
    go_to_source_definition = {
      fallback = true,
    },
    server = {
      on_attach = default_config({ document_formatting = false }).on_attach,
    },
  }
end

return M
