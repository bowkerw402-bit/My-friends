/* TTF -> three.js typeface.json.
   Path opcode order matters and is NOT what you'd guess from the SVG-ish letters:
     m x y                     moveTo
     l x y                     lineTo
     q endX endY ctrlX ctrlY   quadratic  (END POINT FIRST, then the control point)
     b endX endY c1x c1y c2x c2y  cubic   (END POINT FIRST, then both controls)
   three.js FontLoader reads them in that order; emitting SVG order silently produces
   scrambled glyphs. */
import opentype from 'opentype.js';
import { readFileSync, writeFileSync } from 'node:fs';

const [src, out, weight] = process.argv.slice(2);
const buf = readFileSync(src);
const font = opentype.parse(buf.buffer.slice(buf.byteOffset, buf.byteOffset + buf.byteLength));
/* NOTE: opentype.js 2.0's variation.set() does NOT apply gvar deltas to glyph outlines (verified
   with a fresh parse — 400 and 700 produce byte-identical paths). So this is the DEFAULT MASTER,
   weight 400. Mitigate Garamond's fine hairlines with a smaller bevel, not a heavier weight. */
if (weight && font.variation) font.variation.set({ wght: +weight });

const CHARS = ' ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.,:;\'"!?&()-–—·/';
const R = v => Math.round(v);
const glyphs = {};
for (const ch of CHARS) {
  const g = font.charToGlyph(ch);
  if (!g) continue;
  /* g.path — NOT g.getPath(). getPath() returns RENDER coordinates: y-flipped into screen space
     with the baseline offset applied, which produces upside-down glyphs in three.js. glyph.path is
     the raw outline in font units with y UP, which is what the typeface format stores. */
  const p = g.path;
  let o = [];
  for (const c of p.commands) {
    if (c.type === 'M') o.push('m', R(c.x), R(c.y));
    else if (c.type === 'L') o.push('l', R(c.x), R(c.y));
    else if (c.type === 'Q') o.push('q', R(c.x), R(c.y), R(c.x1), R(c.y1));
    else if (c.type === 'C') o.push('b', R(c.x), R(c.y), R(c.x1), R(c.y1), R(c.x2), R(c.y2));
  }
  const bb = p.getBoundingBox();
  glyphs[ch] = {
    ha: R(g.advanceWidth),
    x_min: isFinite(bb.x1) ? R(bb.x1) : 0,
    x_max: isFinite(bb.x2) ? R(bb.x2) : 0,
    o: o.join(' '),
  };
}
const data = {
  glyphs,
  familyName: (font.names.fontFamily && (font.names.fontFamily.en || Object.values(font.names.fontFamily)[0])) || 'EB Garamond',
  ascender: R(font.ascender),
  descender: R(font.descender),
  underlinePosition: -100, underlineThickness: 50,
  boundingBox: { yMin: R(font.descender), xMin: 0, yMax: R(font.ascender), xMax: font.unitsPerEm },
  resolution: font.unitsPerEm,
  original_font_information: { full_font_name: 'EB Garamond ' + (weight || 400) },
  cssFontWeight: String(weight || 400),
  cssFontStyle: 'normal',
};
writeFileSync(out, JSON.stringify(data));
console.log(out, '| glyphs:', Object.keys(glyphs).length, '| resolution:', data.resolution,
            '| kb:', Math.round(JSON.stringify(data).length / 1024));
