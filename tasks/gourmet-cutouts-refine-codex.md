# Codex Task — Gourmet Scoops configurator cutouts: REFINE pass

**From:** Claude (orchestrated with Will, 2026-07-12)  ·  **Priority:** normal
**Continues:** your cutout regen from earlier today (the 24 files in `…\site\photos\scoops\`, 600×860, regenerated ~15:04)

Will reviewed the live configurator and flagged 3 things. Claude audited all 24 images with a bbox script — hard numbers below so you're not guessing. Claude confirmed the **card CSS is already correct** (centered, consistent frame), so all three fixes are in the IMAGES only.

## Target folder / format (unchanged)
`C:\Users\bowke\OneDrive\Documents\Claude\Projects\C.T business\site\photos\scoops\` — keep the exact 24 filenames, 600×860 portrait, warm cream bg matching the site.

## 1. Make the scoop SCALE consistent
Current spread is too wide — the scoops don't match each other:
- scoop bbox **height 525–721px** (should be tight, ~±20px of a single target)
- scoop bbox **width 260–560px**
- Outliers: `lychee-waffle` tall/narrow (307×721), `blueberry-regular` short (418×525), `dragonfruit-waffle` narrow (326×714), `pineapple-large` wide (544×630).
**Fix:** normalize so the same VESSEL renders at the same size across every flavour. All `*-waffle` cones should be the same height/footprint; all `*-regular` cups the same; all `*-large` cups the same. Only the swirl colour/garnish changes between flavours — never the cone/cup scale or camera.

## 2. CENTER them consistently
- centre-X currently **45–56%** (target **50%**, ≤±2%). Off: `pineapple-large` 45%, `dragonfruit-regular` 56%.
- scoop TOP varies **9–34%** down the frame; bottoms are consistent ~95%.
**Fix:** center each scoop horizontally (50%), and use a consistent vertical anchor — same garnish-top % and same cone-tip-bottom % on every image, so swapping flavours/sizes in the configurator doesn't make the product jump around.

## 3. Make the waffle cones look REAL, not plastic
This is the big one. The current waffle cones read as smooth CGI/plastic: the grid is too perfect and uniform, the surface too glossy/even, lighting too soft.
**Fix — photographic waffle-cone realism:**
- Irregular, hand-made grid (slightly varying cell size, not a perfect mesh), real embossed depth in the ridges.
- Toasted colour VARIATION — darker caught edges, lighter valleys, a few slightly-scorched spots; not one flat tan.
- Matte, crumbly biscuit texture (fine crumb/grain), not a glossy sealed surface.
- Natural contact shadow. Reference a real gelato/soft-serve waffle cone photo, not a 3D render.
Apply the same realistic cone to all `*-waffle` images; the cups (`*-regular`/`*-large`) keep the branded paper look.

## Acceptance
- 24 files, same names, 600×860. Same vessel = same scale/position across all flavours (bbox height within ~±20px per vessel class, centre-X 48–52%).
- Waffle cones look photographic (crumb texture + toast variation), not plastic.
- Sanity check: open `http://localhost:8090/gourmet-scoops.html#build`, click through fruits AND sizes — the product should stay put and same-scale, only colour changing.

## Do NOT
- Don't touch the HTML/CSS (Claude owns the layout; the card display is already correct).
- Don't deploy — local until Will approves.

When done, append a note to `CLAUDE OBSIDIAN/.ai/HANDOFF.md` and Claude will re-audit + snap-verify the live configurator.
