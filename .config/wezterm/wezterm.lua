local wezterm = require "wezterm"

local shell
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  local profile_path = os.getenv "HOME" .. "/dotfiles/win/profile.ps1"
  shell = { "pwsh", "-NoLogo", "-NoProfile", "-NoExit", "-File", profile_path }
else
  shell = { "zsh", "-l" }
end

return {
  font = wezterm.font "Sarasa Term J Nerd Font",
  harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
  default_prog = shell,
}
