import { test } from 'node:test';
import assert from 'node:assert/strict';
import { subscribeNumbers, updateNumbers } from './numbers.ts';

test('held Super state survives overlapping keys and out-of-order requests', () => {
  const states = [];
  const unsubscribe = subscribeNumbers(visible => states.push(visible));
  assert.deepEqual(states, [false]);
  assert.equal(updateNumbers(['left', 'down', '1']), true);
  updateNumbers(['right', 'down', '2']);
  updateNumbers(['left', 'up', '3']);
  assert.deepEqual(states, [false, true]);
  updateNumbers(['right', 'up', '4']);
  // A delayed press must not leave the numbers visible after release.
  updateNumbers(['right', 'down', '2']);
  updateNumbers(['right', 'down', '4']);
  assert.deepEqual(states, [false, true, false]);
  for (const args of [[], ['other', 'down'], ['left', 'toggle'],
    ['left', 'down', 'NaN'], ['left', 'down', '-1'], ['left', 'down', '5', 'extra']]) {
    assert.equal(updateNumbers(args), false);
  }
  updateNumbers(['left', 'down', '5']);
  let mountedVisible;
  const cleanup = subscribeNumbers(visible => { mountedVisible = visible; });
  assert.equal(mountedVisible, true);
  cleanup();
  unsubscribe();
  updateNumbers(['left', 'up', '6']);
  assert.deepEqual(states, [false, true, false, true]);
  assert.equal(mountedVisible, true);
});
