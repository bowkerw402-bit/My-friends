---
venture: bbs-evidence-desk
updated: 2026-07-18
status: active
---

# BBS + Evidence Desk — status & schedule

**Bowker's Business Services (BBS)** is the umbrella brand; **Evidence Desk** (V-2026-023) is its flagship
service line. Three lines share **one engine and one bank account**: Evidence Desk, Automation Services, NDIS
Audit Desk. The design is *build once, sell many* — a shared card-engine + generators + a brand seam
(`studio/brand.json`), with a per-niche config file per service.

> **The one thing that matters (Codex's read, confirmed by recon):** the blocker is NOT building — it's that
> outreach is **drafted but unsent**, deliverability is **unverified**, and there are **zero real conversations**.
> Everything is built (97 prospect pages, 94 PDFs, the engine, both storefronts). More building won't validate demand.

## State snapshot
| Line / piece | State | Note |
|---|---|---|
| Evidence Desk engine + automation (19 scripts) | **BUILT** | niche-agnostic core; gov niche populated |
| Storefront A (static) — home + /automation + 5 lanes | **LIVE** | bowkerbusinessesservices.com |
| Storefront B (Next.js + 3D) | **BUILT, not deployed** | different look (navy/champagne); NDIS /ndis page lives only here |
| Evidence Desk outreach (drafts) | **GATE** | drafted in Gmail; **none sent** |
| Automation Services funnel + 11 recipes + audit engine | **BUILT** | GTM direction **not chosen** (1 of 5) |
| NDIS Audit Desk (kit + engine renderer + sample) | **BUILT** | VALIDATION green; 32 prospects listed |
| Clients | **0** | across all three lines |

## Fix-first (cheap, removes footguns) — agents can do now
- **D1/D2 — reconcile the two storefronts:** pick one canonical codebase; the local Netlify link points at a **dead site** (deploy footgun). Analysis + a decision doc only — no deploy. *(Claude)*
- **D3 — add the missing `netlify.toml`** to the static bundle. *(Claude)*
- **QA** the 97 pages / 94 PDFs against the locked design system. *(Claude)*

## The schedule (ranked, owner-assigned)
| # | Next action | Owner | Why it's theirs | Blocked by |
|---|---|---|---|---|
| 1 | **Verify deliverability** — inbox placement + SPF/DKIM/DMARC on the real sending identity, and fix the Gmail wrong-account issue | **Will** (+ Codex drafts the check) | needs account access + real sends | you |
| 2 | **Approve + send one bounded outreach tranche** from the staged drafts | **Will** | outward communication is human-only | #1 |
| 3 | **Enrich NDIS prospects + draft batch 1** as file drafts | **Codex** | Codex owns email/GitHub; not gated | nothing |
| 4 | **Prepare the discovery-call script + free-artifact offer + post-call template** | **Claude** | drafting supports the human gate; not gated | nothing |
| 5 | **Payment readiness** — lawyer-reviewed terms, GST decision, Stripe re-brand (it currently says "CF Restoration Services"), test checkout, consent/AI-disclosure | **Will** | legal/tax/money/identity are human-only | professional advice |

## All Will-gates (the human bottleneck)
Approve/send outreach · Stripe re-brand to BBS + test→live · lawyer-reviewed terms · A$750 pilot deposit ·
**NDIS: buy PI insurance** · deploy the `/ndis` page · pick the canonical storefront · pick 1 of 5 automation
directions · add Netlify email notifications (+ delete the 1 test submission) · GST + PII-sync + AI-disclosure decisions.

## What the agents can do without you
Codex: NDIS email enrichment + batch-1 drafts (see the outbound-email handoff). Claude: storefront
reconciliation doc · netlify.toml · page/PDF QA · discovery-call kit · stage unified studio copy (no deploy).

_This file is the living tracker. Re-run the schedule anytime with `run "refresh the BBS schedule" govt-supplier-evidence-desk`._
