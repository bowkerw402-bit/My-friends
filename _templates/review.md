---
id: YYYY-MM-DD-<slug>
station: REVIEW
venture: <venture-slug>
brief: 00-brief.md
reviewer: codex        # the OTHER agent from the one that built it
---

# Review — <title>

> Anti-backpedal lock #2. The other agent checks the build against the Brief BEFORE it ships.
> Adversarial by default: try to falsify, not to approve.

## Checked against the Brief's Definition of Done
- [ ] <DoD line 1> — met? (evidence / where)
- [ ] <DoD line 2> — met? (evidence / where)
- [ ] <DoD line 3> — met? (evidence / where)

## Defects found
- <defect> — severity (blocker / major / minor) — where

## Falsification attempts
<What I tried to break, and what happened. "I tried X to prove the claim wrong; result: ...">

## Verdict
**PASS** | **PASS-with-locks** | **FAIL**

## Required locks before SHIP (if PASS-with-locks)
- [ ] <thing that must be fixed/confirmed before Will ships>
