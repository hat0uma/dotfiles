local M = {}

function M.config()
  require("nvim-treesitter.configs").setup {
    highlight = {
      enable = true,
      disable = {
        -- 'toml',
      },
    },
  }
end

function M.textobjects_config()
  require("nvim-treesitter.configs").setup {
    textobjects = {
      select = {
        enable = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["ia"] = "@parameter.outer",
          ["aa"] = "@parameter.inner",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["swn"] = "@parameter.inner",
        },
        swap_previous = {
          ["swp"] = "@parameter.inner",
        },
      },
      move = {
        enable = true,
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
        },
      },
    },
  }
end

function M.tsautotag_config()
  require("nvim-treesitter.configs").setup {
    autotag = {
      enable = true,
    },
  }
end

function M.context_commentstring_config()
  require("nvim-treesitter.configs").setup {
    context_commentstring = {
      enable = true,
      enable_autocmd = false,
    },
  }
end

M.parsers = {
  "typescript",
  "tsx",
  "c",
  "c_sharp",
  "cpp",
  "json",
  "yaml",
  "dockerfile",
  "vim",
  "lua",
  "comment",
  "html",
  "bash",
  "go",
  "rust",
  "regex",
  "markdown",
  "markdown_inline",
  -- "norg",
  -- "norg_meta",
  -- "norg_table",
}

function M.install_parsers(opts)
  local _opts = vim.tbl_extend("keep", opts or {}, { force = false, sync = false })
  local parsers_text = table.concat(M.parsers, " ")

  local sync = _opts.sync and "Sync" or ""
  local force = _opts.force and "!" or ""
  vim.cmd(string.format("TSInstall%s%s %s", sync, force, parsers_text))
end

return M
