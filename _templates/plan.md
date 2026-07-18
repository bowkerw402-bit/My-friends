---
id: YYYY-MM-DD-<slug>
station: PLAN
venture: <venture-slug>
brief: 00-brief.md
---

# Plan — <title>

> How the work gets split and done. Shares the willsideas EXECUTION.md schema so ignitions and
> orchestrated runs use one plan format and any cold session can resume from the checkpoint.

LAST-CHECKPOINT: <updated after EVERY completed step, not at the end>

## Approach
<2-4 sentences: the strategy. What order, what's the critical path.>

## Work split
- **Claude:** <workstreams Claude owns — systems, code, deploys, orchestration, QA>
- **Codex:** <workstreams Codex owns — adversarial review, parallel builds, its own-account actions>

## Steps
```
[ ] <step> | owner: claude|codex|gated|will | output: <file path>
[ ] <step> | owner: claude|codex|gated|will | output: <file path>
[~] = in progress   [x] = done
```

## Verification method
<How we will PROVE each step worked end-to-end — the exact check, command, or observation.>

## TRIPWIRES
- <dated falsifiable check from the Brief's kill-criteria> → CONTINUE / PIVOT / KILL

## RISKS & REFRAMES (from council/Codex, if run)
- <risk> → <mitigation or reframe>
