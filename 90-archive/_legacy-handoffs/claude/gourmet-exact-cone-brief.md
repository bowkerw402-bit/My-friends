# Codex brief — Gourmet Scoops: ONE exact wafer cone across all product images

**From:** Claude · 2026-07-11 · **Priority:** active, Will is waiting

Will wants EVERY product cone image on the site to use the **identical wafer cone** shown in the
reference — not slightly-varying generated cones. The current site images (cropped from your earlier
`{fruit}--sizes.png` contact sheets) each have a subtly different cone. Replace them with one locked cone.

## The locked cone
Reference image (6 cones, same cone, different drizzles):
`Gourmet Scoops/assets/menu-library/EXACT-CONE-REFERENCE.png`

That golden waffle cone — its exact shape, fine diamond waffle pattern, proportions, tip, colour and the
soft cream studio background — must be **pixel-consistent in every output**. Only the ice-cream colour changes.

## Deliverables — 8 INDIVIDUAL images (not contact sheets, no baked text labels, no logo)
One soft-serve cone per image, centred, portrait, on the same cream background as the reference, same
lighting/shadow, same swirl shape. Real-fruit soft-serve colour + realistic flecks per fruit:

- banana — pale creamy yellow
- blueberry — muted purple, dark flecks
- raspberry — pink with red flecks
- mango — golden yellow
- pineapple — pale cream-yellow
- dragonfruit — magenta/pink, tiny black seeds
- lychee — white/blush
- cherry — deep pink-red, flecks

Output to: `Gourmet Scoops/assets/menu-library/exact-cone/{fruit}.png` (fruit ids: banana, blueberry,
raspberry, mango, pineapple, dragonfruit, lychee, cherry). High-res, transparent OR the same cream bg.

## Rules
- The CONE is the constant. If two outputs' cones differ, it's wrong.
- No text, no labels, no logo baked into these — Claude renders all copy in HTML.
- Individual files, not sheets — Claude drops them straight into `photos/scoops/{fruit}-waffle.png`.
- Don't touch the site repo or push anything.

Claude handles: cropping/normalising, wiring into the configurator + menu strip, verification.
When the 8 files exist, Claude integrates them.
