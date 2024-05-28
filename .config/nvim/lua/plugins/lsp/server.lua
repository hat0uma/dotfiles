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
  ruff_lsp = {},
  gopls = {
    -- cmd = { vim.fn.expand "~/go/bin/gopls" },
    settings = {
      gopls = {
        -- use from golangci-lint
        staticcheck = false,
      },
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
    "markdownlint-cli2",
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
