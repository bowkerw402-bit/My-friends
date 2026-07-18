# Case study — the APLakeside lake hero

Six rounds, 2026-07-18. The brief: a 3D lake, a boat that follows the cursor, the logo disassembled
into spinning rings, live coordinates, a slow camera descent, scroll-dissolve into the site.

This is the troubleshooting record. Each round: what he said, what I did, **what the cause actually
was**. The pattern is the point — in every single round the real cause was one layer below the
symptom, and in every single round I fixed the symptom first.

---

## Round 1 — v1 (dusk) — APPROVED

> *"Okay this is fucking great bro"*

Dark dusk lake, gold armillary, cursor boat, live LBG coordinates, scroll dissolve.

**Rig:** `NoToneMapping` + sRGB · brand hexes via `convertSRGBToLinear()` · a **bright studio HDRI**
for the metal · travel key+rim lights on top · env-gated motion start · **no bloom, no emissive** —
the gold glowed for free because it reflected a bright env while sitting on a dark scene.

**One deviation made by vibes** (a night HDRI instead of the medallion recipe's studio HDRI) cost a
full fix cycle. First appearance of the lesson that dominates everything below: **reuse an approved
rig atomically, or don't reuse it.**

---

## Round 2 — v2 — REJECTED on specifics

> *"the lettering is really basic… the boat is a little bit basic… the logo shouldn't be over the
> top of it… smaller, top left corner… more colour in the water… represent Lake Burley Griffin
> better"*

All five were **specification gaps, decidable before the first render**. This is where the 6-line
spec in `the-funnel.md` comes from — it deletes this entire round.

---

## Round 3 — v3 (midday rebuild) — REJECTED hard

> *"it now has lost the quality and the premium look. It kinda just looks like animated slop…
> there's no glow… the logo looks like shit because it's not the glowy gold colour"*

v2 had iterated on the dusk model instead of rebuilding to the actual brief (a *midday* corporate
expedition). So v3 rebuilt: ACES + `THREE.Sky` + real Lake Burley Griffin research + 3D wordmark.

**And it killed the gold.** Diagnosis at the time: "ACES desaturates highlights." Fix: bloom +
emissive gold. That worked *well enough* to hide the real problem for three more rounds.

**The real cause, found in round 6:** switching the env from a studio HDRI to `pmrem.fromScene(sky)`.
It felt like a cleanup (local, synchronous, no CDN) but it **tied the metal's response to the mood**.
See round 6.

---

## Round 4 — v3.2 — "I can't see what's happening"

> *"the sky is way too white… be able to see the animations yourself… track the animations
> throughout the entire video, like watching back a video… when it pans to the final angle, you just
> can't see any of those things… the boat is shining too much"*

**The tooling gap.** A frozen `?pose=` snap cannot show what breaks *during* a camera move. Built
`filmstrip.mjs` — captures the arc, tiles it into one contact sheet. It immediately showed the
camera resting into a wall of white horizon with every subject pushed out of frame.

### The five-hour bug: "the logo reads as a broken gold U"

| attempt | hypothesis | result |
|---|---|---|
| 1 | the rings spin edge-on → bound the rotation to a sway | still a U |
| 2 | the gold is too dark → strong emissive floor | brighter U |
| 3 | it needs contrast → dark scrim sprite behind it | worked, but read as a **sticker** |

The filmstrip finally discriminated: the ring was a U **at zero rotation**, and a perfect circle at
the high camera. So the variable was never the pose — it was the **background**. A near-chrome ring
(`metalness .98`) is a *mirror*; its thin upper arc was reflecting the blown-out horizon and
vanishing into it.

> **Two failed fixes on the same symptom = the diagnosis is wrong. Go find the frame that
> discriminates between your hypotheses.**

And the scrim was a band-aid over a symptom whose real cause was still two rounds away.

---

## Round 5 — v3.3 (regrade) — "like a bad camera"

> *"the colours are kinda off… it's not deep enriching colour… the whole thing looks blown out,
> unsaturated, low quality, like an overexposed camera"*

He drew the distinction himself, and it was the useful one: **the elements were right (water,
reflection, boat, sky — "those are all pretty good"), the presentation was wrong.** That is a grade
note, not a build note — and I had been answering it with more geometry.

Fixes: a proper **grade pass** after bloom (saturation, S-curve contrast, split-tone), a **low sun**
(high noon is the worst light there is — blown sky, flat light), and gold rebalanced.

Three bugs of my own, worth remembering:

- **Linear contrast clips.** `(c-pivot)*k+pivot` pushes anything near 1.0 straight past it — it
  turned the sky into a slab of pure white. Use `mix(c, c*c*(3-2c), amount)`: same mid punch, rolls
  off at both ends.
- **The azimuth sign.** `setFromSphericalCoords` measures theta from +Z toward +X, so **above 180°
  swings LEFT**. I twice "moved the sun's glare away from the top-left emblem" and moved it straight
  onto the emblem. *If a directional fix makes the symptom worse, suspect the sign before the theory.*
- **Gold vs orange is the green:red ratio.** A warm key (×.89 green) + warm env + saturation each
  shift red. `#d69b34` (G/R .72) lands at ~.64 and reads as safety-orange.

---

## Round 6 — v3.4 — he sent the v1 render back

> *"I really like the glowiness of it… this gentle gold glow… a lot more high quality, a lot more
> pristine"* + *"refer very heavily to the photo I've sent"*

**Process lesson: when he sends a reference, go READ THE APPROVED FILE. Do not infer the rig from
the picture.** Diffing v1 found the root cause in minutes after three rounds of guessing:

> ### ENV MAP = MATERIAL RESPONSE. SKY + LIGHTS = MOOD. Never merge them.
>
> v1's gold looked pristine because it reflected a **bright studio HDRI** while the **scene** stayed
> dark dusk. `pmrem.fromScene(sky)` tied the metal's response to the mood — at dusk that env is
> dark, so the gold had nothing bright to reflect and went matte. **Four rounds of "fixes"
> (emissive floors, lower metalness, a scrim, an entire regrade) were all compensating for this
> one decision**, each moving further from the thing he approved.

Fix: a procedural studio env (bright emissive softboxes → PMREM), assigned to the **gold materials
only** via `material.envMap`, which overrides `scene.environment`. Metal gets its luster; the scene
keeps its mood. Built in code — v1 pulled its HDRI off a CDN, a known failure class.

Two traps found immediately after:

- **A flat metallic face only mirrors what is BEHIND THE CAMERA.** With no camera-side panel in the
  env, the gold "AP" letters rendered **pure black**. Curved geometry hides this — the torus caught
  highlights from other angles and looked fine. Always put a large soft panel at +z.
- **Porting `NoToneMapping` blew the scene out** — because **v1 had no `THREE.Sky` at all**; its sky
  was a painted CSS gradient (LDR, controlled). A real atmospheric sky *requires* the rolloff.
  Porting one setting out of an approved rig without its context is how "reuse the recipe" becomes
  a regression.

---

## Round 7 — v3.5 — "where did the framework go?"

> *"I'm not sure what you've done with all of the visual psychology stuff, but that seems to have
> completely disappeared… everything now is oversaturated… I want it to be daytime, but keep the
> same visual effects of the quality of things when it was actually at dusk"*

Fair, and the most useful thing he said. I had built a bench that **measured** his taste and then
run this entire build without opening it. Measuring afterwards was damning — see
[calibration.md](calibration.md). Two golds I invented by eye were above his own stated ceiling.

**"Daytime with dusk quality" resolved to a number:** the dusk water measured L=0.263, inside his
house ground band (0.20–0.27); every daytime water I tried sat at 0.335–0.437. Bright canvas sky +
ground pinned to L≈0.25 + low-chroma accent = the dusk register in daylight.

Also this round: the emblem got a **lockup cycle** (see `the-funnel.md`), the box-geometry landmark
was scrapped, and bloom was retuned from glow-wash to LED.

---

## Round 8 — v3.6 — "I can see the pixels"

> *"I would really like this to be upscaled as high as possible realistically… I can see the
> individual pixels sort of breaking… a little bit more glossiness on the logo and the lettering"*

Two causes, neither of them geometry:

1. **`antialias: true` is INERT once EffectComposer is active.** The scene renders into a render
   target, never the MSAA-backed canvas. Every edge in the post chain was aliasing at 1:1. Fix:
   **supersample** — render above display resolution and let the composer downsample. Real SSAA,
   works through bloom and grade both.
2. **No anisotropic filtering on the water normal map.** A normal map at a grazing angle is the
   textbook anisotropic case — the sample footprint is long and thin, so trilinear filtering either
   aliases into crawling speckle or blurs to mush. `texture.anisotropy = maxAnisotropy` is free on
   any modern GPU and is *the* fix for a shimmering lake.

Gloss: `MeshPhysicalMaterial` with `clearcoat` on the emblem and the wordmark — a second specular
lobe over the metal, which reads as lacquered rather than merely shiny.

Guard added: supersampling is the biggest cost here, so sample real frame times once the intro
settles and step the ratio down **once** if the machine can't hold 40fps (never back up —
oscillating resolution is more noticeable than either level). An explicit `?ss=` bypasses it, or
headless QA silently captures the un-supersampled version and every quality snapshot lies.

