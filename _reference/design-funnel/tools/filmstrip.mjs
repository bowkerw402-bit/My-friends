#!/usr/bin/env node
/*
 * filmstrip.mjs — WATCH the animation, not just a frozen pose.
 *
 * Will's ask (2026-07-18): "be able to track the animations throughout the entire video...
 * see what all the gaps are, what's smooth, what's not, what doesn't look good — because at
 * the start it's good, but when it pans to the final angle you can't see those things."
 *
 * A single frozen ?pose= snap can't reveal that. This captures the page AS IT PLAYS at a
 * fixed cadence and tiles the frames into ONE contact-sheet PNG, so the whole motion arc —
 * the camera descent, the reveals, the settle — is reviewable in a single Read. It's the
 * closest thing to scrubbing the video frame by frame.
 *
 *   node filmstrip.mjs <url> [--frames=18] [--interval=420] [--vp=920x575] [--cols=6]
 *                            [--delay=200] [--out=./snaps] [--label=name]
 *   node filmstrip.mjs <url> --poses=0,0.15,0.3,...,1   (scrub the deterministic ?pose arc instead)
 *
 * Live mode (default) screenshots every `interval` ms for `frames` frames — the real playback.
 * Pose mode reloads at each ?pose fraction — the camera arc with everything fully revealed.
 */
import { chromium } from 'playwright';
import { PNG } from 'pngjs';
import { mkdirSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

const argv = process.argv.slice(2);
const url = argv.find(a => !a.startsWith('--'));
if (!url) { console.error('usage: node filmstrip.mjs <url> [--frames=18] [--interval=420] [--poses=0,..,1]'); process.exit(2); }
const flag = (k, d) => { const a = argv.find(x => x.startsWith('--' + k + '=')); return a ? a.split('=')[1] : d; };

const vp = flag('vp', '920x575').split('x').map(Number);
const cols = +flag('cols', 6);
const delay = +flag('delay', 250);           // settle before the first frame (env/loop start)
const outDir = resolve(flag('out', './snaps'));
const label = flag('label', 'film');
const posesArg = flag('poses', null);

mkdirSync(outDir, { recursive: true });

const browser = await chromium.launch();
const ctx = await browser.newContext({ viewport: { width: vp[0], height: vp[1] }, deviceScaleFactor: 1 });
const page = await ctx.newPage();

const shots = [];      // { buf, tag }
if (posesArg) {
  const poses = posesArg.split(',').map(Number);
  for (const p of poses) {
    await page.goto(`${url}${url.includes('?') ? '&' : '?'}pose=${p}`, { waitUntil: 'networkidle', timeout: 25000 });
    await page.waitForTimeout(1600);         // let WebGL/env settle at this pose
    shots.push({ buf: await page.screenshot(), tag: 'pose ' + p });
  }
} else {
  const frames = +flag('frames', 18);
  const interval = +flag('interval', 420);
  await page.goto(url, { waitUntil: 'networkidle', timeout: 25000 });
  await page.waitForTimeout(delay);
  const t0 = Date.now();
  for (let i = 0; i < frames; i++) {
    shots.push({ buf: await page.screenshot(), tag: '+' + (Date.now() - t0) + 'ms' });
    if (i < frames - 1) await page.waitForTimeout(interval);
  }
}
await browser.close();

// tile into a grid with thin gutters + a tick label bar per cell
const pngs = shots.map(s => PNG.sync.read(s.buf));
const fw = pngs[0].width, fh = pngs[0].height;
const rows = Math.ceil(pngs.length / cols);
const gut = 6, bar = 22;
const cw = fw + gut, ch = fh + bar + gut;
const sheet = new PNG({ width: cols * cw + gut, height: rows * ch + gut, fill: true });
for (let y = 0; y < sheet.height; y++) for (let x = 0; x < sheet.width; x++) {
  const idx = (sheet.width * y + x) << 2;
  sheet.data[idx] = 22; sheet.data[idx + 1] = 24; sheet.data[idx + 2] = 28; sheet.data[idx + 3] = 255;
}
pngs.forEach((p, i) => {
  const dx = gut + (i % cols) * cw;
  const dy = gut + Math.floor(i / cols) * ch + bar;
  for (let y = 0; y < fh; y++) {
    const srcStart = (p.width * y) << 2;
    const dstStart = (sheet.width * (dy + y) + dx) << 2;
    p.data.copy(sheet.data, dstStart, srcStart, srcStart + (fw << 2));
  }
  // a gold ordering strip above each cell (length grows with the frame index)
  for (let bx = 0; bx < Math.min(fw, 6 + i * 6); bx++) for (let by = 0; by < 5; by++) {
    const idx = (sheet.width * (dy - 8 + by) + (dx + bx)) << 2;
    sheet.data[idx] = 214; sheet.data[idx + 1] = 155; sheet.data[idx + 2] = 52; sheet.data[idx + 3] = 255;
  }
});

const outPath = resolve(outDir, `${label}_${cols}x${rows}.png`);
writeFileSync(outPath, PNG.sync.write(sheet));
console.log('frames (in order): ' + shots.map((s, i) => `${i}:${s.tag}`).join('  '));
console.log(outPath);
