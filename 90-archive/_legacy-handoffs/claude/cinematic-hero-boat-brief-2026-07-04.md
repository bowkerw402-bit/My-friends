# Brief for Codex — Cinematic Hero: Boat Module (2026-07-04, /orchestrate)

From: Claude. Continuing in Codex thread 019f2c61-b892-7a53-a4c9-04fecddd285e.
Task split: Claude builds the scene/camera/water/sky/intro; Codex builds a self-contained BOAT module.

## Context
We're building a cinematic 3D hero for APLakeside (Lake Burley Griffin corporate experiences).
Stack: vanilla JS + Three.js r128 from CDN. NO build step, NO npm, NO ES modules — plain `<script>` global `THREE`.
Existing verified water hero: `C:\Users\bowke\OneDrive\Documents\Claude\Projects\C.T business\site\hero-3d.html`
(32k-vertex wave mesh, perspective camera, golden-hour palette).

## Your deliverable: a boat factory function, ONE self-contained JS file
Write: `C:\Users\bowke\OneDrive\Documents\Claude\Projects\C.T business\site\boat-module.js`

It must define exactly one global function:
```js
function createBoat(THREE) {
  // build boat entirely from Three.js primitive/extrude geometry — NO external model files
  // return { group, update }  where:
  //   group  = a THREE.Group (the whole boat, centered at origin, ~6 units long, bow toward -Z)
  //   update = function(t, waveHeightFn) { ... }  called every frame
  //            t = elapsed seconds; waveHeightFn(x,z,t) returns water height at world x,z
  //            inside update, sit + bob + roll the boat on the wave surface
  return { group, update };
}
```

## Requirements
- **Silhouette-friendly premium launch/vessel** (APLakeside runs GoBoat + MV Reliance charters). A small elegant motor launch or cabin boat reads best. Dark hull so it silhouettes against the gold sun.
- **Build from primitives only:** ExtrudeGeometry from a hull side-profile Shape is ideal for the hull; BoxGeometry/CylinderGeometry for cabin, mast, trim. A tiny gold pennant (small triangle) at the mast top is a nice touch.
- **Materials:** MeshStandardMaterial. Hull near-black navy `#0b1622` (roughness ~0.7). Cabin `#14263D`. Pennant/trim gold `#B79B61`. Set `fog:true` on materials if you use scene fog (I'll set scene.fog).
- **Bobbing in `update`:** sample `waveHeightFn` at the boat's x,z (and a couple offset points fore/aft, port/stbrd) to sit it ON the surface and derive gentle pitch (rotation.x) and roll (rotation.z). Keep it subtle and premium — a slow, heavy vessel, not a bath toy. Add a faint yaw sway if you like.
- **Scale/orient:** ~6 units long, bow toward -Z, deck roughly at y=0 before bobbing (I'll place the group in the world).
- **Self-contained + testable:** at the bottom, guard an optional quick self-test behind `if (typeof module!=='undefined')` OR just keep it pure. It must run in a browser with only global `THREE` (r128) present. No imports.

## Verify before you hand off
Since there's no build step, sanity-check by reasoning through it: geometry constructed without errors, function returns {group, update}, update mutates group.position.y / rotation. If you can, note any Three.js r128 API caveats (e.g. BufferGeometry vs Geometry — r128 uses BufferGeometry; ExtrudeGeometry/Shape are fine).

## Output location + handoff
- Write `boat-module.js` to the site folder path above.
- Leave a note in `C:\Users\bowke\OneDrive\Documents\GitHub\My-friends\codex\` when done, describing the boat's dimensions/orientation so I can place and light it correctly in the scene.
- Do NOT touch hero-3d.html or any other file — just create boat-module.js. I'm composing the final scene.
