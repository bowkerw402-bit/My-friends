/**
 * hero-shot.mjs — capture the REAL BBS hero (app/MonogramV2.tsx) at post size.
 *
 * Why this exists: the flat cards I generated were not good enough, and the locked
 * monogram cutout fringes white at large sizes. The hero component is the treatment
 * Will approved (two-tone shader, Fresnel champagne rim, studio env), so posts should
 * use IT rather than an imitation of it.
 *
 * The generic snap.mjs fires too early here: it captures before the 6.4MB GLB has
 * loaded and the canvas has painted, which yields blueprint guides and no mark. This
 * waits for the canvas to actually contain non-uniform pixels before shooting.
 *
 * Requires the bbs-dev server running (launch.json config "bbs-dev").
 *
 * Usage: node hero-shot.mjs <baseUrl> <out-dir> [pose1,pose2,...]
 */
import { createRequire } from 'node:module';
import { mkdirSync } from 'node:fs';
import { join, resolve } from 'node:path';

const require = createRequire('C:/Users/bowke/OneDrive/Desktop/CLAUDE/tools/visual-qa/package.json');
const { chromium } = require('playwright');

const [, , baseUrl, outDir, posesArg] = process.argv;
if (!baseUrl || !outDir) {
  console.error('usage: node hero-shot.mjs <baseUrl> <out-dir> [poses]');
  process.exit(2);
}
const poses = (posesArg ?? '1').split(',');
mkdirSync(resolve(outDir), { recursive: true });

const browser = await chromium.launch({
  args: ['--use-gl=angle', '--use-angle=gl', '--enable-unsafe-swiftshader'],
});
const page = await browser.newPage({
  viewport: { width: 1080, height: 1350 },
  deviceScaleFactor: 1,
});

for (const pose of poses) {
  await page.goto(`${baseUrl}/hero-v2?pose=${pose}`, { waitUntil: 'networkidle', timeout: 60000 });

  // Wait for the WebGL canvas to hold an actual image. A canvas exists immediately;
  // what matters is whether the GLB has loaded and painted into it.
  await page.waitForFunction(() => {
    const c = document.querySelector('canvas');
    if (!c || !c.width) return false;
    const gl = c.getContext('webgl2') ?? c.getContext('webgl');
    if (!gl) return false;
    const w = 60, h = 60;
    const px = new Uint8Array(w * h * 4);
    gl.readPixels(
      Math.floor(c.width / 2) - 30, Math.floor(c.height / 2) - 30,
      w, h, gl.RGBA, gl.UNSIGNED_BYTE, px
    );
    // Non-uniform pixels in the centre means geometry is drawn, not just cleared ground.
    let min = 255, max = 0;
    for (let i = 0; i < px.length; i += 4) {
      const lum = px[i] * 0.3 + px[i + 1] * 0.6 + px[i + 2] * 0.1;
      if (lum < min) min = lum;
      if (lum > max) max = lum;
    }
    return max - min > 12;
  }, { timeout: 45000 }).catch(() => {
    console.warn(`  ! pose ${pose}: canvas never showed geometry, shooting anyway`);
  });

  await page.waitForTimeout(1200); // let the rim ignite and the mark settle

  const file = join(resolve(outDir), `hero-pose-${pose}.png`);
  await page.screenshot({ path: file });
  console.log(`shot hero-pose-${pose}.png`);
}

await browser.close();
console.log(`\nwritten to ${resolve(outDir)}`);
