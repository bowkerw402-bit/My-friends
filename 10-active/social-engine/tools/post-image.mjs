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
import { join, resolve } from 'node:path';

const require = createRequire('C:/Users/bowke/OneDrive/Desktop/CLAUDE/tools/visual-qa/package.json');
const { chromium } = require('playwright');

const NAVY = '#061b3a';
const NAVY_2 = '#0a274d';
const CHAMPAGNE = '#c9ae78';
const BONE = '#e8e4db';

const W = 1080;
const H = 1350; // portrait: more feed real estate than square, better reach

function esc(s = '') {
  return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
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
    background:${NAVY};
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
    opacity:.30;
  }
  .glow{
    position:absolute;left:-20%;top:-15%;width:90%;height:70%;
    background:radial-gradient(closest-side, rgba(201,174,120,.10), transparent);
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
  .head{font-weight:600;line-height:1.22;letter-spacing:-.015em;max-width:15ch}
  .stat{
    font-size:170px;font-weight:700;line-height:1;color:${CHAMPAGNE};
    letter-spacing:-.03em;
  }
  .sub{font-size:52px;font-weight:400;line-height:1.3;margin-top:28px;max-width:17ch}
  .foot{font-size:26px;color:${CHAMPAGNE};letter-spacing:.05em}
  </style></head><body>
    <div class="grid"></div><div class="glow"></div>
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
  await page.setContent(card(post), { waitUntil: 'load' });
  const file = join(resolve(outDir), `${post.id}.png`);
  await page.screenshot({ path: file });
  console.log(`rendered ${post.id}.png`);
}

await browser.close();
console.log(`\n${posts.length} images written to ${resolve(outDir)}`);
