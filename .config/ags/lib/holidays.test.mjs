import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { holidayName, holidaysOfYear, lastHolidayYear, parseSyukujitsu, setHolidayData } from './holidays.ts';

const csv = readFileSync(new URL('../data/syukujitsu.csv', import.meta.url), 'utf8');
setHolidayData(csv);

const list = (year) =>
  [...holidaysOfYear(year)]
    .map(([key, name]) => [key.split('-').map(Number), name])
    .sort(([[am, ad]], [[bm, bd]]) => am - bm || ad - bd)
    .map(([[month, day], name]) => `${month}/${day} ${name}`);

test('parser: header, CRLF, blank and malformed lines are skipped', () => {
  const years = parseSyukujitsu('国民の祝日・休日月日,国民の祝日・休日名称\r\n2026/1/1,元日\r\n\r\nbroken,line\r\n2026/5/6,休日\r\n2027/1/11,成人の日\r\n');
  assert.deepEqual([...years.keys()], [2026, 2027]);
  assert.deepEqual([...years.get(2026)], [['1-1', '元日'], ['5-6', '休日']]);
});

test('bundled data: header and every row are well-formed', () => {
  const lines = csv.trimEnd().split('\n');
  assert.equal(lines[0], '国民の祝日・休日月日,国民の祝日・休日名称');
  for (const line of lines.slice(1)) assert.match(line, /^\d{4}\/\d{1,2}\/\d{1,2},\S.*$/);
  assert.ok(lines.length > 900);
});

test('bundled data: 2026 list incl. 休日 (振替休日 / 国民の休日)', () => {
  assert.deepEqual(list(2026), [
    '1/1 元日', '1/12 成人の日', '2/11 建国記念の日', '2/23 天皇誕生日', '3/20 春分の日',
    '4/29 昭和の日', '5/3 憲法記念日', '5/4 みどりの日', '5/5 こどもの日', '5/6 休日',
    '7/20 海の日', '8/11 山の日', '9/21 敬老の日', '9/22 休日', '9/23 秋分の日',
    '10/12 スポーツの日', '11/3 文化の日', '11/23 勤労感謝の日',
  ]);
});

test('bundled data: special years', () => {
  assert.equal(holidayName(2019, 5, 1), '休日（祝日扱い）');
  assert.equal(holidayName(2019, 10, 22), '休日（祝日扱い）');
  assert.equal(holidayName(2021, 7, 23), 'スポーツの日');
  assert.equal(holidayName(2021, 8, 8), '山の日');
  assert.equal(holidayName(2026, 10, 13), undefined);
});

test('bundled data covers the current year (refresh with tools/update-syukujitsu.sh)', () => {
  assert.ok(lastHolidayYear() >= new Date().getFullYear(), `data ends in ${lastHolidayYear()}`);
});
