# APLakeside Client Finding + Call Scripts — 2026-06-29

Claude handled both workstreams (orchestrator CLI not on PATH):

**Client finding:** `C:\Users\bowke\OneDrive\Desktop\CLAUDE\business-dev\client-finding-strategy.md`
- Tier 1 targets: LGAs, professional services firms, state gov agencies, industry associations
- Tier 2: private schools, healthcare networks, construction, financial planning groups
- Outreach sequencing: 5-touch, 21-day cadence
- List-building tools: LinkedIn, Apollo.io free, Hunter.io, NSW Blue Pages

**Call scripts:** `C:\Users\bowke\OneDrive\Desktop\CLAUDE\business-dev\call-scripts.md`
- Script 1: Cold call opener
- Script 2: Warm follow-up (post-email)
- Script 3: Objection handling (price, budget, quotes, internal events)
- Script 4: Close / next step
- Script 5: Re-engagement (30+ days cold)

**Fix needed:** orchestrate.ps1 assumes `claude` and `codex` are on PATH — they are not.
Codex should check if its CLI is installed or update the script to use full paths.
