# Claude review — Gourmet Scoops soft-serve reduction (regular-cup pilot)

**From:** Claude (with Will), 2026-07-13 · **For:** Codex · **Re:** your reduced regular-cup pilot before propagating to 24
**Image reviewed:** `~/.codex/generated_images/019f59de-2f76-7f62-89e6-7ee2e66ba261/exec-030224e6-...png` (15:13:38, blueberry-regular)
**Compared against:** live `…\C.T business\site\photos\scoops\blueberry-regular.png` (old tower)

## Verdict: PROPORTION PASS — lock 2 things before you propagate

Measured (bbox script, non-bg threshold):

| metric | OLD tower | NEW reduced | note |
|---|---|---|---|
| ice-cream : cup height | 0.71 : 1 | **0.54 : 1** | ✅ tower gone, cup is hero. Keep this ratio. |
| centre-X | 52% | 49% | ✅ within tol |
| product width fill | 61% | **70%** | ⚠️ camera/crop drifted tighter |
| resolution | 600×860 | **1047×1502** | ⚠️ off-spec; aspect 0.697≈0.698 so clean downscale |

The swirl is now ~3 low coils, logo fully visible, blueberry garnish + gold rim + warm-peach vignette all read clean. This is the target proportion — replicate it.

## Two locks before the 24-file propagation
1. **One framing for ALL 24, not just regulars.** The crop tightened (61%→70% fill). It looks BETTER, so adopt it — but you must regenerate **larges and cones to the same fill/vessel-baseline too**, or the live configurator (swaps images in place) will make the product jump size when the user switches size/flavour. Anchor per vessel class: same cup-base Y, same cup width, same rim Y across every flavour of that vessel.
2. **Export exactly 600×860.** Downscale from 1047×1502 (aspect matches, no distortion).

## Still holds from regen-v2 audit
Locked palette (one body hex per fruit, reused cup+cone), one background/lighting for all 24, creamy/low-grain texture, flecks subtle & only on raspberry/blueberry/dragonfruit/cherry. Fruit garnish + logo + vignette locked.

## Loop
Propagate → tell Claude → Claude re-audits the full 24 (contact sheet + crosshair + per-vessel bbox consistency: height ±20px, centre-X 48–52%, matching rim Y) and reports pass/fail honestly before anything is wired into the site. Claude owns crop/normalise + wiring once it passes. Don't touch the site repo / don't deploy.
