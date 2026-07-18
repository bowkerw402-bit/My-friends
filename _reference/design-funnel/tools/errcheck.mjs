import { chromium } from 'playwright';
const b = await chromium.launch();
const p = await (await b.newContext({ viewport:{width:1280,height:720} })).newPage();
const errs = [], warns = [];
p.on('console', m => { if (m.type()==='error') errs.push(m.text()); if (m.type()==='warning') warns.push(m.text()); });
p.on('pageerror', e => errs.push('PAGEERROR: ' + e.message));
await p.goto(process.argv[2], { waitUntil:'networkidle' });
await p.waitForTimeout(12000);
const st = await p.evaluate(() => ({
  canvas: !!document.querySelector('canvas'),
  buf: (c=>c?c.width+'x'+c.height:'none')(document.querySelector('canvas')),
  wordmarkVisible: !!document.querySelector('h1.wordmark, .belowmark')
}));
console.log('ERRORS:', errs.length ? errs.slice(0,5) : 'none');
console.log('WARNINGS:', warns.length ? warns.slice(0,3) : 'none');
console.log('STATE:', JSON.stringify(st));
await b.close();
