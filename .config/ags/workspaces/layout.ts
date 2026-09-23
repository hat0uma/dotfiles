import type { WindowInfo } from "../ws-icons/src/icon-core.ts";

export const HEIGHT = 30;
export const PAD = 4;
export interface Monitor {
  width: number; height: number; scale: number; transform: number;
  x: number; y: number;
  reservedLeft: number; reservedTop: number; reservedRight: number; reservedBottom: number;
}
export interface Client extends WindowInfo {
  address: string; workspace: { id: number }; mapped: boolean; hidden: boolean;
  x: number; y: number; width: number; height: number;
  floating: boolean; fullscreen: number; focusHistoryId: number;
}
export interface Pane { x: number; y: number; w: number; h: number; icon: string | null }

export function paneIconSize(w: number, h: number) {
  const size = Math.min(14, w - 2, h);
  return size >= 8 ? size : 0;
}

export function logicalSize(mon: Monitor) {
  const rotated = mon.transform % 2 === 1;
  return {
    width: (rotated ? mon.height : mon.width) / mon.scale,
    height: (rotated ? mon.width : mon.height) / mon.scale,
  };
}
export function minimapWidth(mon: Monitor) {
  const size = logicalSize(mon);
  return Math.round(HEIGHT * size.width / size.height);
}
const recent = (a: Client, b: Client) =>
  a.focusHistoryId - b.focusHistoryId || a.address.localeCompare(b.address);

export function layoutPanes(clients: Client[], mon: Monitor, wsId: number, iconFor: (client: WindowInfo) => string): Pane[] {
  const size = logicalSize(mon);
  const uw = size.width - mon.reservedLeft - mon.reservedRight;
  const uh = size.height - mon.reservedTop - mon.reservedBottom;
  const ox = mon.x + mon.reservedLeft, oy = mon.y + mon.reservedTop;
  const iw = minimapWidth(mon) - PAD * 2, ih = HEIGHT - PAD * 2;
  let wins = clients.filter(c => c.workspace.id === wsId && c.mapped && !c.hidden).sort(recent);
  const fullscreen = wins.find(c => c.fullscreen !== 0);
  const tiled = wins.filter(c => !c.floating);
  const full = Boolean(fullscreen) || (!tiled.length && wins.length > 0);
  wins = fullscreen ? [fullscreen] : tiled.length ? tiled : wins.slice(0, 1);
  const clamp = (v: number) => Math.min(1, Math.max(0, v));
  return wins.sort((a, b) => recent(b, a)).map(c => {
    let x0 = 0, y0 = 0, x1 = iw, y1 = ih;
    if (!full) {
      x0 = Math.round(clamp((c.x - ox) / uw) * iw);
      y0 = Math.round(clamp((c.y - oy) / uh) * ih);
      x1 = Math.round(clamp((c.x + c.width - ox) / uw) * iw);
      y1 = Math.round(clamp((c.y + c.height - oy) / uh) * ih);
      if (x0 > 0) x0++;
      if (y0 > 0) y0++;
      if (x1 < iw) x1--;
      if (y1 < ih) y1--;
    }
    const w = Math.min(iw, Math.max(3, x1 - x0));
    const h = Math.min(ih, Math.max(3, y1 - y0));
    return {
      x: Math.max(0, Math.min(x0, iw - w)), y: Math.max(0, Math.min(y0, ih - h)), w, h,
      icon: paneIconSize(w, h) ? iconFor(c) : null,
    };
  });
}

export function tooltip(clients: Client[], wsId: number, number: number) {
  const wins = clients.filter(c => c.workspace.id === wsId && c.mapped).sort(recent);
  if (!wins.length) return `${number}（空）`;
  return [String(number), ...wins.map(c => {
    const title = Array.from(c.title.replace(/[\r\n]+/g, " "));
    return `${c.class} — ${title.length > 40 ? title.slice(0, 39).join("") + "…" : title.join("")}`;
  })].join("\n");
}
