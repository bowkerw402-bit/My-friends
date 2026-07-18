# Ledger entry format (do NOT invent a different one)

`Business/_ideas/LEDGER.md` is the single source of venture state. Build-BoardState.ps1 and
MissionControlLib both parse this exact format — one line per idea ever generated:

```
YYYY-MM-DD-<kebab-slug> | <name> | <status> | <one-line lesson>
```

## Status vocabulary
| status | meaning | BOARD group |
|---|---|---|
| `open` | generated, not started | Backlog |
| `recurred-xN` | independently resurfaced N times (rank high) | Backlog |
| `ignited` | in flight (one at a time) | In Flight |
| `stalled-at-<gate>` | blocked at a named gate | Stalled |
| `revenue` | earning | Revenue |
| `parked` | deliberately benched, may return | Parked |
| `killed` | dead — keep the lesson | Killed |

## Rules
- IDs are `YYYY-MM-DD-<slug>` — unique forever, so "ignite <slug>" resolves across sessions.
- Only append or change the status/lesson of an existing line — never rewrite history.
- Killed ventures' folders move to `Business/_graveyard/<slug>/` with a one-paragraph post-mortem.
- Anonymised one-liners only — no client PII in the lesson field.
