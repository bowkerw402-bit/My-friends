---
kind: tombstone
date: 2026-07-18
---

# Tombstone - old My-friends layout

The vault was restructured from the old `context/claude/codex/tasks/log` model into the
lifecycle topology (see README.md). Nothing was deleted.

- Per-agent working notes -> `90-archive/_legacy-handoffs/{claude,codex,tasks}/` (history preserved via git mv)
- LLM-council verdicts -> `_reference/council/`
- Stale skill copy -> `90-archive/_legacy-handoffs/orchestrate-skill.md`
- Multi-MB PNGs -> moved OUT of the git text vault to `C:\Users\bowke\OneDrive\Desktop\CLAUDE\_archive\2026-07-18\vault-binaries`
- Full pre-rebuild snapshot -> `C:\Users\bowke\OneDrive\Desktop\CLAUDE\_archive\2026-07-18\my-friends-prerebuild.bundle` (git bundle, all refs)

Recover any file with `git log --follow` + `git mv` back, or `git clone` the bundle.