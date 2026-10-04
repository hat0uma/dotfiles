#!/usr/bin/env -S ags run

import { createBinding, For, This } from "ags";
import app from "ags/gtk4/app";
import AstalHyprland from "gi://AstalHyprland";
import AstalNotifd from "gi://AstalNotifd";
import style from "./styles";
import Bar, { snapshotTarget, toggleNotifications, toggleStatus } from "./widgets/Bar";
import NotificationPopups from "./widgets/NotificationPopups";
import PowerMenu, {
  closePowerMenu,
  togglePowerMenu,
} from "./widgets/PowerMenu";
import ScreenshotMenu, {
  closeScreenshotMenu,
  toggleScreenshotMenu,
} from "./widgets/ScreenshotMenu";

import { readFile } from "ags/file";
import { freezeClock, VISUAL_TEST_APP } from "./lib/clock";
import { setHolidayData } from "./lib/holidays";
import { initIcons } from "./ws-icons/src/icon";
import { updateNumbers } from "./workspaces/numbers";

const hyprland = AstalHyprland.get_default();

// Claim org.freedesktop.Notifications before anything opens a popover that
// would otherwise trigger this lazily.
AstalNotifd.get_default();

app.start({
  css: style,
  icons: `${SRC}/ws-icons/dist/icons`,
  gtkTheme: "Adwaita",

  requestHandler(argv, response) {
    switch (argv[0]) {
      case "workspace-numbers":
        response(updateNumbers(argv.slice(1)) ? "ok" : "usage: workspace-numbers <left|right> <down|up> [order]");
        break;
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
      case "toggle-screenshot":
        toggleScreenshotMenu(hyprland.focusedMonitor?.name);
        response("ok");
        break;
      case "close-screenshot":
        closeScreenshotMenu();
        response("ok");
        break;
      case "visual-freeze": {
        // visual-freeze <unix-seconds> | visual-freeze off
        const seconds = Number(argv[1]);
        freezeClock(argv[1] === "off" || !Number.isFinite(seconds) ? null : seconds);
        response("ok");
        break;
      }
      case "visual-clear": {
        // Dismiss fixture notifications left by tests/visual/capture.sh.
        const fixtures = AstalNotifd.get_default()
          .get_notifications()
          .filter((item) => item.appName === VISUAL_TEST_APP);
        fixtures.forEach((item) => item.dismiss());
        response(`dismissed ${fixtures.length}`);
        break;
      }
      case "snapshot":
      case "snapshot-tree": {
        // snapshot <target> <out.png> [connector]
        const [, target, path, connector] = argv;
        if (!target || (argv[0] === "snapshot" && !path)) {
          response("usage: snapshot <target> <out.png> [connector] | snapshot-tree <target> - [connector]");
          break;
        }
        snapshotTarget(target, path, connector, argv[0] === "snapshot" ? "png" : "tree")
          .then((result) => response(result))
          .catch((error) => response(`error: ${error}`));
        break;
      }
      default:
        response(`unknown request: ${argv.join(" ")}`);
    }
  },

  main() {
    initIcons(`${SRC}/ws-icons/dist`);
    try {
      setHolidayData(readFile(`${SRC}/data/syukujitsu.csv`));
    } catch (error) {
      console.error("holidays: failed to read data/syukujitsu.csv", error);
    }
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
            <ScreenshotMenu gdkmonitor={monitor} />
          </This>
        )}
      </For>
    );
  },
});
