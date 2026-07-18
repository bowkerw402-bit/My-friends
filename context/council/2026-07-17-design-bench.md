# Council Verdict — Design Bench + web-design-3d consolidation (2026-07-17)

**Question:** A personal design system was built in one session and is now the single front door for
all visual work. Is the four-layer architecture sound, is the scaffold seam right, what's wrong?

**Tier:** MINI (3 advisors: Contrarian, Executor, First Principles) + 1 falsification reviewer.
**Pre-registered risk:** the work was already built, so the run was structurally tempted to bless it.
It did not. **Verdict: ABSTAIN on the repair plan. Three things must be found out first.**

---

## Convergences (all verified on disk, not asserted)
1. **The one hard block cannot fire where it matters.** Probe: a canvas/rAF page carrying the
   scaffolder's *own* universal CSS reset → `reducedMotion: INCONCLUSIVE` → `GATE: INCONCLUSIVE` →
   **exit 0**. `getAnimations()` sees 0 WAAPI animations in both contexts. The flagship (BBS) is
   three.js + R3F + GSAP. *"The medical rule is enforced everywhere except where the medicine applies."*
2. **The scaffolder disarms the block** — every new project is born `DECLARED` via
   `design-tokens.template.css:88`, regardless of whether the branch touches the real motion.
3. **The evidence layer is decorative.** `runner.mjs` never reads `findings.json`; `SAFETY` is a
   hardcoded literal; **nothing reads the `blocks` field**. "Only grade `medical` may block" is prose
   with no mechanism. *"The layers aren't coupled — they're adjacent."*
4. **Every real gate run applies the WRONG contract.** `runner.mjs:109` auto-loads `intent.json` only
   for `file:` targets; every real project is `http://`. So `--brand` is never supplied and Evidence
   Desk silently gets APLakeside's restraint.
5. **Off-path mechanisms die.** `taste-corpus.md` — the mechanism the *prior* council (2026-07-10)
   adopted as THE way to converge on Will's eye — is untouched since 2026-07-14. This session cited
   it twice as authority and appended zero entries. **Month 2 arrived on day 3.**
6. **Green ≠ covered.** Fixtures contain no canvas/WebGL — the test set was drawn from the check's
   own competence set.

## Disagreement map
| Clash | Type | Status |
|---|---|---|
| Make the gate BITE (Contrarian/Executor) vs the gate is "a lab coat over a blind sensor" (First Principles) | resolvable by evidence | **X1** |
| Pixel-delta as the sensor fix (chairman) vs churn ≠ optic flow (reviewer) | resolvable by evidence | **X2** |
| The 420 dead stubs are the root cause (chairman/FP) vs countable ≠ causal (reviewer) | resolvable by evidence | **X3** |
| Keep Bench, or is it "a higher-framerate way to watch the iteration Will says he hates"? | **values choice for Will** | open |

## Blind spots the review found (what ALL THREE advisors missed)
- **The system holds zero bits of Will's taste.** Hard-block list empty *by choice*; corpus empty.
  *"All three argue plumbing for an empty pipe."* A safety waiver is not a taste verdict.
- **Nobody asked whether Will requested the motion block.** It reads as self-authorized — the agent's
  own mandate. If it isn't wanted, the strongest move is **delete it**, and half this council evaporates.
  Nobody proposed deletion.
- **"420" is attractive because it's countable.** The measurability-substitution was diagnosed, then
  committed. Untested: would any of those 420 have prevented a specific bad output?
- **Nobody costed "no system"** for a solo operator with a hand-typed gate.
- **The builder is the grader.** The prior council named "self-written justifications rationalize" as a
  root cause; a self-run council is that failure wearing a hat.

## The killed recommendation (chairman's draft, destroyed by review)
Pixel-delta reduced-motion sensor. **Wrong quantity.** VIMS tracks *coherent large-field optic flow*;
frame-differencing measures *pixel churn* — anti-correlated where it matters. Shimmer = high churn / no
sickness (false positive). Slow dolly = low churn / maximal sickness (false negative). Autoplay
carousels (**which Will likes**) churn identically in both contexts → compliant pages fail. Two loads
share no clock → flaky → *a flaky fail-closed gate gets commented out*. And building it before the
separation test **repeats the exact error of fact 6.**

