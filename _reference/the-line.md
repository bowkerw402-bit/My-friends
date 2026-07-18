# The Line — the universal work funnel

**One pipeline for every unit of work** — a venture, a feature, a report, a research task.
Idea-agnostic in *what* flows through; ruthless in *how*. Every unit passes through 7 stations,
each with a required artifact and a quality gate. Templates live in [[_templates]] so producing
each artifact is fast and identical every time.

```
CAPTURE → FRAME → PLAN → BUILD → REVIEW → SHIP → LEARN
```

## The two anti-backpedal locks
The whole point is: **never discover 5 steps in that we built the wrong thing.**
1. **FRAME (lock #1)** — a [[brief|Brief]] is agreed *before* any building. It fixes the
   definition-of-done, the quality bar, the kill-criteria, and which tools we'll use. No Brief, no build.
2. **REVIEW (lock #2)** — the *other* agent adversarially checks the work against that Brief *before*
   anything ships. Nothing passes silently.

## The stations

| # | Station | Who | Input | Output (template) | Gate |
|---|---------|-----|-------|-------------------|------|
| 0 | **CAPTURE** | Will / either | a raw idea or task | a note in `00-inbox/` | is it worth framing? |
| 1 | **FRAME** | Claude (+ willsideas) | inbox item | [[brief\|00-brief.md]] + LEDGER row | PURSUE / BACKBURNER / KILL |
| 2 | **PLAN** | Claude + Codex | the Brief | [[plan\|01-plan.md]] (work split, handoff) | both agree the split |
| 3 | **BUILD** | Claude / Codex / both | the Plan | artifacts + `02-transcript.md` + `03-tools.md` | tools declared were used |
| 4 | **REVIEW** | the *other* agent | the build vs the Brief | [[review\|05-review.md]] | PASS / PASS-with-locks / FAIL |
| 5 | **SHIP** | Will | passed work | the deliverable (a **draft**) | **DRAFT-ONLY — Will sends** |
| 6 | **LEARN** | Claude | the outcome | LEDGER lesson + CALIBRATION + memory | recorded, filed in one home |

## How FRAME reuses willsideas (no duplication)
The Line is the idea-agnostic generalization of what [[willsideas]] already does for business ideas.
FRAME **calls** willsideas — it does not re-implement it:

| Line station | Existing willsideas / Business asset |
|---|---|
| CAPTURE | `00-inbox/` note or `ideas-YYYY-MM-DD.md` |
| FRAME (lock #1) | willsideas **fingerprint** + **Stage-4 "the kill"** + optional **llm-council** → `00-brief.md`; append a row to `Business/_ideas/LEDGER.md` |
| PLAN | willsideas **EXECUTION.md** schema = `01-plan.md` |
| BUILD | willsideas **IGNITE tiers** (revenue-first); artifacts in `Business/<slug>/` |
| REVIEW (lock #2) | the other agent (orchestrate) or council → `05-review.md`; verdict feeds **CALIBRATION.md** |
| SHIP | willsideas **GATED** list — DRAFT-ONLY, Will fires |
| LEARN | **CALIBRATION.md** (promised-vs-actual) + the LEDGER lesson field |

`LEDGER.md` stays the single source of venture state; `mission-control/BOARD.md` is *generated from* it.

## Running a two-agent step (Mission Control)
```powershell
# from the work dir, or pass -WorkDir
& $HOME\.claude\tools\orchestrate.ps1 -Task "the task" -WorkDir "C:\...\Business\<venture>" -Rounds 3
#   -RequireBothAgents   # abort if Codex isn't genuinely answering (instead of a single-agent run)
```
Every run writes a committed [[runrecord|Run Record]] to `runs/<YYYY-MM-DD--HHmm--slug>/` and appends a
line to `log/sessions.md`. Read the day's runs in `mission-control/DAILY.md`.

## Standing rules (non-negotiable)
- **Draft-only.** Neither Claude nor Codex ever sends, deploys, publishes, signs, or spends. Will does.
- **One ignition in flight** at a time (enforced via `IGNITIONS.md`).
- **No client PII in the shared vault.** PII runs keep their full record in the business folder; only a
  redacted stub is committed here (enforced by the `pii_present` gate in the orchestrator).
- **Both agents must be genuinely present** for a run to count as two-agent — the health check marks
  single-agent runs honestly; it never fakes Codex.
- **Every run declares its tools** (`TOOLS-USED:` line) so `03-tools.md` is real evidence, not a claim.
