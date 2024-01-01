import * as ini from "https://deno.land/x/ini@v2.1.0/mod.ts";
import * as gtk from "/lib/gtk.ts";

const DESKTOP_DIRS = [
  "/usr/share/applications",
  "/usr/local/share/applications",
];
interface DesktopEntry {
  Type: "Application" | "Link" | "Directory";
  Name: string;
  NoDisplay?: boolean;
  Icon?: string;
  // and more
}
interface DesktopFile {
  "Desktop Entry": DesktopEntry;
}

function isDesktopFile(obj: unknown): obj is DesktopFile {
  return (
    typeof obj === "object" &&
    obj !== null &&
    typeof (obj as DesktopFile)["Desktop Entry"] === "object" &&
    typeof (obj as DesktopFile)["Desktop Entry"].Type === "string" &&
    typeof (obj as DesktopFile)["Desktop Entry"].Name === "string" &&
    (typeof (obj as DesktopFile)["Desktop Entry"].NoDisplay === "undefined" ||
      typeof (obj as DesktopFile)["Desktop Entry"].NoDisplay === "boolean") &&
    (typeof (obj as DesktopFile)["Desktop Entry"].Icon === "undefined" ||
      typeof (obj as DesktopFile)["Desktop Entry"].Icon === "string")
  );
}

async function listDesktopFiles(dir: string) {
  const entries: string[] = [];
  for await (const entry of Deno.readDir(dir)) {
    if (entry.isFile && entry.name.endsWith(".desktop")) {
      entries.push(entry.name);
    }
  }
  return entries;
}

async function parseDesktopFile(path: string) {
  const content = await Deno.readTextFile(path);
  const parsed = ini.parse(content);
  if (!isDesktopFile(parsed)) {
    console.error(`Failed to parse desktop file: ${path}`);
    return null;
  }
  return parsed;
}

async function iconFromDesktopFile(file: DesktopFile) {
  if (file["Desktop Entry"].Icon) {
    return file["Desktop Entry"].Icon;
  }
  return null;
}

async function allDesktopApps() {
  const files: DesktopFile[] = [];
  for (const dir of DESKTOP_DIRS) {
    const entries = await listDesktopFiles(dir);
    for (const entry of entries) {
      const parsed = await parseDesktopFile(`${dir}/${entry}`);
      if (parsed && parsed["Desktop Entry"].Type === "Application") {
        files.push(parsed);
      }
    }
  }
  return files;
}
export function icon(name: string) {
  const icon = gtk.getIconPath(name, 128, gtk.IconLookupFlags.None);
  console.log(icon);
}
