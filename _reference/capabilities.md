# Capabilities — who does what (the back-end reality)

The honest division of labour and what each side can actually reach right now. This is the map behind
every handoff. Update as connectors get authorized.

## Claude Code (Opus) — builder + orchestrator
**Can:** write/run code + PowerShell + file ops · orchestrate two-agent runs · trading engine + dashboards ·
web search/fetch · the skills library (willsideas, web-design-3d, cold-outreach-engine, deep-research,
brightdata, code-review, llm-council) · the vault + Mission Control · TradingView MCP (read/control charts).
**Cannot right now:** Gmail (connector not authorized on Claude's side) → **handed to Codex** ·
Monday.com (unauthorized — ignored for now) · anything tied to an account only Codex is logged into.

## Codex — second engine + account-holder
**Can:** independent adversarial review (real substrate diversity — it catches what Claude misses) ·
parallel builds · GitHub via `github-local` MCP · TradingView MCP · media generation (muapi) ·
**Gmail / outbound email** (its account has the access → see the outbound-email handoff).
**Note:** Codex's config holds the GitHub token that needs rotating.

## Will — the human gates (draft-only means these are always yours)
Sending anything · deploying / domain changes · signing · spending / payments / Stripe · authorizing
connectors (OAuth) · lawyer review · anything irreversible or outward-facing.

## Auth status (what's actually usable)
| Capability | Status | Owner |
|---|---|---|
| TradingView MCP | OK (local) | Claude / Codex |
| GitHub (`github-local`) | OK — **token needs rotating** | Codex |
| Gmail / email | unauthorized on Claude; Codex has it | **Codex** |
| Monday.com | unauthorized — ignored (ledger is source of truth) | — |
| Stripe / Canva / Notion / Slack / ~30 more | unauthorized | authorize in claude.ai only when a venture needs it |

**Rule of thumb:** if it needs an outside account or sends something outward, it's Codex's or Will's — Claude
builds and orchestrates. When Claude needs something only Codex can reach, it writes a **handoff** (see `handoffs/`).
