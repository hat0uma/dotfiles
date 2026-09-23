#!/usr/bin/env python3
"""ワークスペース・ミニマップ用アイコンのセットアップ (Font Awesome Free)

python tools/icons.py build                  # dist/ を作る (セットアップ時に一度、設定を変えたら再実行)
python tools/icons.py search chat            # 名前と検索語で探す (--brands でブランドも)
python tools/icons.py search chat --preview  # 一覧を /tmp/icon-search.svg に書き出す
python tools/icons.py pin 7.3.1              # 取得元のバージョンと SHA-256 を更新する
"""

import argparse, difflib, hashlib, json, os, re, sys, urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONFIG = ROOT / "icons.config.json"
DIST = ROOT / "dist"
CACHE = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "ws-icons"
URL = "https://raw.githubusercontent.com/FortAwesome/Font-Awesome/{ref}/metadata/icons.json"
SEPARATORS = r"\s+(?:[-—–|·•]|/)\s+"
STYLES = ("solid", "regular", "brands")


# ---------------- 設定 ----------------


def read_config_text():
    return CONFIG.read_text(encoding="utf-8")


def load_config():
    text = "\n".join(
        l for l in read_config_text().splitlines() if not l.lstrip().startswith("//")
    )
    cfg = json.loads(text)
    vars_ = cfg.get("vars", {})

    def expand(s):
        if s is None:
            return None
        out = re.sub(r"\{([A-Z_]+)\}", lambda m: vars_[m.group(1)], s)
        try:
            re.compile(out, re.I)
        except re.error as e:
            sys.exit(f"正規表現の誤り: {s}\n  {e}")
        return out

    cfg["titleBrands"] = expand(cfg.get("titleBrands"))
    for r in cfg["rules"]:
        for k in ("class", "title", "site"):
            if k in r:
                r[k] = expand(r[k])
    return cfg


# ---------------- 取得 (セットアップ時のみ) ----------------


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def download(ref):
    print(f"  Font Awesome {ref} の icons.json を取得中...", file=sys.stderr)
    with urllib.request.urlopen(URL.format(ref=ref)) as r:
        return r.read()


def load_icons(cfg):
    """固定したバージョンの icons.json を返す。キャッシュを優先し、ハッシュが合わなければ止める"""
    ref, want = cfg["source"]["ref"], cfg["source"]["sha256"].lower()
    path = CACHE / f"fa-{want}.json"
    if path.exists():
        data = path.read_bytes()
    else:
        data = download(ref)
    got = sha256(data)
    if got != want:
        sys.exit(
            f"SHA-256 が一致しません (ref={ref})\n  期待: {want}\n  実際: {got}\n"
            f"意図した更新なら `python tools/icons.py pin {ref}` を実行してください"
        )
    if not path.exists():
        CACHE.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
    return json.loads(data)


# ---------------- 索引 ----------------


class Index:
    def __init__(self, raw):
        self.icons = {}  # 名前 -> {"label", "terms", "svg": {style: (w, h, path)}}
        self.alias = {}  # 旧名 -> 名前
        for name, i in raw.items():
            svg = {}
            for s in i.get("free", []):
                e = i.get("svg", {}).get(s)
                if e and isinstance(e.get("path"), str):
                    svg[s] = (e["width"], e["height"], e["path"])
            if not svg:
                continue
            terms = [str(t).lower() for t in i.get("search", {}).get("terms", [])]
            self.icons[name] = {
                "label": i.get("label", name),
                "terms": terms,
                "svg": svg,
            }
            for a in i.get("aliases", {}).get("names", []):
                self.alias.setdefault(a, name)

    def get(self, name):
        return self.icons.get(name) or self.icons.get(self.alias.get(name, ""))

    def real_name(self, name):
        return name if name in self.icons else self.alias.get(name)

    def ref(self, spec, prefer):
        """'名前' か 'スタイル:名前' を (style, name) にする。見つからなければ None"""
        style, _, name = spec.rpartition(":")
        icon = self.get(name)
        if not icon:
            return None
        name = self.real_name(name)
        if style:
            return (style, name) if style in icon["svg"] else None
        for s in (prefer, "solid", "regular", "brands"):
            if s in icon["svg"]:
                return (s, name)
        return None

    def brands(self):
        return [n for n, i in self.icons.items() if "brands" in i["svg"]]

    def search(self, query, brands=False, limit=40):
        words = [w.lower() for w in query.split()]
        hits = []
        for n, i in self.icons.items():
            is_brand = list(i["svg"]) == ["brands"]
            if is_brand and not brands:
                continue
            parts, terms = n.split("-"), i["terms"]
            score = 0
            for w in words:
                if n == w:
                    score += 100
                elif w in parts:
                    score += 50
                elif w in terms:
                    score += 40
                elif n.startswith(w):
                    score += 20
                elif w in n:
                    score += 15
                elif any(w in t for t in terms):
                    score += 10
                elif w in i["label"].lower():
                    score += 5
                else:
                    score = 0
                    break
            if score:
                hits.append((score + (0 if is_brand else 3), len(n), n))
        hits.sort(key=lambda h: (-h[0], h[1]))
        return [n for _, _, n in hits[:limit]]

    def suggest(self, spec):
        name = spec.rpartition(":")[2]
        close = difflib.get_close_matches(name, list(self.icons), n=3, cutoff=0.6)
        return list(
            dict.fromkeys(
                close + self.search(name.replace("-", " "), brands=True, limit=3)
            )
        )


