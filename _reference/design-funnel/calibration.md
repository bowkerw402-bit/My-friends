# Calibration — Will's taste, measured

Not theory. Every band below was measured out of a palette he had already shipped and approved.
The research **explains** the bands; it did not generate them. That order matters — theory-first
produces the internet's mean.

Source of truth: `tools/design-bench/feel.json` (+ `brands/*.json`, which point at shipped code and
never restate a hex).

---

## Run this BEFORE choosing any colour

```bash
node -e "import('C:/Users/bowke/OneDrive/Desktop/CLAUDE/tools/design-bench/lib/oklch.mjs')
  .then(m => console.log(m.hexToOklch('#b79b61')))"
# -> { L: 0.702, C: 0.0832, ... }
```

Fifteen seconds. It is the difference between his taste and mine.

---

## The accent ladder (OKLCh chroma — the perceptual "how colourful" axis)

| brand | accent | chroma | his own words |
|---|---|---|---|
| BBS | champagne `#c9ae78` | **0.078** | flagship, hero LOCKED, "really, really good" |
| APLakeside | gold `#b79b61` | **0.083** | premium-restrained, risk-averse buyers |
| Evidence Desk | green `#136c40` | **0.107** | where he asked for "animation and movement" |
| Lake Casper | gold `#e09e4a` | **0.127** | *"the gold that is too gold"* |

He built these independently, months apart, by eye. The ladder orders **exactly** as his stated
intent for each brand. **He named the top of his own ladder before anyone measured it.**

### What I shipped against it (the failure this file exists to prevent)

| gold I invented | chroma | verdict |
|---|---|---|
| `#dcbb63` | 0.114 | *alive/cinematic* territory — wrong feel entirely |
| `#d69b34` | 0.134 | **above** the gold he calls "too gold" |

Twice. By eye. While a tool that would have caught it in one command sat unopened.

**Do not use HSL saturation for this.** HSL scrambles the ladder (43/37/70/71 — it claims
APLakeside is the *least* saturated when it is second) because HSL saturation is not perceptual at
low lightness. Valdez & Mehrabian ran their regressions on Munsell-derived saturation, so their
exact coefficients are not portable to HSL; what replicates is the **direction** (saturation drives
arousal, hue does not).

---

## The house ground — the most useful number in this file

**L = 24% / 23% / 25%** across APLakeside, BBS and Evidence Desk. Three brands, arrived at
independently, within two points. (Lake Casper sits at 16% — deliberately cinematic.)

He has one ground lightness and had never written it down.

### Why this is the whole game

Asked for *"daytime, but keep the same visual effects of the quality of things when it was actually
at dusk"* — the mechanism is **not** the time of day:

| build | water L | reads as |
|---|---|---|
| dusk | **0.263** | rich (in band) |
| daytime attempt 1 | 0.335 | washed |
| daytime attempt 2 | 0.437 | "grey dishwater" |

The dusk version looked rich because its ground happened to land **inside his band**. So:

> **bright canvas sky + ground pinned to L≈0.25 + low-chroma accent = the dusk register, in full
> daylight.**

Lightness contrast is the pleasure lever (β=.69); low chroma is the low-arousal lever (β=.60).
Time of day is decoration on top of the ground.

---

## The usage rule he already follows

Every gold he has shipped is **decorative** — APCA Lc 33–46 on canvas, never body text. His single
text-capable accent is Evidence Desk's green (Lc 82), the one that carries the evidence chip.

Decorative accents are low-Lc *by his choice*. Text accents earn their contrast. Don't "fix" a
decorative gold's contrast — that is not a bug.

---

## The feels (bands → tokens → gate)

| feel | for | accent chroma | ground L | density |
|---|---|---|---|---|
| **quiet-confidence** | APLakeside, BBS. His default. | 0.070–0.092 | 0.20–0.27 | restrained |
| **alive** | Evidence Desk. Interactive tools. | 0.098–0.118 | 0.20–0.27 | dense |
| **cinematic** | Lake Casper. Scene carries the page. | 0.115–0.140 | 0.12–0.19 | restrained |
| functional | government / public service | *extrapolated — hypothesis only* | | |
| playful | consumer | *extrapolated — hypothesis only* | | |

Two are calibrated against real approvals. One is calibrated on colour and guessed on motion. Two
are guesses end to end and say so. **A feel with no verdicts is fiction with a citation** — gate it
as an opposed tile, never ship straight from it.

Motion for quiet-confidence: 250–450ms, travel ≤24px, stagger 80ms, one ambient exception.

---

## Things he has told me that are not colour

- **"Glow" means LED**, not bloom-wash. Bright core, tight halo. Wide bloom radius + low threshold
  blooms the whole letter face and eats its edges — that soft-focus look reads as cheap.
- **Brand marks should resolve.** Perpetual abstract motion reads as a screensaver: *"there's no
  point where everything merges together and it actually looks like the original logo."*
- **Primitive landmarks read as cheap.** A recognisable building made of boxes is worse than no
  building — it invites the comparison and loses. He said scrap it, and he was right.
- **He dials motion DOWN, not up.** He has never approved a bouncy curve.
- **Silhouettes are unforgiving.** *"You can tell there's bumps in the mountain, you can tell it's
  not rendered very well."* Outline geometry needs real segment counts.
