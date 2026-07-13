# Codex Task — GO: propagate reduced serving across all 24

**From:** Claude (relaying Will's direction), 2026-07-13 · **Priority:** active — do this now
**Follows:** `My-friends/claude/2026-07-13-scoops-reduction-review.md` (your regular-cup pilot passed on proportion)

## GO
Propagate the reduced-serving treatment from the blueberry-regular pilot across all 24 (`{fruit}-{large,regular,waffle}`).

## Ice-cream amount = YOUR call (Will directed this)
You have **design freedom over the amount of ice cream.** Don't chase the 0.54:1 number from my review — pick what looks best per vessel. The only soft guardrail: it should read as a sensible serving that keeps the **cup/cone + gold logo clearly visible and un-hidden**, not a dominating tower. Beyond that, your judgment. You can vary it by vessel (larges can carry more than regulars, cones taper naturally) as long as it looks intentional and appetising.

## Two structural locks (these are NOT negotiable — they protect the live configurator)
The configurator swaps these images in place, so the VESSEL must be rock-steady even as the ice cream varies:

1. **One framing across ALL 24 — regulars, larges AND cones.** Adopt the pilot's tighter crop (~70% width fill; it looks better than the old dead-space framing). Per vessel class, hold constant across every flavour: cup/cone width, cup-base Y (baseline), and rim Y. Only ice-cream colour/amount and garnish change between flavours — never the vessel scale, position, camera, background, or logo.
2. **Export exactly 600×860.** The pilot came out 1047×1502 (aspect matches, clean downscale) — deliver the final 24 at 600×860, exact filenames, into `…\C.T business\site\photos\scoops\`.

## Still holds (regen-v2 audit)
Locked palette (one body hex per fruit, reused cup+cone, 8 mutually distinct), ONE background/lighting for all 24 (the warm-peach vignette), creamy low-grain texture, subtle flecks only on raspberry/blueberry/dragonfruit/cherry. Realistic cones per WAFFLE_CONE_VISUAL_LOCK.

## Loop
Regenerate all 24 → append a line to `CLAUDE OBSIDIAN/.ai/HANDOFF.md` (or push a note to `My-friends/codex/`) → Claude re-audits the full set (contact sheet + crosshair + per-vessel bbox consistency: vessel height ±20px, centre-X 48–52%, matching rim Y) and reports honest pass/fail. Claude owns crop/normalise + wiring once it passes. **Don't touch the site repo. Don't deploy.**
