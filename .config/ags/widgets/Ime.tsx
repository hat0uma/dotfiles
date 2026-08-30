import { createBinding, createComputed, With } from "ags";
import AstalTray from "gi://AstalTray";
import Gio from "gi://Gio";
import Gtk from "gi://Gtk?version=4.0";

let sessionBus: Gio.DBusConnection | null = null;

function getSessionBus() {
  if (!sessionBus) sessionBus = Gio.bus_get_sync(Gio.BusType.SESSION, null);
  return sessionBus;
}

function fcitxToggle() {
  getSessionBus()
    .call(
      "org.fcitx.Fcitx5",
      "/controller",
      "org.fcitx.Fcitx.Controller1",
      "Toggle",
      null,
      null,
      Gio.DBusCallFlags.NONE,
      -1,
      null,
    )
    .catch((error: unknown) => console.error(error));
}

function imeState(iconName: string) {
  const name = iconName.toLowerCase();
  if (name.includes("hiragana")) return { glyph: "あ", jp: true };
  if (name.includes("katakana")) return { glyph: "ア", jp: true };
  if (name.includes("fullwidth")) return { glyph: "Ａ", jp: true };
  return { glyph: "A", jp: false };
}

function setupMenu(button: Gtk.Button, item: AstalTray.TrayItem) {
  const menu = Gtk.PopoverMenu.new_from_model(item.menuModel);
  menu.set_parent(button);
  menu.insert_action_group("dbusmenu", item.actionGroup);
  item.connect("notify::action-group", () =>
    menu.insert_action_group("dbusmenu", item.actionGroup),
  );
  item.connect("notify::menu-model", () => menu.set_menu_model(item.menuModel));

  const gesture = new Gtk.GestureClick();
  gesture.set_button(3);
  gesture.connect("pressed", () => menu.popup());
  button.add_controller(gesture);
}

function ImeChip({ item }: { item: AstalTray.TrayItem }) {
  const state = createBinding(item, "iconName")((name) => imeState(name));

  return (
    <button
      cssClasses={state((s) => ["ime", s.jp ? "jp" : "en"])}
      tooltipText={createBinding(item, "tooltipText")}
      onClicked={fcitxToggle}
      $={(self) => setupMenu(self, item)}
    >
      <label label={state((s) => s.glyph)} />
    </button>
  );
}

export default function Ime() {
  const tray = AstalTray.get_default();
  const items = createBinding(tray, "items");
  const fcitx = createComputed(() => items().find((item) => item.id === "Fcitx") ?? null);

  // Keep a stable widget in the bar. Returning a dynamic widget directly from
  // With makes a late-arriving SNI item get appended at the end of the parent.
  return (
    <box cssClasses={["ime-slot"]}>
      <With value={fcitx}>{(item) => item && <ImeChip item={item} />}</With>
    </box>
  );
}
