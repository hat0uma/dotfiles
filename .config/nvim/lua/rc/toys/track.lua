local queries = {
  c = {
    definition = [[
((function_definition
  declarator: (function_declarator
    declarator: (identifier) @function.name (#eq? @function.name "%s"))))@function.definition
]],
    list = [[
((function_definition
  declarator: (function_declarator
    declarator: (identifier) @function.name)))
]],
  },
}

--- Extract function definition from specified buffer
---@param bufnr integer
---@param identifier string
---@return string?
local function extract_function_definition_from_buf(bufnr, identifier)
  local parser = assert(vim.treesitter.get_parser(bufnr))
  local lang = parser:lang()
  local tree = parser:parse()[1]
  local root = tree:root()
  local query = string.format(queries[lang].definition, identifier)

  local definition ---@type string?
  local query_obj = vim.treesitter.query.parse(lang, query)
  for id, node, metadata, match in query_obj:iter_captures(root, bufnr) do
    local capture_name = query_obj.captures[id]
    if capture_name == "function.definition" then
      definition = vim.treesitter.get_node_text(node, bufnr)
    end
  end

  return definition
end

--- Retrieve function definition in file of revision
---@param dir string
---@param rev string
---@param path string
---@param on_end fun(content?: string, err?: string)
local function show_file_at_rev(dir, rev, path, on_end)
  local cmd = {
    "git",
    "--no-pager",
    "show",
    "--textconv",
    string.format("%s:%s", rev, path),
  }
  vim.system(cmd, { cwd = dir }, function(obj)
    if not obj or obj.code ~= 0 then
      local err = string.format("git show failed with %d: %s", obj.code, obj.stderr)
      on_end(nil, err)
    else
      on_end(obj.stdout, nil)
    end
  end)
end

local M = {}

---@type integer?
M._temp_buf = nil

---
---@param dir string
---@param path string
---@param identifier string
---@param rev string
---@param on_end fun( definition: string|nil )
local function extract_function_definition_at_rev(dir, path, identifier, rev, on_end)
  local bufnr = M._temp_buf or vim.api.nvim_create_buf(false, true)
  M._temp_buf = bufnr

  show_file_at_rev(
    dir,
    rev,
    path,
    vim.schedule_wrap(function(data, err)
      if err and string.find(err, string.format("path '%s' exists on disk, but not in '%s'", path, rev), nil, true) then
        on_end(nil)
        return
      end

      if err then
        error(err)
      end

      local contents = vim.split(data, "\n")
      vim.api.nvim_buf_set_name(bufnr, string.format("%s:%s", rev, path))
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, contents)
      local ft = vim.filetype.match({ buf = bufnr })
      if not ft then
        vim.api.nvim_win_set_buf(0, bufnr)
        error("Failed to detect filetype for this buffer.")
      end

      vim.bo[bufnr].filetype = ft
      local def = extract_function_definition_from_buf(bufnr, identifier)
      on_end(def)
    end)
  )
end

---
---@param dir string
---@param path string
---@param identifier string
---@param rev1 string
---@param rev2 string
---@param diff_opts? vim.diff.Opts
---@return string diff, string rev1_def, string rev2_def
local function get_function_diff(dir, path, identifier, rev1, rev2, diff_opts)
  local bufnr = M._temp_buf or vim.api.nvim_create_buf(false, true)
  M._temp_buf = bufnr

  local rev1_def, rev2_def ---@type string?, string?
  extract_function_definition_at_rev(dir, path, identifier, rev1, function(def)
    rev1_def = (def or "") .. "\n"
  end)
  extract_function_definition_at_rev(dir, path, identifier, rev2, function(def)
    rev2_def = (def or "") .. "\n"
  end)

  local ok, kind = vim.wait(5000, function()
    return rev1_def ~= nil and rev2_def ~= nil
  end)

  if not ok then
    local msg = kind == -1 and "git show timeout." or "git show interrupted."
    error(msg)
  end

  assert(rev1_def)
  assert(rev2_def)
  local diff = assert(vim.diff(rev1_def, rev2_def, diff_opts))
  return diff, rev1_def, rev2_def ---@diagnostic disable-line
end

---@class rc.toys.Track.Commit
---@field hash string
---@field date string
---@field subject string
---@field files string[]

---@param commit rc.toys.Track.Commit
---@param diff string
local function show_diff(diff, commit)
  local bufnr = vim.api.nvim_create_buf(false, true)
  local lines = { string.format("%s\t%s\t%s", commit.hash, commit.date, commit.subject) }
  vim.list_extend(lines, vim.split(diff, "\n"))

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
  vim.bo[bufnr].filetype = "diff"
  vim.api.nvim_win_set_buf(0, bufnr)
end

---@param func string
---@param commit rc.toys.Track.Commit
---@param diff string
local function export_diff(func, diff, commit)
  local head = string.format("%s\t%s\t%s\n", commit.hash, commit.date, commit.subject)
  local path = string.format("%s_%s.diff", func, commit.hash)
  local fd = assert(vim.uv.fs_open(path, "w+", 438)) -- 666

  assert(vim.uv.fs_write(fd, head))
  assert(vim.uv.fs_write(fd, diff))
  assert(vim.uv.fs_close(fd))
end

---
---@param dir? string
---@return rc.toys.Track.Commit[]
function M.list_commits(dir)
  dir = dir or vim.uv.cwd()
  local cmd = {
    "git",
    "--no-pager",
    "log",
    "--pretty=format:%h%n%ad%n%s",
    "--date=format:%Y/%m/%d %H:%M:%S",
    "--name-only",
  }
  local result = vim.system(cmd, { cwd = dir }):wait()
  if result.code ~= 0 then
    error(result.stderr)
  end

  local commits = {} ---@type rc.toys.Track.Commit[]
  --- <hash>
  --- <date>
  --- <subject>
  --- file1
  --- file2
  --- ...
  ---
  --- <hash>
  --- <date>
  --- <subject>
  --- file1
  --- file2
  --- ...
  ---
  for _, lines in ipairs(vim.split(result.stdout, "\n\n")) do
    local l = vim.split(lines, "\n")
    local head = l[1]
    if not head or head == "" then
      break
    end

    table.insert(commits, {
      hash = l[1],
      date = l[2],
      subject = l[3],
      files = vim
        .iter(l)
        :skip(3)
        :map(function(item)
          return vim.fs.normalize(item)
        end)
        :totable(),
    })
  end
  return commits
end

--- Get latest diff
---@param dir string
---@param path string
---@param identifier string
---@return string? diff, rc.toys.Track.Commit?
function M.get_latest_diff(dir, path, identifier)
  local diff_opts = { ---@type vim.diff.Opts
    ignore_whitespace = true,
    result_type = "unified",
    ctxlen = 99999,
  }
  local commits = M.list_commits(dir)
  local newer = commits[1]
  for i = 2, #commits do
    local older = commits[i]
    if vim.tbl_contains(newer.files, vim.fs.normalize(path)) or i == #commits then
      local diff, _, older_def = get_function_diff(dir, path, identifier, older.hash, newer.hash, diff_opts)
      if diff and diff ~= "" then
        return diff, newer
      end

      -- first commit
      if i == #commits then
        ---@diagnostic disable-next-line: return-type-mismatch
        return vim.diff("", older_def, diff_opts), older
      end
    end
    newer = older
  end

  error(string.format("Unknown error dir:%s, path:%s, identifier:%s", dir, path, identifier))
end

function M.track_cursor_changes()
  local dir = assert(vim.uv.cwd())
  local path = assert(vim.fs.relpath(dir, vim.api.nvim_buf_get_name(0)))
  local identifier = vim.fn.expand("<cword>")
  local diff, commit = M.get_latest_diff(dir, path, identifier)
  if diff and commit then
    show_diff(diff, commit)
  end
end

--- list functions
---@param bufnr? integer
---@return string[]
function M.list_function_identifiers(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local parser = assert(vim.treesitter.get_parser(bufnr))
  local lang = parser:lang()
  local tree = parser:parse()[1]
  local root = tree:root()
  local query = queries[lang].list

  local identifiers = {} ---@type string[]
  local query_obj = vim.treesitter.query.parse(lang, query)
  for id, node, metadata, match in query_obj:iter_captures(root, bufnr) do
    local capture_name = query_obj.captures[id]
    if capture_name == "function.name" then
      table.insert(identifiers, vim.treesitter.get_node_text(node, bufnr))
    end
  end

  return identifiers
end

function M.export_function_history()
  local bufnr = vim.api.nvim_get_current_buf()
  local dir = assert(vim.uv.cwd())
  local path = assert(vim.fs.relpath(dir, vim.api.nvim_buf_get_name(0)))
  local functions = M.list_function_identifiers(bufnr)
  local data = {
    "File\tFunction name\tLatest Commit\tLatest Commit Date\tLatest Commit Subject",
  }
  for i, func in ipairs(functions) do
    print(string.format("processing %s %d/%d", func, i, #functions))
    local diff, commit = M.get_latest_diff(dir, path, func)
    if diff and commit then
      table.insert(data, string.format("%s\t%s\t%s\t%s\t%s", path, func, commit.hash, commit.date, commit.subject))
      export_diff(func, diff, commit)
    end
  end

  local result_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(result_buf, 0, -1, true, data)

  vim.cmd.split()
  vim.api.nvim_win_set_buf(0, result_buf)
end

return M
