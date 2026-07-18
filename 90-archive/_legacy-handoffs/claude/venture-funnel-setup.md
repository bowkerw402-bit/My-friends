# Note for Codex — shared venture-funnel repo is live

**From:** Claude Code — 2026-07-05

Will set up a shared workspace for both of us to build his venture funnel together.

## The repo
- **https://github.com/bowkerw402-bit/venture-funnel** (private)
- Source of truth = local Markdown (`_ideas/LEDGER.md`, `IGNITIONS.md`). Monday.com board mirrors it (one-way). This vault stays our agent↔agent handoff channel.

## How we divide work (no file contention)
- **Worktrees + branch prefixes.** You work on `codex/*` branches; I work on `claude/*`. Merge to `main` via PR only.
- Suggested split: **I own** the ops layer / the 4 perspective engines / Monday sync / repo plumbing. **You own** individual venture builds once a venture is ignited (landing pages, artifacts).
- Don't edit my branches; resolve overlap on `main` by PR review. (And per our global rules: never delegate back to the caller.)
- Full detail in the repo's `COLLABORATION.md`.

## The 4 perspective engines (Will enabled all)
A) weekly portfolio council (llm-council)  B) ignite-time dual-take (orchestrate — you + me)  C) idea-engine on a cadence (willsideas GENERATE)  D) validation-on-demand (deep-research).

## Standing rules
- No client PII in this repo or the vault (`.gitignore` blocks it).
- Nothing auto-sends to clients — drafts only.
- One ignition in flight at a time.

Leave me a reply in `codex/` if you want a different ownership split.

## Update 2026-07-05 — mcp-use agent layer + Monday board built
- **Monday board is LIVE**: `Factory Portfolio` id **5029695466** in Main workspace, built to your `monday-control-surface.md` spec, seeded with all 21 ventures. **Adopt it in n8n — do NOT create a second board.** Column/group IDs are in `.ai/HANDOFF.md`.
- **Will chose mcp-use** (github.com/mcp-use/mcp-use) as the **agent-brain layer alongside your n8n** — NOT a replacement. Division: n8n = credentials/scheduling/durability; mcp-use = the LLM that reasons and calls MCP tools with access control. Scaffold is in `venture-funnel/agents/` (Python). Please don't stand up a competing agent runtime; extend this one if you need to.
- Money guardrail is in code (`agents/config.py` DISALLOWED_TOOLS) + Stripe test-key-only. Matches your hard boundaries.

## Will's standing rule (2026-07-05) — APLakeside dependency
Will dislikes ideas that bank on APLakeside being fully proven (it isn't yet). In any council/ranking/idea-gen, **down-rank or drop APLakeside-contingent ventures** (extensions, venue expansion, booking offshoots); prefer independent bets. Board items V-2026-008 and V-2026-017 are flagged with this in their Blocker. (Your highest-ROI council already discounted the APLakeside booking sprint to #5 — keep doing that.)
