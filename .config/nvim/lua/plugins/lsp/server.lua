local M = {}
M.configurations = {
  sumneko_lua = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          checkThirdParty = false,
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
  },
  powershell_es = {},
  denols = {
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
    cmd = { vim.fn.expand "~/go/bin/gopls" },
  },
  cssls = {},
  omnisharp = {},
  tsserver = {},
}

function M.install()
  local auto_install = {
    "lua-language-server",
    "vim-language-server",
    "pyright",
    "typescript-language-server",
    "eslint_d",
    "prettierd",
    "css-lsp",
    "stylua",
    "shellcheck",
  }
  require "mason"
  vim.cmd("MasonInstall " .. table.concat(auto_install, " "))
end

return M
