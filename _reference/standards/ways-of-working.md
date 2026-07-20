---
area: ways-of-working
updated: 2026-07-20
---

# Ways of working

## Flag a line once, then build (set 2026-07-20)
**The rule:** if Will proposes something the agent cannot do as designed, say so once, in one plain
sentence, and immediately pivot to the closest version that works. No ethics lectures, no repeating the
objection, no dwelling. Will cares about the outcome; give him the best working path inside the lines.

**Will's words:** "I don't really appreciate you saying that... just give me what the best option is
while still sitting within, I guess, what your needs are because I want this working."

**How to do it properly:**
- One sentence naming the constraint, then the alternative, then build the alternative.
- Practical risks (bans, IP flags, legal exposure) are worth stating because they affect whether the
  thing works. Moral commentary is not.

## Will shows, he does not describe (set 2026-07-19)
**The rule:** when Will is working on anything visual or 3D, he wants to hand the agent the actual thing
rather than write a paragraph describing it. Assume a picture or a file is coming, and build the channels
that accept one. Never make him translate a shape into words.

**Will's words:** "just the ability for me to show you exactly what and how i am prompting with 3d stuff,
like so i can show u too instead of words."

**How to do it properly:**
- Pasted screenshots work directly in chat. This is the zero-setup path and should always be offered first.
- For real geometry, `tools/visual-qa/look3d.mjs` renders any .glb .gltf .obj .stl .dae .fbx .ply from
  several angles and reports triangle count, bounding box, and materials. The agent Reads the PNGs.
- This is the 3D sibling of `snap.mjs`, which does the same job for web pages.
- The point is mutual: Will shows the agent, and the agent shows Will back, in pictures both times.

## Real deliverables go on the Desktop (set 2026-07-18)
**The rule:** if it is actual output Will needs to use, read, or show to someone, it goes on his Desktop in
one clearly named folder. Not buried in the repo, not a loose local HTML file, and never three similar
files he has to guess between.

**Will's words:** "if I wanna see material, like a folder or a file or a Word doc or just any type of
information, put it on my desktop because I would like to actually see it instead of having to dig around."

**The stipulation, and it matters:** this applies only to real output. Working files, intermediate drafts,
scripts, configs, run records, and anything the system reads but Will does not, all stay in the repo. The
Desktop is only for things he will actually open.

**How to do it properly:**
- One folder per deliverable, named in plain words for what it is, for example "Evidence Desk Call Pack".
- When a deliverable is updated, replace the file in place. Never leave a second copy, so there is never a
  question about which one is current.
- Say where it is, by name, when handing it over.

## Recent work is the priority signal (set 2026-07-18)
The things touched most recently are almost always the things that matter. Timestamp everything, track
when it was last updated, and surface the most recent handful first. Do not resurface old items just
because they are unfinished. **Will's words:** "obviously the most recent five things that we would have
worked on would clearly be the most important."

## Be gentle with sorting and reorganising (set 2026-07-18)
Do not aggressively restructure or archive things on assumption. Move slowly, explain in plain words what
is being moved and why, and prefer leaving something in place over tidying it away. Nothing is ever
deleted, only archived with a note.

## Do not push tasks Will has not asked for (set 2026-07-18)
Suggesting next steps is fine. Pushing a list of jargon tasks he did not ask for, and cannot evaluate, is
not. If a task needs a paragraph of context to make sense, that is a sign it is not ready to offer.

## Will is at school from the week of 2026-07-20 (set 2026-07-18)
Weekday time is no longer reliably available. Do not plan work that assumes long uninterrupted blocks, and
do not stack a week's worth of tasks on a Monday. Keep pieces small enough to pick up and put down.
**Will's words:** "I start school next week as well, though. So some of this stuff is gonna be, like, hard
to get around in terms of, like, planning and timing."

## Finished is finished (set 2026-07-18)
When Will says something is done or not relevant, it comes off the list that night. It does not keep
reappearing in reviews as unresolved. Closed items get recorded as closed, with the date, in the venture
STATUS file.

## Draft only (standing)
Neither agent ever sends, deploys, publishes, signs, or spends. Build to one click of readiness and stop.
Will fires every outward action.

**Social-media carve-out (set 2026-07-20):** for the Social Engine, Will's one click is a single
"approved" reply covering a whole batch (typically a week of posts). On that reply, in that same
thread, the agent may load the approved batch into the official platform schedulers (Meta Business
Suite, TikTok, Buffer), which then auto-publish. Approval is per batch and never carries forward.
**Will's words:** "I want this to be, like, an automated thing."

## One ignition at a time (standing)
Only one venture is actively being ignited. Tracked in `IGNITIONS.md`.

## Prefer horizontal engines (standing)
"The niche is that there is no niche." Prefer build once, sell many. The product is horizontal, the go to
market is niche.

## No AI branded services (standing, 2026-07-16)
Sell the relief, never the technology. Zero AI words in any pitch. AI is margin, not marketing.

## Zero input from the client (standing, 2026-07-16)
A service passes the filter only if the client effort is forwarding one document, or nothing at all.
If gathering the inputs costs as much as doing the task, it fails.
