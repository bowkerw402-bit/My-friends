# My-friends, the shared operating vault

The single place where Will, Claude, and Codex meet. It holds the work pipeline ([[the-line|The Line]]), the
visible record of every two agent run ([[runrecord|Run Records]] and Mission Control), Will's standards, and
the lifecycle for every idea. **Local Markdown is authoritative. Nothing here is ever hard deleted, only archived.**

## Layout
```
QUICKSTART.md      the daily verbs: today, run, board, capture, handoff, standard
00-inbox/          raw captures waiting to be framed, so nothing rots in chat scrollback
10-active/<v>/     ventures and work in flight, each with a STATUS.md tracker
20-backburner/<v>/ deliberately parked, may return
90-archive/<v>/    tombstoned: dead, duplicate or superseded, always recoverable
runs/              Run Records, the committed proof of every orchestrated run
reviews/           the nightly sweep of each day: problems, solutions, decisions, noise
handoffs/          where Claude and Codex hand work to each other, visibly
mission-control/   DAILY.md (morning digest) and BOARD.md (portfolio, generated from the ledger)
_templates/        Brief, Plan, Review, Handoff, Ledger entry, Tombstone
_reference/        the-line.md, runrecord.md, tools.md, capabilities.md, standards/, council/
_tools/            backup mirror of the machine tooling (the running copy is ~/.claude/tools)
log/               sessions.md, a one line chronological index of runs
```

## The lifecycle
`INBOX -> ACTIVE -> (BACKBURNER) -> ARCHIVED`. Venture state lives in `Business/_ideas/LEDGER.md`, which is
the source of truth, and is rendered into `mission-control/BOARD.md`.

## Daily rhythm
- **7:31am, automatic.** The morning report rebuilds, commits, opens, and tells Will what needs him.
- **During the day.** `run "the task" <venture>` for a two agent step. `capture "an idea"` to catch a thought.
- **9:03pm, automatic.** The nightly sweep reads the day's threads, Claude assesses, Codex pressure tests it,
  and the result lands in `reviews/`.
- **Friday 4pm, automatic.** A portfolio pass over the board and the week's reviews.
- Anytime: open **Agent Transcripts.html** on the Desktop to read every exchange.

## Standing rules
- **Draft only.** Neither agent sends, deploys, publishes, signs, or spends. Will does.
- **One ignition** in flight at a time.
- **No client PII in this vault.** The orchestrator enforces it on both path and content.
- **Real deliverables go on Will's Desktop**, in one clearly named folder. Working files stay here.
- **Read `_reference/standards/` first.** Will's rules, dated, newest first. Both agents follow them.

See [[the-line|_reference/the-line.md]] to understand the whole system.