---

## Round 9 — v3.7 — "I can still see pixels in the mountains and the rings"

The quality pass from round 8 **did nothing at all on a HiDPI display**, and I had "verified" it.

```js
// v3.6 — WRONG
var SS = Math.min(Math.max(devicePixelRatio || 1, 1.6), 2);
// on a 2x monitor: min(max(2, 1.6), 2) === 2 === native. Zero supersampling.
```

The cap was **absolute**. On a 1x display the floor of 1.6 kicked in and it genuinely supersampled —
which is exactly the configuration headless capture uses (`deviceScaleFactor: 1`), so every snapshot
I took confirmed it working. On Will's 2x screen it was a no-op.

> **Supersampling must be a MULTIPLE of `devicePixelRatio`, never an absolute number.**
> `min(DPR * 1.5, 2.8)` on desktop, `min(DPR, 2)` on mobile.

> **And: capturing at `deviceScaleFactor: 1` cannot detect a dpr-relative bug.** The check that
> finds it is comparing the canvas **drawing buffer** against its **CSS size** — if
> `buffer === css * dpr` exactly, you are at native and supersampling nothing.

The rest of the round:

- **FXAA as the final pass.** Supersampling fixes AREA coverage but still steps on THIN
  high-contrast edges. A 0.15-radius gold ring rim against bright sky, and a hill silhouette, are
  the two worst cases in this scene — exactly the two things he named. Its `resolution` uniform is
  in DEVICE pixels, so it must track pixelRatio on resize *and* after the adaptive guard fires.
