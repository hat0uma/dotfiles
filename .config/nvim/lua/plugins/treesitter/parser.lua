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
  "powershell",
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
  "gitcommit",
}

local function get_repo_name(lang)
  local parser = require("nvim-treesitter.parsers")[lang]
  if not parser then
    return nil
  end

  local parts = vim.split(parser.install_info.url, "/")
  return parts[#parts]
end

local function is_headless()
  return #vim.api.nvim_list_uis() == 0
end

--- @class rc.plugins.treesitter.ParserPackage: LazyPluginSpec
--- @field langs string[]

---@param lang string
---@return rc.plugins.treesitter.ParserPackage?
local function parser_to_lazy_package(lang)
  local parser = require("nvim-treesitter.parsers")[lang]
  if not parser then
    return nil
  end

  local rev = parser.install_info.revision
  local rev_is_commit_hash = #rev == 40

  local langs = { lang }
  return { --- @type rc.plugins.treesitter.ParserPackage
    parser.install_info.url,
    lazy = true,
    commit = rev_is_commit_hash and rev or nil,
    tag = rev_is_commit_hash and nil or rev,
    submodules = false,
    langs = langs,
    build = function(plugin)
      --- @type async.Task
      local task = require("nvim-treesitter.install").install(langs, { summary = true })
      local ok, err_or_ok = task:pwait(30 * 1000 * 60)
      if not ok then
        error(task:traceback(err_or_ok))
      end
    end,
  }
end

---@return LazyPluginSpec[]
function M.local_parser_packages()
  if not (pcall(require, "nvim-treesitter")) then
    return {}
  end

  local parser_packages = {} ---@type table<string, rc.plugins.treesitter.ParserPackage>
  for _, lang in pairs(parsers) do
    local parser = require("nvim-treesitter.parsers")[lang]
    if parser then
      if not parser_packages[parser.install_info.url] then
        parser_packages[parser.install_info.url] = parser_to_lazy_package(lang)
      else
        table.insert(parser_packages[parser.install_info.url].langs, lang)
      end
    end
  end

  return vim.tbl_values(parser_packages)
end

function M.setup()
  vim.api.nvim_create_user_command("TSUpdate", function()
    M.install({ update = true, sync = is_headless() })
  end, {})
  vim.api.nvim_create_user_command("TSBuild", function()
    M.install({ update = false, sync = is_headless() })
  end, {})

  vim.api.nvim_create_autocmd("User", {
    pattern = "TSUpdate",
    callback = function()
      for _, lang in pairs(parsers) do
        local parser_config = require("nvim-treesitter.parsers")
        local lazy_root = require("lazy.core.config").options.root

        -- Modify parser path from remote repository to local.
        local repo_name = get_repo_name(lang)
        parser_config[lang].install_info.path = vim.fs.joinpath(lazy_root, repo_name)
      end
    end,
    group = vim.api.nvim_create_augroup("rc.treesitter.parser", {}),
  })
end

--- Install parsers
---@param opts { update: boolean, sync: boolean }
function M.install(opts)
  opts = vim.tbl_extend("keep", opts or {}, { sync = false, update = false })

  local manager_opts = { --- @type ManagerOpts
    plugins = vim.tbl_map(get_repo_name, parsers),
    wait = opts.sync,
  }

  -- Update parsers
  -- Force build parsers
  if opts.update then
    require("lazy").update(manager_opts)
  end
  require("lazy").build(manager_opts)
end

return M
