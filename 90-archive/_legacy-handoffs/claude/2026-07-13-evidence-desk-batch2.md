# Codex handoff, batch 2: 20 new prospect emails (2026-07-13)

From: Claude, on Will's instruction. Batch 1 (9 emails) is out with no replies yet; follow-ups fire at +4 days per the kits. This batch expands the pipeline: **20 new prospects, each with a personalised one-pager, a PDF, and a Gmail draft with the PDF attached.** Drafts only. Nothing sends, deploys, or publishes.

## Account gate (hard, first)
Verify Gmail is **williambowker@bowkerbusinessesservices.com** before creating anything. Any other account: STOP and report.

## Sourcing the 20 (in priority order)
1. **Re-verify the 10 soft-held from your own batch-1 research** (held for weak verification, not bad fit): Neoteric, Ethos CRS, Exhale People, CBIT, Leading Insight, Coolamon Advisors, Digital61, Charterpoint, Sustineo, Testgrid. One deeper pass each: named senior decision-maker, headcount signal under ~50, bids at least ~4x/year signal. Pass -> in. Fail -> hold with one-line reason.
2. **Fill the remainder to 20 via bounded AusTender prospecting** (Will approved this expansion by ordering the batch): use `automation/build_prospect_list.py` categories as the frame. Target: small Australian professional-services firms (5 to 50 staff) with repeated recent Commonwealth awards, a public leadership page, and a reachable route (published email preferred; form-only acceptable but flag it).
3. **Exclusions:** the 13 existing prospects, and the hard-dropped (BellchambersBarrett, Liberate Learning, Clear Horizon, Security Consulting Group, Parbery, Integrity Partners, Plain English Foundation).

## Per prospect (the pipeline you already know)
1. **One-pager** at `site/publish/<slug>.html` — same new theme and structure as the existing 13 (copy an existing page as the template). Personalised headline from their AusTender signal, one specific evidence gap from their own public site, sources cited, `noindex`, no em/en dashes, honest voice, no guarantees.
2. **PDF**: run `node tools/visual-qa/pdf.mjs <slug> [<slug> ...]` from `tools/visual-qa/`. It auto-names the PDF from the page title ("prepared for X") into `site/pdf/X - Evidence Desk.pdf`. Batch multiple slugs per run.
3. **Gmail draft** (email-route prospects only): create the draft WITH the PDF attached from the start (you proved create-with-attachment works). Body modeled on the batch-1 replacements: reference "the one-page PDF I have attached", specific hook line, A$750 founding pilot, fifteen-minute ask. Signature exactly: Will Bowker / Bowker's Business Services / ABN 96 697 140 877, [POSTAL ADDRESS, WILL TO FILL BEFORE SENDING]. Keep: Reply "no thanks" and I won't contact you again.
4. **Form-only prospects**: stage the message locally under `ops/staged-form-messages/` instead; message offers to email the PDF on request.
5. **Register**: write `ops/gmail_created_batch2_2026-07-13.json`, same schema as batch 1 (to, subject, draft_id), plus a `route: "email"|"form"` field.

## Standing rules (ops/config.md — unchanged)
No promises of wins/compliance/certification. Nothing auto-sends; Will sends. No classified work. Client PII stays out of the shared vault. Postal address placeholder is Will's to fill.

## Report back
Count sourced vs held (with one-line reasons), then per prospect: slug, route, page built y/n, PDF y/n, draft created y/n (or staged-form), account verified. Confirm nothing sent.
