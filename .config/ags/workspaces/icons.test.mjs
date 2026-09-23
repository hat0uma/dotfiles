import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
import { createResolver } from '../ws-icons/src/icon-core.ts';
import { layoutPanes } from './layout.ts';

const dist = new URL('../ws-icons/dist/', import.meta.url);
const config = JSON.parse(readFileSync(new URL('resolver.json', dist), 'utf8'));
const { iconFor } = createResolver(config);

test('terminal titles, sites, brands and unknown applications resolve', () => {
  for (const [cls, title, expected] of [
    ['kitty', 'nvim file.ts', 'fa-brands-vim-symbolic'],
    ['kitty', 'btop', 'fa-solid-chart-line-symbolic'],
    ['zen', 'Inbox - Gmail — Zen Browser', 'fa-solid-envelope-symbolic'],
    ['zen', 'New chat - Claude — Zen Browser', 'fa-brands-claude-symbolic'],
    ['vesktop', '', 'fa-brands-discord-symbolic'],
    ['org.telegram.desktop', '', 'fa-brands-telegram-symbolic'],
    ['unknown-application-xyz', '', config.fallback],
  ]) assert.equal(iconFor({ class: cls, title }), expected);
});

test('changing title on the same client updates its icon', () => {
  const client = { class: 'zen', title: 'Inbox - Gmail — Zen Browser' };
  assert.equal(iconFor(client), 'fa-solid-envelope-symbolic');
  client.title = 'New chat - Claude — Zen Browser';
  assert.equal(iconFor(client), 'fa-brands-claude-symbolic');
  client.title = 'Article about Gmail — Zen Browser';
  assert.equal(iconFor(client), 'fa-solid-globe-symbolic');
});

test('layout passes initial class and title to the resolver', () => {
  const monitor = { width: 1920, height: 1080, scale: 1, transform: 0, x: 0, y: 0,
    reservedLeft: 0, reservedTop: 0, reservedRight: 0, reservedBottom: 0 };
  const client = { address: '1', workspace: { id: 1 }, mapped: true, hidden: false,
    x: 0, y: 0, width: 1920, height: 1080, floating: false, fullscreen: 0,
    focusHistoryId: 0, class: '', title: '', initialClass: 'kitty', initialTitle: 'nvim file.ts' };
  assert.equal(layoutPanes([client], monitor, 1, iconFor)[0].icon, 'fa-brands-vim-symbolic');
});

test('every configured icon has a generated SVG', () => {
  const names = new Set([config.fallback, ...config.rules.map(r => r.icon), ...Object.values(config.brands)]);
  for (const name of names) assert.ok(existsSync(new URL(`icons/${name}.svg`, dist)), name);
});
