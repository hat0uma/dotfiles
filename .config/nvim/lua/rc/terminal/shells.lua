--- @param opts table
local function shell(opts)
  opts.env.PARENT_NVIM_ADDRESS = vim.v.servername
  return opts
end

return {
  pwsh = shell {
    cmd = string.format("pwsh -NoLogo -NoProfile -NoExit -File %s ", vim.fn.expand "~/dotfiles/win/profile.ps1"),
    env = {
      PATH = string.format("%s;%s", vim.fn.expand "~/.config/nvim/lua/rc/terminal/bin.pwsh", vim.env.PATH),
    },
  },
  zsh = shell {
    cmd = "zsh -l",
    env = {
      PATH = string.format("%s:%s", vim.fn.expand "~/.config/nvim/lua/rc/terminal/bin", vim.env.PATH),
    },
  },
}
