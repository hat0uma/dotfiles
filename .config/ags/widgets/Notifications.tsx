import { createBinding, createComputed, For, With } from "ags";
import AstalNotifd from "gi://AstalNotifd";
import Gtk from "gi://Gtk?version=4.0";

function timeAgo(unixSeconds: number): string {
  const diff = Math.max(0, Math.floor(Date.now() / 1000) - unixSeconds);
  if (diff < 60) return "たった今";
  if (diff < 3600) return `${Math.floor(diff / 60)} 分前`;
  if (diff < 86400) return `${Math.floor(diff / 3600)} 時間前`;
  return `${Math.floor(diff / 86400)} 日前`;
}

function NotificationRow({ notification }: { notification: AstalNotifd.Notification }) {
  const urgent = notification.urgency === AstalNotifd.Urgency.CRITICAL;

  return (
    <box
      cssClasses={["note", urgent ? "urgent" : ""].filter(Boolean)}
      orientation={Gtk.Orientation.VERTICAL}
      spacing={3}
    >
      <box cssClasses={["note-meta"]} spacing={6}>
        <label cssClasses={["note-app"]} label={notification.appName || "通知"} />
        <label label={timeAgo(notification.time)} />
        <box hexpand />
        <button cssClasses={["note-close"]} onClicked={() => notification.dismiss()}>
          <image iconName="window-close-symbolic" />
        </button>
      </box>
      <label cssClasses={["note-sum"]} xalign={0} wrap label={notification.summary} />
      {notification.body && (
        <label cssClasses={["note-body"]} xalign={0} wrap label={notification.body} />
      )}
      {notification.actions.length > 0 && (
        <box cssClasses={["note-actions"]} spacing={6}>
          {notification.actions.map((action) => (
            <button cssClasses={["note-act"]} onClicked={() => action.invoke()}>
              <label label={action.label} />
            </button>
          ))}
        </box>
      )}
    </box>
  );
}

export default function NotificationCenter() {
  const notifd = AstalNotifd.get_default();
  const notifications = createBinding(notifd, "notifications");
  const dnd = createBinding(notifd, "dontDisturb");
  const count = createComputed(() => notifications().length);

  return (
    <box cssClasses={["notif-center"]} orientation={Gtk.Orientation.VERTICAL}>
      <Gtk.Calendar cssClasses={["calendar"]} />

      <box cssClasses={["divider"]} />

      <box cssClasses={["nc-head"]} spacing={8}>
        <label cssClasses={["nc-title"]} label="通知" />
        <With value={count}>
          {(n) => n > 0 && <label cssClasses={["nc-count"]} label={`${n}`} />}
        </With>
        <box hexpand />
        <button
          cssClasses={dnd((on) => ["nc-tool", on ? "on" : ""].filter(Boolean))}
          tooltipText="通知を一時停止"
          onClicked={() => notifd.set_dont_disturb(!notifd.dontDisturb)}
        >
          <image
            iconName={dnd((on) =>
              on ? "notifications-disabled-symbolic" : "preferences-system-notifications-symbolic"
            )}
          />
        </button>
        <button
          cssClasses={["nc-tool"]}
          tooltipText="すべて消去"
          onClicked={() => notifd.get_notifications().forEach((n) => n.dismiss())}
        >
          <image iconName="user-trash-symbolic" />
        </button>
      </box>

      <scrolledwindow vexpand maxContentHeight={360} propagateNaturalHeight>
        <With value={count}>
          {(n) =>
            n === 0 ? (
              <box cssClasses={["empty"]} orientation={Gtk.Orientation.VERTICAL} spacing={6}>
                <image iconName="notifications-disabled-symbolic" pixelSize={26} />
                <label label="通知はありません" />
              </box>
            ) : (
              <box cssClasses={["nc-list"]} orientation={Gtk.Orientation.VERTICAL} spacing={6}>
                <For each={notifications}>
                  {(notification) => <NotificationRow notification={notification} />}
                </For>
              </box>
            )
          }
        </With>
      </scrolledwindow>
    </box>
  );
}
