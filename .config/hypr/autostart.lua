hl.on("hyprland.start", function()
  hl.exec_cmd(
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=hyprland XDG_SESSION_TYPE=wayland"
  )
  hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

  hl.exec_cmd("swaybg -m fill -i ~/.local/share/wallpapers/home.png")

  hl.exec_cmd("foot --server")
  hl.exec_cmd("pcmanfm-qt -d")
  hl.exec_cmd("fcitx5")
  hl.exec_cmd("ags run")
  hl.exec_cmd("1password --silent")
  -- hl.exec_cmd("gtk-launch FFPWA-$(firefoxpwa profile list | sed -n 's/\\- Discord: .* (\\(.*\\))/\\1/p')")
  -- hl.exec_cmd("_dots_hyprland_fix")
end)
