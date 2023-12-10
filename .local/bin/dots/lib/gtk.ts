/// <reference lib="deno.unstable" />
const LIBGTK = "libgtk-3.so";

export const enum IconLookupFlags {
  None = 0,
  NoSvg = 1,
  ForceSvg = 2,
  UseBuiltin = 4,
  GenericFallback = 8,
  ForceSize = 16,
  ForceRegular = 32,
  ForceSymbolic = 64,
  DirLtr = 128,
  DirRtl = 256,
}

// ffi for gtk
const gtk = Deno.dlopen(LIBGTK, {
  gtk_init: {
    parameters: ["pointer", "pointer"],
    result: "void",
  },
  gtk_icon_theme_get_default: {
    parameters: [],
    result: "pointer",
  },
  gtk_icon_theme_rescan_if_needed: {
    parameters: ["pointer"],
    result: "bool",
  },
  gtk_icon_theme_lookup_icon: {
    parameters: ["pointer", "buffer", "i32", "u32"],
    result: "pointer",
  },
  gtk_icon_info_get_filename: {
    parameters: ["pointer"],
    result: "pointer",
  },
});

export function initGtk() {
  gtk.symbols.gtk_init(null, null);
}

export function getIconPath(iconName: string, size: number, flags: IconLookupFlags) {
  // default theme is owned by gtk.
  const theme = gtk.symbols.gtk_icon_theme_get_default();
  gtk.symbols.gtk_icon_theme_rescan_if_needed(theme);
  const iconInfoPtr = gtk.symbols.gtk_icon_theme_lookup_icon(theme, str2cstr(iconName), size, flags);
  if (!iconInfoPtr) {
    return null;
  }

  // filenamePtr is owned by gtk.
  const filenamePtr = gtk.symbols.gtk_icon_info_get_filename(iconInfoPtr);
  const filename = filenamePtr ? ptr2str(filenamePtr) : null;
  return filename;
}

const globalEncoder = new TextEncoder();
function str2cstr(str: string) {
  return globalEncoder.encode(str + "\0");
}

function ptr2str(ptr: Deno.PointerObject) {
  return Deno.UnsafePointerView.getCString(ptr);
}
