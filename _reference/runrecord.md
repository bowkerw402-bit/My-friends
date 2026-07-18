# Run Record — the committed proof of a run

Every orchestrated run writes one of these to `runs/<YYYY-MM-DD--HHmm--slug>/`. It's the visible evidence
of *how* the two agents worked: the exact exchange, the tools each used, the review verdict. Written UTF-8
(no corruption), auto-committed, readable in Obsidian.

## Folder
```
runs/<YYYY-MM-DD--HHmm--slug>/
  00-brief.md       the contract (FRAME) — definition of done, quality bar, kill-criteria, tool manifest
  01-plan.md        the agreed split & handoff (PLAN)
  02-transcript.md  every turn: agent · round · timestamp · the reply, with the exact prompt folded in
  03-tools.md       tool ledger — declared vs actually used (from each reply's TOOLS-USED: line)
  04-output.md      the deliverable(s) / links to artifacts in the work dir
  05-review.md      the other agent's adversarial verdict (REVIEW)
  manifest.json     machine-readable summary (below) — what DAILY.md aggregates
```

## manifest.json (runrecord/v1) — key fields
- `run_id, slug, task, station, venture, work_dir`
- `started_at, ended_at`
- `mode` — `two-agent` | `two-agent-degraded` | `single-agent` (honest; never faked)
- `two_agent`, `degraded`, `codex_status`
- `rounds_planned, rounds_run, done_reason`
- `agents[]` — `{ name, turns, statuses }`
- `tools_declared, tools_used`
- `outputs[]`, `review_verdict`, `ledger_touched`
- `pii_present` — if true, the full record lives in the business folder; only a stub is here
- `encoding` (utf-8), `commit`, `orchestrator_version`

## Guarantees
- **Honest two-agent status.** A run only reads as `two-agent` if Codex genuinely replied. Silent Codex
  failures are marked `single-agent` and surface under DAILY.md → *Needs attention*.
- **No PII in the shared vault.** Runs under `clients/`, `demand-first/lists/`, or prospect paths keep their
  full record in the business folder; the vault gets a redacted stub.
- **Encoding-clean.** Em dashes, `$` amounts, arrows, emoji all round-trip intact.
