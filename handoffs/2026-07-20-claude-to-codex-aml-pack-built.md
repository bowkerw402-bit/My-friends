---
from: claude
to: codex
venture: aml-setup-pack
date: 2026-07-20
status: open
---

# Handoff: AML Setup Pack is built, fulfilment gap closed  (Claude -> Codex)

## Why this exists
You reported honestly that the 50 AML drafts were aligned and unsent, but that the
pack behind them was not built, so a "yes" today had no product. Correct call, and it
was my gap: I wrote the campaign copy that made the promise. The pack is now built.

## What changed
Built at `Business\evidence-pack-store\aml-starter-pack\` (LOCAL, never the vault).
Real estate and conveyancer variants, six documents each, Word and Excel per Will's
Office-formats rule. **Read that folder's `README.md` first** — it is the fulfilment
runbook.

Two corrections that matter more than the files:

1. **AUSTRAC publishes its sector starter kits FREE** (released 30 Jan 2026: real
   estate, conveyancer, accountant, legal, jeweller). So the product is the
   customisation labour, not the templates. Every client-facing document states this
   and points to the free source. Do not let any copy you write drift off that line.
   Three hard rules from AUSTRAC's own licence terms, baked into the build:
   attribute "© AUSTRAC for the Commonwealth of Australia"; never imply AUSTRAC or
   government endorsement; never use their logo or the Coat of Arms.

2. **The reply trigger is the SCOPE one-pager, not the pack.** The drafts ask "would
   it help if I sent the one page scope and order details?" So a reply gets
   `00-send-on-reply/AML-Setup-Pack-Scope-and-Order-<sector>.docx` within the hour.
   The pack goes after payment and a returned intake form, inside two business days.
   Two artifacts, two clocks. My original handoff missed this distinction.

There is also a refund rule in the scope document, so it is now a promise: if the
suitability check shows the standard approach does not fit that business, we do not
deliver and keep the money. We say so and refund.

## Over to you
- [ ] **Task 2 from the original handoff still stands: QA the list.** Sample 20 rows
      of `Business\demand-first\lists\prospects-2026-07-17.csv` across segments, hardest
      on the SA conveyancers (AIC directory mine) and the 30 NSW conveyancers
      (findaconveyancer store_search endpoint), since those are directory-sourced.
      Write to `Business\demand-first\lists\qa-report.md`.
- [ ] **The 18 held drafts.** Your own REVIEW-GATE flags them for route recheck, 7 of
      them high bounce risk (personal-name conveyancer inboxes). Resolve or drop before
      Will sends, so the first batch does not carry avoidable bounces.
- [ ] **Accountant variant** when you want it: a config entry in
      `build/build_pack.py`, not a new document set. Pull suitability criteria and risk
      rows from AUSTRAC's accountant starter kit. Not blocking, no accountant drafts exist.

## Boundaries
- Draft-only. Nothing sends. Will fires every send.
- No prospect data, client PII, or pack contents into this vault. Local paths only.
- Never claim the pack makes anyone compliant. It is documentation, not legal advice,
  and not a guarantee.

## Reply (Codex writes here)
_(pending)_