def norm(s):
    return re.sub(r"[^a-z0-9]", "", s.lower())


def gtk_name(style, name):
    return f"fa-{style}-{name}-symbolic"


# ---------------- SVG ----------------


def build_svg(index, style, name, pad, ref):
    w, h, path = index.icons[name]["svg"][style]
    side = max(w, h) * (1 + pad * 2)
    x, y = (w - side) / 2, (h - side) / 2
    f = lambda n: f"{n:.2f}".rstrip("0").rstrip(".")
    # Font Awesome の配布 SVG と同じ形のクレジットを残す
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="{f(x)} {f(y)} {f(side)} {f(side)}">'
        f"<!--! Font Awesome Free {ref} by @fontawesome - https://fontawesome.com "
        f"License - https://fontawesome.com/license/free (Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT License) -->"
        f'<path fill="#bebebe" d="{path}"/></svg>'
    )


THIRD_PARTY_NOTICES = """# Third-Party Notices

## Font Awesome Free icons

The SVG files in `icons/` are derived from **Font Awesome Free {ref}**
by **Fonticons, Inc.** (https://fontawesome.com).

- Upstream project: https://github.com/FortAwesome/Font-Awesome/tree/{ref}
- Source data: https://github.com/FortAwesome/Font-Awesome/blob/{ref}/metadata/icons.json
- Upstream license notice: https://github.com/FortAwesome/Font-Awesome/blob/{ref}/LICENSE.txt
- Icon license: **Creative Commons Attribution 4.0 International (CC BY 4.0)**
  — https://creativecommons.org/licenses/by/4.0/
- Full license terms: https://creativecommons.org/licenses/by/4.0/legalcode

### Modifications

The selected icon paths are extracted from the upstream metadata and repackaged
as GTK symbolic SVG icons. The generated files use a monochrome fill, 16 × 16
intrinsic dimensions, and a square viewBox with configurable padding. Filenames
are adapted to GTK symbolic icon naming. The original path geometry is retained.
Each SVG includes a Font Awesome attribution and license comment.

### Redistribution

When redistributing these icons, retain their attribution and license notices,
provide a link to CC BY 4.0, and indicate any modifications. Include this notice
with the generated icons and preserve the embedded attribution comments.

### Trademarks

Brand icons are trademarks of their respective owners. They are used here to
identify the corresponding applications, products, or services. No affiliation
with or endorsement by Fonticons, Inc. or the trademark owners is implied.

### Scope

CC BY 4.0 applies to the Font Awesome icon artwork in this directory. Font
Awesome's references to SIL OFL 1.1 and MIT in the embedded comments describe
its upstream font and code licenses; this directory does not bundle font files
or the Font Awesome runtime. Those references do not license this project's
own source code or the rest of the dotfiles repository under MIT or SIL OFL.
"""


# ---------------- コマンド ----------------


