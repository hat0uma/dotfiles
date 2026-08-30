#!/usr/bin/env -S ags run

import { createBinding, For, This } from "ags";
import app from "ags/gtk4/app";
import AstalHyprland from "gi://AstalHyprland";
import style from "./style.css";
import Bar from "./widgets/Bar";
import PowerMenu, {
  closePowerMenu,
  togglePowerMenu,
} from "./widgets/PowerMenu";

const hyprland = AstalHyprland.get_default();

app.start({
  css: style,
  gtkTheme: "Adwaita",

  requestHandler(argv, response) {
    switch (argv[0]) {
      case "toggle-power":
        togglePowerMenu(hyprland.focusedMonitor?.name);
        response("ok");
        break;
      case "close-power":
        closePowerMenu();
        response("ok");
        break;
      default:
        response(`unknown request: ${argv.join(" ")}`);
    }
  },

  main() {
    const monitors = createBinding(app, "monitors");

    return (
      <For each={monitors}>
        {(monitor) => (
          <This this={app}>
            <Bar gdkmonitor={monitor} />
            <PowerMenu gdkmonitor={monitor} />
          </This>
        )}
      </For>
    );
  },
});