- **Aerial perspective instead of more geometry.** A hard silhouette against a bright sky is the
  worst aliasing case there is. Pulling the fog in (60–240 → 42–205) dissolves the far ridges toward
  the sky — softer *and* more physically correct than adding polygons, which would not have helped
  at all because the aliasing was at pixel level, not polygon level.
- **A small glow on the type** while staying LED: raise the emissive floor so letter cores clear the
  bloom threshold, keep the radius tight. Glow comes from the threshold, crispness from the radius.

## Round 10 — v3.8 — "more."

No specifics, so the job was to find the remaining ceilings myself. Three, and the ordering was
wrong in my head before I measured.

**The faceting was the TYPE, not the scene.** `curveSegments: 6` on a serif face facets every bowl
(O, e, s, a); `bevelSegments: 3` stairsteps the exact edge that catches the light. Raised to 18/6.
**Type is the highest-scrutiny geometry on any page** — it is what the eye lands on and reads at
100%, and it was the coarsest thing in a scene where the hills had 128x64.

**Shadow density is `mapSize / extent`, not `mapSize`.** Tightening the shadow camera from 44 to 30
units raises texel density faster than doubling the map — doing both gave ~4.5x.

**Clouds took two failed attempts, and both failures were structural:**

1. A high horizontal cloud LAYER rendered **nothing at all**. The camera far plane is 300 units, and
   a layer at altitude only reaches the horizon thousands of units out — clipped long before it
   entered the thin band of sky the framing shows. (`THREE.Sky` gets away with a 6000-unit scale
   because its vertex shader forces `gl_Position.z = w`; ordinary geometry does not.)
   → **Check the far plane before placing anything distant.**
