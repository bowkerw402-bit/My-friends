# Case study — the BBS monogram hero and the services prism

2026-07-19. Two builds for Bowker Business Services, run straight after the lake hero and using the
funnel deliberately. The brief on the first was explicit: *"I really like the aesthetics of the AP
Lakeside logo animation... I would like those same effects carried over."* The second started as
*"three little animations... on a carousel where they're spinning, like a merry go round"* and ended
as a triangular prism.

Same format as [case-study-lake-hero.md](case-study-lake-hero.md): what he said, what I did, **what
the cause actually was**. Read that one first — this is the sequel and it repeats its central lesson
(the cause is one layer below the symptom) while adding a new one about **tests that accuse correct
code**.

Code: `bowkers-business-services` branch `feat/hero-v2-and-services-prism`, routes `/hero-v2` and
`/services-carousel`.

---

## Part 1 — the monogram hero

### "there is like zero contrast"

> *"decent, but there is like zero contrast and doesnt reflect at all what im trying to make here,
> like can u not see how good this is"* (with the approved APLakeside v1 attached)

**Measured, not eyeballed:** the mark's faces sat at **L .220** against a ground of **L .226**.
Separation **0.005**. The reference he attached runs **0.650** (polished gold L .786 on near-black
L .136) — **130× more**. Navy painted on navy; only the rim was doing any work.

The ground was a flat `#061b3a` fill. Fix was not to brighten the mark, it was to give it somewhere
to separate FROM: near-black at top and bottom with a warm champagne glow band behind it, the same
shape as the reference's horizon. Dark surround, lit subject.

**Lesson: "no contrast" is a measurable claim. Measure both sides before touching either.**

### "why is there no navy on the logo"

I reported the mark was "34% navy" and he could see it wasn't. The classifier tested
`(h > 210 || h < 300)` — **a tautology**. Every hue on the wheel satisfies it. The metric had been
green the whole time while being incapable of returning anything else.

**Lesson: a measurement that cannot fail is not a measurement.** Before trusting a metric, feed it a
case it must reject. If it passes that too, the metric is decoration.

### Three silent edit failures in a row

Multi-line anchors didn't match, the edits reported success, nothing changed. Only caught by grepping
for the applied property afterwards.

**Lesson: verify the edit landed, in the file, before evaluating the result.** Otherwise you are
grading the previous build and concluding your change did nothing.

### Reduced motion lost a hydration race

Implemented in JS (`useSyncExternalStore` → conditional style). Measured at first paint under
emulated `reduce`, the guides still read `strokeDashoffset: 1400` and the wordmark `opacity: 0` — the
accessibility contract depended on hydration completing. Moved to a CSS media query, which cannot
race and does not hide content behind JavaScript.

**Lesson: accessibility branches belong in CSS.** A JS branch is a promise that hydration will win.

---

## Part 2 — the services prism

### Constant spin vs. legibility — a taste call, not a bug

I built the ring spinning at constant speed, filmed a full rotation, and found most frames caught the
panels edge-on or steeply oblique, with one frame showing no readable panel at all. So I changed it
to dwell square-on ~5s per service and turn 120° in ~1s, and explained why.

He overruled it: *"needs to be constantly spinning."*

**That was the right call by him and the right process by me.** The filmstrip found a real defect; the
fix was a legitimate option; the choice between legibility and continuous motion was always his. What
matters is that it was surfaced as a decision instead of silently taken. Constant spin is now
documented as a known, accepted trade.

### "upscale wayyyy more" — the reusable one

**Making a DOM figure bigger is not a width change.** These figures are percentage-based GEOMETRY
carrying viewport-based and fixed-pixel TEXT:

```css
.web-h      { font: italic 500 clamp(12px, 1.5vw, 21px)/1.28 var(--display); }
.web-dots i { width: 6px; height: 6px; }
.ed-plate   { padding: 5px 12px; font-size: clamp(8px, .85vw, 11px); }
```

Widen the panel and the boxes grow while the type, dots, rules and icons stay exactly where they
were. The figure does not scale up, **it comes apart** — microscopic type inside a huge card.

The fix, and it is general:

1. Make the panel a **container**: `container-type: inline-size`.
2. Re-express every fixed and `vw` value inside it in `cqw`, **converted at the size it was designed
   for**. `.85vw` at a 1180px viewport on a 342px panel = `2.9cqw`. The figure then looks exactly as
   drawn and holds that appearance at any size.
3. **Nest containers** when the figure sits inside a larger frame — put `container-type` on the
   figure too, so its internals resolve against the figure while the caption's resolve against the
   frame. Skipping this made every value ~39% too large.

It also stays sharp for free: nothing is a raster being magnified. Percentage geometry, SVG icons,
and live text re-laid-out at the new size.

### Perspective is a SIZE control, not just a drama control

