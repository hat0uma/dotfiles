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

function M.install(opts)
  require "nvim-treesitter"
  local ok, orgmode = pcall(require, "orgmode")
  if ok then
    orgmode.setup_ts_grammar()
    table.insert(parser, "org")
  end

  local _opts = vim.tbl_extend("keep", opts or {}, { force = false, sync = false })
  local parsers_text = table.concat(parser, " ")

  local sync = _opts.sync and "Sync" or ""
  local force = _opts.force and "!" or ""
  vim.cmd(string.format("TSInstall%s%s %s", sync, force, parsers_text))
end

return M
