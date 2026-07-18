# Council Verdict — Full funnel reassessment against the VISION (2026-07-18)

**Question (Will's mandate):** reassess everything — not just whether it works, but whether it fits
the vision. "I don't want you to just make what I'm asking as well as possible... actually understand
what you're reviewing."

**The vision (his words, distilled):** V1 supremely good animation/edit OUTPUT · V2 he pushes vision,
the agent SEES it · V3 grounded in how humans respond · V4 agent builds through code+design skill ·
V5 his input channel (palettes, modules, look, behaviour) · V6 fits any circumstance · V7 design and
FEELING joined.

**Tier:** 4 advisors on deliberately different information slices (hands-on tracer with no vision
statement · vision judge with no mechanics mandate · sanitized outsider (film-post veteran persona) ·
first principles) + 1 falsification reviewer. Prior verdicts read first (2026-07-10 methodology,
2026-07-17 design-bench).

---

## THE CHAIRMAN'S UNDERSTANDING (the thing Will actually asked for)

What I built is a **floor-raising defence system wrapped around a build moment it never enters.**

Quality in this work is decided at generation time — in whether craft and judgment are present while
the thing is being made. The funnel verifies afterwards (honestly and now correctly), routes Will's
language into constraints (now mechanically), and catches drift and breakage (proven). None of that
makes a compliant thing great. The two stages where "supremely good" would have to live — authoring
the opposed tiles, and executing the build with the craft shelf open — are precisely the two stages
with no tooling, no measurement, and no forcing function. I answered a generation-time failure with
inspection, because inspection is measurable and generation is not. That is the same
measurability-substitution I have now committed twice, and this council caught it because four
different information slices converged on it independently.

## Convergences (all four advisors + tracer evidence)
1. **feel.json was wired to NOTHING** — every band reached a build by hand (4 manual transcriptions);
   the gate enforced the WRONG feel until overrides were hand-written with an invented provenance.
   [FIXED this run — see repairs.]
2. **A mediocre in-band design passes all seven stages untouched.** No stage's job is raising quality.
3. **The proven historic wound (craft skills present, never consulted at build time) is addressed by
   NO stage.** "Seven new stages guard every door except that one."
4. **Zero cycles everywhere:** zero real jobs through the funnel, zero new corpus entries. "A bridge
   with zero crossings is architecture, not a joining."
5. Stage-level truth (tracer, empirical): PALETTE-PENDING's documented blocking was a lie; the
   funnel's own `.m-reveal` class was unknown to its own scanner; file:// permanently INCONCLUSIVEd
   reduced-motion; stagger hardcoded against the feel's own numbers; corpus endpoint accepted mangled
   UTF-8. [ALL FIXED this run.] The checks that exist are honest — the gate caught the tracer's one
   real defect (footer contrast).

## Vision scorecard (vision judge, strict)
V1 UNSERVED · V2 PARTIAL (past vision genuinely seen — the measured chroma ladder; new pushes have
only prose to land in) · V3 SERVED · V4 PARTIAL (capability exists, zero output) · V5 SERVED (the
strongest item) · V6 PARTIAL (web only; video/edits have no lane) · V7 PARTIAL (the bridge exists,
uncrossed).

## The falsification review (the sharpest cut of the day)
1. **Artifact-binding is KILLED.** The proposed fix (scaffold emits recipe-derived starters; gate
   CHECKs hand-rolled residue) fails three ways: the signature moment is definitionally off-preset, so
   the flag red-lights exactly the best work — an anti-quality mechanism; residue tracing isn't
   computable (oklch()/calc()/color-mix/GSAP runtime values); frozen starters = tasteful-generic, the
   2026-07-10 failure recursed. "B called the vocabulary a rearview mirror; D pours concrete into it."
2. **The naive "run one real job" test cannot fail as specified.** The builder is the grader; the
   references ritual is retroactively producible; n=1 with no control attributes nothing.
3. **What ALL FOUR missed:** the shared frame "supremacy is installable by mechanism." The evidence
   says otherwise — skills-present-never-consulted is *revealed preference*, not a routing defect:
   **nothing in this system depends on being judged.** Supremacy comes from reps under an eye that can
   reject; there have been ~zero reps and there is no judge. "The funnel is a substitute for a
   customer — plausibly the procrastination itself." Bottleneck ranking: **external judge > cadence >
   tooling.**

## Repairs shipped this run (floors — making existing promises true, no new machinery)
- `scaffold.mjs --feel=<name>`: bands land in tokens.css + intent.json + brand overrides mechanically,
  provenance citing the feel's calibration (real, not invented). EXTRAPOLATED feels are **refused** —
  guesses earn bands at the pixel gate, then become wireable.
- The palette stop rule is now real: intent.json `conversationHappened:false` → **CHECK, exit 1** (the
  contract's own "never silently proceed on a NEW build").
- file:// reduced-motion: Node-side read of local linked CSS when CSSOM is blocked.
- `.m-reveal` known to its own scanner; stagger token-driven (`--stagger-step`); honest
  motion-presets header (no more "pre-passed... gate just confirms"); corpus endpoint rejects U+FFFD.
- Suites: design-bench **107/107**, visual-qa full pass (incl. new pending-palette fixture).

## VERDICT
The funnel is now a **true floor**: honest, per-brand, mechanically routed, self-tested. It is **not
a quality engine and no further mechanism should be built to pretend it is.** The bottleneck is not
tooling. It is (1) an external judge — Will's rejecting eye on real pieces — and (2) reps. The system
has consumed a full day of building and judged zero pieces of real work.

**Recommendation: run the CONTROL EXPERIMENT, then stop building.**
One real brief (Will picks — an actual piece he wants). TWO builds of it:
- **Arm A (freehand):** built with the craft references open, no funnel — the outsider's demand:
  delivered with the 3 references studied and the one thing stolen from each.
- **Arm B (funnel):** scaffolded with --feel, built from presets, gated, delivered the same way.
Pre-registered bar, written BEFORE building. Will judges the pieces side by side — as pieces, not
pipelines. **The question on trial: does the funnel beat its own absence?** The control has never
been run, and every hour of further tooling before it is spent on an unfalsifiable claim.

**Deletions recommended, Will's call (his surfaces, not deleted unilaterally):** the bench colour/
motion lab surfaces (builder's comfort — keep drift detection + the verdict box + the Feel ladder);
the runner's engine-matrix/crawl depth (certification machinery for jobs that don't exist).

## Tripwires + flip-evidence
- **14-day tripwire (carried from 07-17, still live):** count hand-typed runner invocations and corpus
  appends. Both zero → the verification half is dead; delete rather than maintain.
- **New tripwire:** if the control experiment doesn't run within 14 days, the funnel's V1 claim is
  unfalsifiable and the default becomes the outsider's position: judge pieces, ignore pipeline.
- **Flip-evidence:** Arm B clearly beating Arm A flips the "compliance engine" verdict and justifies
  further funnel investment. Arm A winning or tying kills further funnel work entirely.

## First step
Will names the real piece for the control experiment (and the bar: what would "supremely good" mean
for THIS piece, in his words, written down before either arm builds).

---

## Appendix
**Core claims:** Tracer — "no mechanism moves any number from feel.json into the build; chroma is
verified by no stage" (empirically proven, now partially repaired). Vision judge — "feed it a
mediocre in-band design and all seven stages pass it untouched; no stage exists to name" (unrefuted).
Outsider — "the next piece will be no better than the last four, because the one behaviour proven to
cause past failures is the one behaviour nothing forces" (falsifiable via the control experiment).
First principles — "quality is decided at generation time; the builder answered a generation-time
failure with inspection; the funnel grew around a build moment it never entered" (adopted as the
chairman's understanding). Reviewer — "supremacy is not installable by mechanism; bottleneck is
judge > cadence > tooling; the control has never been run" (adopted as the verdict's frame).

**Delta vs chairman's Step-0 baseline:** baseline suspected "compliance engine, adoption is the
risk." The council went materially further: proved the wiring gap empirically (tracer), killed the
chairman's inherited fix (artifact-binding), demonstrated the naive real-job test couldn't fail,
and reframed the bottleneck from tooling to judge+reps. Not a blessing run.

**UNVERIFIED assumptions carried:** that Will will actually judge the control pieces (the whole plan
rests on his rejecting eye showing up); that a "supremely good" bar can be pre-registered in his
words; that web pieces generalise to "edits"/video (V6 remains unserved — no lane exists).

**Compliance:** MINI-spec exceeded (4 advisors — Will explicitly asked for "a council and a bunch of
sub agents"); 1 falsification reviewer per MINI. Substrate diversity NOT achieved (all same model;
mitigated by disjoint information slices — the tracer had no vision statement, the outsider no
mechanics, and their conclusions converged independently, which is the strongest independence signal
available without a second substrate). Context pack shown in-message, not gated on. Tracer's sandbox
verified clean (brands dir restored, corpus md5-identical, servers killed). Chairman argued against
own leading recommendation (artifact-binding: inherited, then killed by review; "one real job":
kept only in control-arm form).
