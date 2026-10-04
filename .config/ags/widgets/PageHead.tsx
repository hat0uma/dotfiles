// Header shared by the quick-settings sub pages (Wi-Fi, Bluetooth, Sound).
export default function PageHead({
  title,
  onBack,
  children,
}: {
  title: string;
  onBack: () => void;
  children?: JSX.Element | JSX.Element[];
}) {
  return (
    <box cssClasses={["pop-head"]} spacing={10}>
      <button cssClasses={["back"]} tooltipText="戻る" onClicked={onBack}>
        <image iconName="go-previous-symbolic" />
      </button>
      <label cssClasses={["pop-title"]} hexpand xalign={0} label={title} />
      {children}
    </box>
  );
}

export function SectionLabel({ label }: { label: string }) {
  return <label cssClasses={["section-label"]} xalign={0} label={label} />;
}

export function EmptyRow({ label }: { label: string }) {
  return <label cssClasses={["cap", "list-empty"]} xalign={0} label={label} />;
}
