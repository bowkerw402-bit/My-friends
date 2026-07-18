# Claude → Codex · Gourmet Scoops 24-swap visual audit

**2026-07-12 · independent visual/consistency audit** (the one Codex handed off; Claude CLI was logged out so Claude Code app ran it). Evidence: `gourmet-scoops-audit-sheet.png` (all 24 on a red-crosshair grid) in this folder.

**Files audited:** `C.T business/site/photos/scoops/{fruit}-{large,regular,waffle}.png` — 8 flavours × 3 vessels = 24. All are correctly **600×860** (file dims consistent ✓). Everything below is about the CONTENT inside that frame.

**IMPORTANT — the brief evolved.** The old brief (`gourmet-exact-cone-brief.md`) said "one exact WAFER CONE everywhere." Will's live reference is now a **branded CUP** (banana soft-serve, banana-slice garnish, gold GOURMET SCOOPS logo, soft cream studio bg). So the vessels are intentional: **large + regular = cup, waffle = cone.** The consistency standard is: same background, same per-fruit colour, same framing, smoother/lower-texture ice cream, matched to that banana-cup reference. `banana-large` is currently the closest to the target — use it as the north star.

## Verdict: NOT consistent. Concrete issues, prioritised.

### P1 — Colour (Will's #1 complaint), confirmed at full res
1. **Same fruit differs across its 3 vessels.** `mango-large` = pale yellow; `mango-waffle` = much more golden/saturated. Same drift on `blueberry` (waffle more purple than the greyer regular) and `raspberry` (waffle more saturated than regular). **Fix:** lock ONE colour per fruit and render all 3 vessels from it. A given flavour must be the same colour in cup and cone.
2. **Two different backgrounds.** Cup shots (large/regular) = warm peach studio bg with a vignette; cone shots (waffle) = lighter, flatter, cooler cream. **Fix:** one background for all 24 — the reference's soft warm cream, even tone, no heavy vignette.
3. **The three yellows are hard to tell apart.** banana / pineapple / mango all read pale yellow. **Fix:** banana = pale creamy yellow; pineapple = pale cream-yellow (a touch warmer); mango = clearly more golden-orange. They must be distinguishable at a glance.
4. **lychee reads near-white/grey.** Brief wants white/blush. **Fix:** add the faint pink blush so it doesn't look like plain vanilla.

### P2 — Texture / smoothness (Will's explicit note: "texture needs to be lower, ice cream smoother")
5. Surfaces are grainy/matte with hard swirl ridges (see `mango-large` up close). **Fix:** creamier, softer, subtle sheen — soften the ridge shadows, drop the surface grain. Keep only gentle real-fruit flecks on raspberry / blueberry / dragonfruit / cherry, and make even those subtler. Banana/mango/pineapple/lychee should be near-fleckless and smooth.

### P3 — Framing / sizing (Will: "framing and the sizing")
6. **Cones (waffle column) are wildly inconsistent.** `mango-waffle`, `pineapple-waffle`, `dragonfruit-waffle`, `cherry-seasonal-waffle` run long with the tip near the bottom edge; `banana-waffle` & `blueberry-waffle` are short and float high. **Fix:** identical cone footprint + tip baseline Y + swirl scale across all 8 cones (this is the "one exact cone" rule, still in force for the waffle set).
7. **Cups (large/regular) drift in placement & scale.** `lychee-large` sits high with dead space below; `cherry-seasonal-large` sits low; swirl heights vary. **Fix:** normalise product centre to the frame centre, cup rim/baseline to a fixed Y, and product scale to a consistent % of the 600×860 frame. Large should read visibly bigger than regular by a *consistent* ratio across every flavour.
8. **Garnish placement inconsistent.** `mango`'s cube sits upper-right and tilted; others are top-centre. `lychee` has no garnish on large/waffle but something on regular. **Fix:** one garnish position/scale/tilt convention per flavour, present on all 3 vessels (or none).

## Acceptance criteria for the re-do (so the next set passes in one shot)
- One background, one lighting setup, for all 24.
- One locked colour per fruit, reused across large/regular/waffle; the 8 colours mutually distinguishable.
- Smooth creamy surface, minimal grain; flecks only on berry/cherry/dragonfruit and subtle.
- Cones: identical cone + tip-Y + scale across all 8. Cups: product centred, fixed baseline, consistent large:regular size ratio.
- Consistent garnish convention per flavour across its 3 vessels.
- Still 600×860, no baked text/labels/logo on the ice cream (the cup's printed logo is fine — it's on the physical cup), transparent or the reference cream bg.

Claude handles crop/normalise + wiring once the new set exists. Don't touch the site repo or push.

---

## LOCKED FLAVOUR PALETTE (exact hexes — hit these)
Sampled from the cup images, corrected for distinctness. Visual strip: `gourmet-scoops-palette.html` (open it). One BODY colour per fruit, reused across cup + cone. Highlight = soft sheen, Shadow = swirl-ridge shading, Fleck = subtle, only where listed.

| Fruit | Body (target) | Highlight | Shadow | Fleck | Notes |
|---|---|---|---|---|---|
| banana | `#ECCE8E` | `#F0D9A7` | `#B39D6C` | none | pale creamy yellow — the north-star reference |
| pineapple | `#F0DCAE` | `#F3E4C0` | `#B6A784` | none | palest cream-yellow — must read LIGHTER than banana |
| mango | `#F2BD63` | `#F5CC85` | `#B8904B` | none | golden — most saturated yellow, clearly distinct |
| raspberry | `#E493A3` | `#EAABB7` | `#AD707C` | `#A83246` | clean pink, subtle red flecks |
| dragonfruit | `#D98BB2` | `#E1A5C3` | `#A56A87` | `#2A2320` | magenta-pink, tiny near-black seeds |
| cherry | `#C56F79` | `#D28F96` | `#96545C` | `#9C2F3B` | deep pink-red — darkest of the pinks |
| blueberry | `#B7A8CB` | `#C7BBD6` | `#8B809A` | `#4B3A6B` | muted lavender-purple, dark flecks |
| lychee | `#F0E3E2` | `#F3E9E8` | `#B6ADAC` | none | white with faint blush (NOT plain vanilla; NOT the beige it is now) |

**Rules for using these:** body is the mid-swirl colour; highlight/shadow define the range for the sheen and ridge shadows — keep the transition SOFT and creamy (low texture, per Will). Flecks subtle and sparse. banana/pineapple/mango/lychee stay smooth and near-fleckless. Same body hex in a fruit's cup AND cone — no drift.
