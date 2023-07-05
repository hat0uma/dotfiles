local M = {}

local function calc_ab(cb, hash1, hash2)
  vim.system(
    {
      "git",
      "rev-list",
      "--left-right",
      "--count",
      string.format("%s...%s", hash1, hash2),
    },
    { text = true },
    vim.schedule_wrap(function(obj)
      local ahead, behind = obj.stdout:match "(%d+)\t(%d+)"
      cb { ahead = ahead, behind = behind }
    end)
  )
end

-- Function to read file
local function read_file(path)
  local fd = assert(vim.loop.fs_open(path, "r", 438)) -- 438 corresponds to octal 0666
  local stat = assert(vim.loop.fs_fstat(fd))
  local data = assert(vim.loop.fs_read(fd, stat.size, 0))
  assert(vim.loop.fs_close(fd))

  return data
end

local function get_head()
  -- Read current branch
  local head_path = ".git/HEAD"
  local head_file = read_file(head_path)
  local current_branch = head_file:match "ref: refs/heads/(%w+)"

  -- Get commit hash of current branch
  local head = read_file(".git/refs/heads/" .. current_branch):match "[^\r\n]+"
  return { branch = current_branch, commit = head }
end

-- Parse git config file
local function parse_git_config(data)
  local config = {}
  local section, sub_section

  for line in data:gmatch "[^\r\n]+" do
    -- Match subsection
    local new_sub_section = { line:match '^%[([^%]]+) "([^"]+)"%]$' }
    if #new_sub_section == 2 then
      section, sub_section = unpack(new_sub_section)
      config[section] = config[section] or {}
      config[section][sub_section] = config[section][sub_section] or {}
      goto continue
    end

    -- Match section
    local new_section = line:match "^%[([^%]]+)%]$"
    if new_section then
      section = new_section
      sub_section = nil
      config[section] = config[section] or {}
      goto continue
    end

    -- Match key-value pairs
    local key, value = line:match "^%s*([^=%s]+)%s*=%s*(.-)%s*$"
    if key and value and section then
      if sub_section then
        config[section][sub_section][key] = value
      else
        config[section][key] = value
      end
      goto continue
    end

    ::continue::
  end
  return config
end

local git_config = read_file ".git/config"
local parsed_config = parse_git_config(git_config)

local head = get_head()
local remote_name = parsed_config.branch[head.branch].remote
local remote_branch = parsed_config.branch[head.branch].merge:match "refs/heads/(%w+)"
local remote_hash = read_file(".git/refs/remotes/" .. remote_name .. "/" .. remote_branch):match "[^\r\n]+"

-- vim.print(parsed_config)
vim.print("current branch : " .. head.branch)
vim.print("current hash : " .. head.commit)
vim.print("remote branch : " .. remote_branch)
vim.print("remote hash : " .. remote_hash)
calc_ab(function(ab)
  vim.print(string.format("ahead: %s,behind: %s", ab.ahead, ab.behind))
end, head.commit, remote_hash)

return M
