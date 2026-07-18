# Codex handoff, send-day prep for the 9 Evidence Desk drafts (2026-07-13)

From: Claude. Goal: every one of the 9 Gmail drafts is SEND-READY today. You prepare them; Will presses send. Nothing sends, schedules, or auto-follows-up. Ever.

## Account check first (hard gate)
Verify the Gmail tool is authenticated as **williambowker@bowkerbusinessesservices.com** before touching anything. If it is any other account (ramonslapdog, aplakesideservices, bowkerw402), STOP and report. You reconnected this correctly on 2026-07-12; just re-verify.

## What changed since you created the drafts
1. Delivery is now a **PDF attachment**, not a hosted link. The 13 one-pagers are rendered at `Business/govt-supplier-evidence-desk/site/pdf/<Name> - Evidence Desk.pdf`. The prospect pages are no longer on the public site (the homepage is now a multi-service storefront), so any page-link placeholder in a draft is dead weight.
2. Per-prospect kits now exist at `Business/govt-supplier-evidence-desk/prospect-kits/<slug>/` (dossier, follow-up sequence, call script). Follow-ups are written for PDF delivery. These are for Will's use after send day; you do not need to act on them today.

## Your job today, per draft (register: `ops/gmail_created_personalised_2026-07-12.json`)
For each of the 9 drafts (draft_ids in the register):
1. **Replace the page-link line.** Remove `[PERSONALISED PAGE LINK TO ADD BEFORE SENDING]` and rephrase that sentence to reference the attached one-pager, e.g. "I have attached a one-page PDF I put together for <Firm>, specific to what I noticed." Keep the surrounding copy otherwise verbatim.
2. **Attach the matching PDF** from `site/pdf/`:
   - Yellow Edge - Evidence Desk.pdf -> clientservice@yellowedge.com.au
   - MicroWay - Evidence Desk.pdf -> sales@microway.com.au
   - Wisdom Learning - Evidence Desk.pdf -> kirstin.mckune@wisdomlearning.com.au
   - Morpht - Evidence Desk.pdf -> murray@morpht.com
   - ConceptSix - Evidence Desk.pdf -> admin@conceptsix.com.au
   - Work Science - Evidence Desk.pdf -> scott.paine@workscience.com.au
   - JWS Research - Evidence Desk.pdf -> info@jwsresearch.com
   - Pragma Partners - Evidence Desk.pdf -> info@pragma.com.au
   - Strategic Development Group - Evidence Desk.pdf -> connect@strategicdevelopment.com.au
3. **Signature block**: ensure it reads exactly
   Will Bowker / Bowker's Business Services / ABN 96 697 140 877, [POSTAL ADDRESS, WILL TO FILL BEFORE SENDING]
   and keep the unsubscribe line: Reply "no thanks" and I won't contact you again.
4. **Leave the postal address placeholder in place.** Do not invent an address. It is the single field Will fills at send time (required by the Spam Act sender-identification rules).
5. Verify each draft after editing by reading it back (you know the trick: read the draft back and check the resolved account and attachment, do not trust tool follow-up chatter).

## The 4 form-only prospects (no Gmail drafts)
Griffin Legal, ARTD, RD Consulting, SafeAssure have staged local messages (you built them) and kits. Web forms cannot carry attachments, so their messages offer to email the PDF on request. Nothing for you to do in Gmail; Will submits these via the websites.

## Report back
Per draft: recipient, subject, PDF attached (y/n), placeholder intact (y/n), account verified. Then a one-line confirmation that nothing was sent.

## Will's remaining manual steps (so the mail can go out today)
1. Fill the postal address in each draft (one paste x 9).
2. Skim each draft once.
3. Press send.
4. Diarise follow-ups from each kit (+4 days, +10 days).
