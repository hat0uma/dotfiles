local M = {}

local VALID_PANE_DIRECTIONS = { "bottom", "right", "left", "top" }

--- @type integer | nil
local last_opened_pane = nil

---Activate wezterm pane
---@param id integer
local function activate_pane(id)
  local cmd = {
    "wezterm",
    "cli",
    "activate-pane",
    "--pane-id",
    tostring(id),
  }
  vim.system(cmd, { text = true }, function(obj)
    if obj.code ~= 0 then
      error("Failed to activate pane: " .. obj.stderr)
    end
  end)
end

---Kill wezterm pane
---@param id integer
local function kill_pane(id)
  local cmd = {
    "wezterm",
    "cli",
    "kill-pane",
    "--pane-id",
    tostring(id),
  }
  vim.system(cmd, { text = true })
end

---Open Image
---@param file string
---@param opts { cwd?:string, direction?: "bottom"| "right"| "left"| "top", keep_focus?:boolean}
function M.open(file, opts)
  -- options
  local direction = opts.direction or "bottom"
  local cwd = opts.cwd or assert(vim.uv.cwd())
  local keep_focus = opts.keep_focus or true
  if not vim.tbl_contains(VALID_PANE_DIRECTIONS, direction) then
    error(string.format("invalid direction for open image: %s", direction))
  end

  -- get current pane
  local current_pane = assert(tonumber(vim.env.WEZTERM_PANE), "Failed to get $WEZTERM_PANE")

  -- kill last pane
  if last_opened_pane then
    kill_pane(last_opened_pane)
    last_opened_pane = nil
  end

  -- open new pane and show image.
  local cmd = {
    "wezterm",
    "cli",
    "split-pane",
    "--cwd",
    cwd,
    "--" .. direction,
    "wezterm",
    "imgcat",
    "--hold",
    file,
  }

  vim.system(cmd, { text = true }, function(obj)
    if obj.code ~= 0 then
      error("Failed to open image: " .. obj.stderr)
    end

    -- save pane id
    last_opened_pane = tonumber(obj.stdout)

    -- restore focus
    if keep_focus then
      activate_pane(current_pane)
    end
  end)
end

return M
