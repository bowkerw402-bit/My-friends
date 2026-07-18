# Run Record — the committed proof of a run

Every orchestrated run writes one of these to `runs/<YYYY-MM-DD--HHmm--slug>/`. It's the visible evidence
of *how* the two agents worked: the exact exchange, the tools each used, the review verdict. Written UTF-8
(no corruption), auto-committed, readable in Obsidian.

## Folder (lean by default)
Always four files; the Line's station files appear only when there's real content for them.
```
runs/<YYYY-MM-DD--HHmmss--slug>/
  00-SUMMARY.md   single glance: task · mode · done-reason · verified tools · PII status
  transcript.md   every turn: agent · round · timestamp · the reply, with the exact prompt folded in
  tools.md        tool ledger — VERIFIED (Claude's real invocations) vs declared (Codex self-report)
  manifest.json   machine-readable summary (below) — what DAILY.md aggregates
  brief.md        (optional) the FRAME contract — written only when a Brief was supplied
  plan.md         (optional) the PLAN split/handoff
  output.md       (optional) the deliverable(s)
  review.md       (optional) the REVIEW verdict
```

## manifest.json (runrecord/v1) — key fields
- `run_id, slug, task, station, venture, work_dir`
- `started_at, ended_at`
- `mode` — `two-agent` | `two-agent-degraded` | `single-agent` (honest; never faked)
- `two_agent`, `degraded`, `codex_status`
- `rounds_planned, rounds_run, done_reason`
- `agents[]` — `{ name, turns, statuses }`
- `tools_manifest` (planned, from a Brief) · `tools_verified` (Claude, real invocations) · `tools_declared` (Codex, self-reported)
- `outputs[]`, `review_verdict`, `ledger_touched`
- `pii_present` + `pii_reason` (path / content / none) — if present, the full record lives in the business folder; only a stub is here
- `encoding` (utf-8), `commit`, `orchestrator_version`

## Guarantees
- **Honest two-agent status.** A run only reads as `two-agent` if Codex genuinely replied. Silent Codex
  failures are marked `single-agent` and surface under DAILY.md → *Needs attention*.
- **No PII in the shared vault.** Runs under `clients/`, `demand-first/lists/`, or prospect paths keep their
  full record in the business folder; the vault gets a redacted stub.
- **Encoding-clean.** Em dashes, `$` amounts, arrows, emoji all round-trip intact.
