local M = {}
local parser = {
  "bash",
  "c",
  "c_sharp",
  "comment",
  "cpp",
  "dockerfile",
  "go",
  "html",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "ruby",
  "rust",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

function M.setup()
  local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
  parser_config.fsharp = {
    install_info = {
      url = "https://github.com/ionide/tree-sitter-fsharp",
      branch = "main",
      files = { "src/scanner.c", "src/parser.c" },
    },
    requires_generate_from_grammar = false,
    filetype = "fsharp",
  }
  local ok, orgmode = pcall(require, "orgmode")
  if ok then
    orgmode.setup_ts_grammar()
    table.insert(parser, "org")
  end
end

function M.install(opts)
  M.setup()
  local _opts = vim.tbl_extend("keep", opts or {}, { force = false, sync = false })
  local parsers_text = table.concat(parser, " ")

  local sync = _opts.sync and "Sync" or ""
  local force = _opts.force and "!" or ""
  vim.cmd(string.format("TSInstall%s%s %s", sync, force, parsers_text))
end

return M
