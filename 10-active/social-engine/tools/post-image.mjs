/**
 * post-image.mjs — render branded post images for the Social Engine.
 *
 * Instagram will not accept a text-only post, so every draft ships with a real PNG.
 * Palette is BBS-locked and measured (see _reference/design-funnel/calibration.md):
 * ground navy #061b3a sits at L=23%, the house ground; champagne #c9ae78 at chroma 0.078
 * is the flagship accent and must not drift upward into "too gold".
 *
 * Usage:  node post-image.mjs <spec.json> <out-dir>
 */
import { createRequire } from 'node:module';
import { readFileSync, mkdirSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
// The LOCKED BBS monogram, navy body with champagne edges, alpha cutout.
// Do not substitute or redraw this: the letterform is locked.
const MONOGRAM = 'data:image/png;base64,' +
  readFileSync(join(HERE, '..', 'assets', 'monogram.png')).toString('base64');

const require = createRequire('C:/Users/bowke/OneDrive/Desktop/CLAUDE/tools/visual-qa/package.json');
const { chromium } = require('playwright');

const NAVY = '#061b3a';
const NAVY_2 = '#0a274d';
const CHAMPAGNE = '#c9ae78';
const BONE = '#e8e4db';

const W = 1080;
const H = 1350; // portrait: more feed real estate than square, better reach
const COVER_W = 1640;
const COVER_H = 624; // Facebook Page cover

function esc(s = '') {
  return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

/** Wide Page-cover lockup. Same palette and grid, laid out horizontally. */
function cover(post) {
  return `<!doctype html><html><head><meta charset="utf-8"><style>
  *{margin:0;padding:0;box-sizing:border-box}
  html,body{width:${COVER_W}px;height:${COVER_H}px}
  body{
    background:${NAVY};
    font-family:"Segoe UI",system-ui,-apple-system,sans-serif;
    color:${BONE};position:relative;overflow:hidden;
  }
  .grid{
    position:absolute;inset:0;
    background-image:
      linear-gradient(${NAVY_2} 1px,transparent 1px),
      linear-gradient(90deg,${NAVY_2} 1px,transparent 1px);
    background-size:90px 90px;opacity:.30;
  }
  .glow{
    position:absolute;right:2%;top:-40%;width:55%;height:180%;
    background:radial-gradient(closest-side, rgba(201,174,120,.16), transparent);
  }
  .mark{
    position:absolute;right:118px;top:50%;transform:translateY(-50%);height:132%;
    filter:drop-shadow(0 30px 60px rgba(0,0,0,.55));
  }
  .plate{
    position:absolute;inset:0;padding:0 110px;
    display:flex;flex-direction:column;justify-content:center;
  }
  .kicker{
    font-size:22px;letter-spacing:.22em;text-transform:uppercase;
    color:${CHAMPAGNE};font-weight:600;
  }
  .rule{width:78px;height:2px;background:${CHAMPAGNE};margin:24px 0 30px}
  .head{font-size:64px;font-weight:600;line-height:1.2;letter-spacing:-.015em;max-width:22ch}
  </style></head><body>
    <div class="grid"></div><div class="glow"></div>
    <img class="mark" src="${MONOGRAM}" alt="">
    <div class="plate">
      <div class="kicker">${esc(post.kicker ?? 'BOWKER BUSINESS SERVICES')}</div>
      <div class="rule"></div>
      <div class="head">${esc(post.text)}</div>
    </div>
  </body></html>`;
}

function card(post) {
  const kicker = post.kicker ?? 'BOWKER BUSINESS SERVICES';
  const footer = post.footer ?? 'bowkerbusinessesservices.com';

  // Headline scales down as it gets longer, so long lines never overflow the plate.
  const len = (post.stat ? post.stat.length : 0) + (post.text?.length ?? 0);
  const size = len > 150 ? 58 : len > 100 ? 66 : len > 60 ? 76 : 88;

  const body = post.stat
    ? `<div class="stat">${esc(post.stat)}</div><div class="sub">${esc(post.text)}</div>`
    : `<div class="head" style="font-size:${size}px">${esc(post.text)}</div>`;

  return `<!doctype html><html><head><meta charset="utf-8"><style>
  *{margin:0;padding:0;box-sizing:border-box}
  html,body{width:${W}px;height:${H}px}
  body{
    background:
      radial-gradient(120% 90% at 72% 68%, ${NAVY_2} 0%, ${NAVY} 62%);
    font-family:"Segoe UI",system-ui,-apple-system,sans-serif;
    color:${BONE};
    position:relative;
    overflow:hidden;
  }
  /* Blueprint construction grid, carried over from the locked BBS hero. Very low
     opacity: it should read as texture, never as decoration. */
  .grid{
    position:absolute;inset:0;
    background-image:
      linear-gradient(${NAVY_2} 1px,transparent 1px),
      linear-gradient(90deg,${NAVY_2} 1px,transparent 1px);
    background-size:90px 90px;
    opacity:.26;
  }
  /* The locked mark, bled off the lower-right corner so it reads as an object in
     the frame rather than a logo stuck on top of it. */
  .mark{
    position:absolute;right:-130px;bottom:-90px;width:760px;
    filter:drop-shadow(0 40px 70px rgba(0,0,0,.55));
    opacity:.97;
  }
  .glow{
    position:absolute;right:-5%;bottom:-10%;width:80%;height:60%;
    background:radial-gradient(closest-side, rgba(201,174,120,.16), transparent);
  }
  .plate{
    position:absolute;inset:0;
    padding:104px 96px;
    display:flex;flex-direction:column;justify-content:space-between;
  }
  .kicker{
    font-size:21px;letter-spacing:.20em;text-transform:uppercase;
    color:${CHAMPAGNE};font-weight:600;
  }
  .rule{width:74px;height:2px;background:${CHAMPAGNE};margin-top:26px}
  .head{font-weight:600;line-height:1.22;letter-spacing:-.015em;max-width:13ch;
    text-shadow:0 2px 24px rgba(6,27,58,.9)}
  .stat{
    font-size:170px;font-weight:700;line-height:1;color:${CHAMPAGNE};
    letter-spacing:-.03em;
  }
  .sub{font-size:52px;font-weight:400;line-height:1.3;margin-top:28px;max-width:14ch;
    text-shadow:0 2px 24px rgba(6,27,58,.9)}
  .foot{font-size:26px;color:${CHAMPAGNE};letter-spacing:.05em}
  </style></head><body>
    <div class="grid"></div><div class="glow"></div>
    <img class="mark" src="${MONOGRAM}" alt="">
    <div class="plate">
      <div><div class="kicker">${esc(kicker)}</div><div class="rule"></div></div>
      <div>${body}</div>
      <div class="foot">${esc(footer)}</div>
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
  const file = join(resolve(outDir), `${post.id}.png`);
  await page.screenshot({ path: file });
  console.log(`rendered ${post.id}.png`);
}

await browser.close();
console.log(`\n${posts.length} images written to ${resolve(outDir)}`);
