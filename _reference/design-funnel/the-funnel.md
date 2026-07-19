# Immersive 3D scene — the build recipe (the "funnel")

The concrete pipeline that produced the APLakeside lake hero (Will, 2026-07-18: "fucking great
bro" → approved). This is the reusable way to build a code-generated 3D web moment: a scene, a
signature object, motion, a scroll transform, delivered and verified. Read alongside
`build-recipes.md` (coin/logo recipes) and `visual-psychology.md` (why it lands).

The one-line thesis: **spec it before you build it, build it as one file reusing an approved rig,
verify it with your own eyes on frozen poses before Will sees it, gate it, and hand him a URL.**

---

## 0. SPEC FIRST — the 6-line contract (the biggest speed win)

Every refinement round on the lake hero was a *specification* gap, not a craft miss — the logo
position, the boat class, the reveal choreography, the local water colour were all decidable
before the first render. **Write these six lines before writing any scene code:**

1. **Shot** — the camera move in one sentence (e.g. "high/distant → descend to the waterline, then
   dead still"). Its duration.
2. **Frame budget** — where each hero element lives *on screen* (emblem top-left, wordmark centre,
   boat lower-right, HUD bottom-left). Prevents two objects both anchored dead-centre.
3. **Palette + lighting target** — the exact hexes and the mood (dusk/teal/warm-gold), committed
   before the first light is placed. If reusing a brand, read the tokens off the bench, don't
   retype them.
4. **Signature object** — the one bespoke thing (here: the medallion disassembled into an
   armillary). Everything else is restraint funding it.
5. **Motion budget** — the one cinematic exception (the camera) + the ambient set (water, slow
   rings, drift). UI motion stays in the contract band (250–450ms, ≤24px, ease-out).
6. **Reveal choreography** — the order things introduce themselves, one at a time, with gaps.

Plus a **mobile line**: how the frame reflows portrait (emblem tucks tighter, camera pulls back).
Building centre-composition and discovering later that the logo wanted a corner is a re-do you can
delete here.

---

## 1. BUILD — one self-contained file, reusing an approved rig

- **One HTML file**, no build step (Will's stack). Three.js + add-ons by `<script>` (r128 globals).
- **Reuse the approved lighting/gold rig ATOMICALLY, not cherry-picked.** The medallion recipe is:
  `renderer.outputEncoding = sRGBEncoding` · `toneMapping = NoToneMapping` (flat graphic/brand gold)
  · brand hexes via `new THREE.Color(hex).convertSRGBToLinear()` (r128 has no colour management) ·
  real HDRI (PMREM) for metal · **travel key+rim lights** on top of the env (a spin passes through
  angles the single HDRI leaves muddy) · **env-gated motion start** (nothing moves until lighting
  resolves — PMREM mid-animation = dropped frames) · a `setTimeout` fallback-lights path so the loop
  always starts. Porting *half* of this (e.g. a different HDRI) cost a full fix cycle. Bank the
  separation: **env map = material response; mood = painted sky + directional lights.**
- **Every animated object needs an explicit resting transform at creation.** The lake armillary
  rendered as a giant centred ring on the pre-loop frame because its scale was only set inside the
  loop — default scale 1 until the first tick. Set the start pose (often `scale 0`, revealing in) at
  creation, so the very first rendered frame is correct.
- **Determinism hooks, built in from the start** (they're free and they're how you self-review):
  - `?pose=0..1` — freeze the signature animation at any fraction.
  - `?scroll=0..1` — jump the scroll transform to any point.
  - a `reduced` branch (`prefers-reduced-motion`) that keeps state, drops motion (the safety floor).
- **Self-host every external asset up front, as a class** — textures, HDRI, and ideally three.js
  itself. A CDN texture CORS-failed the gate; the fix is knowable at write time. Zero external URLs
  before the first snap = a whole class of failures gone (offline, CDN-down, CORS-on-canvas).

---

## 2. THE REALISM PLAYBOOK (r128 WebGL)

Will's north star (2026-07-18): *optical realism* — he cited the boat's reflection on the water as
"realistic movement and realistic optics" and wants everything to reach it. The four cues that read
as real: **fresnel + a real environment reflected + low reflection distortion + slow layered
desynced motion.** Everything below serves those.

**Water (the `THREE.Water` object):**
- Paint the body a **deep desaturated teal-green** (a freshwater lake, e.g. `#17403a`) and let
  **fresnel reflect the sky for the blue**. Painting water sky-blue is the "plastic pool" tell.
- Calm-lake levers vs the ocean default: `distortionScale` ~1.5–2 (keeps the reflection a legible
  mirror — the optics), `size` ~5–6 (fine ripples, not swell), `time += ~1/165` per frame (~0.36/s),
  warm `sunColor`, low `sunDirection` (a long dusk glint streak).
- **Never remove the fresnel** — dark head-on, sky-reflective at grazing angle is the single biggest
  real-optics cue, and it's already in the shader.

**Grounding (the biggest realism-per-line win):**
- **Contact shadow.** A floating object with a mirror reflection still reads as pasted-on. A soft
  dark radial patch on the surface, following the object, darkens where it meets the water. ~20 lines.
- **Raycast the cursor to the actual surface plane**, don't map screen→world linearly — the object
  goes where you're truly pointing, on every aspect ratio.

**The honest r128 ceiling** (fake these; don't chase the real thing): no GI → HemisphereLight
sky/ground + baked vertex AO + env IBL; no soft area shadows → `PCFSoftShadowMap` + `shadow.radius`
or a blob; no subsurface → backlight fake (`dot(-N, L) × translucency × thickness`) for dusk-lit
leaves; reflections → planar `Water`/`Reflector` for flats, env map elsewhere.

**The tone-mapping fork — and how bloom resolves it (2026-07-18):** `NoToneMapping` keeps brand gold
saturated and, on a DARK background, it glows for free (the dusk look). `ACESFilmicToneMapping` + sRGB
gives natural daylight rolloff — needed for a bright/midday scene — **but it flattens the gold to a
matte pale, killing the premium glow.** The resolution is NOT to pick one: it's **UnrealBloomPass**.
Under ACES, give the gold materials a warm **emissive** (`emissive:#5a3f0e, emissiveIntensity:~0.5`)
so they're the brightest thing, then bloom with a **threshold (~0.7) that catches the emissive gold
and sun-glitter but spares the bright sky** (strength ~1.0, radius ~0.55). Deepen the sky (rayleigh
~3) and lower exposure (~0.5) so there's contrast for the glow to read against. That gets premium
glowy gold AND midday realism together. (Self-host the r128 post-processing scripts — order matters:
`EffectComposer.js` defines `THREE.Pass`, so it must load before RenderPass/ShaderPass/MaskPass/
UnrealBloomPass; the shaders it uses load before it. Route every render through `composer.render()`.)
A subtle CSS **vignette** over the canvas makes a bright scene read "shot", not flat — cheap premium.

**ENV MAP = MATERIAL RESPONSE. SKY + LIGHTS = MOOD. Never merge them (2026-07-18).** The single
most expensive mistake of the lake build. v1's gold looked "pristine" because it reflected a BRIGHT
studio HDRI while the SCENE stayed dark dusk. Switching the environment to `pmrem.fromScene(sky)`
felt like a cleanup (local, synchronous, no CDN) but it **tied the metal's response to the mood** —
at dusk that env is dark, so the gold had nothing bright to reflect and went matte. Then four
rounds of "fixes" (emissive floors, lower metalness, a dark scrim, a whole regrade) were all
compensating for it, each one moving further from the approved look.
- **Give the metal its own env**: `material.envMap` overrides `scene.environment`, so a bright
  studio cubemap can be assigned to the GOLD ONLY while everything else keeps the mood env.
- **Build it procedurally** (emissive planes as softboxes → `pmrem.fromScene`) instead of loading an
  HDRI: no CDN, no CORS, no load race — v1's remote HDRI was a known failure class.
- **A FLAT metallic face only mirrors what is BEHIND THE CAMERA.** With no camera-side panel in the
  env, gold 3D letters render pure BLACK. Curved geometry hides this (a torus catches a highlight
  from almost any angle), so the bug shows up only on flat faces. Always put a large soft panel at
  +z. And drop flat letterforms to ~.6 metalness so they keep some diffuse colour.
- **Satin, not chrome.** `metalness .87 / roughness .25 / no emissive` is what produces the soft
  dark-to-bright gradient that reads as precious metal. Near-chrome (.98) is a hard mirror; heavy
  emissive is a flat glowing plastic. Neither reads as gold.

**Match the RIG to the SKY you're using.** `NoToneMapping` was v1's setting and it blew out
completely when ported — because **v1 had no `THREE.Sky` at all**; its sky was a painted CSS
gradient (LDR, fully controlled), so nothing had physical radiance to clip. A real atmospheric sky
REQUIRES tone-mapped rolloff. Porting one setting out of an approved rig without its context is how
"reuse the approved recipe" turns into a regression.

**Rotational symmetry makes phase offsets invisible.** A torus maps onto itself every half turn, so
offsetting two rings by π in their spin axis produces *no visible difference whatsoever*. Make the
offset read with mirrored TILTS instead. Also: Euler `'XYZ'` applies `.y` before `.x`, so setting
both gives you a ring spinning on its own axis inside a tilted frame — a gyroscope, for free, with
no extra Group.

**THE GRADE — the difference between "3D scene" and "premium" (2026-07-18, the hardest lesson).**
Will on the ungraded midday build: *"blown out, unsaturated, low quality, like an overexposed
camera"* — and the diagnosis that matters: the ELEMENTS were right, the PRESENTATION was wrong.
**ACES desaturates by design.** On a bright key it drains exactly the saturated luxury register a
dark NoToneMapping scene gets for free. Do what film does — filmic rolloff first, **then a grade
pass for the look**: a `ShaderPass` after bloom doing saturation, contrast, and split-tone (cool
deep shadows, warm highlights). Four rules learned the hard way:
1. **S-curve, never linear contrast.** `(c-pivot)*k+pivot` pushes anything near 1.0 straight past it
   and CLIPS — it turned a sky into a slab of pure white. `mix(c, c*c*(3-2c), amount)` gives the same
   mid-tone punch and rolls off at both ends.
2. **A LOW SUN is the single biggest lever for richness.** High noon is the worst light there is:
   blown sky, flat light, no colour. A low sun (elev ~15-20°) gives deep saturated colour for free —
   warm key, deep sky, long specular glitter, real shadows. Keep the disk just above frame: you get
   the glow and the glitter without a blown sun in shot. **Time of day is a lighting choice, not a
   brief requirement** — Will: *"regardless of the time of day, that doesn't matter as much as the
   quality."*
3. **Gold vs orange is the GREEN:RED ratio.** A warm key (×.89 green) + warm env reflection + a
   saturation boost each shift red. `#d69b34` (G/R .72) lands at ~.64 and brand gold reads as
   safety-orange. Start higher — `#dcbb63` (G/R .85) survives the warm pipeline AS GOLD. Same trap
   catches dark navy: it grades to pure BLACK and loses the brand colour, so lift it at the source.
4. **Never "fix" a grade problem with local patches.** Translucent CSS tint slabs over the canvas,
   emissive floors, and scrims all *lower* contrast and saturation — they make the wash worse while
   looking like fixes. Fix the light and the grade; the patches then delete themselves.

**HTML type must be recoloured when the scene's key flips.** Absolutely-positioned overlay text is
tuned to a background that a relight silently invalidates: navy-on-pale became navy-on-dark-water
(invisible), and a kicker at 26% landed exactly on a dark hill band. After any relight, re-check
every overlay element against what is now behind it.

**Coordinate gotcha that cost two failed fixes:** `setFromSphericalCoords(r, phi, theta)` measures
theta from **+Z toward +X**, so 180° is dead ahead (−Z) and **going above 180° swings LEFT**. Twice
"moved the sun's glare away from the top-left emblem" — and moved it straight onto the emblem. If a
directional fix makes a symptom *worse*, suspect the sign before you suspect the theory.

**Thin METALLIC geometry disappears against a bright background — the brand-mark trap (2026-07-18).**
A near-chrome material (`metalness ~.98`) is mostly a *mirror*, so what it shows is whatever is behind
the camera-side of it. On a midday scene, the upper arc of the gold logo ring mirrored the blown-out
horizon and vanished — the ring read as a broken "U". This bites logos/emblems specifically, because
they are thin, must read at all times, and often sit in a corner where the backdrop changes as the
camera moves. Three levers, in order of reliability:
1. **A scrim that travels with the mark** — a soft radial dark sprite (brand ink, peak alpha ~.5,
   `depthWrite:false`, parented to the emblem group so it scales in with the reveal and holds the
   corner). Guarantees contrast against *any* backdrop. Reads as a vignette, not a badge.
2. **An emissive floor** — `metalness ~.86, roughness ~.26, emissiveIntensity ~.85`. Satin glowing
   gold self-lights instead of depending on reflections, and bloom then catches the WHOLE mark
   (uniform premium glow) rather than one hotspot.
3. **Bounded motion** — sway (`sin(t)*0.7`) instead of a full spin, so a ring never tumbles edge-on.
Corollary: **a mark that must always read cannot rely on reflection alone.** Reflection is for
surfaces you want to look real; self-glow + contrast is for surfaces you want to look *legible*.

**Reflections of large near-camera objects need CALM water.** The 3D wordmark's reflection fractured
into a dirty smear at `distortionScale` 2.1; at ~1.15 it became a legible inverted mirror. The bigger
and closer the object, the calmer the water has to be to mirror it — and a legible reflection IS the
premium optic Will is asking for. If it still smears, push the object BACK (and scale up to
compensate): that moves its reflection toward the horizon where it compresses, instead of sprawling
across the foreground.

**Plastic tells to hunt and kill:** uniform roughness; no fresnel; a single flat colour; hard/missing
shadows; no AO in cracks; opaque flat-lit foliage; everything lit equally; no tone mapping. **Reads
real:** fresnel on shiny things; roughness + colour micro-variation (noise/vertex colours); soft
shadows + AO; backlight on thin things; a real env reflected; fog tying planes to the horizon;
motion that is slow, layered, desynced — never uniform.

---

## 3. VERIFY — frozen poses, your eyes, BEFORE Will sees it

- **WATCH THE MOTION, don't just snap it.** A frozen pose cannot show what breaks *during* a camera
  move — Will (2026-07-18): *"at the start it's really good, but when it pans to the final angle you
  just can't see any of those things."* `tools/visual-qa/filmstrip.mjs` captures the page across the
  arc and tiles the frames into ONE contact-sheet PNG, so the whole move is reviewable in a single
  Read. **This is the default review for anything that animates**; every v3.2 fix on the lake was
  found by reading a filmstrip, none by guessing.
  ```
  node filmstrip.mjs <url> --poses=0,0.2,0.4,0.6,0.8,1.0 --vp=900x560 --cols=3 --label=panarc
  node filmstrip.mjs <url> --frames=18 --interval=440        # live playback cadence instead
  ```
  **Trap: pose mode misrepresents motion that is driven off the pose param.** If `?pose` also drives
  a spin, high poses show rotations the real playback never rests on — the emblem looked "broken at
  pose 1" purely as a scrub artifact. **Confirm any resting-state judgement with a LIVE snap** taken
  after the intro completes (`snap.mjs --wait=10000`). Pose mode = camera arc; live = what ships.
- **Batch the QA into one contact sheet**, don't dribble it over rounds. Snap the key states in one
  pass: `?pose=0` (arrival), `?pose=1` (settled), `?scroll=0.3` (mid-transition), plus mobile and
  dark. Read them together — first-frame defects (crushed sky, overlap, bleached materials) surface
  in one look instead of over five fix passes.
- **Diagnose from the evidence, not the first plausible story.** The lake emblem read as a broken
  gold "U"; the obvious culprit was the ring's rotation, and two fixes aimed at rotation both failed.
  The filmstrip settled it: the ring was a "U" *even at zero Y-rotation*, and full at the high camera
  — so the variable was the BACKGROUND, not the pose. Two failed fixes on the same symptom means the
  diagnosis is wrong; go find the frame that discriminates.
- **Snap tool:** `tools/visual-qa/snap.mjs <url> --vp=… --wait=… --out=…`. WebGL needs a long
  `--wait` (7–11s) so the env-gated loop has started and textures are built — a short wait catches a
  pre-loop frame (this is a headless-capture artifact, not a page bug; if mobile renders right and
  desktop doesn't, it's timing — increase the wait).
- **Fix everything you can see before delivery.** The lake hero had 11 defects caught pre-Will across
  6 poses. Velocity ≠ progress: after two failed fixes on the same thing, stop and re-diagnose (Will
  burns trust watching non-converging iteration).

---

## 4. GATE — mechanical, then deliver a URL

- `node runner.mjs <http-url> --quick` from inside the project dir (brand auto-resolves via cwd).
  taste/a11y/errors/functional/darkMode/reveals should PASS; a WebGL scene honestly returns
  **INCONCLUSIVE** overall (the gate can't see inside a canvas) — that's expected, not a fail.
- **Don't trust the gate's heuristics blindly on novel work** — it false-fired on the lake (a 120ms
  reveal-settle vs the page's contract-legal 420ms reveals; "6fps stutter" measured across
  intentional env-gated hold frames). Both were fixed in the gate. If a FAIL contradicts what your
  eyes see on a known-good frame, suspect the check, not the art — and feed the gate the declared
  durations.
- **Deliver a running URL**, never a bare `.html` (a JS-stripped sandbox once made a build
  invisible). `Start-Process "http://localhost:PORT/…"`.

---

## 5. CLOSE THE LOOP

- **Log Will's verdict to `taste-corpus.md`** with the reason — the corpus is how the next piece
  starts closer to his eye. This is the on-path mechanism; do it the moment he reacts.
- **Checkpoint the approved file** (`<page>-approved-YYYY-MM-DD-vN.html`) + a one-line changelog
  entry. Prefer anchored edits over full-file rewrites so there's a diff to reason about.

---

## What this recipe does NOT yet cover (the tree frontier)
Organic/photoreal work breaks the tricks that carried the stylised lake: pose-snapping needs a still
state (wind has none — capture a short loop); there's no "match the approved hex" ground truth for
bark/foliage, so gather **reference AND anti-reference photos** as the target before building; and
foliage's real failures (alpha-sort popping, wind shimmer, z-fighting) are frame- and view-dependent
— invisible in a still. The full tree technique (queue-based branch generator, instanced alpha-card
foliage with canopy-outward normals, 3-band vertex wind, dusk backlight translucency) is banked in
the 2026-07-18 realism research; build it with ACES from the start.

---

## 6. USE THE BENCH BEFORE YOU PICK A COLOUR (2026-07-18 — the failure that keeps repeating)

`tools/design-bench/feel.json` holds Will's taste MEASURED from work he already approved. It exists
precisely so colour decisions stop being eyeballed. It was built, and then ignored for an entire
multi-round build — he noticed: *"the visual psychology stuff seems to have completely disappeared
from the framework."*

**Run this before choosing any hex:**
```
node -e "import('<bench>/lib/oklch.mjs').then(m=>console.log(m.hexToOklch('#rrggbb')))"
```
- **APLakeside / BBS = `quiet-confidence`**: accent chroma **0.070–0.092**, ground **L 0.20–0.27**,
  canvas **L 0.92–1.00**, accent **decorative only** (APCA Lc 33–46, never body text).
- Golds invented by eye during that build measured 0.114 and 0.134 — the second is *above* the Lake
  Casper gold Will himself calls "the gold that is too gold" (0.127). The band is not decoration.

**The ground carries the richness, not the time of day.** Asked for "daytime but keep the dusk
quality", the mechanism is: dusk water measured L=0.263 (inside his house ground band) while every
daytime water sat at L=0.335–0.437 and read washed. **Bright canvas sky + ground held at L≈0.25 +
low-chroma accent** reproduces the dusk register in full daylight. Lightness contrast is the pleasure
lever (β=.69); low chroma is the low-arousal lever. Both are in feel.json with their provenance.

**Brand marks should RESOLVE.** Perpetual abstract motion reads as a screensaver. Will: *"there's no
point where everything merges together and it actually looks like the original logo."* Give the
signature object a **lockup cycle** — precess/turn in 3D, then ease every degree of freedom to zero so
the mark snaps into its flat brand form, hold it, reopen. Implementation: put each ring in a
precession FRAME (frame rotates about the view axis Z, ring holds a fixed lean on X) — the ring then
traces a CIRCLE rather than swinging open like a door, and easing the single lean value to 0 produces
the lockup for free. Spinning a torus about its own axis is the wrong primitive for both.

**"Glow" means LED, not bloom-wash.** Bright core, tight halo. Wide bloom radius + low threshold
blooms the whole letter face and eats its edges — that soft-focus look reads as cheap. Use a high
threshold (~0.85) and small radius (~0.24) so only genuine highlights bloom and edges stay crisp.

**Primitive landmarks read as cheap — scrap them.** A recognisable building made of boxes is worse
than no building: it invites the comparison and loses. Silhouette geometry needs real segment counts
(128×64, not 28×18) because an outline is unforgiving.

---

## 7. RESOLUTION, ANTI-ALIASING AND MATERIAL POLISH (2026-07-18)

The "I can still see pixels" pass. Ordered by how much each actually bought.

**`antialias: true` is INERT once EffectComposer is active.** The scene renders into a render target,
never the MSAA-backed canvas, so every edge in the post chain aliases at 1:1. The fix is
**supersampling** — render above display resolution and let the composer downsample. Real SSAA, and
it works through bloom and grade both.

**Supersampling must be a MULTIPLE of `devicePixelRatio`, never an absolute cap.** `min(max(dpr,1.6),2)`
returns exactly 2 on a HiDPI display — i.e. native, supersampling nothing. Use `min(DPR * 1.5, 2.8)`
on desktop, `min(DPR, 2)` on mobile. **And note the verification trap:** headless capture runs at
`deviceScaleFactor: 1`, so a dpr-relative bug passes every screenshot. The check that finds it is
comparing the canvas **drawing buffer** against its **CSS size**.

**Add FXAA after the grade.** SSAA fixes area coverage but still steps on THIN high-contrast edges —
a thin ring rim against bright sky, a hill silhouette. Its `resolution` uniform is in DEVICE pixels,
so it must track pixelRatio on resize *and* after any adaptive quality change.

**Anisotropic filtering is the fix for a shimmering water surface.** A normal map at a grazing angle
is the textbook anisotropic case: long thin sample footprint, so trilinear filtering either aliases
into crawling speckle or blurs to mush. `tex.anisotropy = renderer.capabilities.getMaxAnisotropy()`.
**Ripple tiling and anisotropy are coupled** — finer tiling only works once anisotropy is in.

**Guard the cost, but step DOWN partially.** Sample real frame times after the intro settles; if the
machine can't hold it, reduce the ratio ~30% and never raise it again (oscillating resolution is more
noticeable than either level). Give it a `?ss=` override that also bypasses the guard, or headless QA
trips it and every quality snapshot silently lies.

**Silhouette aliasing is better solved with ATMOSPHERE than with polygons.** Hard edges against a
bright sky are the worst case; pulling fog in so far ridges dissolve is cheaper *and* more physically
honest. More triangles would not have helped — the aliasing was at pixel level, not polygon level.

**Flat single-colour materials are the loudest "painted cardboard" tell.** A greyscale `map`
MULTIPLIES the material colour, so one mottle texture varies every landmass without touching any
palette. Keep the range shallow (~0.66–1.0): terrain at distance has low local contrast.

**Clearcoat is what reads as lacquered rather than merely shiny** — a second specular lobe over the
metal. When you upgrade a material family, grep for the one surface that missed it.

**Seed every procedural texture.** An unseeded one changes each load, destroying `?pose`
reproducibility and any pixel baseline. One shared noise implementation, not one per consumer.

---

## 8. GETTING A BRAND FONT INTO 3D — `tools/ttf-to-typeface.mjs`

`TextGeometry` needs three.js's own `typeface.json`. If you skip this you end up doing what this
build did for eleven rounds: shipping the wordmark in whatever stock font was lying around
(`gentilis_bold`) while every other element on the page used the real brand serif. Will's note was
*"redesign the text it doesn't fit well"* — the mechanical cause was that it was **the only
off-brand type on the page**.

```bash
npm i opentype.js
node ttf-to-typeface.mjs <font.ttf> <out.typeface.json> [weight]
```

Get real TTFs from `raw.githubusercontent.com/google/fonts/main/ofl/<family>/`. **Do not** use the
legacy-User-Agent trick against the Google Fonts CSS API — it returns **EOT**, which opentype.js
rejects with "Unsupported OpenType signature".

Two traps that produce silently-wrong output:

1. **Use `glyph.path`, NOT `glyph.getPath()`.** `getPath()` returns RENDER coordinates — y-flipped
   into screen space with the baseline offset applied — which yields upside-down glyphs. `glyph.path`
   is the raw outline in font units, y-up, which is what the format stores.
2. **The opcode order is not SVG order.** `m x y` · `l x y` · `q endX endY ctrlX ctrlY` ·
   `b endX endY c1x c1y c2x c2y` — **end point first**, then controls. Emitting SVG order gives
   scrambled glyphs with no error.

Also: **opentype.js 2.0's `variation.set()` does not apply `gvar` deltas to outlines** (verified on a
fresh parse — 400 and 700 come out byte-identical). So a variable font converts at its default
master only. If you need a heavier weight, find a static instance; otherwise compensate for fine
hairlines with a **smaller bevel**, not a heavier face.

**Sanity-check before shipping:** compare a glyph against a known-good typeface.json. Coordinates
should sit in the 0–1000 font-unit range with y increasing upward. If they cluster near zero or go
negative where they should be positive, the coordinate source is wrong.


---

## 9. EXTRUDED TYPE READS AS PLASTIC — and the debugging rule that came out of fixing it

`ExtrudeGeometry` emits **non-indexed** geometry, so `computeVertexNormals` produces flat per-face
normals: a glyph's entire front face shares ONE normal. On a mostly-diffuse material, constant
irradiance on a constant normal is **literally one colour**. Measured on a shipping build:
**2,188 px of exactly `#d6d5d5`** across the ivory letters, 586 px of exactly `#bd9d4f` across the
gold. That is the whole reason 3D type looks like moulded plastic.

Two fixes, both free if you already build the wordmark glyph-by-glyph (which you must anyway,
because **three.js r128 applies no kerning**):

1. **Per-glyph micro-rotation** — index-hashed so it stays deterministic, ±2–3°. Each letter then
   samples the environment from a different direction. Varies tone BETWEEN letters.
2. **A fine micro-relief normal map** — per-PIXEL normal variation, so a single face samples a
   RANGE of the environment instead of one direction. This is what turns a flat fill into a
   gradient. Amplitude should read as "the surface isn't mathematically perfect", never as texture.

Measured effect on the largest single-colour region: 7.6% → 5.1% (rotation) → 4.4% (normal map).

### The debugging rule — worth more than the fix

The normal map at `normalScale 0.18` was a **complete no-op** (4358 unique colours vs 4357 without
it — noise). The tempting next move is to go hunting for why it "doesn't work": missing UVs,
missing tangents, wrong wrap mode, material not rebuilt. All plausible, all wrong.

> **Before diagnosing why an effect isn't working, push its parameter to an absurd value to prove
> the channel is live.**

Setting it to 2.5 made the flat region vanish instantly — so it *was* reaching the shader and the
amplitude was simply ~14× too small. One test separates **"not wired up"** from **"wired up but too
subtle"**, and those two have completely different fixes. This is the same discipline as finding the
discriminating frame: make the experiment answer a binary question rather than a vague one.

### Two type-specific rules

- **`bevelSize` ≤ ~25% of the THINNEST stroke, not the thickest.** Bevels apply outward on every
  edge, so an oversized one eats hairlines *and* closes the gaps between letters. At a serif's
  concave bracket, a bevel wider than the fillet radius inverts it into folded, self-intersecting
  facets — which under clearcoat read as bright wrong-facing specular chips.
- **Extrude depth 0.3–0.6× stem width**, not ~1×. Depth equal to the stem is a plastic
  block-letter proportion, and if the camera views the glyphs near their own normal you barely see
  the side walls anyway — so excess depth buys a weight defect (outer glyphs gain apparent weight
  from visible side walls, inner ones don't) instead of dimensionality.

**Verify the property landed, don't assume the edit did.** One material silently never received the
normal map because a string anchor didn't match. `grep` for the applied property afterwards.


---

## 10. PERFORMANCE — budget pixels, never ratios

The same `devicePixelRatio` blind spot produced two different bugs in this project: first a quality
fix that was a **no-op** on HiDPI (v3.7), then a framerate collapse **caused** by HiDPI (v4.2).

> **Never express a rendering cost as a ratio. Express it as a pixel budget.**

A ratio multiplies with BOTH window size and DPR, so `DPR * 1.5` quietly became 10–16 megapixels per
frame on a HiDPI laptop — 44–70 MP across four post passes — while the case actually measured
(dpr 1) was 2.3 MP. Roughly 7x the tested load, invisible to every check.

```js
var MAX_MAIN_PIXELS = 5.5e6;
var target = (DPR >= 1.75) ? DPR : DPR * 1.6;   // see below
var budget = Math.sqrt(MAX_MAIN_PIXELS / (innerWidth * innerHeight));
var SS = Math.max(1, Math.min(target, budget, 2.0));
```

**Supersampling is for LOW-DPI displays.** At dpr ≥ 1.75 the panel already oversamples; target native
and spend nothing extra. At dpr 1 an aliased edge is genuinely visible, so ~1.6x earns its cost. Code
that scales supersampling UP with DPR spends most on the displays that need it least — exactly
backwards.

**Know your recurring costs.** In a water scene the planar reflection **re-renders the entire scene
every frame** — after the main buffer it is the single largest recurring cost, and its resolution is
usually the cheapest big win. Shadow map size is the other: tightening the shadow camera raises texel
density faster than growing the map, so do that FIRST and you may not need the bigger map at all.

**Smoothness ≠ framerate.** Periodic hitching usually means per-frame allocation feeding the GC, not
a low average. Hoist scratch vectors out of the render loop.

**Adaptive quality must be continuous and multi-step.** A guard that samples once and steps once
leaves the page slow forever if one step wasn't enough. Rolling median over ~90 frames, up to 3
steps, and strictly one-way — resolution that oscillates is more noticeable than resolution that is
simply lower.

**You cannot measure GPU performance headlessly.** Software rasterisation reports ~1fps regardless,
so absolute numbers are meaningless and only ratios between two runs mean anything. The honest design
is therefore to measure on the USER'S machine and back off — which is what the guard is for.
