# Tools

Canonical location: `C:\Users\bowke\OneDrive\Desktop\CLAUDE\tools\`
(**not** in this repo — that folder is not under git. See "Drift warning" at the bottom.)

Six self-contained tools are copied into `./tools/` here so the method survives even if that
folder doesn't. The heavier ones (runner, design-bench) stay canonical at the path above.

---

## filmstrip.mjs — WATCH the motion

The most important tool in the set. A frozen frame cannot show what breaks *during* a camera move.
This captures the page across the arc and tiles every frame into **one** contact-sheet PNG, so the
whole motion is reviewable in a single look.

```bash
cd tools/visual-qa

# scrub the deterministic camera arc
node filmstrip.mjs "http://localhost:3021/intro.html" \
  --poses=0,0.2,0.4,0.6,0.8,1.0 --vp=900x560 --cols=3 --label=panarc

# sample REAL playback instead (for ambient/looping motion)
node filmstrip.mjs "http://localhost:3021/intro.html" \
  --frames=9 --interval=1500 --vp=880x550 --cols=3 --label=lockup
```

**Trap:** pose mode misrepresents any motion driven *off the pose param*. If `?pose` also drives a
spin, high poses show rotations real playback never rests on. **Confirm resting-state judgements
with a live snap** (`snap.mjs --wait=10000`). Pose mode = the camera arc; live = what ships.

---

## snap.mjs — a real screenshot

The browser-pane screenshot times out (~30s, reproduced 6/6) and backgrounds the tab so WebGL never
paints. Use this instead.

```bash
node snap.mjs "http://localhost:3021/intro.html" --vp=1280x720 --wait=10000 --out=./snaps/x.png
node snap.mjs "http://localhost:3021/intro.html?ss=2" --vp=1280x720 --wait=17200   # force full quality
```

WebGL needs a long `--wait` (7–11s+) so the env-gated loop has started. A short wait catches a
pre-loop frame — that's a capture artifact, not a page bug.

---

## errcheck.mjs — console errors, fast

```bash
node errcheck.mjs "http://localhost:3021/intro.html"
```

Faster than the full gate and catches the thing that actually breaks a build (a material or shader
that throws). Use it after any material/shader change.

---

## perfcheck.mjs — FPS and the real drawing buffer

```bash
node perfcheck.mjs        # default ratio
node perfcheck.mjs 1      # force ?ss=1 to A/B the cost of supersampling
```

Reports fps, the drawing-buffer size, and the CSS size — so you can confirm supersampling actually
engaged (buffer > CSS) and what it costs.

**Read the numbers honestly:** headless Chromium uses software rasterisation, so absolute fps is
meaningless (the lake scene sits at ~1fps headless and 60 on real hardware). Only the **ratio**
between two runs is informative.

---

## predeliver.mjs — THE SHOW / NO-SHOW GATE (run this before Will sees anything)

**The rule: you do not show Will a build until this exits 0.**

```bash
node predeliver.mjs <url> --brand=aplakeside      --ref="<url of the last APPROVED checkpoint>"
```

Why it exists, from the council on why the lake build took 14 rounds: a 1088-line playbook and a
calibration file both existed by 20:03, and five more rounds shipped after them without either being
opened. **A document that CAN be skipped IS skipped.** And the old QA gate carried zero information —
it returned the same verdict on the build Will approved on sight and on the builds he rejected,
including a check named `taste` that passed on every rejected build.

So this is a different KIND of object: it is **on-path** (it stands between the build and delivery),
its expected values are **read out of files Will already approved** (the builder does not author the
pass condition), and it has **no advisory verdict** for what it measures.

What it checks, and which past round each one would have caught:

| check | catches |
|---|---|
| `resolution` | v3.7 — a "quality fix" that was a total no-op on HiDPI and passed every headless check |
| `brand-typeface` | v4.0 — the hero wordmark was the only off-brand type on the page, true since round 1 |
| `accent-consistency` | two golds in one frame at different chroma reading as two different golds |
| `ground-lightness` | washed-out frames — his house ground is L .20–.27 across three brands |
| `flat-region` | v4.1 — extruded type rendering as single flat colours (plastic) |
| `drift-vs-approved` | **the important one.** v3.4 — the gold cascade, caught at v3.1 instead of v3.4 |

**`accent-chroma` is deliberately ADVISORY, and that matters.** The band in `feel.json` was measured
from approved SOURCE TOKENS and does not transfer to rendered PIXELS. Proof: v1 — the build Will
approved on sight — renders its gold at median chroma 0.054, far below the source band. An absolute
pixel band would have BLOCKED the most-approved artifact in the project. Blocking on drift versus an
approved reference is the honest version.

---

## resizetest.mjs — the transition test

```bash
node resizetest.mjs
```

Fires 25 spurious resize events and asserts the drawing buffer does **not** change, then performs a
real resize and asserts it **does**. Both directions — otherwise you have only proven you broke
resizing.

It exists because **every other tool here renders at ONE fixed viewport and never resizes or
scrolls**, so defects living in the TRANSITIONS between configurations are structurally invisible to
the whole harness. Known gap: there is still no equivalent for a mid-run adaptive-quality step,
because it cannot be triggered headlessly (software rasterisation runs ~1fps, so a 90-frame window
takes 90 seconds).

---

## runner.mjs — the mechanical gate

```bash
cd <project dir>          # brand auto-resolves from cwd
node ../tools/visual-qa/runner.mjs "http://localhost:3021/intro.html?ss=1" --quick
```

Expect **PASS** on contrast / content / reveals / errors / a11y / taste / functional, and an honest
**INCONCLUSIVE** overall on any WebGL scene — the gate cannot see inside a canvas. That is correct
behaviour, not a failure.

- **Run WebGL pages at `?ss=1`.** Supersampling makes headless software rendering so slow the gate
  times out.
- **Don't trust its heuristics blindly on novel work.** It has false-fired on a reveal-settle window
  and on "stutter" measured across intentional env-gated hold frames. If a FAIL contradicts what
  your eyes see on a known-good frame, suspect the check — and then go fix the check.

---

## design-bench — the calibration

```bash
node tools/design-bench/server.mjs      # -> http://127.0.0.1:4321
```

Brand board (real tokens read live from shipped code + drift detection), colour lab (APCA vs WCAG2),
motion lab, feel vocabulary. **Use it before choosing a colour** — see [calibration.md](calibration.md)
for the one-liner that matters most.

---

## Determinism hooks to build into every scene

Free, and they are how you review your own work:

| hook | does |
|---|---|
| `?pose=0..1` | freeze the signature animation at any fraction |
| `?scroll=0..1` | jump the scroll transform to any point |
| `?ss=<n>` | force the supersample ratio (also bypasses the adaptive guard) |
| `prefers-reduced-motion` branch | keeps state, drops motion — the safety floor |

---

## Drift warning

`C:\Users\bowke\OneDrive\Desktop\CLAUDE\` is **not** a git repo. The tools live there and are
canonical; the copies in `./tools/` are a lifeboat, not a source of truth. If you edit one, edit the
canonical one and re-copy — a second copy that drifts is exactly the failure the design-bench's
drift scanner exists to catch.
