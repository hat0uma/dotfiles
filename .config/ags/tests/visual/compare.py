#!/usr/bin/env python3
"""Compare widget snapshots against baselines.

    compare.py <baseline-dir> <current-dir> <report-dir> [--max-ratio R] [--tolerance T]

For every PNG in <current-dir> that has a baseline, writes
<report-dir>/<name>.side.png (baseline | current | diff) and prints the ratio of
changed pixels.  Exits 1 if any target exceeds --max-ratio or is missing a
baseline / changed size.  Requires Pillow.
"""
import argparse
import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw

HIGHLIGHT = (230, 30, 90, 255)


def pad(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    canvas = Image.new("RGBA", size, (0, 0, 0, 0))
    canvas.paste(image, (0, 0))
    return canvas


def flatten(image: Image.Image) -> Image.Image:
    # Popovers are rendered with a transparent margin; compare over white.
    background = Image.new("RGBA", image.size, (255, 255, 255, 255))
    return Image.alpha_composite(background, image).convert("RGB")


def compare(baseline: Path, current: Path, report: Path, tolerance: int):
    a = Image.open(baseline).convert("RGBA")
    b = Image.open(current).convert("RGBA")
    size = (max(a.width, b.width), max(a.height, b.height))
    fa, fb = flatten(pad(a, size)), flatten(pad(b, size))

    diff = ImageChops.difference(fa, fb).convert("L")
    mask = diff.point(lambda v: 255 if v > tolerance else 0)
    changed = mask.histogram()[255]
    ratio = changed / (size[0] * size[1])

    overlay = fb.copy().convert("RGBA")
    overlay = Image.blend(overlay, Image.new("RGBA", size, (255, 255, 255, 255)), 0.6)
    overlay.paste(Image.new("RGBA", size, HIGHLIGHT), (0, 0), mask)

    gap, label_h = 16, 28
    side = Image.new("RGB", (size[0] * 3 + gap * 2, size[1] + label_h), (255, 255, 255))
    draw = ImageDraw.Draw(side)
    for index, (title, image) in enumerate([("baseline", fa), ("current", fb), ("diff", overlay.convert("RGB"))]):
        x = index * (size[0] + gap)
        side.paste(image, (x, label_h))
        draw.text((x + 4, 6), title, fill=(70, 66, 97))
    report.mkdir(parents=True, exist_ok=True)
    side.save(report / f"{current.stem}.side.png")
    return ratio, a.size != b.size, mask.getbbox()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("baseline", type=Path)
    parser.add_argument("current", type=Path)
    parser.add_argument("report", type=Path)
    parser.add_argument("--max-ratio", type=float, default=0.002,
                        help="allowed fraction of changed pixels (default 0.002)")
    parser.add_argument("--tolerance", type=int, default=24,
                        help="per-pixel luminance difference ignored as noise (default 24)")
    args = parser.parse_args()

    failed = False
    for current in sorted(args.current.glob("*.png")):
        baseline = args.baseline / current.name
        if not baseline.exists():
            print(f"NEW   {current.stem}: no baseline")
            failed = True
            continue
        ratio, resized, bbox = compare(baseline, current, args.report, args.tolerance)
        bad = ratio > args.max_ratio or resized
        failed |= bad
        note = " (size changed)" if resized else ""
        where = f" bbox={bbox}" if bbox else ""
        print(f"{'FAIL' if bad else 'ok  '}  {current.stem}: {ratio:.4%} changed{note}{where}")
    print(f"report: {args.report}")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
