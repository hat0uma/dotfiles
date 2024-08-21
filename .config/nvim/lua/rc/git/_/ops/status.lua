local util = require("rc.git.util")
local M = {}

--- @class GitStatus
--- @field branch GitBranchStatus
--- @field ordinary_changed GitOrdinaryChangedEntry
--- @field renamed_or_copied GitRenamedOrCopiedEntry
--- @field unmerged GitUnmergedEntry
--- @field untracked GitUntrackedEntry
--- @field ignored GitIgnoredEntry
M.GitStatus = {}

---@return GitStatus
function M.GitStatus.new()
  local obj = {}
  obj.branch = {
    oid = "",
    head = "",
    upstream = "",
    ab = { a = 0, b = 0 },
  }
  obj.ordinary_changed = {}
  obj.renamed_or_copied = {}
  obj.unmerged = {}
  obj.untracked = {}
  obj.ignored = {}
  return obj
end

--- @class GitBranchStatus
--- @field oid string
--- @field head string
--- @field upstream string
--- @field ab {a:number,b:number}

--- @class GitOrdinaryChangedEntry
--- @field status{ staged:string, unstaged:string }
--- @field submodule string
--- @field filemodes {head:string,index:string,worktree:string}
--- @field object_names {head:string,index:string}
--- @field path string

--- @class GitRenamedOrCopiedEntry
--- @field status{ staged:string, unstaged:string }
--- @field submodule string
--- @field filemodes {head:string,index:string,worktree:string}
--- @field object_names {head:string,index:string}
--- @field score string
--- @field path string
--- @field orig_path string

--- @class GitUnmergedEntry
--- @field status{ staged:string, unstaged:string }
--- @field submodule string
--- @field filemodes {stage1:string,stage2:string,stage3:string,worktree:string}
--- @field object_names {stage1:string,stage2:string,stage3:string}
--- @field path string

--- @class GitUntrackedEntry
--- @field path string

--- @class GitIgnoredEntry
--- @field path string

local BRANCH_COMPONENTS = {
  oid = {
    n = 1,
    pattern = "# branch%.oid (%S+)",
    transform = unpack,
  },
  head = {
    n = 1,
    pattern = "# branch%.head (%S+)",
    transform = unpack,
  },
  upstream = {
    n = 1,
    pattern = "# branch%.upstream (%S+)",
    transform = unpack,
  },
  ab = {
    n = 2,
    pattern = "# branch%.ab %+(%d) %-(%d)",
    transform = function(matches)
      local a, b = unpack(matches)
      return { a = tonumber(a) or 0, b = tonumber(b) or 0 }
    end,
  },
}

local function escape_entry(pattern)
  -- git status --help
  return pattern
    :gsub("<XY>", "[%%.MADRCU][%%.MADRCU]")
    :gsub("<sub>", "[NS][CMU%%.]+")
    :gsub("<mH>", "%%d+")
    :gsub("<mI>", "%%d+")
    :gsub("<mW>", "%%d+")
    :gsub("<hH>", "%%S+")
    :gsub("<hI>", "%%S+")
    :gsub("<X>", "[RC]")
    :gsub("<score>", "%%w+")
    :gsub("<path>", "%%S+")
    :gsub("<sep>", "%%t")
    :gsub("<origPath>", "%%S+")
    -- unmerged entries
    :gsub("<m1>", "%%d+")
    :gsub("<m2>", "%%d+")
    :gsub("<m3>", "%%d+")
    :gsub("<h1>", "%%S+")
    :gsub("<h2>", "%%S+")
    :gsub("<h3>", "%%S+")
end

local ENTRY_PATTERNS = {
  ordinary_changed = {
    n = 8,
    pattern = escape_entry("1 (<XY>) (<sub>) (<mH>) (<mI>) (<mW>) (<hH>) (<hI>) (<path>)"),
    transform = function(matches)
      return {
        status = {
          staged = string.sub(matches[1], 1, 1),
          unstaged = string.sub(matches[1], 2, 2),
        },
        submodule = matches[2],
        filemodes = {
          head = matches[3],
          index = matches[4],
          worktree = matches[5],
        },
        object_names = {
          head = matches[6],
          index = matches[7],
        },
        path = matches[8],
      }
    end,
  },
  renamed_or_copied = {
    n = 10,
    pattern = escape_entry("2 (<XY>) (<sub>) (<mH>) (<mI>) (<mW>) (<hH>) (<hI>) (<X><score>) (<path>)<sep>(<origPath>)"),
    transform = function(matches)
      return {
        status = {
          staged = string.sub(matches[1], 1, 1),
          unstaged = string.sub(matches[1], 2, 2),
        },
        submodule = matches[2],
        filemodes = {
          head = matches[3],
          index = matches[4],
          worktree = matches[5],
        },
        object_names = {
          head = matches[6],
          index = matches[7],
        },
        score = matches[8],
        path = matches[9],
        orig_path = matches[10],
      }
    end,
  },
  unmerged = {
    n = 10,
    pattern = escape_entry("u (<XY>) (<sub>) (<m1>) (<m2>) (<m3>) (<mW>) (<h1>) (<h2>) (<h3>) (<path>)"),
    transform = function(matches)
      return {
        status = {
          staged = string.sub(matches[1], 1, 1),
          unstaged = string.sub(matches[1], 2, 2),
        },
        submodule = matches[2],
        filemodes = {
          stage1 = matches[3],
          stage2 = matches[4],
          stage3 = matches[5],
          worktree = matches[6],
        },
        object_names = {
          stage1 = matches[7],
          stage2 = matches[8],
          stage3 = matches[9],
        },
        path = matches[10],
      }
    end,
  },
  untracked = {
    n = 1,
    pattern = escape_entry("? (<path>)"),
    transform = function(matches)
      return { path = unpack(matches) }
    end,
  },
  ignored = {
    n = 1,
    pattern = escape_entry("! (<path>)"),
    transform = function(matches)
      return { path = unpack(matches) }
    end,
  },
}

--- parse git status --porcelain=v2
---@param out string[]
---@return GitStatus|nil
function M.parse_status_v2(out)
  if #out == 0 then
    return nil
  end

  local status = M.GitStatus.new()
  local branch_lines, entry_lines = util.list_partition(function(line)
    return vim.startswith(line, "#")
  end, out)

  for _, line in ipairs(branch_lines) do
    for name, component in pairs(BRANCH_COMPONENTS) do
      local matches = { line:match(component.pattern) }
      if #matches == component.n then
        status.branch[name] = component.transform(matches)
        break
      end
    end
  end

  for _, line in ipairs(entry_lines) do
    for name, p in pairs(ENTRY_PATTERNS) do
      local matches = { line:match(p.pattern) }
      if #matches == p.n then
        table.insert(status[name], p.transform(matches))
        break
      end
    end
  end

  return status
end

--- get status
---@param opts SystemOpts
---@param on_exit fun( sts:GitStatus? )
---@return SystemObj
function M.run(opts, on_exit)
  opts = vim.tbl_extend("keep", opts or {}, { env = {}, cwd = vim.loop.cwd(), text = true })
  ---@type fun(obj:SystemCompleted)
  local _on_exit = function(obj)
    if obj.code ~= 0 then
      on_exit(nil)
    else
      on_exit(M.parse_status_v2(vim.split(obj.stdout, "\n")))
    end
  end
  return vim.system({ "git", "status", "--porcelain=v2", "--branch" }, opts, _on_exit)
end

return M
