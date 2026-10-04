import { test } from 'node:test';
import assert from 'node:assert/strict';
import { holidayName, holidaysOfYear } from './holidays.ts';

const list = (year) =>
  [...holidaysOfYear(year)]
    .map(([key, name]) => [key.split('-').map(Number), name])
    .sort(([[am, ad]], [[bm, bd]]) => am - bm || ad - bd)
    .map(([[month, day], name]) => `${month}/${day} ${name}`);

// Cabinet Office (内閣府) published list.
test('2026: full list incl. 振替休日 and 国民の休日 (silver week)', () => {
  assert.deepEqual(list(2026), [
    '1/1 元日', '1/12 成人の日', '2/11 建国記念の日', '2/23 天皇誕生日', '3/20 春分の日',
    '4/29 昭和の日', '5/3 憲法記念日', '5/4 みどりの日', '5/5 こどもの日', '5/6 振替休日',
    '7/20 海の日', '8/11 山の日', '9/21 敬老の日', '9/22 国民の休日', '9/23 秋分の日',
    '10/12 スポーツの日', '11/3 文化の日', '11/23 勤労感謝の日',
  ]);
});

test('2025: Sunday holidays move to Monday', () => {
  assert.equal(holidayName(2025, 2, 24), '振替休日');
  assert.equal(holidayName(2025, 5, 6), '振替休日');
  assert.equal(holidayName(2025, 11, 24), '振替休日');
  assert.equal(holidayName(2025, 3, 20), '春分の日');
  assert.equal(holidayName(2025, 9, 23), '秋分の日');
  assert.equal(holidaysOfYear(2025).size, 19);
});

test('2019: era change specials', () => {
  assert.equal(holidayName(2019, 4, 30), '国民の休日');
  assert.equal(holidayName(2019, 5, 1), '天皇の即位の日');
  assert.equal(holidayName(2019, 5, 2), '国民の休日');
  assert.equal(holidayName(2019, 5, 6), '振替休日');
  assert.equal(holidayName(2019, 10, 22), '即位礼正殿の儀の行われる日');
  assert.equal(holidayName(2019, 12, 23), undefined);
  assert.equal(holidayName(2019, 2, 23), undefined);
});

test('2020/2021: Olympics moved holidays', () => {
  assert.equal(holidayName(2020, 7, 23), '海の日');
  assert.equal(holidayName(2020, 7, 24), 'スポーツの日');
  assert.equal(holidayName(2020, 8, 10), '山の日');
  assert.equal(holidayName(2020, 10, 12), undefined);
  assert.equal(holidayName(2021, 7, 22), '海の日');
  assert.equal(holidayName(2021, 7, 23), 'スポーツの日');
  assert.equal(holidayName(2021, 8, 8), '山の日');
  assert.equal(holidayName(2021, 8, 9), '振替休日');
});

test('equinoxes and pre-2007 names', () => {
  assert.equal(holidayName(2024, 3, 20), '春分の日');
  assert.equal(holidayName(2024, 9, 22), '秋分の日');
  assert.equal(holidayName(2024, 9, 23), '振替休日');
  assert.equal(holidayName(2027, 3, 21), '春分の日');
  assert.equal(holidayName(2027, 3, 22), '振替休日');
  assert.equal(holidayName(2005, 4, 29), 'みどりの日');
  assert.equal(holidayName(2005, 5, 4), '国民の休日');
  assert.equal(holidayName(2015, 9, 22), '国民の休日');
});

test('plain days and out-of-range years', () => {
  assert.equal(holidayName(2026, 10, 13), undefined);
  assert.equal(holidaysOfYear(1999).size, 0);
});
