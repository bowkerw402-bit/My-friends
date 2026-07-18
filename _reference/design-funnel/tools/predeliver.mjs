#!/usr/bin/env node
/*
 * predeliver.mjs — THE SHOW / NO-SHOW GATE.
 *
 * Built 2026-07-19 out of the council on "why did the lake hero take 14 rounds".
 *
 * WHY THIS EXISTS, AND WHY IT IS NOT ANOTHER CHECKLIST
 * ---------------------------------------------------
 * The lake build already had a 1088-line playbook and a calibration file measuring Will's taste in
 * numbers. Both existed by 20:03. Five more rounds shipped after that (v3.7 20:47, v3.8 21:01,
 * v3.9 21:19, v4.0 22:01, v4.1 22:22) and neither artifact was opened during any of them. Earlier,
 * two golds shipped ABOVE Will's own recorded chroma ceiling while the ceiling sat in a file on
 * disk. Conclusion, from evidence rather than theory: **a document that CAN be skipped IS skipped.**
 *
 * The existing QA gate did not help either, for a different and worse reason: it emitted a
 * structurally identical verdict — "PASS ... overall INCONCLUSIVE (WebGL)" — on v1, which Will
 * approved on sight, AND on v2, v3 and v3.2, which he rejected outright. It even has a check named
 * `taste` that PASSED on every single build he rejected. A verdict that is identical either side of
 * the only outcome that matters carries zero information.
 *
 * So this is deliberately a different KIND of object:
 *   - It is ON-PATH. The rule is: you do not show Will a build until this exits 0. It cannot be
 *     quietly not-read, because it stands between the build and delivery.
 *   - Its expected values are READ OUT of files Will already approved (brands/*.json, feel.json,
 *     the project's own stylesheet). The builder does not get to author the pass condition. That is
 *     what stops it becoming another self-written justification.
 *   - It has NO advisory verdict for the things it measures. INCONCLUSIVE is poison: an advisory
 *     verdict is always overridden by the party under time pressure. Every check here is either a
 *     hard number or it is not included.
 *   - It DIFFS against the last approved checkpoint where one exists. The only two rounds in the
 *     whole build that actually resolved anything (v3.4, v4.1) were comparisons against a
 *     known-good artifact, not rule-checks.
 *
 * Usage:
 *   node predeliver.mjs <url> --brand=aplakeside [--ref=<approved.html url>] [--region=x,y,w,h]
 *   node predeliver.mjs <url> --brand=aplakeside --json
 *
 * Exit 0 = safe to show. Exit 1 = do not show; fix the drift first.
 */
