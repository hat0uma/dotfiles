import $ from "https://deno.land/x/dax@0.35.0/mod.ts";
import { Delay } from "https://deno.land/x/dax@0.35.0/src/common.ts";
import { notify } from "/lib/notify.ts";

const HOME = Deno.env.get("HOME") ?? "";
const ICON_CACHE = `${HOME}/.cache/dots/icon.json`;
const ICON_URL = "https://raw.githubusercontent.com/FortAwesome/Font-Awesome/master/metadata/icons.json";
const FETCH_TIMEOUT: Delay = "30s";
const ICON_DEFAULT = "";
const ICON_OVERRIDES = new Map<string, string>([
  // case insensitive
  // [window class, icon name]
  ["foot", "terminal"],
  ["wezterm", "terminal"],
  ["webcord", "discord"],
  ["pcmanfm-qt", "folder"],
]);

type FontAwesomeIcon = {
  changes: string[];
  ligatures: string[];
  search: {
    terms: string[];
  };
  styles: string[];
  unicode: string;
  label: string;
  voted: boolean;
  svg: {
    [style: string]: {
      last_modified: number;
      raw: string;
      viewBox: string[];
      width: number;
      height: number;
      path: string;
    };
  };
  free: string[];
};

type FontAwesomeIcons = {
  [key: string]: FontAwesomeIcon;
};

const icons = await loadIcons().catch(async (e) => {
  console.error(e);
  await notify("dots", `Failed to load icons: ${e}`)
    .setAppName("dots")
    .setUrgency("critical")
    .setTimeout(10)
    .send();
  Deno.exit(1);
});

// fetch icons from github and cache them
async function fetchIcons(cachePath: string): Promise<FontAwesomeIcons> {
  // fetch icons from github
  console.error("Fetching icons from github...");
  const icons = await $.request(ICON_URL).timeout(FETCH_TIMEOUT).json<FontAwesomeIcons>();

  // cache icons
  const dir = $.path(cachePath).dirname();
  await Deno.mkdir(dir, { recursive: true });
  await Deno.writeTextFile(cachePath, JSON.stringify(icons));
  return icons;
}

// load icons from cache
async function loadIconFromCache(file: string): Promise<FontAwesomeIcons> {
  const cacheFile = await Deno.readTextFile(file);
  return JSON.parse(cacheFile) as FontAwesomeIcons;
}

// load icons from cache or fetch them
async function loadIcons(): Promise<Map<string, string>> {
  const icons = await loadIconFromCache(ICON_CACHE).catch((_) => fetchIcons(ICON_CACHE));
  return new Map(
    Object.entries(icons).map(([key, icon]) => [
      key,
      String.fromCodePoint(parseInt(icon.unicode, 16)),
    ]),
  );
}

// lookup icon by name
export function lookupIcon(iconName: string): string {
  const iconNameLower = iconName.toLowerCase();
  const lookupName = ICON_OVERRIDES.get(iconNameLower) ?? iconNameLower;
  const icon = icons.get(lookupName) ?? ICON_DEFAULT;
  return icon;
}
