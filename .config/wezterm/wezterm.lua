local wezterm = require "wezterm"

local shell
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  shell = { "powershell", "-NoLogo" }
else
  shell = { "zsh", "-l" }
end

return {
  font = wezterm.font "Sarasa Term J Nerd Font",
  default_prog = shell,
}
