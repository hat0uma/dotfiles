import theme from "./theme.css";
import base from "./base.css";
import bar from "./bar.css";
import workspaces from "./workspaces.css";
import bar_widgets from "./bar-widgets.css";
import popover from "./popover.css";
import quick_settings from "./quick-settings.css";
import power_menu from "./power-menu.css";
import screenshot_menu from "./screenshot-menu.css";
import network from "./network.css";
import notifications from "./notifications.css";
import toasts from "./toasts.css";

// Preserve cascade order and bundle CSS without runtime file imports.
export default [
  theme,
  base,
  bar,
  workspaces,
  bar_widgets,
  popover,
  quick_settings,
  power_menu,
  screenshot_menu,
  network,
  notifications,
  toasts,
].join("");
