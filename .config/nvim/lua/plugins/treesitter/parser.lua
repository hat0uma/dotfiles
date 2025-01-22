local M = {}

local parsers = {
  "bash",
  "c",
  "c_sharp",
  "comment",
  "cpp",
  "dockerfile",
  "fsharp",
  "go",
  "html",
  "javascript",
  "jsdoc",
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

--- @type table<string, ParserInfo>
local default_parser_config

local function get_repo_name(lang)
  local parser = default_parser_config[lang]
  if not parser then
    return nil
  end

  local parts = vim.split(parser.install_info.url, "/")
  return parts[#parts]
end

---@param lang string
---@return LazyPluginSpec?
local function parser_to_lazy_package(lang)
  local parser = default_parser_config[lang]
  if not parser then
    return nil
  end

  --- @type LazyPluginSpec
  return {
    parser.install_info.url,
    build = function() ---@async
      local update_parser = require("nvim-treesitter.install").update({ with_sync = true })
      update_parser(lang)
    end,
    submodules = false,
  }
end

---@return LazyPluginSpec[]
function M.local_parser_packages()
  if not (pcall(require, "nvim-treesitter")) then
    return {}
  end

  M.setup()

  local parser_packages = {}
  local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
  local lazy_root = require("lazy.core.config").options.root

  for _, lang in pairs(parsers) do
    -- Add parsers from nvim-treesitter
    local spec = parser_to_lazy_package(lang)
    table.insert(parser_packages, spec)

    -- Modify parser url from remote repository to local.
    local repo_name = get_repo_name(lang)
    parser_config[lang].install_info.url = vim.fs.joinpath(lazy_root, repo_name)
  end

  return parser_packages
end

function M.setup()
  if default_parser_config then
    return
  end

  default_parser_config = vim.deepcopy(require("nvim-treesitter.parsers").get_parser_configs())
  vim.api.nvim_create_user_command("TSUpdateMyParsers", function()
    M.install()
  end, {})
end

function M.install(opts)
  opts = vim.tbl_extend("keep", opts or {}, { force = false, sync = false })

  M.setup()

  -- Update packages
  require("lazy").sync({
    plugins = vim.tbl_map(get_repo_name, parsers),
    wait = opts.sync,
  })

  -- local _opts = vim.tbl_extend("keep", opts or {}, { force = false, sync = false })
  -- local parsers_text = table.concat(parsers, " ")
  --
  -- local sync = _opts.sync and "Sync" or ""
  -- local force = _opts.force and "!" or ""
  -- vim.cmd(string.format("TSInstall%s%s %s", sync, force, parsers_text))
end

return M