import { chromium } from 'playwright';
import { PNG } from 'pngjs';
import { readFileSync, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { resolve, join } from 'node:path';

const argv = process.argv.slice(2);
const url = argv.find(a => !a.startsWith('--'));
const flag = (k, d) => { const a = argv.find(x => x.startsWith('--' + k + '=')); return a ? a.split('=')[1] : d; };
const asJson = argv.includes('--json');
if (!url) {
  console.error('usage: node predeliver.mjs <url> --brand=<id> [--ref=<url>] [--region=x,y,w,h]');
  process.exit(2);
}

const BENCH = resolve('C:/Users/bowke/OneDrive/Desktop/CLAUDE/tools/design-bench');
const brandId = flag('brand', null);

/* ---------- expected values, READ from Will's approved files ---------- */
const { hexToOklch } = await import('file://' + join(BENCH, 'lib', 'oklch.mjs').replace(/\\/g, '/'));
const feel = JSON.parse(readFileSync(join(BENCH, 'feel.json'), 'utf8'));

function brandFeel(id) {
  // brands/<id>.json may name its feel; default to Will's default register.
  const bp = join(BENCH, 'brands', id + '.json');
  let feelName = 'quiet-confidence';
  let brand = null;
  if (existsSync(bp)) {
    brand = JSON.parse(readFileSync(bp, 'utf8'));
    if (brand.feel) feelName = brand.feel;
  }
  return { feelName, spec: feel.feels[feelName], brand };
}
const { feelName, spec, brand } = brandFeel(brandId || 'aplakeside');
if (!spec) { console.error('no feel spec for brand ' + brandId); process.exit(2); }

const EXPECT = {
  feel: feelName,
  accentChroma: spec.colour.accentChroma,   // {min,max}
  groundL: spec.colour.groundL,             // {min,max}
};

/* ---------- helpers ---------- */
function oklchOfRGB(r, g, b) {
  const hex = '#' + [r, g, b].map(v => v.toString(16).padStart(2, '0')).join('');
  return hexToOklch(hex);
}

async function capture(pageUrl) {
  const browser = await chromium.launch();
  const ctx = await browser.newContext({ viewport: { width: 1280, height: 720 }, deviceScaleFactor: 1 });
  const page = await ctx.newPage();
  const errors = [];
  page.on('pageerror', e => errors.push(String(e.message)));
  page.on('console', m => { if (m.type() === 'error') errors.push(m.text()); });
  await page.goto(pageUrl, { waitUntil: 'networkidle', timeout: 45000 });
  await page.waitForTimeout(11000);

  const facts = await page.evaluate(() => {
    const c = document.querySelector('canvas');
    const styles = getComputedStyle(document.body);
    // every font-family actually rendered in the document
    const fams = new Set();
    document.querySelectorAll('body, body *').forEach(el => {
      if (!el.getClientRects().length) return;
      const f = getComputedStyle(el).fontFamily;
      if (f) fams.add(f.split(',')[0].replace(/["']/g, '').trim());
    });
    // any three.js typeface the page loads
    const fontUrls = performance.getEntriesByType('resource')
      .map(r => r.name).filter(n => /typeface\.json$/i.test(n));
    return {
      dpr: window.devicePixelRatio,
      buffer: c ? { w: c.width, h: c.height } : null,
      css: c ? { w: c.clientWidth, h: c.clientHeight } : null,
      families: [...fams],
      typefaces: fontUrls,
      bodyFont: styles.fontFamily,
    };
  });
  const shot = await page.screenshot();
  await browser.close();
  return { facts, png: PNG.sync.read(shot), errors };
}

/* ---------- measurements ---------- */
/* MEDIAN, not max. A max-pixel statistic is dominated by specular highlights and bloom, which add
 * chroma that is not the material's. Measured on this build: max 0.1046 vs median 0.1037 happened
 * to agree, but only because the distribution was tight — on a scene with a strong glint they
 * diverge badly and the gate reports the highlight instead of the accent. */
function accentMedian(png, x0, y0, x1, y1) {
  const cs = [];
  for (let y = y0; y < y1; y++) for (let x = x0; x < x1; x++) {
    const i = (png.width * y + x) << 2;
    const o = oklchOfRGB(png.data[i], png.data[i + 1], png.data[i + 2]);
    if (!o || o.L < 0.35 || o.C < 0.045) continue;
    cs.push(o.C);
  }
  cs.sort((a, b) => a - b);
  return cs.length > 40 ? cs[Math.floor(cs.length / 2)] : NaN;
}

function measure(png, region) {
  const [rx, ry, rw, rh] = region;
  const counts = new Map();
  for (let y = ry; y < ry + rh; y++) {
    for (let x = rx; x < rx + rw; x++) {
      const i = (png.width * y + x) << 2;
      const r = png.data[i], g = png.data[i + 1], b = png.data[i + 2];
      const key = (r << 16 | g << 8 | b).toString(16).padStart(6, '0');
      counts.set(key, (counts.get(key) || 0) + 1);
    }
  }
  const maxC = accentMedian(png, rx, ry, rx + rw, ry + rh);
  const maxCpx = null;
  /* two independent samples of "the accent" in one frame — the subject, and the whole frame
     (which is dominated by whatever other accent-coloured elements exist, e.g. a logo mark). */
  const accentByRegion = [
    { name: 'subject', C: maxC },
    { name: 'frame', C: accentMedian(png, 0, 0, png.width, png.height) },
  ].filter(r => Number.isFinite(r.C));
  // ground = dominant colour of the lower third of the frame
  const gcounts = new Map();
  for (let y = Math.floor(png.height * 0.72); y < png.height - 40; y += 2) {
    for (let x = 60; x < png.width - 60; x += 2) {
      const i = (png.width * y + x) << 2;
      const key = (png.data[i] << 16 | png.data[i + 1] << 8 | png.data[i + 2]).toString(16).padStart(6, '0');
      gcounts.set(key, (gcounts.get(key) || 0) + 1);
    }
  }
  const groundHex = [...gcounts.entries()].sort((a, b) => b[1] - a[1])[0][0];
  const total = [...counts.values()].reduce((a, b) => a + b, 0);
  const top = [...counts.entries()].sort((a, b) => b[1] - a[1])[0];
  return {
    accentChroma: maxC,
    accentL: maxCpx ? maxCpx.L : null,
    ground: hexToOklch('#' + groundHex),
    groundHex: '#' + groundHex,
    flatPct: 100 * top[1] / total,
    flatHex: '#' + top[0],
    uniqueColours: counts.size,
    accentByRegion,
  };
}

/* ---------- run ---------- */
const region = (flag('region', '400,240,480,90')).split(',').map(Number);
const cand = await capture(url);
const m = measure(cand.png, region);

const checks = [];
const push = (name, verdict, detail, why) => checks.push({ name, verdict, detail, why });

// 1. RESOLUTION — catches v3.7: a "quality fix" that was a total no-op on HiDPI and passed every
//    headless check because headless runs at deviceScaleFactor 1, the very variable under test.
const f = cand.facts;
if (f.buffer && f.css) {
  const ratio = f.buffer.w / f.css.w;
  const native = f.dpr;
  push('resolution',
    ratio > native + 0.01 ? 'PASS' : 'BLOCK',
    `buffer ${f.buffer.w}x${f.buffer.h} vs css ${f.css.w}x${f.css.h} @dpr ${native} => ${ratio.toFixed(2)}x`,
    'ratio must EXCEED devicePixelRatio, or nothing is being supersampled at all');
} else push('resolution', 'SKIP', 'no canvas', '');

// 2. BRAND TYPEFACE — catches v4.0: the hero wordmark was the only off-brand type on the page,
//    true since round 1, and nobody ever grepped the project's own stylesheet.
if (brand && brand.tokens && brand.tokens.file) {
  const cssPath = resolve(brand.root || '.', brand.tokens.file);
  if (existsSync(cssPath)) {
    const css = readFileSync(cssPath, 'utf8');
    const serif = (css.match(/--serif\s*:\s*'([^']+)'/) || [])[1];
    if (serif) {
      const used = f.families.some(x => x.toLowerCase() === serif.toLowerCase());
      const tf = f.typefaces.join(',').toLowerCase();
      const tfOk = !f.typefaces.length || tf.includes(serif.toLowerCase().replace(/\s+/g, ''));
      push('brand-typeface', used && tfOk ? 'PASS' : 'BLOCK',
        `site --serif = "${serif}" | rendered: ${f.families.join(', ')} | 3D typeface: ${f.typefaces.map(u => u.split('/').pop()).join(',') || 'none'}`,
        'the 3D wordmark must use the SAME face as the site specimen');
    }
  }
}

/* 3. ACCENT CHROMA — ADVISORY ONLY, and the reason is worth stating, because getting this wrong is
 *    how a gate starts crying wolf and gets ignored (which is how the LAST gate died).
 *
 *    feel.json's band (0.070-0.092) was measured from Will's approved SOURCE TOKENS. It does NOT
 *    transfer to rendered PIXELS: rendering adds or removes chroma via lighting, exposure, emissive
 *    and the grade pass. Proof, measured: v1 — the build Will approved on sight, instantly — renders
 *    its gold at median chroma 0.054, i.e. far BELOW the source band. The current build renders at
 *    0.081, almost exactly the token value. An absolute band applied to pixels would have BLOCKED
 *    the single most-approved artifact in the project.
 *
 *    So the band is reported for context and never blocks. What blocks is DRIFT VERSUS AN APPROVED
 *    REFERENCE (below) — the council's finding that the only two rounds which ever resolved anything
 *    were diffs against a known-good build, not rule-checks. */
const ac = EXPECT.accentChroma;
const inBand = m.accentChroma >= ac.min && m.accentChroma <= ac.max;
push('accent-chroma',
  'INFO',
  `rendered median ${m.accentChroma.toFixed(4)} | source-token band ${ac.min}-${ac.max} (${inBand ? 'inside' : 'outside — expected, see note'})`,
  '');

/* 3b. INTERNAL CONSISTENCY — every gold element in one frame should be the SAME gold. This is the
 *     check that has no reference-build dependency, so it works on a brand-new project too. */
if (m.accentByRegion && m.accentByRegion.length > 1) {
  const cs = m.accentByRegion.map(r => r.C).filter(Number.isFinite);
  const spread = Math.max(...cs) - Math.min(...cs);
  push('accent-consistency', spread <= 0.020 ? 'PASS' : 'BLOCK',
    m.accentByRegion.map(r => `${r.name} ${r.C.toFixed(4)}`).join(' | ') + ` => spread ${spread.toFixed(4)}`,
    'two golds in the same frame at different chroma read as two different golds');
}

// 4. GROUND LIGHTNESS — the mechanism behind "daytime but keep the dusk quality".
const gl = EXPECT.groundL;
push('ground-lightness',
  (m.ground.L >= gl.min - 0.03 && m.ground.L <= gl.max + 0.03) ? 'PASS' : 'BLOCK',
  `measured L=${m.ground.L.toFixed(3)} (${m.groundHex}) | house band ${gl.min}-${gl.max}`,
  'his house ground is L .20-.27 across three brands; outside it the frame reads washed or crushed');

// 5. FLAT REGION — catches v4.1: extruded type rendering as single flat colours (plastic).
push('flat-region',
  m.flatPct < 6.0 ? 'PASS' : 'BLOCK',
  `largest single colour ${m.flatHex} = ${m.flatPct.toFixed(1)}% of subject band (${m.uniqueColours} unique)`,
  'a large exactly-uniform area means a surface has one normal and no micro-variation');

// 6. ERRORS — non-negotiable.
push('console', cand.errors.length ? 'BLOCK' : 'PASS',
  cand.errors.length ? cand.errors.slice(0, 3).join(' | ') : 'none', 'a build that throws is not shown');

/* ---------- optional diff against the last approved build ---------- */
let ref = null;
const refUrl = flag('ref', null);
if (refUrl) {
  const r = await capture(refUrl);
  const rm = measure(r.png, region);
  ref = { accentChroma: rm.accentChroma, groundL: rm.ground.L, flatPct: rm.flatPct };
  const drift = (a, b) => (b - a);
  const dC = drift(rm.accentChroma, m.accentChroma);
  const dL = drift(rm.ground.L, m.ground.L);
  const bad = Math.abs(dC) > 0.030 || Math.abs(dL) > 0.070;
  push('drift-vs-approved', bad ? 'BLOCK' : 'PASS',
    `accentC ${dC >= 0 ? '+' : ''}${dC.toFixed(4)} | groundL ${dL >= 0 ? '+' : ''}${dL.toFixed(3)} | flat ${drift(rm.flatPct, m.flatPct).toFixed(1)}pp  (ref: ${refUrl.split('/').pop()})`,
    'drifted materially from the last build Will approved — this is the check that would have caught the v3 gold cascade at v3.1 instead of v3.4');
}

/* ---------- report ---------- */
const blocked = checks.filter(c => c.verdict === 'BLOCK');
if (asJson) {
  console.log(JSON.stringify({ url, brand: brandId, feel: feelName, checks, measured: m, ref, blocked: blocked.length }, null, 1));
} else {
  console.log('\n  PRE-DELIVERY GATE — ' + (brandId || 'aplakeside') + ' / ' + feelName);
  console.log('  ' + '-'.repeat(76));
  for (const c of checks) {
    const tag = c.verdict === 'BLOCK' ? 'BLOCK' : c.verdict === 'PASS' ? ' ok  ' : c.verdict.padEnd(5);
    console.log(`  ${tag} ${c.name.padEnd(18)} ${c.detail}`);
    if (c.verdict === 'BLOCK' && c.why) console.log(`        ^ ${c.why}`);
  }
  console.log('  ' + '-'.repeat(76));
  console.log(blocked.length
    ? `  DO NOT SHOW — ${blocked.length} blocking drift(s). Fix, then re-run.\n`
    : `  SAFE TO SHOW.\n`);
}
process.exit(blocked.length ? 1 : 0);
