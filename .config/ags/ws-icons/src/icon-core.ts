// ウィンドウ → アイコン名の解決 (GJS / Node どちらでも動く純粋ロジック)
// 入力は tools/icons.py build が作る dist/resolver.json

export type ResolverJson = {
  version: 1
  fallback: string
  titleBrands: string | null
  separators: string
  rules: { class?: string; title?: string; site?: string; icon: string }[]
  brandAliases: Record<string, string> // 小文字の class / サイト名 → 正規化したブランド名
  brands: Record<string, string>       // 正規化したブランド名 → アイコン名
}

// Hyprland のクライアント (hyprctl clients -j / AstalHyprland.Client) の必要な部分
export type WindowInfo = {
  class: string
  title: string
  initialClass?: string
  initialTitle?: string
}

export type Explanation = { icon: string; by: string }

type Rule = { cls?: RegExp; title?: RegExp; site?: RegExp; icon: string; index: number }

const IGNORE = new Set(["io", "com", "org", "net", "dev", "app", "desktop", "github", "gitlab", "gnome", "kde"])
const SUFFIX = /(-desktop|-browser|-app|-stable|-bin|-beta|-nightly|-developer-edition)$/
const MEMO_LIMIT = 1000

const norm = (s: string) => s.toLowerCase().replace(/[^a-z0-9]/g, "")

export function createResolver(json: ResolverJson) {
  if (json.version !== 1) throw new Error(`resolver.json の version ${json.version} には対応していません`)

  const compile = (s?: string) => (s ? new RegExp(s, "i") : undefined)
  const rules: Rule[] = json.rules.map((r, index) => ({
    cls: compile(r.class), title: compile(r.title), site: compile(r.site), icon: r.icon, index,
  }))
  const withTitle = rules.filter(r => r.title || r.site)
  const classOnly = rules.filter(r => !r.title && !r.site)
  const titleBrands = compile(json.titleBrands ?? undefined)
  const sep = new RegExp(json.separators)
  const aliases = new Map(Object.entries(json.brandAliases))
  const brands = new Map(Object.entries(json.brands))

  const memo = new Map<string, Explanation>()
  const classBrandMemo = new Map<string, Explanation | null>()

  const segments = (title: string) =>
    title.split(sep).map(p => p.trim().replace(/^\(\d+\)\s*/, "")).filter(Boolean)

  const brandOf = (raw: string): string | undefined => {
    const a = aliases.get(raw.toLowerCase())
    if (a) return brands.get(a)
    const k = norm(raw)
    return k.length >= 2 ? brands.get(k) : undefined
  }

  const matches = (r: Rule, cls: string, title: string, segs: () => string[]) =>
    (!r.cls || r.cls.test(cls)) &&
    (!r.title || r.title.test(title)) &&
    (!r.site || segs().some(p => r.site!.test(p)))

  // class からブランドを探す (firefox, zen-browser, org.telegram.desktop, steam_app_730 ...)
  function classBrand(cls: string): Explanation | null {
    if (classBrandMemo.has(cls)) return classBrandMemo.get(cls)!
    const cands = [cls, cls.replace(SUFFIX, ""), cls.replace(/_app_\d+$/, "")]
    const segs = cls.split(".")
    if (segs.length > 1)
      for (const s of segs.slice(-2).reverse())
        if (!IGNORE.has(s)) cands.push(s, s.replace(SUFFIX, ""))
    const head = (segs.at(-1) ?? cls).split(/[-_]/)[0]
    if (!IGNORE.has(head)) cands.push(head)

    let hit: Explanation | null = null
    for (const c of cands) {
      const icon = brandOf(c)
      if (icon) { hit = { icon, by: `class brand (${c})` }; break }
    }
    classBrandMemo.set(cls, hit)
    return hit
  }

  // 評価順:
  // 1. title / site 条件を持つルール  2. title からのブランド (titleBrands の class のみ)
  // 3. class だけのルール              4. class からのブランド  5. fallback
  function explainUncached(cls: string, title: string): Explanation {
    let cache: string[] | null = null
    const segs = () => (cache ??= segments(title))

    for (const r of withTitle)
      if (matches(r, cls, title, segs)) return { icon: r.icon, by: `rules[${r.index}]` }

    if (titleBrands?.test(cls)) {
      // 末尾はブラウザ自身の名前 ("— Zen Browser") なので、自分と同じブランドは飛ばす
      const self = classBrand(cls)?.icon
      for (const s of [...segs()].reverse()) {
        if (s.split(/\s+/).length > 3) continue
        const icon = brandOf(s)
        if (icon && icon !== self) return { icon, by: `title brand (${s})` }
      }
    }

    for (const r of classOnly)
      if (matches(r, cls, title, segs)) return { icon: r.icon, by: `rules[${r.index}]` }

    return classBrand(cls) ?? { icon: json.fallback, by: "fallback" }
  }

  function explain(win: WindowInfo): Explanation {
    const cls = (win.class || win.initialClass || "").toLowerCase()
    const title = win.title || win.initialTitle || ""
    const key = `${cls}\n${title}`
    const hit = memo.get(key)
    if (hit) return hit
    if (memo.size >= MEMO_LIMIT) memo.clear()
    const e = explainUncached(cls, title)
    memo.set(key, e)
    return e
  }

  return {
    // GTK のアイコン名 (Gtk.Image の iconName にそのまま渡す)
    iconFor: (win: WindowInfo) => explain(win).icon,
    // どのルールで決まったか (デバッグ用)
    explain,
  }
}
