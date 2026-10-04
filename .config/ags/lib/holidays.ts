// Japanese public holidays (国民の祝日), computed offline.
//
// Follows the 祝日法 rules in force for 2000-2099, including the one-off
// changes for 2019 (改元) and the 2020/2021 Olympics.  The equinox days use the
// usual approximation formulas, which match the official announcements for
// this range.  Outside 2000-2099 an empty map is returned.
//
// Update path: when the law changes or a special holiday is announced, add it
// to SPECIAL / the rule tables below and extend holidays.test.mjs.

export type HolidayMap = Map<string, string>;

const SUBSTITUTE = "振替休日";
const CITIZENS = "国民の休日";

// One-off holidays and moved holidays, keyed by year.
const SPECIAL: Record<number, [number, number, string][]> = {
  2019: [
    [5, 1, "天皇の即位の日"],
    [10, 22, "即位礼正殿の儀の行われる日"],
  ],
};

function key(month: number, day: number) {
  return `${month}-${day}`;
}

// nth weekday (0 = Sunday) of a month, 1-based month.
function nthWeekday(year: number, month: number, nth: number, weekday: number) {
  const first = new Date(year, month - 1, 1).getDay();
  return 1 + ((weekday - first + 7) % 7) + (nth - 1) * 7;
}

function vernalEquinox(year: number) {
  return Math.floor(20.8431 + 0.242194 * (year - 1980) - Math.floor((year - 1980) / 4));
}

function autumnalEquinox(year: number) {
  return Math.floor(23.2488 + 0.242194 * (year - 1980) - Math.floor((year - 1980) / 4));
}

function baseHolidays(year: number): [number, number, string][] {
  const days: [number, number, string][] = [
    [1, 1, "元日"],
    [1, nthWeekday(year, 1, 2, 1), "成人の日"],
    [2, 11, "建国記念の日"],
    [3, vernalEquinox(year), "春分の日"],
    [4, 29, year >= 2007 ? "昭和の日" : "みどりの日"],
    [5, 3, "憲法記念日"],
    [5, 5, "こどもの日"],
    [9, autumnalEquinox(year), "秋分の日"],
    [11, 3, "文化の日"],
    [11, 23, "勤労感謝の日"],
  ];
  if (year >= 2007) days.push([5, 4, "みどりの日"]);

  if (year >= 2020) days.push([2, 23, "天皇誕生日"]);
  else if (year <= 2018) days.push([12, 23, "天皇誕生日"]);

  if (year === 2020) days.push([7, 23, "海の日"]);
  else if (year === 2021) days.push([7, 22, "海の日"]);
  else days.push([7, year >= 2003 ? nthWeekday(year, 7, 3, 1) : 20, "海の日"]);

  if (year === 2020) days.push([8, 10, "山の日"]);
  else if (year === 2021) days.push([8, 8, "山の日"]);
  else if (year >= 2016) days.push([8, 11, "山の日"]);

  days.push([9, year >= 2003 ? nthWeekday(year, 9, 3, 1) : 15, "敬老の日"]);

  if (year === 2020) days.push([7, 24, "スポーツの日"]);
  else if (year === 2021) days.push([7, 23, "スポーツの日"]);
  else days.push([10, nthWeekday(year, 10, 2, 1), year >= 2020 ? "スポーツの日" : "体育の日"]);

  return [...days, ...(SPECIAL[year] ?? [])];
}

const cache = new Map<number, HolidayMap>();

// Map of "month-day" (1-based month) to holiday name.
export function holidaysOfYear(year: number): HolidayMap {
  const cached = cache.get(year);
  if (cached) return cached;
  const holidays: HolidayMap = new Map();
  if (year < 2000 || year > 2099) return holidays;

  for (const [month, day, name] of baseHolidays(year)) holidays.set(key(month, day), name);

  const isHoliday = (date: Date) =>
    date.getFullYear() === year && holidays.has(key(date.getMonth() + 1, date.getDate()));
  const sorted = [...holidays.keys()]
    .map((value) => value.split("-").map(Number))
    .map(([month, day]) => new Date(year, month - 1, day))
    .sort((a, b) => a.getTime() - b.getTime());

  // 国民の休日: a weekday sandwiched between two holidays.
  for (const date of sorted) {
    const next = new Date(year, date.getMonth(), date.getDate() + 1);
    const after = new Date(year, date.getMonth(), date.getDate() + 2);
    if (!isHoliday(next) && isHoliday(after) && next.getDay() !== 0) {
      holidays.set(key(next.getMonth() + 1, next.getDate()), CITIZENS);
    }
  }

  // 振替休日: a holiday on Sunday moves to the next day that is not a holiday.
  for (const date of sorted) {
    if (date.getDay() !== 0) continue;
    const next = new Date(year, date.getMonth(), date.getDate() + 1);
    while (isHoliday(next)) next.setDate(next.getDate() + 1);
    if (next.getFullYear() === year) holidays.set(key(next.getMonth() + 1, next.getDate()), SUBSTITUTE);
  }

  cache.set(year, holidays);
  return holidays;
}

// Holiday name for a date (1-based month), or undefined.
export function holidayName(year: number, month: number, day: number) {
  return holidaysOfYear(year).get(key(month, day));
}
