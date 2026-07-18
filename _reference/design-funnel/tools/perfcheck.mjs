import { chromium } from 'playwright';
const b = await chromium.launch();
let p = await (await b.newContext({ viewport:{width:1280,height:720}, deviceScaleFactor:1 })).newPage();
const ss = process.argv[2] || '';
  await p.goto('http://localhost:3021/intro.html' + (ss ? '?ss='+ss : ''), { waitUntil:'networkidle' });
await p.waitForTimeout(9000);
const r = await p.evaluate(() => new Promise(res => {
  const c = document.querySelector('canvas');
  let n = 0; const t0 = performance.now();
  function f(){ n++; if (performance.now() - t0 < 3000) requestAnimationFrame(f);
    else res({ fps:+(n/((performance.now()-t0)/1000)).toFixed(1),
               drawingBuffer: c.width+'x'+c.height, cssSize: c.clientWidth+'x'+c.clientHeight }); }
  requestAnimationFrame(f);
}));
console.log(JSON.stringify(r, null, 1));
await b.close();