## Premortem (3 months on, all fixes shipped, design still "an issue")
None of the fixes make design *good* — they answer "does this break a rule". Contracts encode tokens,
not composition, hierarchy, restraint or type. The waiver became the path of least resistance and Will
waived by reflex; the corpus filled with "fine", carrying zero taste. Brand resolution got fixed so the
gate passed — on ugly pages. The 420 got repaired and the agent still picked wrong, because the failure
was **routing, not availability**. Nobody wired a pre-commit hook, so it stayed discretionary and the
on-path law ate it. **Three months of green gates on ugly pages.**

## VERDICT — abstain, find out X first
**X1 (Will, one question).** Five hard "never ship this" rules in his own words — and **is motion
safety among them?** Until the block list is non-empty *with his entries*, every enforcement fix
optimises rules nobody wrote. If he never wanted the motion block: **delete it.**
**X2 (experiment, before any code).** 5 repeat runs of any candidate motion sensor against (a) BBS,
(b) a hand-compliant control, (c) a compliant page with video. Overlapping distributions = zero
discriminative power = don't build it.
**X3 (counterfactual).** Take the last three bad designs. Was the skill that would have saved them among
the 420? If not, "420 dead stubs" is a coincidence wearing a root cause's clothes.

---

# RESOLVED — X2 and X3 were run the same day (2026-07-17)

Will's call on X1: *"fix the sensor properly — but test first."* So X2 ran before any code.

## X2 — motion sensor separation experiment: **DO NOT BUILD**
Script: `tools/visual-qa/experiments/x2-motion-sensor-separation.mjs` (5 repeats × 5 specimens ×
2 contexts). Candidate: mean absolute per-pixel delta between consecutive frames; decision rule
`ratio = motion(reduce)/motion(normal)`.

| specimen | truth | ratio mean | spread |
|---|---|---|---|
| a — rAF canvas, universal CSS reset (the BBS class) | FAIL | 1.029 | **0.285** |
| b — rAF canvas honouring matchMedia | PASS | 0.000 | 0.000 |
| c — compliant + autoplaying video | PASS | **0.591** | 0.162 |
| d — compliant + JS autoplay carousel (**Will LIKES these**) | PASS | **0.771** | 0.184 |
| e — non-compliant slow full-field dolly | FAIL | 0.998 | 0.008 |

**gap between classes 0.033 · noise within a class 0.285 · margin 0.12 (needs ≥1.0) → NOT SEPARATED.**

Two independent confirmations of the reviewer:
1. **False positives landed exactly as predicted.** A *compliant* page scores 0.591 for containing
   video and **0.771 for containing an autoplay carousel** — which the contract says to *never flag*.
2. **Flakiness proven across runs.** Between two runs of the same experiment the non-compliant
   minimum moved 0.859 → 0.842 and its spread doubled (0.141 → 0.285). **The run-to-run variance is
   larger than the gap between the classes.** A threshold here is fitted to sampling luck.

⚠ **The experiment nearly fooled its author.** The first decision rule compared observed *extremes*
and printed **"SEPARATED — BUILD IT"** off a 0.021 gap sitting under a 0.141 spread. The measurement
was fine; the *decision rule* was the defect. Fixed to require gap ≥ noise. **The script that exists to
stop me trusting myself almost got trusted.**

→ **The pixel-delta sensor is dead.** The chairman's load-bearing fix is falsified empirically, not
by argument.

## X3 — the 420 counterfactual: **the 420 is NOT the root cause**
For every failure recorded in `taste-corpus.md`, the skill that would have prevented it was **LIVE and
BUNDLED the whole time**: `threejs/threejs-lighting` (12KB), `threejs-materials` (13KB),
`threejs-geometry` (14KB), `r3f/r3f-fundamentals` (17KB), `design/blender-web-pipeline` (17KB),
`design/modern-web-design` (27KB). And **zero of the 420 dead stubs are 3D/render/lighting/animation
skills** — none of them could have prevented any recorded bad design.

