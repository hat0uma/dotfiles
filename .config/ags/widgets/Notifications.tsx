import { createBinding, createComputed, createState, For, With } from "ags";
import AstalNotifd from "gi://AstalNotifd";
import Gtk from "gi://Gtk?version=4.0";

function timeAgo(unixSeconds: number): string {
  const diff = Math.max(0, Math.floor(Date.now() / 1000) - unixSeconds);
  if (diff < 60) return "たった今";
  if (diff < 3600) return `${Math.floor(diff / 60)} 分前`;
  if (diff < 86400) return `${Math.floor(diff / 3600)} 時間前`;
  return `${Math.floor(diff / 86400)} 日前`;
}

type CalendarDay = {
  day: number;
  currentMonth: boolean;
  today: boolean;
  marked: boolean;
  weekday: number;
};

function dateKey(date: Date) {
  return `${date.getFullYear()}-${date.getMonth()}-${date.getDate()}`;
}

function Calendar({ notifications }: { notifications: () => AstalNotifd.Notification[] }) {
  const now = new Date();
  const [month, setMonth] = createState({ year: now.getFullYear(), month: now.getMonth() });
  const weeks = createComputed(() => {
    const shown = month();
    const first = new Date(shown.year, shown.month, 1);
    const start = new Date(shown.year, shown.month, 1 - first.getDay());
    const marked = new Set(notifications().map((item) => dateKey(new Date(item.time * 1000))));
    const days = Array.from({ length: 42 }, (_, index): CalendarDay => {
      const date = new Date(start.getFullYear(), start.getMonth(), start.getDate() + index);
      return {
        day: date.getDate(),
        currentMonth: date.getMonth() === shown.month,
        today: date.toDateString() === now.toDateString(),
        marked: marked.has(dateKey(date)),
        weekday: index % 7,
      };
    });
    return Array.from({ length: 6 }, (_, row) => days.slice(row * 7, row * 7 + 7));
  });

  const moveMonth = (offset: number) => setMonth((current) => {
    const date = new Date(current.year, current.month + offset, 1);
    return { year: date.getFullYear(), month: date.getMonth() };
  });

  return (
    <box cssClasses={["calendar"]} orientation={Gtk.Orientation.VERTICAL}>
      <box cssClasses={["cal-head"]} spacing={6}>
        <label
          cssClasses={["cal-month"]}
          hexpand
          xalign={0}
          label={month((shown) => `${shown.year}年 ${shown.month + 1}月`)}
        />
        <button cssClasses={["cal-nav"]} onClicked={() => moveMonth(-1)}>
          <image iconName="go-previous-symbolic" />
        </button>
        <button cssClasses={["cal-nav"]} onClicked={() => moveMonth(1)}>
          <image iconName="go-next-symbolic" />
        </button>
      </box>
      <box cssClasses={["cal-weekdays"]} homogeneous>
        {Array.from("日月火水木金土").map((label, index) => (
          <label
            cssClasses={["cal-weekday", index === 0 ? "sun" : index === 6 ? "sat" : ""].filter(Boolean)}
            label={label}
          />
        ))}
      </box>
      <box cssClasses={["cal-grid"]} orientation={Gtk.Orientation.VERTICAL} spacing={1}>
        <For each={weeks}>
          {(week) => (
            <box homogeneous>
              {week.map((cell) => (
                <box cssClasses={["cal-day-slot"]} halign={Gtk.Align.CENTER}>
                  <label
                    cssClasses={[
                      "cal-day",
                      cell.weekday === 0 ? "sun" : cell.weekday === 6 ? "sat" : "",
                      cell.currentMonth ? "" : "out",
                      cell.today ? "today" : "",
                      cell.marked ? "mark" : "",
                    ].filter(Boolean)}
                    label={`${cell.day}`}
                  />
                </box>
              ))}
            </box>
          )}
        </For>
      </box>
    </box>
  );
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
        <label label="·" />
        <label label={timeAgo(notification.time)} />
        <box hexpand />
        <button cssClasses={["note-close"]} onClicked={() => notification.dismiss()}>
          <image iconName="window-close-symbolic" />
        </button>
      </box>
      <label cssClasses={["note-sum"]} xalign={0} wrap label={notification.summary} />
      {notification.body && <label cssClasses={["note-body"]} xalign={0} wrap label={notification.body} />}
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
  const view = createComputed(() => ({ count: count(), dnd: dnd() }));

  return (
    <box cssClasses={["notif-center"]} orientation={Gtk.Orientation.VERTICAL}>
      <Calendar notifications={notifications} />
      <box cssClasses={["divider"]} />
      <box cssClasses={["nc-head"]} spacing={8}>
        <label cssClasses={["nc-title"]} label="通知" />
        <With value={count}>{(n) => n > 0 && <label cssClasses={["nc-count"]} label={`${n}`} />}</With>
        <box hexpand />
        <button
          cssClasses={dnd((on) => ["nc-tool", on ? "on" : ""].filter(Boolean))}
          tooltipText="通知を一時停止"
          onClicked={() => notifd.set_dont_disturb(!notifd.dontDisturb)}
        >
          <image iconName={dnd((on) => on ? "notifications-disabled-symbolic" : "preferences-system-notifications-symbolic")} />
        </button>
        <button
          cssClasses={["nc-tool"]}
          sensitive={count((n) => n > 0)}
          tooltipText="すべて消去"
          onClicked={() => notifd.get_notifications().forEach((item) => item.dismiss())}
        >
          <image iconName="user-trash-symbolic" />
        </button>
      </box>
      <scrolledwindow vexpand maxContentHeight={360} propagateNaturalHeight>
        <With value={view}>
          {(state) => state.dnd || state.count === 0 ? (
            <box cssClasses={["empty"]} orientation={Gtk.Orientation.VERTICAL} spacing={8}>
              <image iconName={state.dnd ? "notifications-disabled-symbolic" : "preferences-system-notifications-symbolic"} pixelSize={26} />
              <label label={state.dnd ? "おやすみモード中" : "通知はありません"} />
              {state.dnd && <label cssClasses={["empty-sub"]} label="通知は溜めておき、解除したときにここに並ぶ" />}
            </box>
          ) : (
            <box cssClasses={["nc-list"]} orientation={Gtk.Orientation.VERTICAL} spacing={6}>
              <For each={notifications}>{(notification) => <NotificationRow notification={notification} />}</For>
            </box>
          )}
        </With>
      </scrolledwindow>
    </box>
  );
}
