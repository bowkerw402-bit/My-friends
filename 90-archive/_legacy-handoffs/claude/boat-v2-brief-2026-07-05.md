# Brief for Codex — Boat v2: real vessel, not a cut-out (2026-07-05)

Will's feedback on the live scene: boat reads as a flat "crop out". Root causes: hard-chined lineTo() extrusions (no hull curvature), near-black materials (0x0b1622 at roughness .7) that swallow the golden-hour light, so it renders as a silhouette.

## Task: rebuild the VISUALS in `C:\Users\bowke\OneDrive\Documents\Claude\Projects\C.T business\site\boat-module.js`
Keep the contract EXACTLY: global `createBoat(THREE)` → `{ group, update }`, bow toward -Z, ~6 units long, deck near y=0, and KEEP your existing update() flotation logic unchanged (it's good — world-space sampling + smoothing). Only the geometry/materials change. r128, global THREE, no imports, no external assets.

## Visual requirements
1. **Curved hull, not flat slabs.** Use quadraticCurveTo/bezierCurveTo in the hull plan Shape (curveSegments ≥ 12) so the bow sweeps and the sides curve. Consider a second smaller flared sheer-line extrusion for the gunwale cap. A subtle tumblehome (upper hull slightly wider than lower) sells volume.
2. **Materials that catch the light** (scene key light is warm 0xffc684 from high behind-left, plus a warm rim light I'm adding from behind):
   - Hull sides: navy 0x1a2e44, roughness .38, metalness .12 — glossy enough for a sun highlight streak
   - Lower hull/antifoul: deep 0x0e1c2b, roughness .6
   - Gold waterline stripe wrapping the hull (thin torus-ish band or thin extrude), color 0xB79B61, metalness .55, roughness .3
   - Deck: warm teak-ish 0x6b543a, roughness .75
   - Cabin: 0x1c3049 with LARGE warm-lit windows: glass material emissive 0xffb46a, emissiveIntensity ~.55 — golden-hour interior glow is what makes it read as a real occupied vessel
3. **Detail pass (budget ≤ 60 meshes):** raked windscreen with visible frame, helm silhouette or bench seats in the cockpit, bow navigation light (tiny emissive red/green optional — or keep single gold), stern flag staff w/ gold pennant (keep), a low radar arch or grab rails, cleats. Small emissive white stern light sphere.
4. **Proportions:** slightly lower and longer profile than v1 — length ~6.3, beam ~2.1, cabin height under 1.1 so it sits elegant, not tippy.

## Verify before handoff
Reason through r128 API validity (BufferGeometry-based Extrude/Lathe/Cylinder all fine). No scene/DOM access — module stays pure. Handoff note to My-friends\codex describing what changed.
Do NOT touch hero-cinematic-scene.js, hero-cinematic.html, ambience-module.js.
