# Codex Task — Gourmet Scoops 24 swaps: REGEN v2 (colour + texture + framing)

**From:** Claude (independent visual audit, with Will) · 2026-07-12 · **Priority:** active — Will is iterating on this now
**Supersedes:** `gourmet-cutouts-refine-codex.md` where they conflict. That note's framing/scale numbers still stand; this one ADDS the three things Will flagged after seeing the live set: **colour, texture, and an evolved reference.**

## Read first (full spec + evidence, don't guess)
`My-friends/claude/gourmet-scoops-audit-2026-07-12.md` — the complete audit, acceptance criteria, and the **locked flavour palette with exact hexes**.
- `My-friends/claude/gourmet-scoops-audit-sheet.png` — all 24 on a crosshair grid (what Claude saw).
- `My-friends/claude/gourmet-scoops-palette.html` — the swatch strip (open it).

## What changed since your last pass (the 3 new things)
1. **Reference evolved from waffle cone → branded CUP.** Will's target is banana soft-serve in the gold-logo cup with a banana-slice garnish. Vessels are intentional: **large + regular = cup, waffle = cone.** `banana-large` is the north star.
2. **Colour is inconsistent** — same fruit differs across its own 3 vessels (e.g. `mango-large` pale vs `mango-waffle` golden), two different backgrounds (cups warm-peach vignette vs cones flat cream), the 3 yellows blur together, lychee reads beige. → Use the **locked palette** (one body hex per fruit, reused across cup + cone, all 8 mutually distinct). One background/lighting for all 24.
3. **Texture too high / not smooth** (Will's words). → Creamier, softer surface, subtle sheen, minimal grain. Flecks only on raspberry/blueberry/dragonfruit/cherry and even those subtle. banana/pineapple/mango/lychee near-fleckless.

Plus the framing/scale normalisation from the earlier note still applies: same vessel = same size + tip/baseline Y + centre across every flavour.

## Output (unchanged)
`…\C.T business\site\photos\scoops\{fruit}-{large,regular,waffle}.png`, exact 24 filenames, 600×860, no baked text/labels/logo on the ice cream. **Don't touch the site repo or push.**

## Loop
Regenerate → tell Claude → **Claude re-runs the same audit on the new 24** (contact sheet + crosshair + full-res spot checks) and reports pass/fail honestly before anything is logged as accepted. Claude handles crop/normalise + wiring once the set passes.
