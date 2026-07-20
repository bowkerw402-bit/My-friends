/**
 * post-image.mjs — render branded post images for the Social Engine.
 *
 * Instagram will not accept a text-only post, so every draft ships with a real PNG.
 *
 * THE ASSET: public/monogram.png from the Bowker Business Events site, which is the
 * finished hero render Will approved and the exact image he pointed at. It is used as
 * a file, not re-rendered: the 3D hero needs a GPU that the agent sandbox does not have,
 * and reproducing the shader treatment by hand would only be an imitation of it.
 *
 * THE GROUND is the site's ivory, not navy, so posts read as the same object as the
 * homepage. Type is navy; champagne carries the kicker and rule.
 * Palette per _reference/design-funnel/calibration.md: champagne #c9ae78 at chroma 0.078
 * is the locked BBS accent and must not drift upward into "too gold".
 *
 * Usage:  node post-image.mjs <spec.json> <out-dir>
 */
import { createRequire } from 'node:module';
import { readFileSync, mkdirSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const require = createRequire('C:/Users/bowke/OneDrive/Desktop/CLAUDE/tools/visual-qa/package.json');
const { chromium } = require('playwright');

const HERE = dirname(fileURLToPath(import.meta.url));
const HERO = 'data:image/png;base64,' +
  readFileSync(join(HERE, '..', 'assets', 'monogram-hero.png')).toString('base64');

const IVORY = '#f2efe8';      // the site's hero ground
const NAVY = '#0d2340';       // headline navy, matches the mark's body
const NAVY_DEEP = '#061b3a';
const CHAMPAGNE = '#b2955c';  // kicker/rule: a touch deeper than #c9ae78 so it holds on ivory

const W = 1080;
const H = 1350;
const COVER_W = 1640;
const COVER_H = 624;

function esc(s = '') {
  return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

const FONT = 'Georgia,"Times New Roman",serif';   // matches the site's serif headline

function card(post) {
  const kicker = post.kicker ?? "BOWKER'S BUSINESS SERVICES";
  const footer = post.footer ?? 'bowkerbusinessesservices.com';
  const len = (post.stat ? String(post.stat).length : 0) + (post.text?.length ?? 0);
  const size = len > 130 ? 62 : len > 90 ? 70 : len > 55 ? 80 : 92;

  const body = post.stat
    ? `<div class="stat">${esc(post.stat)}</div><div class="sub">${esc(post.text)}</div>`
    : `<div class="head" style="font-size:${size}px">${esc(post.text)}</div>`;

  return `<!doctype html><html><head><meta charset="utf-8"><style>
  *{margin:0;padding:0;box-sizing:border-box}
  html,body{width:${W}px;height:${H}px}
  body{background:${IVORY};font-family:${FONT};color:${NAVY};position:relative;overflow:hidden}
  /* The mark sits lower-right, bled off the edge, so it reads as an object in the frame
     rather than a logo pasted on. Its own ivory ground melts into the page ground. */
  /* Mark low and right, clear of the type. The text block sits top-left, so the two
     never overlap: an overlapping headline was the first thing that read as amateur. */
  .mark{position:absolute;right:-70px;bottom:-50px;width:660px}
  .fade{position:absolute;right:0;bottom:0;width:720px;height:820px;
    background:linear-gradient(to top, ${IVORY} 0%, transparent 20%),
               linear-gradient(to right, ${IVORY} 0%, transparent 16%)}
  .plate{position:absolute;inset:0;padding:100px 92px;
    display:flex;flex-direction:column;justify-content:flex-start}
  .body{margin-top:74px}
  .foot{position:absolute;left:92px;bottom:96px}
  .kicker{font-family:"Segoe UI",system-ui,sans-serif;font-size:20px;letter-spacing:.22em;
    text-transform:uppercase;color:${CHAMPAGNE};font-weight:600}
  .rule{width:72px;height:2px;background:${CHAMPAGNE};margin-top:24px}
  .head{font-weight:700;line-height:1.16;letter-spacing:-.012em;max-width:12ch;color:${NAVY_DEEP}}
  .stat{font-size:180px;font-weight:700;line-height:1;color:${NAVY_DEEP};letter-spacing:-.035em}
  .sub{font-size:50px;font-weight:400;line-height:1.28;margin-top:22px;max-width:13ch;color:${NAVY}}
  .foot{font-family:"Segoe UI",system-ui,sans-serif;font-size:25px;color:${CHAMPAGNE};letter-spacing:.04em}
  </style></head><body>
    <img class="mark" src="${HERO}" alt=""><div class="fade"></div>
    <div class="plate">
      <div><div class="kicker">${esc(kicker)}</div><div class="rule"></div></div>
      <div class="body">${body}</div>
      <div class="foot">${esc(footer)}</div>
    </div>
  </body></html>`;
}

function cover(post) {
  return `<!doctype html><html><head><meta charset="utf-8"><style>
  *{margin:0;padding:0;box-sizing:border-box}
  html,body{width:${COVER_W}px;height:${COVER_H}px}
  body{background:${IVORY};font-family:${FONT};color:${NAVY_DEEP};position:relative;overflow:hidden}
  .mark{position:absolute;right:150px;bottom:-120px;width:620px}
  .fade{position:absolute;right:0;bottom:0;width:920px;height:100%;
    background:linear-gradient(to right, ${IVORY} 0%, transparent 30%)}
  .plate{position:absolute;inset:0;padding:0 110px;
    display:flex;flex-direction:column;justify-content:center}
  .kicker{font-family:"Segoe UI",system-ui,sans-serif;font-size:21px;letter-spacing:.24em;
    text-transform:uppercase;color:${CHAMPAGNE};font-weight:600}
  .rule{width:76px;height:2px;background:${CHAMPAGNE};margin:22px 0 28px}
  .head{font-size:62px;font-weight:700;line-height:1.16;max-width:20ch}
  </style></head><body>
    <img class="mark" src="${HERO}" alt=""><div class="fade"></div>
    <div class="plate">
      <div class="kicker">${esc(post.kicker ?? "BOWKER'S BUSINESS SERVICES")}</div>
      <div class="rule"></div>
      <div class="head">${esc(post.text)}</div>
    </div>
  </body></html>`;
}

const [, , specPath, outDir] = process.argv;
if (!specPath || !outDir) {
  console.error('usage: node post-image.mjs <spec.json> <out-dir>');
  process.exit(2);
}

const posts = JSON.parse(readFileSync(resolve(specPath), 'utf8'));
mkdirSync(resolve(outDir), { recursive: true });

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: 1 });

for (const post of posts) {
  const isCover = post.layout === 'cover';
  await page.setViewportSize(
    isCover ? { width: COVER_W, height: COVER_H } : { width: W, height: H }
  );
  await page.setContent(isCover ? cover(post) : card(post), { waitUntil: 'load' });
  await page.screenshot({ path: join(resolve(outDir), `${post.id}.png`) });
  console.log(`rendered ${post.id}.png`);
}

await browser.close();
console.log(`\n${posts.length} images written to ${resolve(outDir)}`);
