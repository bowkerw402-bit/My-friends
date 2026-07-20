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
const PROFILE = 1000;   // square avatar; Facebook and Instagram both crop it to a circle

function esc(s = '') {
  return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

const FONT = 'Georgia,"Times New Roman",serif';   // matches the site's serif headline

/* FIVE IDENTICAL POSTS READ AS TEMPLATED and the feed scrolls past them. Each variant
 * keeps the brand fixed (same mark, same palette, same serif) and changes only the
 * COMPOSITION, so the week has rhythm without drifting off-brand.
 *   mark  — mark lower-right, type top-left        (the anchor layout)
 *   crop  — mark blown up and cropped, type over the clear upper band
 *   navy  — inverted: navy ground, ivory type, mark small and low
 *   quiet — no mark at all, type and rule only, generous space
 */
const VARIANTS = {
  mark:  { ground: IVORY, ink: NAVY_DEEP, markCss: 'right:-70px;bottom:-50px;width:660px', fade: true },
  /* Cropped big, and pushed well below the type. The render's own ivory ground is what
     lets it bleed seamlessly, so crop stays on ivory. */
  crop:  { ground: IVORY, ink: NAVY_DEEP, markCss: 'right:-240px;bottom:-300px;width:1120px', fade: true },
  /* NO MARK on navy. The hero render carries a baked ivory background, so on a navy
     ground it renders as a hard white box. The transparent cutout is the alternative but
     it fringes white, which is worse on navy. An inverted type-only card is cleaner than
     either, and gives the feed a genuine change of key. */
  navy:  { ground: NAVY_DEEP, ink: '#efece4', markCss: null, fade: false },
  quiet: { ground: IVORY, ink: NAVY_DEEP, markCss: null, fade: false },
};

function card(post) {
  const kicker = post.kicker ?? "BOWKER'S BUSINESS SERVICES";
  const footer = post.footer ?? 'bowkerbusinessesservices.com';
  const v = VARIANTS[post.variant] ?? VARIANTS.mark;
  const len = (post.stat ? String(post.stat).length : 0) + (post.text?.length ?? 0);
  let size = len > 130 ? 62 : len > 90 ? 70 : len > 55 ? 80 : 92;
  if (post.variant === 'quiet') size = Math.round(size * 1.18); // no mark, so type carries it

  const body = post.stat
    ? `<div class="stat">${esc(post.stat)}</div><div class="sub">${esc(post.text)}</div>`
    : `<div class="head" style="font-size:${size}px">${esc(post.text)}</div>`;

  return `<!doctype html><html><head><meta charset="utf-8"><style>
  *{margin:0;padding:0;box-sizing:border-box}
  html,body{width:${W}px;height:${H}px}
  body{background:${v.ground};font-family:${FONT};color:${v.ink};position:relative;overflow:hidden}
  /* The mark sits lower-right, bled off the edge, so it reads as an object in the frame
     rather than a logo pasted on. Its own ivory ground melts into the page ground. */
  /* Mark low and right, clear of the type. The text block sits top-left, so the two
     never overlap: an overlapping headline was the first thing that read as amateur. */
  .mark{position:absolute;${v.markCss ?? 'display:none'}}
  /* Melts the render's edges into the page ground, and keeps the upper band clear so
     the headline always sits on flat colour rather than on top of the mark. */
  .fade{position:absolute;inset:0;
    background:linear-gradient(to bottom, ${v.ground} 0%, ${v.ground} 34%, transparent 46%),
               linear-gradient(to right, ${v.ground} 0%, transparent 16%);
    ${v.fade ? '' : 'display:none'}}
  .plate{position:absolute;inset:0;padding:100px 92px;
    display:flex;flex-direction:column;justify-content:flex-start}
  .body{margin-top:74px}
  .kicker{font-family:"Segoe UI",system-ui,sans-serif;font-size:20px;letter-spacing:.22em;
    text-transform:uppercase;color:${CHAMPAGNE};font-weight:600}
  .rule{width:72px;height:2px;background:${CHAMPAGNE};margin-top:24px}
  .head{font-weight:700;line-height:1.16;letter-spacing:-.012em;max-width:12ch;color:${v.ink}}
  .stat{font-size:180px;font-weight:700;line-height:1;color:${v.ink};letter-spacing:-.035em}
  .sub{font-size:50px;font-weight:400;line-height:1.28;margin-top:22px;max-width:13ch;color:${v.ink}}
  .foot{position:absolute;left:92px;bottom:96px;
    font-family:"Segoe UI",system-ui,sans-serif;font-size:25px;color:${CHAMPAGNE};letter-spacing:.04em}
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

/* Square avatar. The mark is inset generously because both platforms crop to a circle
 * and then shrink it to ~40px in a feed: anything tight to the edge gets clipped. */
function profile(post) {
  return `<!doctype html><html><head><meta charset="utf-8"><style>
  *{margin:0;padding:0;box-sizing:border-box}
  html,body{width:${PROFILE}px;height:${PROFILE}px}
  body{background:${IVORY};position:relative;overflow:hidden;
    display:flex;align-items:center;justify-content:center}
  img{width:74%;max-width:none}
  </style></head><body><img src="${HERO}" alt=""></body></html>`;
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
  const size = post.layout === 'cover'
    ? { width: COVER_W, height: COVER_H }
    : post.layout === 'profile'
      ? { width: PROFILE, height: PROFILE }
      : { width: W, height: H };
  await page.setViewportSize(size);
  const html = post.layout === 'cover' ? cover(post)
    : post.layout === 'profile' ? profile(post)
    : card(post);
  await page.setContent(html, { waitUntil: 'load' });
  await page.screenshot({ path: join(resolve(outDir), `${post.id}.png`) });
  console.log(`rendered ${post.id}.png`);
}

await browser.close();
console.log(`\n${posts.length} images written to ${resolve(outDir)}`);
