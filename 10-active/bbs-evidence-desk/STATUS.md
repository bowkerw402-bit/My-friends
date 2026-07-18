---
venture: bbs-evidence-desk
updated: 2026-07-18
status: active
---

# BBS and Evidence Desk, status and schedule

**Bowker's Business Services (BBS)** is the umbrella brand. **Evidence Desk** (V-2026-023) is its flagship
service line. Three lines share one engine and one bank account: Evidence Desk, Automation Services, NDIS
Audit Desk. The design is build once, sell many: a shared card engine plus generators plus a brand seam
(`studio/brand.json`), with one config file per niche.

> **The one thing that matters** (Codex's read, confirmed by recon): the blocker is not building. Outreach is
> drafted but unsent, deliverability is unverified, and there are zero real conversations. Everything is
> already built (97 prospect pages, 94 PDFs, the engine, both storefronts). More building will not validate demand.

## Decisions
**2026-07-18, the live static storefront is canonical.** Will's call. The unpublished Next.js version (the
one with the 3D monogram) is superseded and gets archived, never deleted.
**Before it is archived:** the NDIS service page exists only in that unpublished version, so it must be
rebuilt on the live site first. Until then the folder stays where it is, marked superseded.

## State snapshot
| Line or piece | State | Note |
|---|---|---|
| Evidence Desk engine and automation (19 scripts) | BUILT | niche agnostic core, gov niche populated |
| Live storefront: home, /automation, 5 lanes | LIVE | bowkerbusinessesservices.com. **Canonical.** |
| Unpublished Next.js storefront (3D monogram) | SUPERSEDED | archive after the NDIS page is rebuilt on the live site |
| Evidence Desk outreach drafts | GATE | drafted in Gmail, none sent |
| Automation Services funnel, 11 recipes, audit engine | BUILT | go to market direction not chosen (1 of 5) |
| NDIS Audit Desk kit, engine renderer, sample report | BUILT | validation green, 32 prospects listed |
| Clients | 0 | across all three lines |

## Agents can do now, no gate
- Rebuild the NDIS service page on the live static site, so the unpublished version can be archived safely. (Claude)
- Add the missing `netlify.toml`, and fix the local Netlify link that points at a dead site. (Claude)
- Enrich NDIS prospects and draft batch 1 as file drafts. (Codex, see the outbound email handoff)
- QA the 97 pages and 94 PDFs against the locked design system. (Claude)
- Prepare the discovery call script, free artifact offer, and post call template. (Claude)

## The schedule, ranked
| # | Next action | Owner | Blocked by |
|---|---|---|---|
| 1 | Verify email deliverability (inbox placement, SPF, DKIM, DMARC) and fix the wrong Gmail account | **Will** | you |
| 2 | Approve and send one bounded outreach tranche from the staged drafts | **Will** | #1 |
| 3 | Enrich NDIS prospects and draft batch 1 | Codex | nothing |
| 4 | Rebuild the NDIS page on the live site, then archive the unpublished storefront | Claude | nothing |
| 5 | Payment readiness: lawyer reviewed terms, GST, Stripe rebrand (it currently reads "CF Restoration Services"), test checkout, consent | **Will** | professional advice |

## Every gate that is yours
Approve and send outreach, Stripe rebrand to BBS then test to live, lawyer reviewed terms, the A$750 pilot
deposit, buy PI insurance for NDIS, deploy approval, pick 1 of 5 automation directions, add Netlify email
notifications and delete the 1 test submission, GST and PII sync and AI disclosure decisions.

_Living tracker. Refresh it with `run "refresh the BBS schedule" govt-supplier-evidence-desk`._
