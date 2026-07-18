# HANDOFF → Codex: cold-email machine — fulfillment + QA side
Date: 2026-07-17 · From: Claude · Status: LIST COMPLETE — 410 rows, all unique/valid emails.
Segments: aml-conveyancer 191 · aml-realestate 123 · ndis-pack 43 · agedcare-desk 33 · aml-accountant 20.
States: SA 159 · NSW 93 · VIC 64 · QLD 42 · WA 22 · TAS 18 · ACT 7 · NT 5.
QA note for your task 2: the SA conveyancers (AIC SA directory mine) and the 30 NSW conveyancers
(findaconveyancer.com.au store_search endpoint) are directory-sourced — sample those hardest.
12 VIC rows are Sargeants franchise branches (locally owned; network may have head-office AML plans —
Will may drop or keep). A further ~348 NSW conveyancer records with emails sit unharvested in that
same store_search endpoint if the list ever needs a second wave.

## Context (read this, then the local files)
Will pivoted the venture system to demand-first: sell by cold email, build the product on the first
"yes". Claude has built the campaign kit and a verified prospect list. Everything below lives LOCALLY
on Will's machine — **no prospect names/emails in this vault, ever** (PII rule). Paths:

- `Desktop\CLAUDE\Business\demand-first\probe-targets-2026-07-16.md` — 3 campaigns, ready-to-send
  email sequences (AML pack A$149 · NDIS self-audit pack A$129 · House-in-Order report A$190),
  firing rules, 21 sniper prospects with per-target caveats.
- `Desktop\CLAUDE\Business\demand-first\lists\prospects-2026-07-17.csv` — the big list (278 rows and
  growing; campaign,business,person,email,phone,state,source_url,notes). Every email was read off a
  live page; source_url is the Spam Act inferred-consent evidence.
- `Desktop\CLAUDE\Business\demand-first\lists\SENDING-PLAN.md` — deliverability gates. Hard rules:
  Will sends everything manually; 15–20/day ceiling from main identity; Gmail identity bug must be
  fixed first; opt-outs permanent.
- `Desktop\CLAUDE\Business\demand-first\pressure-map-2026-07-17.md` — the wider demand research
  (grants/tenders/aged-care/DA angles) if you want the strategic picture.
- Deadline driving urgency: AUSTRAC enrolment for Tranche 2 entities closes **29 July 2026**;
  obligations already live since 1 July.

## Your tasks (in priority order)
1. **Build the AML Starter Pack to fulfillment-ready.** The promise in Campaign 1's email: AML/CTF
   program document + ML/TF risk assessment template + staff-training register, pre-filled for a
   small real-estate agency (variant B: conveyancer). Source material: the evidence-engine corpus at
   `Business\govt-supplier-evidence-desk\` (niche-agnostic schema) and `Business\ndis-audit-desk\`
   (structure to mirror). Output to `Business\evidence-pack-store\aml-starter-pack\`. Quality bar:
   Will can send it within 1 hour of a "yes" reply. Mark clearly NOT LEGAL ADVICE; it's a
   documentation starter kit.
2. **QA the list.** Random-sample 20 rows of `prospects-2026-07-17.csv` across campaigns: fetch each
   source_url, confirm the email is still visible, flag dead pages/obfuscated rows. Write findings to
   `Business\demand-first\lists\qa-report.md` with a bounce-risk verdict per segment (the 141 SA
   conveyancer rows came from one directory mine — they most need the sample check).
3. **Mail-merge prep (drafts only — NOTHING SENDS).** Script that joins the CSV to the campaign
   templates in probe-targets-2026-07-16.md and emits per-row .txt drafts (subject + body, personal
   name where present, per-row defect line for house-in-order) into
   `Business\demand-first\lists\drafts\<campaign>\`. Plus `send-log.csv` skeleton per SENDING-PLAN.
   Will reviews and sends by hand.

## Boundaries (unchanged, full strength)
- Nothing auto-sends to anyone. No deploy/domain/production changes. No prospect data in this vault.
- The Gmail identity fix and all sending are Will-only gates.
- If you finish 1–3, the stretch task is the NDIS self-audit pack (same corpus, Practice Standards
  config already ~80% exists in ndis-audit-desk).

Leave your status/questions in `codex/` as usual. — Claude
