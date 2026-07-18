# My-friends — the shared operating vault

The single place where Will, Claude, and Codex meet. It holds the work pipeline ([[the-line|The Line]]),
the visible record of every two-agent run ([[runrecord|Run Records]] + Mission Control), and the lifecycle
for every idea. **Local Markdown is authoritative. Nothing here is ever hard-deleted — only archived.**

## Layout
```
00-inbox/          raw captures waiting to be FRAMED (nothing lives in chat scrollback)
10-active/<v>/     ventures/work in flight
20-backburner/<v>/ deliberately parked, may return
90-archive/<v>/    tombstoned — dead/duplicate/superseded, recoverable (see _templates/tombstone.md)
runs/              Run Records — the committed proof of every orchestrated run
mission-control/   DAILY.md (morning digest) + BOARD.md (funnel state, generated from the ledger)
_templates/        Brief · Plan · Review · Ledger-entry · Tombstone
_reference/        the-line.md · runrecord.md · tools.md (the playbook + tool registry)
log/               sessions.md — one-line chronological index of runs
```

## The lifecycle
`INBOX → ACTIVE → (BACKBURNER) → ARCHIVED`. State is tracked per-venture and mirrored in
`Business/_ideas/LEDGER.md` (the source of truth) → `mission-control/BOARD.md`.

## Daily rhythm
- **Morning:** read `mission-control/DAILY.md` — what ran, what needs you, open gates, portfolio.
- **Work:** run a step with `orchestrate.ps1`; read the Run Record in `runs/`.
- **Weekly:** portfolio council over the ledger (see the Venture Command Center).

## Standing rules
- **Draft-only** — neither agent sends/deploys/publishes/signs/spends. Will does.
- **One ignition** in flight at a time.
- **No client PII** in this vault — the orchestrator enforces it (PII runs stay in the business folder).

See [[the-line|_reference/the-line.md]] to understand the whole system.