2. Replacing it with sprite banks showed **the sprites' own rectangles** as translucent panels in
   the sky, because the noise texture had no alpha falloff at its borders.
   → **Any sprite-based natural element needs its alpha faded to zero at all four edges**, or the
   quad boundary becomes the most visible thing in frame.

Result kept deliberately faint — thin high haze that breaks the flat gradient. *Bad clouds are far
worse than no clouds*, which is his own rule from the box-geometry landmark, applied to myself.

**Seed procedural textures.** The noise uses mulberry32 with a fixed seed. An unseeded texture
changes every load, which destroys `?pose` reproducibility and makes any pixel baseline worthless.

## Round 11 — v3.9 — "keep pushing"

Went looking for the largest *areas* still doing the least work, rather than polishing what was
already good. The answer was embarrassing: **the hills and shoreline were flat single-colour
materials with no map at all**, and they are the second-largest region in frame after the water.

- **Flat fill is the loudest "painted cardboard" tell there is.** A greyscale `map` MULTIPLIES the
  material colour, so ONE procedural mottle texture varies every landmass without touching any
  brand palette — clumped dark patches read as tree canopy, lighter ones as dry grass between.
  Keep the range SHALLOW (0.66–1.0): terrain at distance has low local contrast, and heavy mottle
  reads as noise, not vegetation.
- **Waterline haze.** Over water, distance haze is densest exactly at the land/water junction.
  Without it the shore meets the lake on a hard graphic line — a strong "diagram, not photograph"
  signal, and one of the cheapest realism wins available.
- **Ripple scale and anisotropy are coupled.** Dropping the water's normal tiling from 6.0 to 4.2
  gave the near field real surface texture — but a finer tiling at grazing angles only works
  *because* anisotropic filtering went in two rounds earlier. Alone, either change is wrong: coarse
  tiling looks flat, fine tiling without anisotropy crawls into speckle.
- **Audit for the one surface that missed the treatment.** The emblem's ivory waves were still matte
  in a mark otherwise made entirely of clearcoat gold — they read as flat plastic ribbons beside it.
  They also needed the *studio* env like the gold, or ivory goes dull in a scene whose own env is a
  dim sky. When you upgrade a material family, grep for everything in that family.
- **Deduplicate procedural helpers.** The clouds had their own private copy of the seeded noise;
  extracted to one shared `NZ`. Two implementations of the same function is precisely the drift the
  design-bench scanner exists to catch — writing it twice in my own file was not a good look.

**Method note:** the useful question at this stage is not "what looks bad" but **"which surface
occupies the most pixels while receiving the least attention."** In this frame that was the terrain,
and it had been sitting there untouched for eleven rounds.

## The transferable pattern

1. **The symptom is never the cause.** Broken-U → not rotation. Matte gold → not the material.
   Oversaturated → not the grade alone. Visible pixels → not the geometry.
2. **Two failed fixes = wrong diagnosis.** Stop. Find the discriminating frame.
3. **Compensating fixes compound.** Emissive floor, scrim, tint slab, regrade — four fixes for one
   root cause, each making the next one necessary. When you find the root, *delete* the compensations
   rather than keeping them.
4. **When he references old work, read the old file.** Not the screenshot.
5. **Measure before choosing.** The tool existed the whole time.
6. **Verify on the real target's parameters.** A quality fix that only works at `dpr=1` will pass
   every headless check and fail on the user's actual monitor. Ask what the verification environment
   differs from the target in, *then* pick the check.
