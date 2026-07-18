---
area: tools-mirror
updated: 2026-07-18
---

# _tools (backup mirror)

A committed copy of the machine tooling that runs the system. The canonical, running copy lives at
`C:\Users\bowke\.claude\tools\` because the scheduled tasks and the daily verbs point at hard coded paths.

This mirror exists so the tooling is versioned, recoverable if the machine dies, and readable from GitHub
by Codex or anyone else without needing local access.

Refresh it after any change to the tools, then commit.