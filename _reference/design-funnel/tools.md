# Tools

Canonical location: `C:\Users\bowke\OneDrive\Desktop\CLAUDE\tools\`
(**not** in this repo — that folder is not under git. See "Drift warning" at the bottom.)

Copies of the two small self-contained ones live in `./tools/` here so the method survives even if
that folder doesn't.

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