def cmd_build(_args):
    cfg = load_config()
    index = Index(load_icons(cfg))
    ref, prefer, pad = (
        cfg["source"]["ref"],
        cfg.get("prefer", "solid"),
        cfg.get("pad", 0.06),
    )
    wanted, errors = {}, []

    def want(spec, where):
        r = index.ref(spec, prefer)
        if not r:
            hint = ", ".join(index.suggest(spec)) or "候補なし"
            errors.append(f"{where}: {spec} が見つかりません (もしかして: {hint})")
            return None
        wanted[r] = gtk_name(*r)
        return wanted[r]

    rules = []
    for i, r in enumerate(cfg["rules"]):
        g = want(r["icon"], f"rules[{i}]")
        rules.append(
            {k: r[k] for k in ("class", "title", "site") if k in r} | {"icon": g}
        )
    fallback = want(cfg["fallback"], "fallback")

    # ブランドは自動照合のため全部書き出す。短い名前を優先 (github > square-github)
    brands = {}
    for n in sorted(index.brands(), key=len):
        brands.setdefault(norm(n), gtk_name("brands", n))
        wanted[("brands", n)] = brands[norm(n)]
    for a, n in index.alias.items():
        if "brands" in index.icons[n]["svg"]:
            brands.setdefault(norm(a), gtk_name("brands", n))

    aliases = {}
    for k, v in cfg.get("brandAliases", {}).items():
        if norm(v) in brands:
            aliases[k.lower()] = norm(v)
        else:
            hint = (
                ", ".join(
                    n for n in index.suggest(v) if "brands" in index.icons[n]["svg"]
                )
                or "候補なし"
            )
            errors.append(
                f"brandAliases: {v} はブランドにありません (もしかして: {hint})"
            )

    if errors:
        sys.exit("\n".join(errors))

    out = DIST / "icons"
    out.mkdir(parents=True, exist_ok=True)
    keep, written = set(), 0
    for (style, name), g in wanted.items():
        p = out / f"{g}.svg"
        keep.add(p.name)
        svg = build_svg(index, style, name, pad, ref)
        if not p.exists() or p.read_text(encoding="utf-8") != svg:
            p.write_text(svg, encoding="utf-8")
            written += 1
    removed = 0
    for p in out.glob("*.svg"):
        if p.name not in keep:
            p.unlink()
            removed += 1

    resolver = {
        "version": 1,
        "fallback": fallback,
        "titleBrands": cfg.get("titleBrands"),
        "separators": SEPARATORS,
        "rules": rules,
        "brandAliases": aliases,
        "brands": brands,
    }
    (DIST / "resolver.json").write_text(
        json.dumps(resolver, ensure_ascii=False, separators=(",", ":"), indent=4),
        encoding="utf-8",
    )
    (DIST / "THIRD_PARTY_NOTICES.md").write_text(
        THIRD_PARTY_NOTICES.format(ref=ref), encoding="utf-8"
    )
    print(
        f"Font Awesome {ref}: アイコン {len(keep)} 個 (更新 {written}, 削除 {removed}) → {out}"
    )


def cmd_search(args):
    cfg = load_config()
    index = Index(load_icons(cfg))
    hits = index.search(" ".join(args.words), brands=args.brands, limit=args.limit)
    for n in hits:
        i = index.icons[n]
        print(f"{n:32} {','.join(i['svg']):22} {i['label']}")
    if not hits:
        print("見つかりませんでした", file=sys.stderr)
    if args.preview and hits:
        cell, cols = 104, 8
        rows = -(-len(hits) // cols)
        out = [
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{cols * cell}" height="{rows * cell}">'
            f'<rect width="100%" height="100%" fill="#f4efe8"/>'
        ]
        for k, n in enumerate(hits):
            style = next(
                s
                for s in (cfg.get("prefer", "solid"), "solid", "regular", "brands")
                if s in index.icons[n]["svg"]
            )
            w, h, path = index.icons[n]["svg"][style]
            side = max(w, h)
            x, y = (k % cols) * cell, (k // cols) * cell
            out.append(
                f'<svg x="{x + 34}" y="{y + 12}" width="36" height="36" viewBox="{(w - side) / 2} {(h - side) / 2} {side} {side}">'
                f'<path fill="#3f3b52" d="{path}"/></svg>'
            )
            out.append(
                f'<text x="{x + cell / 2}" y="{y + 68}" text-anchor="middle" font-family="monospace" font-size="10" fill="#6e6a7e">{n[:16]}</text>'
            )
            out.append(
                f'<text x="{x + cell / 2}" y="{y + 81}" text-anchor="middle" font-family="monospace" font-size="9" fill="#a19dac">{style}</text>'
            )
        out.append("</svg>")
        Path("/tmp/icon-search.svg").write_text("".join(out), encoding="utf-8")
        print("\npreview: /tmp/icon-search.svg", file=sys.stderr)


def cmd_pin(args):
    data = download(args.ref)
    json.loads(data)  # 壊れていないことだけ確認
    digest = sha256(data)
    CACHE.mkdir(parents=True, exist_ok=True)
    (CACHE / f"fa-{digest}.json").write_bytes(data)
    text = read_config_text()
    text = re.sub(r'("ref"\s*:\s*)"[^"]*"', rf'\g<1>"{args.ref}"', text, count=1)
    text = re.sub(r'("sha256"\s*:\s*)"[^"]*"', rf'\g<1>"{digest}"', text, count=1)
    CONFIG.write_text(text, encoding="utf-8")
    print(
        f"source を {args.ref} ({digest}) に更新しました。`python tools/icons.py build` で反映してください"
    )


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("build")
    s = sub.add_parser("search")
    s.add_argument("words", nargs="+")
    s.add_argument("--brands", action="store_true", help="ブランドアイコンも含める")
    s.add_argument("--limit", type=int, default=40)
    s.add_argument("--preview", action="store_true")
    p = sub.add_parser("pin")
    p.add_argument("ref", help="Font Awesome のタグかコミット (例: 7.3.1)")
    args = ap.parse_args()
    {"build": cmd_build, "search": cmd_search, "pin": cmd_pin}[args.cmd](args)


if __name__ == "__main__":
    main()
