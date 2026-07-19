import { chromium } from 'playwright';
const URL='http://localhost:3000/services-carousel';
const b = await chromium.launch();
const deg = p => p.evaluate(() => { const m=new DOMMatrixReadOnly(getComputedStyle(document.querySelector('.mgr-ring')).transform); return Math.atan2(-m.m13,m.m11)*180/Math.PI; });
let fail=0; const ok=(n,c,d='')=>{console.log(`${c?'  PASS':'  FAIL'}  ${n}${d?'   '+d:''}`); if(!c)fail++;};

const p = await b.newPage({viewport:{width:1180,height:740}});
const errs=[]; p.on('pageerror',e=>errs.push(e.message));
await p.goto(URL,{waitUntil:'networkidle'}); await p.waitForTimeout(500);
/* Sample for LONGER than one full period, or this cannot observe a full revolution and reports a
   false failure — it did, at 26 samples x 800ms against a 26s spin (reached 2/3 on a ring that
   provably sweeps all 360 degrees). Tolerance must also be >= the angular step between samples
   (26s/360deg x 700ms = ~9.7deg), else a seat can be stepped straight over. */
const seats=new Set();
for(let i=0;i<48;i++){ seats.add(Math.round(((await deg(p))+360)%360/5)*5); await p.waitForTimeout(700); }
const hit=[0,120,240].filter(s=>[...seats].some(v=>Math.min(Math.abs(v-s),360-Math.abs(v-s))<=12));
ok('advances through all three services', hit.length===3, `reached ${hit.length}/3 seats over ${(48*0.7).toFixed(0)}s of a 26s rotation`);
const kf=await p.evaluate(()=>{const r=[...document.styleSheets].flatMap(s=>{try{return[...s.cssRules]}catch{return[]}}).find(r=>r.type===7&&r.name==='mgr-spin'); return r?[...r.cssRules].map(k=>k.keyText+' -> '+k.style.transform):null;});
ok('loops without a visible rewind', !!kf && /100%/.test(kf.at(-1)) && /rotateY\(-?360deg\)/.test(kf.at(-1)), kf?kf.at(-1):'no keyframes');
/* NEVER STOPS. Hover pause was removed at Will's request, so the assertion inverts: resting a
   pointer on the stage must NOT freeze it. Asserting this is worth more than asserting the pause
   was, because a stray :hover or pointer-events rule silently killing the motion is the realistic
   regression here. */
await p.hover('.mgr-stage'); await p.waitForTimeout(300);
const h1=await deg(p); await p.waitForTimeout(1800);
ok('keeps spinning under the pointer', Math.abs(h1-(await deg(p)))>2,
   `moved ${Math.abs(h1-(await deg(p))).toFixed(1)}deg while hovered`);
ok('nothing can pause it', await p.evaluate(()=>getComputedStyle(document.querySelector('.mgr-ring')).animationPlayState)==='running');

/* THE PRISM. Three faces only meet at their edges when the radius is the apothem of the triangle
   they form: width * 0.28868. Off by a few percent and it silently degrades to a ring of floating
   cards, which is exactly what this was before and is invisible in a still. */
/* Read the APPLIED radius out of the face's own transform matrix, not the --r custom property:
   getPropertyValue('--r') hands back the literal "calc(var(--w) * 0.28868)" token because custom
   properties do not compute to lengths, which parseFloat turns into NaN (it did). The automation
   face sits at 0deg, so its matrix is translate(-50%,-50%) translateZ(r) and m43 IS the radius —
   and this measures what the browser actually did rather than what the stylesheet claims. */
const geo = await p.evaluate(()=>{
  const f=document.querySelector('.mgr-ring .obj-automation');
  return {w:parseFloat(getComputedStyle(f).width),
          r:new DOMMatrixReadOnly(getComputedStyle(f).transform).m43};});
const ratio = geo.r/geo.w;
ok('faces meet as a triangular prism', Math.abs(ratio-0.28868)<0.004,
   `radius/width = ${ratio.toFixed(5)}, apothem needs 0.28868`);
ok('all three faces are the same rectangle', await p.evaluate(()=>{
  const b=[...document.querySelectorAll('.mgr-ring .scene-obj')].map(e=>e.offsetWidth+'x'+e.offsetHeight);
  return new Set(b).size===1;}));
ok('no page errors', errs.length===0, errs.join('; '));
await p.close();

const t=await b.newPage({viewport:{width:390,height:780},hasTouch:true});
await t.goto(URL,{waitUntil:'networkidle'}); await t.waitForTimeout(400);
await t.dispatchEvent('.mgr-stage','touchstart'); await t.waitForTimeout(200);
const t1=await deg(t); await t.waitForTimeout(1600);
ok('keeps spinning through a touch', Math.abs(t1-(await deg(t)))>2);
/* Only the FRONT panel must fit. The two side seats at +-120deg legitimately swing past the frame
   edge — that is what a ring looks like from the side, and asserting otherwise fails a correct
   carousel (it did, first run). Front = the largest projected width. */
const front=await t.evaluate(()=>[...document.querySelectorAll('.mgr-ring .scene-obj')]
  .map(e=>e.getBoundingClientRect()).sort((a,b)=>b.width-a.width)[0]);
ok('front mobile face fits the viewport', front.left>-8 && front.right<398, `${front.left.toFixed(0)}..${front.right.toFixed(0)} of 390`);
const mgeo = await t.evaluate(()=>{const f=document.querySelector('.mgr-ring .obj-automation');
  return {w:parseFloat(getComputedStyle(f).width),
          r:new DOMMatrixReadOnly(getComputedStyle(f).transform).m43};});
ok('mobile keeps the apothem ratio', Math.abs(mgeo.r/mgeo.w-0.28868)<0.004,
   `radius/width = ${(mgeo.r/mgeo.w).toFixed(5)}`);
await t.close();

const r=await b.newPage({viewport:{width:1180,height:740},reducedMotion:'reduce'});
await r.goto(URL,{waitUntil:'networkidle'}); await r.waitForTimeout(600);
ok('reduced motion stops the ring', await r.evaluate(()=>getComputedStyle(document.querySelector('.mgr-ring')).animationName)==='none');
const vis=await r.evaluate(()=>[...document.querySelectorAll('.mgr-ring .scene-obj')].map(e=>{const b=e.getBoundingClientRect(); return b.width>60&&b.height>60&&b.left>-40&&b.right<innerWidth+40&&getComputedStyle(e).visibility!=='hidden';}));
ok('all three readable when stopped', vis.length===3&&vis.every(Boolean), JSON.stringify(vis));
await r.close(); await b.close();
console.log(fail?`\n${fail} FAILED`:'\nall carousel behaviours pass');
process.exit(fail?1:0);
