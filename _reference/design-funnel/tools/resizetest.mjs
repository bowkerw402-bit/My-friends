import { chromium } from 'playwright';
const b = await chromium.launch();
const ctx = await b.newContext({ viewport:{width:900,height:560}, deviceScaleFactor:1 });
const p = await ctx.newPage();
await p.goto('http://localhost:3021/intro.html?ss=1', { waitUntil:'networkidle', timeout:45000 });
await p.waitForTimeout(9000);

const before = await p.evaluate(() => { const c=document.querySelector('canvas'); return c.width+'x'+c.height; });
// fire 25 SPURIOUS resize events (same size) — exactly what scrolling does
await p.evaluate(() => { for (let i=0;i<25;i++) window.dispatchEvent(new Event('resize')); });
await p.waitForTimeout(1200);
const afterNoop = await p.evaluate(() => { const c=document.querySelector('canvas'); return c.width+'x'+c.height; });
// now a GENUINE resize
await p.setViewportSize({ width: 1200, height: 700 });
await p.waitForTimeout(1500);
const afterReal = await p.evaluate(() => { const c=document.querySelector('canvas'); return c.width+'x'+c.height; });

console.log('buffer before          :', before);
console.log('after 25 no-op resizes :', afterNoop, afterNoop === before ? '(unchanged — reallocation skipped)' : '(CHANGED — guard failed)');
console.log('after a real resize    :', afterReal, afterReal !== before ? '(updated — genuine resize still works)' : '(FAILED to update)');
const ok = afterNoop === before && afterReal !== before;
console.log('\n' + (ok ? 'PASS: spurious resizes no longer reallocate; real resizes still do.' : 'FAIL'));
await b.close();
process.exit(ok ? 0 : 1);
