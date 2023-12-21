import $ from "https://deno.land/x/dax@0.35.0/mod.ts";

const ICONS = await fetchIcons();
const ICON_DEFAULT = "";
const ICON_OVERRIDES = new Map<string, string>([
  // case insensitive
  // [window class, icon name]
  ["foot", "terminal"],
  ["wezterm", "terminal"],
  ["webcord", "discord"],
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

// fetch font awesome icons
async function fetchIcons(): Promise<Map<string, string>> {
  const url = "https://raw.githubusercontent.com/FortAwesome/Font-Awesome/master/metadata/icons.json";
  const icons = await $.request(url).json<FontAwesomeIcons>();
  return new Map(
    Object.entries(icons).map(([key, icon]) => [
      key,
      String.fromCodePoint(parseInt(icon.unicode, 16)),
    ]),
  );
}

export function lookupIcon(iconName: string): string {
  const lookupName = (ICON_OVERRIDES.get(iconName) ?? iconName).toLowerCase();
  const icon = ICONS.get(lookupName) ?? ICON_DEFAULT;
  return icon;
}
