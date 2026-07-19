/* Proves the adaptive-quality step can never produce a black frame.
 *
 * The black cut came from renderer.setPixelRatio() writing canvas.width — which per the HTML spec
 * CLEARS the drawing buffer — happening in a rAF callback that ran AFTER tick()'s draw() in the same
 * frame. With alpha:false, a cleared buffer composites as opaque black.
 * The fix defers the change to the TOP of the next tick. This asserts that ordering actually holds
 * at runtime, instead of trusting a code read.
 *
 * Uses ?guardwin to shrink the guard's 90-frame decision window, which is otherwise untestable
 * headlessly (software rasterisation ~1fps => 90 seconds per decision).
 */
import { chromium } from 'playwright';
const b = await chromium.launch();
const p = await (await b.newContext({ viewport:{width:800,height:500}, deviceScaleFactor:1 })).newPage();
const errs = [];
p.on('pageerror', e => errs.push(String(e.message)));
await p.goto('http://localhost:3021/intro.html?guardwin=6', { waitUntil:'networkidle', timeout:45000 });

let qa = null;
for (let i = 0; i < 22; i++) {                       // poll until the guard has acted
  await p.waitForTimeout(2500);
  qa = await p.evaluate(() => window.__qa && {
    ssApplied: __qa.ssApplied, appliedInTick: __qa.appliedInTick,
    appliedAfterDraw: __qa.appliedAfterDraw, ssHistory: __qa.ssHistory,
    buf: (c => c.width + 'x' + c.height)(document.querySelector('canvas')),
  });
  if (qa && qa.ssApplied > 0) break;
}
console.log('qa:', JSON.stringify(qa));
console.log('pageerrors:', errs.length ? errs.slice(0,2) : 'none');

const checks = [
  ['guard actually fired (window shrunk so it can be observed)', qa && qa.ssApplied > 0],
  ['EVERY quality change applied inside tick()',                 qa && qa.appliedInTick === qa.ssApplied],
  ['ZERO changes applied after a draw (the black-cut condition)', qa && qa.appliedAfterDraw === 0],
  ['supersample only ever steps DOWN',                            qa && qa.ssHistory.every((v,i,a) => i===0 || v <= a[i-1])],
  ['ratio never drops below 1.0 (never sub-native)',              qa && qa.ssHistory.every(v => v >= 1)],
  ['no page errors',                                              errs.length === 0],
];
let bad = 0;
for (const [name, ok] of checks) { console.log((ok ? '  ok   ' : '  FAIL ') + name); if (!ok) bad++; }
console.log('\n' + (bad ? bad + ' FAILED' : 'PASS: a quality step cannot present a cleared buffer.'));
await b.close();
process.exit(bad ? 1 : 0);
