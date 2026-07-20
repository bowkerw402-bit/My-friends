---
venture: social-engine
status: active
created: 2026-07-20
owner: will
agent: claude
---

# Social Engine: free distribution across every live brand

Will's goal in his words: "as distributive and widespread as possible", using the old phones,
without paying for ads.

## The design in one paragraph

One real account per platform per brand. Each phone is dedicated to one brand, so its camera roll,
logins, and notifications belong to that brand only. Claude drafts every post (draft only, Will
fires everything). Free official scheduling tools queue the posts, so a whole day is approved in
one sitting. Volume comes from repurposing (one idea becomes a different post per platform), not
from duplicate accounts. This is the version that compounds instead of getting banned: platforms
reward accounts with consistent history, and every follower gained is kept.

## Account architecture (corrected 2026-07-20)

Will's question: "if they are all under different emails and accounts how can they come back to
one meta suite?" The answer, and it simplifies the build:

- A Facebook Page has NO login. Pages are administered by Will's personal Facebook profile. There
  is no "BBS Facebook account". One profile administers every brand Page.
- ONE Business Portfolio at business.facebook.com holds every brand Page and every brand Instagram
  account. Business Suite then shows a brand switcher.
- Instagram and TikTok accounts DO have their own logins, one per brand, held on the phones. Each
  is connected to the portfolio ONCE, after which posting flows through the portfolio.
- Net effect: many brands, many Instagram logins, one Business Suite, one key (Will's personal
  Facebook profile). Adding brand number three costs no more than brand number two.

The phones are therefore for FILMING and for holding each brand's Instagram/TikTok login. They are
not the posting mechanism. All scheduling happens from the signed-in Chrome on the desktop.

## Phone map

REVISED 2026-07-20, after the Business Suite build proved the phones are not the posting mechanism.
The original five-phone map was written before we knew that. It was wrong, and the corrected
version is much smaller.

**Only ONE phone is needed right now.** Set up a second only when a second brand goes live.

| Phone | Job | Status |
|---|---|---|
| 1 | **The working phone.** Instagram app logged into @bbservicescanberra for Stories, DM replies, and trending-audio browsing. Plus filming, with OneDrive camera upload ON so footage lands on the desktop by itself. | SET UP NOW |
| 2 | APLakeside phone, same pattern. | When APLakeside accounts are created. |
| 3 | Evidence / NDIS desk. | Gated on Will's branding call. |
| 4, 5 | Not needed. Do not set up. | Retired from the plan. |

**Why the shrink.** Facebook Pages have no login, so no phone is needed to hold one. Every
scheduled post is loaded from the signed-in Chrome on the desktop. LinkedIn and Google Business
Profile are desktop jobs. So a phone only earns its place for two things: the native app features
that genuinely are phone-only (Instagram Stories, DMs, TikTok's audio library), and filming.

One phone covers both for one brand. Five phones covered a problem we do not have.

## Where distribution actually comes from (set 2026-07-20)

Will's challenge, and it is a fair one: "that's not multiple different accounts then, it's one.
which means 1 account not 5."

Correct. The reach does not come from account count. It comes from SURFACE count multiplied by
post frequency. Reach on these platforms is earned per post through engagement, not granted per
account, so fifteen zero-follower accounts reach roughly fifteen times nothing.

**The six surfaces, one account each:**

| Surface | Status | Why it matters |
|---|---|---|
| Facebook Page | LIVE | Local reach, shares, the Business Suite hub |
| Instagram | LIVE | Visual, Reels reach beyond followers |
| Google Business Profile | NOT BUILT | **Highest value for BBS.** Puts the business in Maps and local search for Canberra buyers actively looking |
| LinkedIn company page | NOT BUILT | The actual B2B buyers: bookkeepers, agencies, property managers |
| TikTok | NOT BUILT | Pairs with APLakeside video; low priority for BBS |
| YouTube Shorts | NOT BUILT | Same vertical video, second audience, free |

Six surfaces at two posts a day is over eighty posts a week from one brand, all landing on
accounts that compound instead of accounts that are invisible. THAT is the widespread version.

Priority order for closing the gap: Google Business Profile, then LinkedIn, then the video pair.

## Cadence

- Target: morning slot (~7:30am) and evening slot (~6:00pm) per active brand.
- Ramp: week 1 is one post per brand per day. Week 2 onward moves to two once approval takes
  Will under five minutes. School has started, so the system must cost Will minutes, not hours.

## The loop (updated 2026-07-20: one word fires the week)

Will's requirement in his words: "I want this to be, like, an automated thing." The design that
delivers it: the PLATFORMS are the posting robot. Their schedulers auto-publish queued posts with
nobody touching anything. Will's only recurring act is one approval word per batch.

1. Monday 7:22am: the social-drafts routine writes the FULL WEEK of posts to
   `content/queue/TODAY.md` and asks for approval in the thread.
2. Will reads it and replies "approved" (or "approved, but change X"). One word, once a week.
3. That same session, Claude drives Will's logged-in Chrome and loads every approved post into
   Meta Business Suite (Facebook + Instagram), TikTok's scheduler, and Buffer (LinkedIn), each
   with its scheduled time. The platforms then publish automatically, morning and evening, all
   week. Everything scheduled is logged in STATE.md.
4. Other mornings the routine only tops up or redrafts on request.
5. Weekly: Claude reads what performed (Will screenshots the insights pages, per the
   "show, don't describe" standard) and tilts next week's drafts toward what worked.

The floor that cannot be removed: content goes public only on Will's explicit approval, per batch.
No approval, no scheduling. Approval never carries from one batch to the next.

## Content pillars

- **BBS**: relief from hated chores, hours-back stories, plain-English explainers of the five
  automation lanes, "we watch it so you don't". ZERO AI words (standing rule).
- **Evidence/NDIS Desk**: deadline radar (real dates, e.g. AUSTRAC enrolment 29 Jul), plain-language
  obligation explainers, checklist posts. Factual, never legal advice, no fear-selling, no client PII.
- **APLakeside**: the lake, the venue, offsite outcomes, leadership content for the EL1 audience.

## Rules this engine runs under

- Draft only. Claude never posts, schedules, or publishes. Will fires every post.
- One real account per platform per brand, in the business's real name. No duplicate or
  persona accounts. (Flagged once on 2026-07-20; this is the working version.)
- No AI words in any BBS or desk content.
- No client PII ever appears in a post.
- Recent-first: the queue only ever shows today and tomorrow, never a guilt backlog.

## Open gates (Will's calls)

1. Create the accounts (agent cannot create accounts). Checklist on the Desktop.
2. Phone 2 branding: does the desk post as BBS or under its own name?
3. Yes or no on adding a `social-drafts` morning routine so drafts appear automatically every day.
