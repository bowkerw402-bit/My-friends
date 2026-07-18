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
**2026-07-18 evening, the NDIS page rebuild is no longer urgent.** Will's call: there are no clients and no
booked calls, so nothing depends on that page existing yet. It stays on the list, unranked, until there is
a real call that needs it.

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

## Closed out 2026-07-18 evening (Will confirmed done)
- Squarespace to Netlify domain cutover for the Evidence Desk store. **Done.**
- APLakeside hero polish (lettering, boat). **Done.** Now a candidate to go live on the APLakeside site,
  see "Open questions" below.
- Cone image regeneration. **Dropped.** Will: not relevant to anything, that website is finished. The
  staged brief and reference image can be left where they are, no action.
- The BBS "nothing there" report. Treated as resolved, Will is seeing the site fine.
- GitHub token rotation is Will's, happening 2026-07-19.

## Next week, from Will 2026-07-18
Monday is the real start. Two things carry weight:
1. **Prepare for the Evidence Desk call.** The call pack is already built (register, deck, two guides).
   What is left is rehearsal and the script, not more building.
2. **More NDIS cold calls.**

**Constraint: Will starts school next week.** Planning and timing get harder from here. Do not assume
weekday blocks are available. Keep tasks small enough to pick up and put down.

## Open questions Will is sitting on, do not action
- Whether the polished APLakeside 3D hero goes on the live APLakeside site. Leaning yes, not decided.
- A serious BBS website redesign. He likes the current site and does not want it thrown away. The ambition
  is higher quality and new ideas, and specifically that the site should *demonstrate* the web design
  capability just by being looked at, since design is one of the things being sold.
- Visualising the automation systems so they can be shown to people: on the website, on LinkedIn, and on
  calls. Will sees this as the piece that makes the offer land.

## The schedule, ranked
| # | Next action | Owner | Blocked by |
|---|---|---|---|
| 1 | Verify email deliverability (inbox placement, SPF, DKIM, DMARC) and fix the wrong Gmail account | **Will** | you |
| 2 | Approve and send one bounded outreach tranche from the staged drafts | **Will** | #1 |
| 3 | Prepare the Evidence Desk call: script, free artifact offer, post call template | Claude | nothing |
| 4 | Enrich NDIS prospects and draft batch 1 | Codex | nothing |
| 5 | Payment readiness: lawyer reviewed terms, GST, Stripe rebrand (it currently reads "CF Restoration Services"), test checkout, consent | **Will** | professional advice |
| - | Rebuild the NDIS page on the live site, then archive the unpublished storefront | Claude | deprioritised, no client needs it |

## Every gate that is yours
Approve and send outreach, Stripe rebrand to BBS then test to live, lawyer reviewed terms, the A$750 pilot
deposit, buy PI insurance for NDIS, deploy approval, pick 1 of 5 automation directions, add Netlify email
notifications and delete the 1 test submission, GST and PII sync and AI disclosure decisions.

_Living tracker. Refresh it with `run "refresh the BBS schedule" govt-supplier-evidence-desk`._
