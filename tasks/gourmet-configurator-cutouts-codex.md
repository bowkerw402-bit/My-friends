# Codex Task — Gourmet Scoops: Build-a-Scoop configurator cutouts

**From:** Claude (handoff)  ·  **Date:** 2026-07-11  ·  **Priority:** normal
**Continues:** your thread `019f507d-f1b7-7cb1-b683-cbcf37cbe5aa` (the "Pick your size" flavour boards)

## Why
You made 8 gorgeous per-flavour **size boards** (waffle cone / regular cup / large cup) + a combined grid. Claude already pushed those to the **menu page** (`menu.html`) — done, don't touch that.

But the **Build-a-Scoop configurator** (`gourmet-scoops.html#build`) still swaps in the OLD single-scoop cutouts, which don't match your new style. Your boards are 3-size composites, so they can't feed the configurator — it needs **single-item cutouts**. That's this job.

## The job
Produce **24 single-scoop cutouts** — one image per (flavour × size) — in the **exact same style as your new boards** (softened premium tones, corrected straight waffle-cone shape, the smaller large-cup proportions, per-flavour garnish). Each image = ONE item, centered, hero-framed (like the current `raspberry-waffle.png`).

### Output location (overwrite the existing files)
`C:\Users\bowke\OneDrive\Documents\Claude\Projects\C.T business\site\photos\scoops\`

### Exact filenames (these are hard-coded in the configurator — do not rename)
Pattern: `{fruitId}-{sizeKey}.png`

- fruitId ∈ `banana, blueberry, raspberry, mango, pineapple, dragonfruit, lychee, cherry-seasonal`
- sizeKey ∈ `waffle` (Waffle Cone), `regular` (Regular Cup), `large` (Large Cup)

So: `banana-waffle.png, banana-regular.png, banana-large.png, blueberry-waffle.png … cherry-seasonal-large.png` (24 total).
⚠️ Cherry's id is **`cherry-seasonal`**, not `cherry`.

### Format (match existing exactly so the swap is seamless)
- **300×430 px portrait** (or render 2× at 600×860 and downscale — but final files must display at 300:430 aspect). Existing files are 300×430 RGB.
- **Warm cream studio background** identical to your boards (NOT transparent — existing are baked RGB). Same soft contact shadow.
- Single item centered, filling the frame like a hero shot (see reference below). Consistent scale, lighting, and camera height across all 24 so flipping fruit/size in the configurator looks like one product line.

### Style must match the boards
- `waffle` = soft-serve in the straight waffle cone (your corrected cone shape).
- `regular` = soft-serve in the small branded Gourmet Scoops cup.
- `large` = soft-serve in the larger branded cup (bigger portion — but the **reduced** large-cup swirl from your last fix, not the oversized one).
- Per-flavour colour + garnish, using the softened/muted tones from the combined grid: raspberry (raspberry on top), banana (banana slice), **blueberry (light creamy lavender — the softened tone, not the strong purple)**, mango (mango chunk), pineapple (pineapple wedge), dragonfruit (dragonfruit piece), lychee (lychee ball), cherry (cherry).

### Reference images
- Your new boards (style source): `…\site\photos\menu-boards\{flavour}.png` (raspberry, banana, blueberry, mango, pineapple, dragonfruit, lychee, cherry, all-flavours-grid)
- Framing/scale reference (how a single cutout should sit): `…\site\photos\scoops\raspberry-waffle.png`
- Your originals: `~/.codex/generated_images/019f507d-f1b7-7cb1-b683-cbcf37cbe5aa/`

## Acceptance
- 24 files, correct names, in the scoops folder, each 300:430 portrait.
- Style visibly matches the boards; blueberry is the softened lavender; large cups are the reduced size.
- Sanity check: open `http://localhost:8090/gourmet-scoops.html#build`, click through every fruit and every size — the photo swaps and always matches the selection.

## Do NOT
- Don't touch `menu.html` (Claude already updated it with your boards + WebP).
- Don't change `lib/cone-background.js` (Claude enlarged the 3D cone).
- Don't deploy to Netlify — local only until Will approves.

## When done
Append a short entry to `CLAUDE OBSIDIAN/.ai/HANDOFF.md` (what you generated, any deviations), so Claude can pick up verification/deploy.
