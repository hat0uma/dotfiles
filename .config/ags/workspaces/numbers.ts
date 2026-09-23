const held = { left: false, right: false };
const latest = { left: -1, right: -1 };
const listeners = new Set<(visible: boolean) => void>();

export function updateNumbers(args: string[]): boolean {
  const [side, action, order] = args;
  if (args.length < 2 || args.length > 3 ||
      (side !== "left" && side !== "right") ||
      (action !== "down" && action !== "up")) return false;
  const stamp = order === undefined ? undefined : Number(order);
  if (stamp !== undefined && (!Number.isFinite(stamp) || stamp < 0)) return false;
  // Separate ags processes can arrive out of order during a quick tap.
  if (stamp !== undefined && stamp <= latest[side]) return true;
  if (stamp !== undefined) latest[side] = stamp;
  const before = held.left || held.right;
  held[side] = action === "down";
  const visible = held.left || held.right;
  if (visible !== before) listeners.forEach(notify => notify(visible));
  return true;
}

export function subscribeNumbers(notify: (visible: boolean) => void) {
  listeners.add(notify);
  notify(held.left || held.right);
  return () => { listeners.delete(notify); };
}
