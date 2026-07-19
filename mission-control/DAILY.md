# DAILY - Monday, 2026-07-20

_Mission Control morning digest. Generated 09:34._

## Runs (last 24h)  -  3

- 12:55 - DESIGN DECISION — I need your independent judgement, not code review. CONTEXT: BBS hero, a 3D interl...  -> runs/2026-07-19--125511--design-decision-i-need-your-independent/
- 11:30 - Independent review of a shipped-quality WebGL hero implementation. Be critical and specific. FILE TO...  -> runs/2026-07-19--113038--independent-review-of-a-shipped-quality/
- 11:08 - BBS website hero — 2D concept frames for a logo animation redesign. CONTEXT (locked facts, do not vi...  **[single-agent]**  -> runs/2026-07-19--110855--bbs-website-hero-2d-concept-frames-for-a/

## Recently touched  -  newest first

- **10-active\bbs-evidence-desk\STATUS.md**  (1d ago, 2026-07-18 22:36)
- **handoffs\2026-07-18-claude-to-codex-outbound-email.md**  (2d ago, 2026-07-18 14:04)
- **handoffs\README.md**  (2d ago, 2026-07-18 14:04)

## Needs attention  -  3

- DESIGN DECISION — I need your independent judgement, not code review.

CONTEXT: BBS hero, a 3D interlocking "LB/BB" monogram (locked letterform, supplied GLB) on a
near-black navy ground with blueprint construction guides. Brand palette is FIXED and is exactly
two colours plus neutrals: navy #061b3a (and #0a274d, #102f57) and champagne #c9ae78 (light
#eadab6). Ground is near-black navy. Type is champagne.

WHAT JUST HAPPENED: the mark was navy with champagne RIMS only. Measured, its face sat at OKLCh
L .220 against a ground of L .226 — 0.005 lightness separation, i.e. invisible except for the rim.
Will said "zero contrast". I then made the ENTIRE mark champagne metal. Separation is now 0.369 and
it reads well, BUT Will's reaction is: "looks better, dk why its all gold tho".

He is right. He asked champagne to carry MORE of the mark, and I made it carry ALL of it. The brand
is navy AND champagne; an all-gold mark has deleted half the identity.

THE QUESTION — answer decisively, pick ONE and justify it:
How should navy and champagne divide this mark so that BOTH read, while keeping strong separation
from a near-black ground? Options I can see:

A. Champagne front faces, navy extruded SIDE WALLS (split by surface normal in the shader).
B. Navy body, champagne only on the bevel/edge chamfers — thicker and more present than the thin
   rim it had, but not the whole face.
C. Champagne on ONE letter of the interlock, navy on the other (they are separable visually).
D. Champagne body with navy in the recessed inner channel / cavities only.
E. Something better I have not listed.

CONSTRAINTS: the letterform is locked; I cannot edit geometry. I can split by surface normal, by
depth/cavity, or per-mesh if the GLB has separate meshes. Keep it buildable in three.js/R3F.

Also answer: does an all-champagne mark on near-black actually harm the brand, or is Will's reaction
about something else — e.g. that it now reads as a generic "gold logo" rather than as BBS? - did not finish, it ran out of rounds without the agents agreeing
- Independent review of a shipped-quality WebGL hero implementation. Be critical and specific.

FILE TO REVIEW: app/MonogramV2.tsx (and app/hero-v2/page.tsx) in this repo.
It renders the LOCKED Meshy monogram GLB with a redesigned treatment: navy metal
(MeshPhysicalMaterial metalness .95 / roughness .17 / clearcoat .9), a Fresnel RIM glow in
champagne injected via onBeforeCompile AFTER <tonemapping_fragment>, drei Sparkles, a studio
Environment of Lightformers, ContactShadows, on a dark navy ground with SVG blueprint guides.

CONSTRAINTS THAT ARE NOT UP FOR DEBATE:
- The letterform is LOCKED (public/monogram.png is the shape lock). Do not propose redesigning it.
- Palette is fixed: navy #061b3a, champagne #c9ae78, champagne-light #eadab6.
- Will approved this dark-ground direction. Do not propose switching to a light/cream ground.

WHAT I WANT FROM YOU — FINISH QUALITY ONLY. Answer these four, concretely:
1. Read the Fresnel injection. Is `vNormal` correct there, or should it be the perturbed normal?
   Does injecting after tonemapping cause any problem I have not accounted for (e.g. with
   outputColorSpace / sRGB encoding in three 0.185)?
2. The monogram has tight interlocking overlaps. A Fresnel rim keyed on view angle will pile up
   champagne in those crevices. Is that visible risk real, and what is the cheapest mitigation that
   does NOT require editing the locked geometry?
3. Large coplanar extruded faces share one normal and render as flat fills. I added a micro-relief
   normal map but had to dial it to sub-visible (0.16) because it read as dirt. Is there a better
   technique for this specific case?
4. Name the single biggest thing that would make this read as MORE expensive, that I have not done.

Be blunt. Do not restate my own reasoning back to me. If something I did is wrong, say so. - did not finish, it ran out of rounds without the agents agreeing
- BBS website hero — 2D concept frames for a logo animation redesign.

CONTEXT (locked facts, do not violate):
- Brand: Bowker Business Services. Palette is FIXED: navy #061b3a, navy-2 #0a274d, navy-3 #102f57,
  champagne #c9ae78, champagne-light #eadab6, ivory/bone background, pearl.
- The mark is an interlocking "LB"/"BB" monogram. Its LETTERFORM IS LOCKED — public/monogram.png is
  the logo-shape lock. Do NOT redesign the letterform. A hand-rebuilt version was rejected before
  ("needs to look like the photo").
- The redesign is of the TREATMENT and the ANIMATION, not the mark.

THE TARGET AESTHETIC (carried from an approved sister project):
Dark ground, a champagne/gold GLOW on the RIMS/EDGES of the monogram, highly reflective metal,
subtle sparkle, everything reading as expensive and restrained. The animation: blueprint guide lines
draw themselves on, the mark assembles/sweeps into place, the rims ignite, then it settles dead
still. Restrained, not flashy. Think luxury watch advert, not gaming intro.

YOUR DELIVERABLE: standalone SVG concept frames (no build step, no dependencies) that show
KEY FRAMES of this animation as static pictures. Write each as a separate .svg file in
design/concepts/codex/ named 01-guides.svg, 02-assemble.svg, 03-rim-ignite.svg, 04-settle.svg.
Use ONLY the palette hexes above. Use gradients/filters for the gold rim glow.
Represent the monogram as a simple placeholder geometric interlock — do NOT attempt to draw the real
letterform, since it is locked and you do not have it.

Also write design/concepts/codex/NOTES.md: 5 bullet points on what you think makes the rim-glow read
as expensive rather than cheap, and one risk you see in this direction. - ran single-agent (codex: timeout), consider re-running

## Open gates awaiting you  -  1

- **govt-supplier-evidence-desk**: 4 item(s) in approvals-queue

## Open handoffs  -  1

- to **codex**: outbound email ownership  (handoffs/2026-07-18-claude-to-codex-outbound-email.md)

## Portfolio  -  92 ventures

In Flight (3): Government Supplier Truth & Evidence Desk; Automation Services (blanket, white-label-first); NDIS Audit Desk

_Full board: mission-control/BOARD.md_
