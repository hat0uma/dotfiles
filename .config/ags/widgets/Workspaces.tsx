import { onCleanup } from "ags";
import AstalHyprland from "gi://AstalHyprland";
import Gtk from "gi://Gtk?version=4.0";
import { HEIGHT, PAD, layoutPanes, minimapWidth, tooltip } from "../workspaces/layout";
import { subscribe } from "../workspaces/store";

const hyprland = AstalHyprland.get_default();
const COUNT = 5;

export default function Workspaces({ connector }: { connector: string }) {
  const box = new Gtk.Box({ spacing: 8, cssClasses: ["workspaces"] });
  const slots = Array.from({ length: COUNT }, (_, index) => {
    const fixed = new Gtk.Fixed({ overflow: Gtk.Overflow.HIDDEN, hexpand: false, vexpand: false });
    const frame = new Gtk.Box({
      cssClasses: ["minimap", "mm-empty"], valign: Gtk.Align.CENTER, halign: Gtk.Align.CENTER,
      hexpand: false, vexpand: false,
      overflow: Gtk.Overflow.HIDDEN,
    });
    frame.append(fixed);
    const button = new Gtk.Button({
      cssClasses: ["ws-slot"], heightRequest: HEIGHT, child: frame, hexpand: false, vexpand: false,
    });
    const slot = { button, frame, fixed, id: 0, panesKey: "", stateKey: "", tooltip: "", width: 0 };
    button.connect("clicked", () => {
      if (slot.id > 0) hyprland.dispatch(`hl.dsp.focus({ workspace = ${slot.id} })`, "");
    });
    button.set_sensitive(false);
    button.set_tooltip_text(`${index + 1}（空）`);
    box.append(button);
    return slot;
  });

  const scroll = new Gtk.EventControllerScroll({
    flags: Gtk.EventControllerScrollFlags.VERTICAL | Gtk.EventControllerScrollFlags.DISCRETE,
  });
  scroll.connect("scroll", (_, _dx, dy) => {
    const monitor = hyprland.get_monitor_by_name(connector);
    if (!monitor || !dy) return true;
    const index = slots.findIndex(s => s.id === monitor.activeWorkspace?.id);
    if (index < 0) return true;
    const target = slots[index + (dy > 0 ? 1 : -1)];
    if (target?.id) hyprland.dispatch(`hl.dsp.focus({ workspace = ${target.id} })`, "");
    return true;
  });
  box.add_controller(scroll);

  const unsubscribe = subscribe(() => {
    const monitor = hyprland.get_monitor_by_name(connector);
    if (!monitor) return;
    const ownIds = hyprland.workspaces
      .filter(w => w.id > 0 && w.monitor?.name === connector).map(w => w.id);
    // The compositor's workspace rules remain the source of monitor/block assignment.
    if (hyprland.monitors.length > 1 && !ownIds.length) return;
    const base = hyprland.monitors.length > 1
      ? Math.floor((Math.min(...ownIds) - 1) / COUNT) * COUNT : 0;
    const clients = hyprland.clients;
    const width = minimapWidth(monitor);
    slots.forEach((slot, index) => {
      const id = base + index + 1;
      if (slot.id !== id) {
        slot.id = id;
        slot.button.set_sensitive(true);
      }
      const panes = layoutPanes(clients, monitor, id);
      const active = monitor.activeWorkspace?.id === id;
      const focused = hyprland.focusedMonitor?.name === connector;
      const empty = !panes.length;
      const stateKey = `${active}/${focused}/${empty}`;
      if (slot.stateKey !== stateKey || slot.width !== width) {
        slot.stateKey = stateKey;
        slot.width = width;
        slot.frame.set_css_classes([
          "minimap", ...(empty ? ["mm-empty"] : []), ...(active ? ["active"] : []),
          ...(focused ? ["focused-mon"] : []),
        ]);
        // Empty frames have no content; reserve the outer size directly so
        // fractional CSS borders cannot alter the slot's natural size.
        slot.frame.set_size_request(width, HEIGHT);
        slot.fixed.set_size_request(empty ? 0 : width - PAD * 2, empty ? 0 : HEIGHT - PAD * 2);
      }
      const panesKey = JSON.stringify(panes);
      if (slot.panesKey !== panesKey) {
        slot.panesKey = panesKey;
        let child = slot.fixed.get_first_child();
        while (child) {
          const next = child.get_next_sibling();
          slot.fixed.remove(child);
          child = next;
        }
        for (const pane of panes) {
          const widget = new Gtk.Box({ cssClasses: ["pane"], overflow: Gtk.Overflow.HIDDEN });
          widget.set_size_request(pane.w, pane.h);
          if (pane.icon) widget.append(new Gtk.Image({
            iconName: pane.icon, pixelSize: 12, hexpand: true, vexpand: true,
            halign: Gtk.Align.CENTER, valign: Gtk.Align.CENTER,
          }));
          slot.fixed.put(widget, pane.x, pane.y);
        }
      }
      const text = tooltip(clients, id, index + 1);
      if (slot.tooltip !== text) {
        slot.tooltip = text;
        slot.button.set_tooltip_text(text);
      }
    });
  });
  onCleanup(unsubscribe);
  return box;
}
