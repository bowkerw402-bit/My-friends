# DISPOSITION — the one-time cleanup approval list

**Rule:** nothing is hard-deleted. "Archive" = move to a tombstoned, recoverable folder; every live
repo is `git bundle`-backed up first. Evidence Desk + NDIS working trees are never touched. Approve the
list once and I execute in the safe order at the bottom.

Verified on disk 2026-07-18. `state` from a read-only probe.

## A. Duplicates → collapse to one home (low risk, reversible)

| # | Item | Found at (state) | Action | Canonical |
|---|------|------------------|--------|-----------|
| A1 | **APLakeside** | Desktop\CLAUDE\APLakeside (git-ok, 06-29) · Documents\GitHub\APLakeside (git-ok, 06-29) · CLAUDE OBSIDIAN\APLakeside (no-git) · CLAUDE OBSIDIAN\github\APLakeside (dead-git) | The two git copies have **diverged SHAs** — reconcile (merge unique commits) then archive the 3 non-canonical. It's FROZEN, so low stakes. | **Documents\GitHub\APLakeside** |
| A2 | **My-friends** | Documents\GitHub\My-friends (git-ok, **07-17, LIVE**) · Desktop\CLAUDE\My-friends (git-ok, stale 06-29) · CLAUDE OBSIDIAN\github\My-friends (dead-git) | Diff-rescue any unique file from the stale copies, then archive them. | **Documents\GitHub\My-friends** |
| A3 | **orchestrate.ps1** | ~/.claude/tools (**v2, 07-18**) · APLakeside\tools · CLAUDE OBSIDIAN\github\APLakeside\tools | Archive the 2 legacy copies; drop a one-line pointer README. | **~/.claude/tools** |
| A4 | **ask-codex.ps1 / ask-claude.ps1** | 6 copies across APLakeside\tools + CLAUDE OBSIDIAN\...\tools | Fold their one-shot behaviour into orchestrate v2 later; archive all 6 now. | ~/.claude/tools |
| A5 | **Command center** | Business\_ops\COMMAND-CENTER.md (current) · CLAUDE OBSIDIAN\Venture Factory\CONTROL PLANE.md (older) | Fold anything unique into _ops; archive CONTROL PLANE. | **Business\_ops** |

## B. Dead / killed → graveyard (with tombstone)

| # | Item | State | Action |
|---|------|-------|--------|
| B1 | **ai-enquiry-desk** (V-2026-021, killed) | Business\ai-enquiry-desk (3 items) | Move to Business\_graveyard\ai-enquiry-desk with a one-para post-mortem. |
| B2 | **2 multi-MB PNGs in the text vault** | My-friends\claude\gourmet-*.png (1.79 + 1.53 MB) | Move out of the text vault into the venture's design folder (keep the vault text-only). |
| B3 | **~/.codex/logs_2.sqlite** (283 MB) | local, not synced | Truncate/delete (regenerable Codex log). Your call — it's just log bloat. |

## C. BBS storefront → its own home (medium risk — LIVE site)

| # | Item | State | Action |
|---|------|-------|--------|
| C1 | **Bowker Businesses Services storefront** | buried in Business\govt-supplier-evidence-desk\{automation-services, studio} | Move to **Business\bowker-business-services\**. It's LIVE (bowkerbusinessesservices.com) — sequence LAST, verify the site's paths/links still resolve after the move. |

## D. Trading root → version control IN PLACE (high care — live cron)

| # | Item | State | Action |
|---|------|-------|--------|
| D1 | **Trading engine root** | Desktop\CLAUDE (**dead .git**, 814 items, live scheduled tasks) | `.zip` backup → remove dead `.git` → `git init` in place → keep existing CSV ignores AND add the non-trading subdirs (Business/, APLakeside/, CLAUDE OBSIDIAN/, My-friends/, Court/, Job hunter/, mcp-*/) to `.gitignore` so the repo tracks ONLY trading files → commit engines + `book_manifest.json` + state ledgers. **No files move** (protects the willsideas/Mission-Control hard-coded paths and the 8:00/17:00 cron). Init only after a scheduled run completes. **Local commit only — new remote + push waits on your GitHub + the token fix.** |

- `Documents\GitHub\Stocks` = confirmed the **tradingview-mcp** server (name in package.json), NOT the engine. Leave it as-is.

## E. Will-only / separate

- **E1 — Rotate the GitHub PAT** in `~/.codex/config.toml` (compromised-by-exposure). Move to an env var / credential store. *(You do this — I never touch credentials.)*
- **E2 — CLAUDE OBSIDIAN** (dead .git, 48 items, your personal vault): leave in place this pass; optional git repair later.

## Safe execution order (only after you approve)
1. `git bundle` backup My-friends + both APLakeside repos; `.zip` the trading root.
2. **P4 vault rebuild** (My-friends): commit the 4 untracked files → `git mv` into the new topology → drop in the staged _templates/_reference/README → move the 2 PNGs out → tombstone old layout.
3. A1–A5, B1 (archive duplicates/dead with tombstones + update references).
4. C1 (BBS move) → verify site links.
5. D1 (trading git-init, local only) → smoke-test `paper_broker.py --status`.
6. Regenerate Mission Control against the real vault + commit.

Everything above is reversible via the tombstone `Recover with:` line or the git bundles.
