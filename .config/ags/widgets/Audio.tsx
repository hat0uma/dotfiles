import { type Accessor, createBinding, createComputed, For } from "ags";
import { execAsync } from "ags/process";
import AstalWp from "gi://AstalWp";
import Gtk from "gi://Gtk?version=4.0";
import PageHead, { EmptyRow, SectionLabel } from "./PageHead";

function endpointName(endpoint: AstalWp.Endpoint) {
  return endpoint.description || endpoint.name || "不明なデバイス";
}

function EndpointRow({ endpoint, fallbackIcon }: { endpoint: AstalWp.Endpoint; fallbackIcon: string }) {
  const isDefault = createBinding(endpoint, "isDefault");

  return (
    <button
      cssClasses={isDefault((on) => ["ap", on ? "current" : ""].filter(Boolean))}
      onClicked={() => {
        if (!endpoint.isDefault) endpoint.set_is_default(true);
      }}
    >
      <box spacing={12}>
        <image iconName={fallbackIcon} />
        <label
          cssClasses={["ap-name"]}
          hexpand
          xalign={0}
          ellipsize={3}
          maxWidthChars={1}
          tooltipText={endpointName(endpoint)}
          label={createBinding(endpoint, "description")(() => endpointName(endpoint))}
        />
        <image cssClasses={["check"]} visible={isDefault} iconName="object-select-symbolic" />
      </box>
    </button>
  );
}

function EndpointList({
  endpoints,
  fallbackIcon,
  empty,
}: {
  endpoints: Accessor<AstalWp.Endpoint[]>;
  fallbackIcon: string;
  empty: string;
}) {
  return (
    <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
      <For each={endpoints}>{(endpoint) => <EndpointRow endpoint={endpoint} fallbackIcon={fallbackIcon} />}</For>
      <box visible={createComputed(() => endpoints().length === 0)}>
        <EmptyRow label={empty} />
      </box>
    </box>
  );
}

export function AudioPage({ onBack }: { onBack: () => void }) {
  const audio = AstalWp.get_default()?.audio;
  if (!audio) {
    return (
      <box cssClasses={["sub-page"]} orientation={Gtk.Orientation.VERTICAL} spacing={10}>
        <PageHead title="サウンド" onBack={onBack} />
        <label cssClasses={["cap"]} label="WirePlumber に接続できません" />
      </box>
    );
  }

  const speakers = createBinding(audio, "speakers")((list) => list ?? []);
  const microphones = createBinding(audio, "microphones")((list) => list ?? []);

  return (
    <box cssClasses={["sub-page"]} orientation={Gtk.Orientation.VERTICAL} spacing={10}>
      <PageHead title="サウンド" onBack={onBack} />
      <scrolledwindow minContentHeight={320} maxContentHeight={320} propagateNaturalHeight={false}>
        <box cssClasses={["ap-list"]} orientation={Gtk.Orientation.VERTICAL} spacing={4}>
          <SectionLabel label="出力" />
          <EndpointList endpoints={speakers} fallbackIcon="audio-speakers-symbolic" empty="出力デバイスがありません" />
          <SectionLabel label="入力" />
          <EndpointList endpoints={microphones} fallbackIcon="audio-input-microphone-symbolic" empty="入力デバイスがありません" />
        </box>
      </scrolledwindow>
      <button cssClasses={["pop-foot"]} onClicked={() => execAsync(["pavucontrol"]).catch(console.error)}>
        <box spacing={8}>
          <image iconName="preferences-system-symbolic" />
          <label hexpand xalign={0} label="詳細設定" />
          <label cssClasses={["mono"]} label="pavucontrol" />
        </box>
      </button>
    </box>
  );
}

export function AudioRow({ onOpen }: { onOpen: () => void }) {
  const speaker = AstalWp.get_default()?.defaultSpeaker;
  const subtitle = speaker
    ? createBinding(speaker, "description")(() => endpointName(speaker))
    : "デバイスなし";

  return (
    <box cssClasses={["conn-row"]} spacing={10}>
      <button cssClasses={["conn-row-main"]} hexpand onClicked={onOpen}>
        <box spacing={12}>
          <image iconName="audio-speakers-symbolic" />
          <box orientation={Gtk.Orientation.VERTICAL} hexpand valign={Gtk.Align.CENTER}>
            <label cssClasses={["conn-name"]} xalign={0} label="サウンド出力" />
            <label cssClasses={["conn-sub"]} xalign={0} ellipsize={3} maxWidthChars={1} hexpand label={subtitle} />
          </box>
          <image cssClasses={["chev"]} iconName="go-next-symbolic" />
        </box>
      </button>
    </box>
  );
}
