#!/usr/bin/env -S ags run

import { createBinding, For, This } from "ags";
import app from "ags/gtk4/app";
import AstalHyprland from "gi://AstalHyprland";
import AstalNotifd from "gi://AstalNotifd";
import style from "./style.css";
import Bar, { toggleNotifications, toggleStatus } from "./widgets/Bar";
import NotificationPopups from "./widgets/NotificationPopups";
import PowerMenu, {
  closePowerMenu,
  togglePowerMenu,
} from "./widgets/PowerMenu";

const hyprland = AstalHyprland.get_default();

// Claim org.freedesktop.Notifications before anything opens a popover that
// would otherwise trigger this lazily.
AstalNotifd.get_default();

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
      case "toggle-notifications":
        toggleNotifications(hyprland.focusedMonitor?.name);
        response("ok");
        break;
      case "toggle-status":
        toggleStatus(hyprland.focusedMonitor?.name);
        response("ok");
        break;
      case "clear-notifications":
        AstalNotifd.get_default().get_notifications().forEach((item) => item.dismiss());
        response("ok");
        break;
      default:
        response(`unknown request: ${argv.join(" ")}`);
    }
  },

  main() {
    const monitors = createBinding(app, "monitors");

    // Mounted once, independent of the per-monitor bar/power-menu tree below.
    const notifications = <NotificationPopups />;
    void notifications;

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
