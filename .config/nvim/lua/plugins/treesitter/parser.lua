local M = {}
local parser = {
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
}

function M.install(opts)
  require "nvim-treesitter"

  local _opts = vim.tbl_extend("keep", opts or {}, { force = false, sync = false })
  local parsers_text = table.concat(parser, " ")

  local sync = _opts.sync and "Sync" or ""
  local force = _opts.force and "!" or ""
  vim.cmd(string.format("TSInstall%s%s %s", sync, force, parsers_text))
end

return M
