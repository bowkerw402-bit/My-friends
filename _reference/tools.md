# Tool Registry

The menu of tools each agent can reach, and whether they're actually usable right now. A [[brief|Brief]]'s
**Tool Manifest** cites `id`s from this table; a run's `03-tools.md` records which were actually used, so this
doubles as the audit vocabulary. **Living doc — update auth status as connectors get authorized.**

Legend: auth = `ok` usable · `needs-oauth` connector installed but not authorized · `rotate` credential must be replaced.

## MCP servers / connectors
| id | tool | claude | codex | auth | pii | what it's for |
|----|------|:------:|:-----:|------|-----|---------------|
| `tv-mcp` | tradingview-mcp | yes | yes | ok (local) | low | live chart read/control, Pine dev, replay/backtest |
| `gh-local` | github-local | – | yes | **rotate** (PAT in `~/.codex/config.toml`) | med | repo ops from Codex |
| `algobuilder` | algobuilder-mcp | (config pending) | – | needs-setup | med | read-only AlgoBuilder bots/backtests |
| `monday` | Venture Command Center board | needs-oauth | – | needs-oauth | low | mirror the ledger to a Monday board (view only) |
| `gmail` | Gmail connector | needs-oauth | – | needs-oauth | high | read/draft mail (DRAFT-ONLY — never send) |
| `stripe` | Stripe | needs-oauth | – | needs-oauth | high | payments (Will-only actions) |
| `canva` | Canva | needs-oauth | – | needs-oauth | low | brand/design assets |

## Skills (Claude-side)
| id | skill | auth | what it's for |
|----|-------|------|---------------|
| `willsideas` | willsideas | ok | GENERATE / IGNITE the venture funnel; owns FRAME for business ideas |
| `willstradeentry` | willstradeentry / -postentry | ok | trade entry + post-entry discipline |
| `cold-outreach-engine` | cold-outreach-engine | ok | all cold outreach/email/sequence/deliverability (drafts only) |
| `web-design-3d` | web-design-3d | ok | 3D/animation web builds (design-first router) |
| `will-voice` | will-voice | ok | write in Will's voice |
| `llm-council` | llm-council | ok | multi-model council review (feeds REVIEW/FRAME) |
| `deep-research` | deep-research | ok (metered) | cited multi-source research report (Will's call = approval) |
| `code-review` | code-review | ok | diff review for correctness + cleanups |
| `brightdata` | brightdata live-research / competitive-intel | ok (metered) | live market validation (willsideas VALIDATE) |
| `schedule` | schedule | ok | cloud cron routines (internal-only automations) |

## Notes
- **Draft-only** applies to every tool: no sending, deploying, publishing, signing, or spending by either agent.
- **Auth gap:** the `needs-oauth` connectors are unusable until Will authorizes them (claude.ai → Connectors, or `/mcp` in an interactive terminal). Until then, a Brief that lists them should note "capability blocked on auth."
- **`gh-local` PAT:** rotate the GitHub token and move it out of `~/.codex/config.toml` into an env var / credential store.
