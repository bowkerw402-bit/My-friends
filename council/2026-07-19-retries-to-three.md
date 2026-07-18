# Council verdict — "20 retries → 3"

**Question.** The lake hero took 14 recorded rounds in one session. Will: *"let's make sure next
time it's like three."* Finalise the funnel, squeeze out remaining ideas, make it fast/efficient/
understandable, get the right questions asked, find Codex's role.

**Compliance note (honest).** FULL council convened: 5 advisors returned. **All 3 falsification
reviewers failed on a session limit.** So this verdict has advisor diversity but NO adversarial
review — it is less tested than the spec requires. Treat the recommendation as provisional.

---

## 1. Disagreement map

**The baseline was FALSIFIED, with evidence.** My pre-registered answer was "most rounds were
mechanically checkable before building, so add a pre-build gate." Two advisors killed it using this
build's own timestamps:

- The funnel (1088 lines) + calibration file existed at **20:01–20:03**. Rounds v3.7 (20:47),
  v3.8 (21:01), v3.9 (21:19), v4.0 (22:01), v4.1 (22:22) shipped **after** it — 36% of the build —
  each on a mechanism no checklist contained. Neither artifact was opened during any of them.
- Earlier, two golds shipped **above Will's own recorded ceiling while the ceiling sat on disk**.

> **A document that CAN be skipped IS skipped.** Proposing a bigger checklist is proposing more of
> the artifact class that had just measurably failed.

**Resolvable by evidence** — *is 14 rounds actually the problem?* Contrarian says no: the cost was
14 **viewings**, not 14 rounds; at least four builds (v3.1, v3.3, part of 3.2, v3.6) were the
builder debugging in public. Retarget to **3 SHOWINGS, unlimited internal rounds**. This is
evidence-backed by Will's own words ("yo slow down", "i dont see shit") and I accept it.

**Values choice for Will** — whether "3" means three rounds of *his attention* (Contrarian's read,
which I endorse) or three total builds (his literal words).

## 2. Convergences

- The old QA gate carried **zero bits**: identical verdict (PASS/INCONCLUSIVE) on v1 which he
  approved on sight AND on v2/v3/v3.2 which he rejected. It has a check named `taste` that passed on
  **every build he rejected**. That is a self-written justification in a pass/fail costume.
- `INCONCLUSIVE` is poison — an advisory verdict is always overridden under time pressure.
- The only two rounds that ever *resolved* anything were **diffs against a known-good artifact**
  (v3.4, when Will sent the v1 render back; v4.1, when a panel measured the shipping build).
- ON-PATH survives, off-path dies (confirms the 2026-07-10 council).

## 3. Blind spots

- ~4 of 13 rounds were legitimate taste discovery and are **irreducible**. Three showings is
  therefore close to the true floor, not an aspiration.
- Eight rounds produced eight *new* mechanisms with zero repeats — they were subsystem couplings,
  not rule violations. A checklist written from mechanisms 1..N catches N+1 at chance.

## 4. Recommendation

**Build the mechanism, not the document.** `tools/predeliver.mjs` — a SHOW/NO-SHOW gate that:
reads its expected values out of files Will already approved (never authored by the builder);
has no advisory verdict for what it measures; blocks on **drift versus the last approved build**;
and sits between the build and delivery so it cannot be quietly not-read.

**Metric change: count SHOWINGS, not rounds.** Unlimited internal iteration; three contacts.

**Demote the prose.** the-funnel.md and the case study become after-action archive. Nothing in the
build loop may depend on anyone remembering to read 1088 lines.

## 5. Tripwire + flip-evidence

- **Tripwire:** if the next project exceeds 5 showings, `predeliver.mjs` has failed the same way the
  playbook did — delete it rather than maintain it.
- **Flip-evidence:** if the next project's rejections are things predeliver CAN'T measure (subject,
  concept, mood), then the gate is treating a taste problem as a defect problem and the answer is
  earlier/cheaper taste sampling instead.

## 6. First step

Run `predeliver.mjs` before the next thing Will is shown. It already found, on the current build,
that the wordmark gold renders at a different chroma from the emblem gold — a real inconsistency
no human named across 14 rounds.

## 7. Appendix

- **Baseline delta:** the council did NOT merely agree. It falsified my central proposal with
  timestamps and replaced it with a different *kind* of object (on-path mechanism vs document).
- **A measurement I got wrong, caught by testing:** I first blocked on absolute rendered chroma vs
  the source-token band. Then measured v1 — the build Will approved instantly — at **0.054**, far
  BELOW the band. An absolute pixel band would have blocked the most-approved artifact in the
  project. Source-token bands do **not** transfer to rendered pixels. Now advisory; drift-vs-approved
  blocks instead.
- **UNVERIFIED:** the 3-showing target has never been run.
- **Skipped:** falsification review (session limit).