At `perspective: 1400px` with the faces at `translateZ(281px)`, the front face is magnified

    1400 / (1400 - 281) = 1.25×

which took a 512px figure to **658px on screen** and put its caption at y=815 on a 780px viewport.
Nothing in the CSS said 658. Pushing the camera to 2100px dropped it to 1.17× and the panels kept
their size while fitting the frame.

**Any `translateZ` under a perspective silently rescales the element. Measure the rendered box.**

### Radius is a RATIO to panel width

At `--r: 620px` against a 600px panel the ring was wider than the viewport: faces swung to x = ±620
on a 1280 screen and the middle of frame went empty. Radius has to be expressed against the panel, not
picked as a number.

### THE PRISM — the constraint that makes it an object

> *"connect them like a tri prism almost"*

Three faces only **meet** at their vertical edges when the radius is the apothem of the equilateral
triangle they form:

    apothem = width / (2 · tan 60°) = width × 0.28868

Larger and the faces separate into floating cards. Smaller and they intersect through each other.
Derive it from one size input so the ratio survives every breakpoint:

```css
.ring { --w: min(46vw, 640px); --r: calc(var(--w) * 0.28868); }
.face { width: var(--w); transform: translate(-50%,-50%) rotateY(var(--deg)) translateZ(var(--r)); }
```

Three consequences that are not optional:

- **Every face must be the same rectangle.** Any per-panel scale correction breaks the prism. Fit the
  content INSIDE a uniform face instead (here 72% / 88% / 66% width, chosen so three figures of
  aspect 1:1, 1.34:1 and 1:1.08 land within ~9% of each other in height).
- **Faces must be opaque.** At 92–96% alpha the background showed through and the solid read
  collapsed into three tinted sheets.
- **Light the edges.** `inset 1px 0 0` light on the leading edge, `inset -1px 0 0` dark on the
  trailing one, plus a cross-face gradient. Two faces then meet with a genuine tonal step instead of
  a drawn line. This is what sells it as an object.

### Depth shading — why perspective alone reads flat

Perspective makes far faces smaller but leaves them **just as bright**. Give each face a
brightness/saturate/shadow cycle on the same period as the ring, phase-offset per seat:

    --delay = -PERIOD × (1 − seat° / 360)

### TRIED AND REJECTED — six seats from three figures

Mount the set twice, half-turned: seats every 60°, something always within 30° of front, and
duplicates sit exactly opposite so backface culling hides one. **The geometry was right and it looked
wrong.** On a tight orbit six large panels collide rather than queue, and because one figure is mostly
transparent the panel behind showed straight through it, so its icons floated on top of the website
mock.

**Coverage was never the binding constraint; overlap was.** Recorded in the source file so it does not
get re-derived and re-shipped.

---

## The new lesson: tests that accuse correct code

Three times in one build, the test was wrong and the code was right. Each failure was confident and
specific, which is exactly what makes it dangerous.

| Assertion | Verdict | Actual fault |
|---|---|---|
| every panel stays inside the viewport | FAIL | The two side seats at ±120° are **supposed** to swing off-frame. Only the front one must fit. |
| advances through all three seats | FAIL "2/3" | Sampled 26 × 800ms = **20.8s against a 26s period** — it could not observe a full revolution. |
| radius/width = apothem | FAIL `NaN` | `getPropertyValue('--r')` returns the literal `calc(var(--w) * 0.28868)` token; custom properties **do not compute to lengths**. |

The third one produced the better assertion: read the applied radius out of the face's transform
matrix (`m43` on the 0° face), which measures **what the browser actually did** rather than what the
stylesheet claims.

**Rule: when a test fails on something your eyes say is fine, suspect the observation before the
code — specifically the window (is it long enough to see the event?), the selector (is it measuring
the right element?), and the units (is the value even a number?).** This is the same instinct as
[tools.md](tools.md)'s note on `guardtest.mjs`, now confirmed three more times.

And the converse still holds: two failed fixes on one symptom means the diagnosis is wrong.

---

## What transferred from the funnel, and what it saved

| Funnel rule | Used | Outcome |
|---|---|---|
| Watch the motion, don't snap it | every round | Found the dead-stage frame, the caption collisions, the six-seat collapse. **Every real defect came from a filmstrip.** |
| Measure before choosing colour | contrast round | Turned "zero contrast" into 0.005 vs 0.650 and pointed at the ground, not the mark. |
| Verify the edit landed | after 3 silent failures | Caught changes that reported success and did nothing. |
| Reuse an approved rig atomically | rim/glow treatment | Carried whole from APLakeside v1; no fix cycle. |
| Two failed fixes = wrong diagnosis | throughout | Held. |

**Cost:** the lake hero took 14 rounds. This took 4 showings across two artifacts, and 3 of those 4
were Will changing his mind about what he wanted, not the build being wrong.
