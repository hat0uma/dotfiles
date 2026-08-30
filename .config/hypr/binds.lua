local mod = "SUPER"

hl.bind(mod .. " + Escape", hl.dsp.exit())

hl.bind(mod .. " + Return", hl.dsp.exec_cmd("footclient"))
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mod .. " + F2", hl.dsp.exec_cmd("google-chrome-stable"))
hl.bind(mod .. " + D", hl.dsp.exec_cmd("wofi --show drun"))
hl.bind(mod .. " + SHIFT + D", hl.dsp.exec_cmd("wofi --show run"))
hl.bind(mod .. " + O", hl.dsp.exec_cmd("1password --quick-access"))
hl.bind(mod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mod .. " + E", hl.dsp.exec_cmd("pcmanfm-qt"))

hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + V", hl.dsp.window.float())
hl.bind(mod .. " + S", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + G", hl.dsp.group.toggle())
hl.bind(mod .. " + C", hl.dsp.window.center())
hl.bind(mod .. " + SHIFT + N", hl.dsp.group.next())
hl.bind(mod .. " + SHIFT + P", hl.dsp.group.prev())

hl.bind("Print", hl.dsp.exec_cmd("screenshot --activewindow"))
hl.bind(mod .. " + Print", hl.dsp.exec_cmd("screenshot --fullscreen"))
hl.bind(mod .. " + SHIFT + Print", hl.dsp.exec_cmd("screenshot --regionedit"))

hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))

hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

hl.bind(mod .. " + RIGHT", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + LEFT", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + UP", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
hl.bind(mod .. " + DOWN", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })

for i = 1, 9 do
  hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + 0", hl.dsp.workspace.toggle_special(""))
hl.bind(mod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mod .. " + SHIFT + E", function()
  hl.exec_cmd("ags request toggle-power")
  hl.dispatch(hl.dsp.submap("powermenu"))
end)

hl.define_submap("powermenu", function()
  hl.bind("SHIFT + S", hl.dsp.exec_cmd("systemctl poweroff"), { repeating = true })
  hl.bind("SHIFT + R", hl.dsp.exec_cmd("systemctl reboot"), { repeating = true })
  hl.bind("SHIFT + Z", hl.dsp.exec_cmd("systemctl suspend"), { repeating = true })
  hl.bind("SHIFT + L", hl.dsp.exec_cmd("swaylock -f -c 000000"), { repeating = true })
  hl.bind("SHIFT + Q", hl.dsp.exit(), { repeating = true })
  hl.bind("escape", function()
    hl.exec_cmd("ags request close-power")
    hl.dispatch(hl.dsp.submap("reset"))
  end)
end)
