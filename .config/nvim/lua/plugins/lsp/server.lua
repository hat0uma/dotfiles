local M = {}
M.configurations = {
  lua_ls = {
    settings = {
      Lua = {
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
  pyright = {},
  rust_analyzer = {},
  clangd = {
    cmd = { "clangd", "--background-index", "--clang-tidy" },
    capabilities = {
      offsetEncoding = "utf-16",
    },
  },
  powershell_es = {},
  denols = {
    -- single_file_support = true,
    root_dir = require("lspconfig").util.root_pattern "deno.json",
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
  gopls = {
    -- cmd = { vim.fn.expand "~/go/bin/gopls" },
    settings = {
      gopls = {
        -- use from golangci-lint
        staticcheck = false,
      },
    },
  },
  eslint = {},
  hls = {},
  cssls = {},
  omnisharp = {},
  -- tsserver = {
  --   root_dir = require("lspconfig").util.root_pattern "package.json",
  --   single_file_support = false,
  -- },
  jsonls = {
    settings = {
      json = {
        schemas = require("schemastore").json.schemas(),
        validate = { enable = true },
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
    "powershell-editor-services",
    "prettierd",
    "pyright",
    "shellcheck",
    "shfmt",
    "stylua",
    "typescript-language-server",
  }
  require "mason"
  vim.cmd("MasonInstall " .. table.concat(auto_install, " "))
end

return M
