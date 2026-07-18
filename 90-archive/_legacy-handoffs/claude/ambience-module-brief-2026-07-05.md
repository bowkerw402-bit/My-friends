# Brief for Codex — Lake Ambience Module (2026-07-05, /orchestrate continues)

From: Claude. Your scene refactor is good — I'm keeping it. One integration bug on my plate: the boat "sinks" because your CPU `waveHeight()` uses world coords while the water mesh sits at `water.position.z = -78` and its shader displaces in OBJECT space (78-unit phase offset). I'm fixing that in `hero-cinematic-scene.js` — do NOT touch that file or `boat-module.js` this round.

## Your task: ONE new file — `C:\Users\bowke\OneDrive\Documents\Claude\Projects\C.T business\site\ambience-module.js`

Global function, same pattern as the boat:
```js
function createAmbience(THREE) {
  // returns { group, update }
  //   group  = THREE.Group added at world origin
  //   update = function(t) — animate contents; t = elapsed seconds
}
```

Contents (golden-hour restraint — this is a premium corporate site, not a screensaver):
1. **3–5 gliding bird silhouettes** — tiny dark two-triangle shapes far off near the horizon (y 6–12, z −60 to −110), slow drifting arcs with a gentle wing-flap scale oscillation. Near-black colour so they read as silhouettes against the sun.
2. **2–3 distant moored buoys/poles** — thin dark posts with a tiny gold cap catching the light, sitting in the water zone (z −30 to −70, x spread ±30). Static, just presence.
3. Optional if cheap: a very faint drifting haze band near the horizon (large transparent plane or sprite, additive, opacity ≤ 0.08).

Rules:
- Three.js r128 primitives only, global THREE, no imports, no external assets.
- Total mesh budget ≤ 40; everything must be cheap (this runs every frame alongside water + boat).
- MeshBasicMaterial fine for silhouettes; set `fog: true` where it helps them melt into the distance.
- `update(t)` moves ONLY the birds (position + flap); keep amplitudes slow and small.
- No pointer interaction, no DOM, no listeners — pure scene content.

Handoff: note in `My-friends\codex\` when done. I'll wire `createAmbience` into the scene optionally (same guarded pattern as the boat), so your module must not error if simply never called.
