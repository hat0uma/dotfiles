import { test } from 'node:test';
import assert from 'node:assert/strict';
import { layoutPanes, minimapWidth, tooltip } from './layout.ts';
const mon = { width: 1920, height: 1080, scale: 1, transform: 0, x: 0, y: 0, reservedLeft: 0, reservedTop: 0, reservedRight: 0, reservedBottom: 0 };
const client = (values = {}) => ({ address: '1', workspace: { id: 1 }, mapped: true, hidden: false, x: 0, y: 0, width: 1920, height: 1080, floating: false, fullscreen: 0, focusHistoryId: 0, class: 'kitty', title: '', ...values });
test('monitor aspect is independent of reserved space, scale and rotation are applied', () => {
  assert.equal(minimapWidth({ ...mon, reservedTop: 56 }), 53);
  assert.equal(minimapWidth({ ...mon, scale: 1.25 }), 53);
  assert.equal(minimapWidth({ ...mon, transform: 1 }), 17);
});
test('two, three and four tiles have 2px shared gaps', () => {
  for (const split of [2, 3, 4]) {
    const rects = split === 2 ? [[0, 0, 960, 1080], [960, 0, 960, 1080]] : split === 3
      ? [[0, 0, 960, 1080], [960, 0, 960, 540], [960, 540, 960, 540]]
      : [[0, 0, 960, 540], [960, 0, 960, 540], [0, 540, 960, 540], [960, 540, 960, 540]];
    const panes = layoutPanes(rects.map(([x,y,width,height], i) => client({ address: String(i), x,y,width,height, focusHistoryId: i })), mon, 1);
    const left = panes.find(p => p.x === 0);
    const right = panes.find(p => p.x > 0);
    assert.equal(right.x - (left.x + left.w), 2);
    if (split > 2) {
      const upper = panes.find(p => p.x > 0 && p.y === 0);
      const lower = panes.find(p => p.x > 0 && p.y > 0);
      assert.equal(lower.y - (upper.y + upper.h), 2);
      assert.equal(lower.icon, null);
    }
  }
});
test('logical origin includes reserved area on a negative-origin fractional-scale monitor', () => {
  const m = { ...mon, x: -1536, y: -20, scale: 1.25, reservedTop: 40 };
  assert.deepEqual(layoutPanes([client({ x: -1536, y: 20, width: 1536, height: 824 })], m, 1), [{ x: 0, y: 0, w: 45, h: 22, icon: 'ws-terminal-symbolic' }]);
});
test('fullscreen, floating-only, hidden and workspace filtering', () => {
  const tiled = client();
  const floating = client({ address: '2', floating: true, class: 'firefox', focusHistoryId: 1 });
  assert.equal(layoutPanes([tiled, floating], mon, 1)[0].icon, 'ws-terminal-symbolic');
  assert.equal(layoutPanes([tiled, { ...floating, fullscreen: 1 }], mon, 1)[0].icon, 'ws-browser-symbolic');
  assert.equal(layoutPanes([floating, client({ floating: true })], mon, 1)[0].icon, 'ws-terminal-symbolic');
  assert.deepEqual(layoutPanes([client({ hidden: true }), client({ workspace: { id: -1 } })], mon, 1), []);
});
test('small clipped tiles remain in bounds and recent client is drawn last', () => {
  const panes = layoutPanes([client({ width: 1, height: 1, x: 1920, y: 1080 }), client({ address: '2', focusHistoryId: 1 })], mon, 1);
  assert.equal(panes[0].w, 45);
  assert.deepEqual(panes[1], { x: 42, y: 19, w: 3, h: 3, icon: null });
});
test('glyph thresholds and terminal title mapping', () => {
  const panes = layoutPanes([client({ title: 'nvim file.ts' })], mon, 1);
  assert.equal(panes[0].icon, 'ws-code-symbolic');
  assert.equal(layoutPanes([client()], { ...mon, transform: 1 }, 1)[0].icon, null);
});
test('tooltip includes hidden and floating clients, uses recent order and Unicode truncation', () => {
  const text = tooltip([client({ hidden: true, title: '😀'.repeat(41) }), client({ floating: true, focusHistoryId: 1, class: 'firefox', title: 'page' })], 1, 3);
  assert.equal(text.split('\n')[0], '3');
  assert.equal(Array.from(text.split('\n')[1].split(' — ')[1]).length, 40);
  assert.equal(text.split('\n')[2], 'firefox — page');
  assert.equal(tooltip([], 1, 3), '3（空）');
});
