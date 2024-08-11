--- Shell configurations.
--- @param opts rc.Shell
--- @return rc.Shell
local function shell(opts)
  opts.env.PARENT_NVIM_ADDRESS = vim.v.servername
  return opts
end

---@class rc.Shell
---@field cmd string
---@field env table<string, string>

return {
  ---@type rc.Shell
  pwsh = shell({
    cmd = "pwsh -NoLogo",
    env = {
      PATH = string.format("%s;%s", vim.fn.expand("~/.config/nvim/lua/rc/terminal/bin.pwsh"), vim.env.PATH),
    },
  }),
  ---@type rc.Shell
  zsh = shell({
    cmd = "zsh -l",
    env = {
      PATH = string.format("%s:%s", vim.fn.expand("~/.config/nvim/lua/rc/terminal/bin"), vim.env.PATH),
    },
  }),
}