→ **"420 dead stubs" is a coincidence wearing a root cause's clothes.** Reviewer confirmed. It was
attractive because it was *countable* — the measurability-substitution First Principles diagnosed, then
committed by the chairman within the same session.
→ **The real failure is ROUTING, not availability.** The skills were present, large, and correct, and
were not consulted. Will opening this very session with `/use-skills-aggressively` is the evidence.

## What this changes
- **Sensor: not built.** The reduced-motion block covers **declarative motion only** (proven both ways:
  `planted.html` CHECKs, `clean.html` PASSes). On canvas/WebGL/GSAP it returns INCONCLUSIVE — which is
  the gate's existing and correct philosophy (*never claim what you cannot verify*). **The defect was
  never the block — it was calling it a guarantee.** Fix the claim, not the code.
- **420 cleanup: deprioritised.** Not the root cause. The 9 design-relevant tombstones stand (they were
  genuinely dead); the remaining ~411 are noise, not causation, and deleting them buys nothing measured.
- **Routing is the open problem** and nothing built today addresses it.

## Tripwire + flip-evidence
- **Tripwire:** in 14 days, count hand-typed `runner.mjs` invocations and `taste-corpus.md` appends.
  **If both are 0, the verification half is dead — delete it rather than maintain it.**
- **Flip-evidence:** Will saying *"I never asked for a motion block"* reverses the verdict and deletes
  facts 1/2/6 and half the repair plan.

## First step
Ask Will X1. One question. It decides whether four of the six proposed fixes should exist at all.

---

## Appendix
**Advisor core claims (one line each):**
- **Contrarian:** "The one hard block is disarmed by the system's own scaffold and cannot fire on the
  flagship stack." → verified by probe, exit 0.
- **Executor:** "Every gate run against a real project silently applies the WRONG contract." → verified,
  `runner.mjs:109`.
- **First Principles:** "Every mechanism requiring a discretionary human act *after* Will already has
  what he wanted is dead on arrival." Survival law: **on-path lives, off-path dies.** Diagnosed the
  substitution: the complaint was **retrieval-at-generation**; **verification-at-review** got built,
  because verification is measurable and loading isn't.
- **Reviewer:** the pixel-delta fix relocates the tension rather than dissolving it; the system holds
  zero bits of Will's taste; the question is **not decidable** without X1/X2/X3.

**Delta vs the chairman's Step-0 baseline:** Baseline said *"architecture sound, untested, the risk is
adoption, go use it on a real project."* The council **beat it materially**: it *proved* (not suspected)
that the hard block cannot fire on the flagship; showed the corpus had already died on day 3; showed
the evidence layer's authority is decorative prose; and surfaced that the system contains none of
Will's actual taste. The baseline's "just go use it" would have shipped all six defects. **This was not
a blessing run.**

**UNVERIFIED assumptions carried into the verdict:** that Will wants a motion block at all (X1); that
any motion sensor can discriminate compliant from non-compliant on his stack (X2); that the 420 stubs
caused any real bad output (X3).

**Compliance — steps of the v2 spec skipped this run, and why:**
- **Substrate diversity NOT achieved.** `ask-codex.ps1` is absent from `CLAUDE/tools`; `orchestrate.ps1`
  exists but memory records the standalone CLI auth as broken. All four agents were the same model, so
  *agreement between them is the null hypothesis, not signal.* Mitigated by exclusion lists + different
  context slices, and the advisors did produce divergent, falsifiable, disk-verified claims rather than
  persona cosplay — but the caveat stands.
- **Context pack shown but not gated on.** It was published to Will in-message and spawned in the same
  turn rather than waiting for objection.
- **Anonymization:** digest order randomised; no stronger claim made.
- Fixed mid-run before advisors spawned (found by the Step-0 assumptions check): `--no-taste` disabled
  the medical safety floor, because the reduced-motion check was gated on `CONTRACT?.safety` and
  `--no-taste` nulls CONTRACT. Now unconditional; test added.
