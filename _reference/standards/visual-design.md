---
area: visual-design
updated: 2026-07-18
---

# Visual design

## Design first, then build (standing)
Never write website code without an approved visual direction. Rendered options come first, Will picks,
then it gets built. Taste wins over evidence when the two disagree.

## The rendered page is the truth (standing)
Code that looks right is not proof. Verify what actually renders using the visual QA tool
(`tools/visual-qa/snap.mjs`), because the browser pane screenshot is unreliable and pauses WebGL.
Animations get measured across the timeline, not eyeballed once.

## One moment per page (standing)
A page earns one memorable moment, not five competing ones.

## Nothing published without approval (standing)
Deploys and domain changes are Will's call, every time.

## The BBS site is the portfolio (set 2026-07-18)
Web design is one of the things BBS sells, so the site has to prove it on sight. A visitor should be able
to tell the design capability is real just by looking, without being told. This raises the bar on the BBS
site above "clean and clear": it needs at least one thing on it that a prospect could not have got from a
template. **Will's words:** "I would obviously want it to be the thing that you can see just by looking at
our website."

## Keep what already works when redesigning (set 2026-07-18)
Will likes the current BBS site. A redesign is an upgrade on top of it, not a teardown. Push new ideas and
higher quality, but the burden of proof is on the new version.

## Automation systems need to be visible (set 2026-07-18)
The automation work is invisible, which makes it hard to sell. It needs a visual form that can be shown on
the website, posted to LinkedIn, and pointed at during a call. Treat this as a design problem, not a
documentation problem. Not started, and not to be started without Will picking a direction.

_Seed this file further as Will states more visual preferences. Colour, typography, motion, and brand
rules belong here so Codex can read them too._

## 2026-07-21 — animation library
Will: "use anime.js when relevant."
Applies to DOM/SVG animation on web builds (entrances, staggers, settles, draw-ons). anime.js v4 is
already installed in the BBS repo and is APLakeside's engine per the web-design-3d arbitration.
Not a mandate to force it where it does not fit: continuous WebGL loops (e.g. a turntable's
constant rotation) stay in the render loop (useFrame / rAF); anime.js drives the choreography
around them. Motion stays inside the calibrated quiet-confidence band: 250–450ms, travel ≤24px,
stagger ~80ms, no bouncy curves.
