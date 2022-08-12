local wezterm = require "wezterm"

local function get_shell()
  if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    return { os.getenv "UserProfile" .. "/dotfiles/win/nvim_terminal.cmd" }
  else
    return { os.getenv "HOME" .. "/dotfiles/scripts/nvim_terminal.sh" }
  end
end
return {
  use_ime = true,
  enable_tab_bar = false,
  -- exit_behavior = "Hold",
  -- xim_im_name = "fcitx",
  font = wezterm.font "Sarasa Term J Nerd Font",
  harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
  default_prog = get_shell(),
  color_scheme = "Afterglow",
}
