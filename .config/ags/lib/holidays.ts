// Japanese public holidays (国民の祝日・休日) from the Cabinet Office list.
//
// data/syukujitsu.csv is a UTF-8 copy of
// https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv, refreshed by
// tools/update-syukujitsu.sh (run monthly by .github/workflows/update-syukujitsu.yml).
// Years not in the file simply have no holidays.

export type HolidayMap = Map<string, string>;

function key(month: number, day: number) {
  return `${month}-${day}`;
}

// Parse the CSV ("YYYY/M/D,名称" rows after a header) into year -> "M-D" -> name.
export function parseSyukujitsu(text: string) {
  const years = new Map<number, HolidayMap>();
  for (const line of text.split(/\r?\n/)) {
    const match = line.match(/^(\d{4})\/(\d{1,2})\/(\d{1,2}),(.+)$/);
    if (!match) continue;
    const [, year, month, day, name] = match;
    let holidays = years.get(Number(year));
    if (!holidays) years.set(Number(year), (holidays = new Map()));
    holidays.set(key(Number(month), Number(day)), name.trim());
  }
  return years;
}

let data = new Map<number, HolidayMap>();

export function setHolidayData(text: string) {
  data = parseSyukujitsu(text);
}

// Map of "month-day" (1-based month) to holiday name.
export function holidaysOfYear(year: number): HolidayMap {
  return data.get(year) ?? new Map();
}

// Holiday name for a date (1-based month), or undefined.
export function holidayName(year: number, month: number, day: number) {
  return data.get(year)?.get(key(month, day));
}

// Last year covered by the loaded data (0 if none).
export function lastHolidayYear() {
  return Math.max(0, ...data.keys());
}
