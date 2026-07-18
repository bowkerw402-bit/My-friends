# Handoff: Codex — NDIS Audit Desk outreach email production
From: Claude · 2026-07-16 · Venture: NDIS Audit Desk (V-2026-023 spearhead)

## Context (60 seconds)
New BBS service line, ignited today: fixed-price audit readiness for registered NDIS providers.
$990 Gap Report (front door) → $590/mo Audit Desk (the business). Zero AI words in any copy —
standing rule. Everything is drafts; **nothing sends — Will sends**. Working folder (source of
truth): `Desktop/CLAUDE/Business/ndis-audit-desk/`.

## Your job
1. **Enrich emails.** `ops/prospects.csv` has 32 REAL registered providers scraped from the NDIS
   Commission register today (names, ABNs, phones, registration expiry, registration groups —
   all verified from the register; do NOT invent or swap any of it). Most rows lack an email.
   Visit each listed website, find the practice's contact email (contact page, mailto links,
   privacy policy). Fill the `email` column. If no website or no email found, mark
   `no-email-found` in the email column — DO NOT guess addresses.
2. **Draft the emails.** Templates live in `06-outreach.md` (base 5) and `08-procurement-funnel.md`
   (pressure variants). Personalisation slots come from the CSV:
   - Rows noted WAVE1 → use the renewal-window template (Email 1 / W1-A): reference their actual
     expiry month from `registration_expiry` and their real registration groups.
   - Rows flagged `FLAG register shows expiry PASSED` → SKIP drafting; these need Will to verify
     status by phone first.
   - `Balanced Account Bookkeeping` row → use a CHANNEL-partner angle (plan manager + bookkeeper),
     not the prospect template.
   - Everything else → Email 2 (cold, register-facts-as-homework).
3. **Output format.** One file: `Business/ndis-audit-desk/ops/drafts-batch-1.md` — each draft as
   `### {provider_name}` + `To:` + `Subject:` + body, ready for Will to copy-paste/send. Do NOT
   create drafts in any live mail client — the business email identity is unresolved (known
   Gmail routing issue), so file-based drafts only this round.

## Hard rules (from the venture's EXECUTION.md — non-negotiable)
- Never send anything. Never create drafts in a live mailbox this round.
- Zero AI words in copy. Zero invented facts — every claim about a provider must trace to the CSV.
- Every email keeps the identity + opt-out line from the templates.
- We are "not an Approved Quality Auditor" — don't strengthen any claim beyond the templates.
- Client/prospect data stays in the business folder; this vault note carries no provider PII
  beyond what's already public register data.

## Nice-to-have (if time)
- Sanity-check phone formats in the CSV (register exports them as +610XXXXXXXXX — strip the
  stray 0 after +61).
- Note in `ops/ops-log.md` (one line) when done.

— Claude
