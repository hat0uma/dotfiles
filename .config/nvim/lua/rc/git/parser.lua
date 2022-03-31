local parser = {}

local STATUS_CHARS = " MADRCU?"
local STATUS_PATTERNS = ("([STATUS_CHARS])([STATUS_CHARS]) (.*)"):gsub("STATUS_CHARS", STATUS_CHARS)

--- parse git status -- porcelain v1
---@param out string[]
-- @return table
function parser.parse_status_v1(out)
  if #out == 0 then
    return {}
  end

  -- parse branch info
  local branch_line = out[1]
  local branch, remote_branch = string.match(branch_line, "## (.*)%.%.%.(%S*)")
  local ahead_num = string.match(branch_line, "%[ahead (%d)%]") or 0
  local behind_num = string.match(branch_line, "%[behind (%d)%]") or 0

  local staged_changes = {}
  local unstaged_changes = {}
  local untracked_changes = {}

  -- parse changes
  for i = 2, #out, 1 do
    local staged, unstaged, file = string.match(out[i], STATUS_PATTERNS)
    if staged == "?" or unstaged == "?" then
      table.insert(untracked_changes, file)
    else
      if staged ~= " " then
        table.insert(staged_changes, { file = file, status = staged })
      end
      if unstaged ~= " " then
        table.insert(unstaged_changes, { file = file, status = unstaged })
      end
    end
  end
  local is_dirty = #staged_changes ~= 0 or #unstaged_changes ~= 0 or #untracked_changes ~= 0
  return {
    branch = branch or "",
    remote_branch = remote_branch or "",
    ahead_num = ahead_num,
    behind_num = behind_num,
    staged_changes = staged_changes,
    unstaged_changes = unstaged_changes,
    untracked_changes = untracked_changes,
    is_dirty = is_dirty,
  }
end

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
    transform = function(tbl)
      local a, b = unpack(tbl)
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
    pattern = escape_entry "1 (<XY>) (<sub>) (<mH>) (<mI>) (<mW>) (<hH>) (<hI>) (<path>)",
    transform = function(matches)
      --- @class OrdinaryChangedEntry
      local entry = {
        status = {
          staged = matches[1]:sub(1, 1),
          unstaged = matches[1]:sub(2, 2),
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
    pattern = escape_entry "2 (<XY>) (<sub>) (<mH>) (<mI>) (<mW>) (<hH>) (<hI>) (<X><score>) (<path>)<sep>(<origPath>)",
    transform = function(matches)
      --- @class RenamedOrCopiedEntry
      local entry = {
        status = {
          staged = matches[1]:sub(1, 1),
          unstaged = matches[1]:sub(2, 2),
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
      return entry
    end,
  },
  unmerged = {
    n = 10,
    pattern = escape_entry "u (<XY>) (<sub>) (<m1>) (<m2>) (<m3>) (<mW>) (<h1>) (<h2>) (<h3>) (<path>)",
    transform = function(matches)
      --- @class UnmergedEntry
      local entry = {
        status = {
          staged = matches[1]:sub(1, 1),
          unstaged = matches[1]:sub(2, 2),
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
      return entry
    end,
  },
  untracked = {
    n = 1,
    pattern = escape_entry "? (<path>)",
    transform = function(matches)
      --- @class UntrackedEntry
      local entry = { path = unpack(matches) }
      return entry
    end,
  },
  ignored = {
    n = 1,
    pattern = escape_entry "! (<path>)",
    transform = function(matches)
      --- @class ignoredEntry
      local entry = { path = unpack(matches) }
      return entry
    end,
  },
}

local list_partition = function(predicate, tbl)
  local part1 = {}
  local part2 = {}
  for _, value in ipairs(tbl) do
    if predicate(value) then
      table.insert(part1, value)
    else
      table.insert(part2, value)
    end
  end
  return part1, part2
end

function parser.parse_status_v2(out)
  if #out == 0 then
    return {}
  end

  local branch_lines, entry_lines = list_partition(function(line)
    return vim.startswith(line, "#")
  end, out)

  local branch = {}
  for _, line in ipairs(branch_lines) do
    for name, component in pairs(BRANCH_COMPONENTS) do
      local matches = { line:match(component.pattern) }
      if #matches == component.n then
        branch[name] = component.transform(matches)
        break
      end
    end
  end

  local function safe_insert_item(tbl, key, value)
    if not tbl[key] then
      tbl[key] = {}
    end
    table.insert(tbl[key], value)
  end
  local entries = {}
  for _, line in ipairs(entry_lines) do
    for name, p in pairs(ENTRY_PATTERNS) do
      local matches = { line:match(p.pattern) }
      if #matches == p.n then
        safe_insert_item(entries, name, p.transform(matches))
        break
      end
    end
  end

  print(vim.inspect(branch_lines))
  print(vim.inspect(entry_lines))
  print(vim.inspect(branch))
  print(vim.inspect(entries))
end

return parser
