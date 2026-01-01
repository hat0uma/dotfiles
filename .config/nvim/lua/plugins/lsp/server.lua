local M = {}

---@type table<string,vim.lsp.Config>
M.configurations = {
  astro = {},
  biome = {},
  jdtls = {},
  lua_ls = {
    settings = {
      Lua = {
        hint = {
          arrayIndex = "Disable",
        },
        diagnostics = {
          -- globals = { "vim" },
          groupFileStatus = {
            ["ambiguity"] = "Opened",
            ["await"] = "Opened",
            ["codestyle"] = "None",
            ["duplicate"] = "Opened",
            ["global"] = "Opened",
            ["luadoc"] = "Opened",
            ["redefined"] = "Opened",
            ["strict"] = "Opened",
            ["strong"] = "Opened",
            ["type-check"] = "Opened",
            ["unbalanced"] = "Opened",
            ["unused"] = "Opened",
          },
        },
        workspace = {
          checkThirdParty = false,
        },
        completion = {
          callSnippet = "Replace",
        },
        telemetry = {
          enable = false,
        },
      },
    },
  },
  vimls = {},
  dockerls = {},
  pyright = {
    on_init = function(client) ---@param client vim.lsp.Client
      local venv = vim.fs.joinpath(client.config.root_dir, ".venv")
      if vim.uv.fs_access(venv, "R") then
        client.config.settings.venv = venv
        client.config.settings.python.pythonPath =
          vim.fs.joinpath(venv, rc.sys.is_windows and "Scripts/python.exe" or "bin/python")
      end
    end,
    root_markers = {
      ".venv",
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      "pyrightconfig.json",
      ".git",
    },
  },
  rust_analyzer = {},
  clangd = {
    cmd = { "clangd", "--background-index", "--clang-tidy" },
    capabilities = {
      offsetEncoding = "utf-16",
    },
  },
  powershell_es = {
    on_attach = function(client, bufnr)
      client.server_capabilities.semanticTokensProvider = nil
    end,
    bundle_path = vim.fs.joinpath(
      vim.fn.stdpath("data"),
      "mason/packages/powershell-editor-services"
      -- "/PowerShellEditorServices"
    ),
    -- shell = "powershell.exe",
  },
  denols = {
    -- single_file_support = true,
    root_markers = {
      "deno.json",
    },
    init_options = {
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
    },
  },
  ruff = {
    root_markers = {
      "pyproject.toml",
      "ruff.toml",
      ".git",
      ".venv",
    },
    on_init = function(client) ---@param client vim.lsp.Client
      client.config.settings.interpreter = {
        rc.sys.is_windows
          and vim.fs.joinpath(client.config.root_dir, ".venv/Scripts/python.exe")
          and vim.fs.joinpath(client.config.root_dir, ".venv/bin/python"),
      }
    end,
  },
  gopls = {
    -- cmd = { vim.fn.expand "~/go/bin/gopls" },
    settings = {
      gopls = {
        -- use from golangci-lint
        staticcheck = false,
      },
    },
  },
  roslyn_ls = {
    offset_encoding = "utf-16",
    cmd = {
      "Microsoft.CodeAnalysis.LanguageServer",
      "--stdio",
      "--logLevel",
      "Information",
      "--extensionLogDirectory",
      vim.fn.stdpath("cache"),
    },
  },
  marksman = {},
  eslint = {
    -- on_new_config = function(config, new_root_dir)
    --   local lspconfig = require "lspconfig"
    --   local util = require "lspconfig.util"
    --
    --   -- apply default `on_new_config`
    --   lspconfig["eslint"].document_config.default_config.on_new_config(config, new_root_dir)
    --
    --   -- patch for yarn pnp on windows
    --   local sysname = vim.uv.os_uname().sysname
    --   if sysname:match "Windows" then
    --     local pnp_cjs = util.path.join(new_root_dir, ".pnp.cjs")
    --     local pnp_js = util.path.join(new_root_dir, ".pnp.js")
    --     if util.path.exists(pnp_cjs) or util.path.exists(pnp_js) then
    --       local yarn = vim.fn.exepath "yarn"
    --       config.cmd = {
    --         yarn ~= "" and yarn or "yarn",
    --         "exec",
    --         "vscode-eslint-language-server", -- By default, `sanitize_cmd` is applied to this value.
    --         "--stdio",
    --       }
    --     end
    --   end
    -- end,
  },
  hls = {},
  html = {},
  cssls = {},
  -- omnisharp = {
  --   settings = {
  --     RoslynExtensionsOptions = {
  --       EnableImportCompletion = true,
  --       InlayHintsOptions = {
  --         -- https://github.com/OmniSharp/omnisharp-roslyn/blob/master/src/OmniSharp.Shared/Options/InlayHintsOptions.cs
  --         EnableForParameters = true,
  --         ForLiteralParameters = true,
  --         ForIndexerParameters = false,
  --         ForObjectCreationParameters = true,
  --         ForOtherParameters = true,
  --         SuppressForParametersThatDifferOnlyBySuffix = true,
  --         SuppressForParametersThatMatchMethodIntent = true,
  --         SuppressForParametersThatMatchArgumentName = true,
  --         EnableForTypes = false,
  --         ForImplicitVariableTypes = true,
  --         ForLambdaParameterTypes = true,
  --         ForImplicitObjectCreation = true,
  --       },
  --     },
  --   },
  -- },
  -- tsserver = {
  --   root_dir = require("lspconfig").util.root_pattern "package.json",
  --   single_file_support = false,
  -- },
  jsonls = {
    single_file_support = true,
    root_dir = nil,
    settings = {
      json = {
        schemas = require("schemastore").json.schemas(),
        validate = { enable = true },
        format = {
          enable = true,
          keepLines = true,
        },
      },
    },
  },
}

function M.install()
  local auto_install = {
    "css-lsp",
    "eslint-lsp",
    "json-lsp",
    "lua-language-server",
    "markdownlint-cli2",
    "powershell-editor-services",
    "prettierd",
    "pyright",
    "ruff",
    "mypy",
    "shellcheck",
    "shfmt",
    "stylua",
    "typescript-language-server",
  }
  require("mason")
  vim.cmd("MasonInstall " .. table.concat(auto_install, " "))
end

return M
