# The Line, the universal work funnel

**One pipeline for every unit of work:** a venture, a feature, a report, a research task. Idea agnostic in
*what* flows through, ruthless in *how*. Every unit passes through 7 stations, each with a required artifact
and a quality gate. Templates live in `_templates/` so producing each artifact is fast and identical.

```
CAPTURE -> FRAME -> PLAN -> BUILD -> REVIEW -> SHIP -> LEARN
```

## The two anti backpedal locks
The whole point: **never discover 5 steps in that we built the wrong thing.**
1. **FRAME (lock 1).** A [[brief|Brief]] is agreed *before* any building. It fixes the definition of done,
   the quality bar, the kill criteria, and which tools will be used. No Brief, no build.
2. **REVIEW (lock 2).** The *other* agent adversarially checks the work against that Brief *before* anything
   ships, and ends with a `VERDICT:` line that lands in the run manifest.

## The stations

| # | Station | Who | Input | Output | Gate |
|---|---------|-----|-------|--------|------|
| 0 | **CAPTURE** | Will or either agent | a raw idea or task | a note in `00-inbox/` | is it worth framing? |
| 1 | **FRAME** | Claude (calls willsideas) | inbox item | `brief.md` + a LEDGER row | PURSUE / BACKBURNER / KILL |
| 2 | **PLAN** | Claude + Codex | the Brief | `plan.md` (work split, handoff) | both agree the split |
| 3 | **BUILD** | Claude, Codex, or both | the Plan | artifacts + `transcript.md` + `tools.md` | the declared tools were used |
| 4 | **REVIEW** | the *other* agent | the build vs the Brief | `review.md` + a `VERDICT:` line | PASS / PASS with locks / FAIL |
| 5 | **SHIP** | Will | passed work | the deliverable, as a **draft** | **draft only, Will sends** |
| 6 | **LEARN** | Claude | the outcome | LEDGER lesson + CALIBRATION + memory | recorded, filed in one home |

**Lean by default.** A plain orchestrated run writes only `00-SUMMARY.md`, `transcript.md`, `tools.md` and
`manifest.json`. The station files above appear only when that station actually produced something, so a run
record never ships pages of empty stubs.

## How FRAME reuses willsideas, without duplicating it
The Line is the idea agnostic generalisation of what [[willsideas]] already does for business ideas.
FRAME **calls** willsideas, it does not re implement it.

| Line station | Existing willsideas or Business asset |
|---|---|
| CAPTURE | `00-inbox/` note, or `ideas-YYYY-MM-DD.md` |
| FRAME (lock 1) | willsideas **fingerprint** + **Stage 4 "the kill"** + optional **llm-council**, producing `brief.md`, plus a row in `Business/_ideas/LEDGER.md` |
| PLAN | the willsideas **EXECUTION.md** schema, as `plan.md` |
| BUILD | willsideas **IGNITE tiers** (revenue first), artifacts in `Business/<slug>/` |
| REVIEW (lock 2) | the other agent, or a council, producing `review.md`; the verdict feeds **CALIBRATION.md** |
| SHIP | the willsideas **GATED** list. Draft only, Will fires |
| LEARN | **CALIBRATION.md** (promised versus actual) plus the LEDGER lesson field |

`LEDGER.md` stays the single source of venture state. `mission-control/BOARD.md` is generated from it.

## Running a two agent step
```powershell
run "the task" <venture-slug>          # the daily verb, defaults to demanding both agents
# or the full form:
& $HOME\.claude\tools\orchestrate.ps1 -Task "the task" -WorkDir "C:\...\Business\<venture>" -Rounds 3
#   -RequireBothAgents   abort rather than quietly running single agent
```
Every run writes a committed [[runrecord|Run Record]] to `runs/<YYYY-MM-DD--HHmmss--slug>/` and one line to
`log/sessions.md`. Read the day in `mission-control/DAILY.md`, or open **Agent Transcripts.html** on the
Desktop to read the exchanges visually.

## Standing rules
- **Draft only.** Neither agent ever sends, deploys, publishes, signs, or spends. Will does.
- **One ignition in flight** at a time, tracked in `IGNITIONS.md`.
- **No client PII in this vault.** PII runs keep their full record in the business folder and commit only a
  redacted stub. The orchestrator enforces this on both the path and the content.
- **Both agents genuinely present.** A run counts as two agent only if each one actually engaged with the
  task. Replying without engaging is marked `no-engagement` and degrades the run.
- **Tools are evidenced, not claimed.** Claude's tool calls are captured from real invocations. Codex's are
  self declared and labelled as such in `tools.md`.
- **Read `_reference/standards/` before producing anything.** Will's rules live there, newest first.
