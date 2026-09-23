// AGS (GJS) 用の入口
// dist/icons を AGS のアイコン検索パスに追加したうえで使う (README 参照)
import GLib from "gi://GLib"
import { createResolver, type ResolverJson, type WindowInfo, type Explanation } from "./icon-core"

let resolver: ReturnType<typeof createResolver> | null = null

// 起動時に一度呼ぶ。distDir は tools/icons.py build の出力先 (dist/)
export function initIcons(distDir: string) {
  const path = GLib.build_filenamev([distDir, "resolver.json"])
  const [ok, bytes] = GLib.file_get_contents(path)
  if (!ok) throw new Error(`${path} を読めません。tools/icons.py build を実行してください`)
  resolver = createResolver(JSON.parse(new TextDecoder().decode(bytes)) as ResolverJson)
}

function get() {
  if (!resolver) throw new Error("initIcons() が呼ばれていません")
  return resolver
}

// ウィンドウのアイコン名 (Gtk.Image の iconName に渡す)
export const iconFor = (win: WindowInfo): string => get().iconFor(win)

// どのルールで決まったか (デバッグ用)
export const explainIcon = (win: WindowInfo): Explanation => get().explain(win)
