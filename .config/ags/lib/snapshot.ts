import GLib from "gi://GLib";
import Graphene from "gi://Graphene";
import Gtk from "gi://Gtk?version=4.0";

// Widget-level snapshots for visual regression tests (tests/visual).
// Rendering a widget through its own renderer keeps the image independent of
// the wallpaper and of whatever windows happen to sit behind the bar.

export function renderWidgetToPng(widget: Gtk.Widget, path: string, scale = 2) {
  const width = widget.get_width();
  const height = widget.get_height();
  if (width <= 0 || height <= 0) throw new Error(`widget is not allocated (${width}x${height})`);

  const paintable = new Gtk.WidgetPaintable({ widget });
  const snapshot = new Gtk.Snapshot();
  snapshot.scale(scale, scale);
  paintable.snapshot(snapshot, width, height);
  const node = snapshot.to_node();
  if (!node) throw new Error("widget rendered nothing");

  const renderer = widget.get_native()?.get_renderer();
  if (!renderer) throw new Error("widget has no renderer");
  const viewport = new Graphene.Rect().init(0, 0, width * scale, height * scale);
  const texture = renderer.render_texture(node, viewport);
  GLib.mkdir_with_parents(GLib.path_get_dirname(path), 0o755);
  if (!texture.save_to_png(path)) throw new Error(`failed to write ${path}`);
  return `${path} ${width}x${height}@${scale}`;
}

export function wait(ms: number) {
  return new Promise<void>((resolve) =>
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, ms, () => {
      resolve();
      return GLib.SOURCE_REMOVE;
    }));
}

// Text dump of the widget tree with allocation and css classes; handy to see
// why a widget ended up with an unexpected size without opening the inspector.
export function describeTree(widget: Gtk.Widget, depth = 0, maxDepth = 12): string {
  const classes = widget.get_css_classes().join(".");
  const name = widget.get_css_name();
  const line = `${"  ".repeat(depth)}${name}${classes ? `.${classes}` : ""} ${widget.get_width()}x${widget.get_height()}${widget.get_visible() ? "" : " (hidden)"}`;
  const lines = [line];
  if (depth < maxDepth) {
    for (let child = widget.get_first_child(); child; child = child.get_next_sibling()) {
      lines.push(describeTree(child, depth + 1, maxDepth));
    }
  }
  return lines.join("\n");
}
