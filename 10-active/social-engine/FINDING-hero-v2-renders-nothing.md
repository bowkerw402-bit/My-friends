---
found: 2026-07-20
corrected: 2026-07-20
severity: LOW. Unused experimental route only. The live hero is fine.
---

# CORRECTED: hero-v2 renders nothing, but hero-v2 is not the live hero

## The correction first

An earlier version of this file warned that the BBS homepage might be showing a blueprint frame
with no logo. **That was wrong, and the warning is withdrawn.**

`/` renders the monogram correctly: navy body, champagne edges, blueprint ground, exactly as
intended. Verified in Will's own Chrome. Will said "confused because it does match", and he was
right to be.

The mistake: `Bowker Business Events/CLAUDE.md` states plainly that **`app/Monogram3D.tsx` is the
active one-shot hero animation** on `/`. `app/MonogramV2.tsx` behind `/hero-v2` is a separate
treatment experiment. I tested the experiment and reported it as though it were the live site.
The lesson is cheap and worth keeping: read which route is live before declaring a route broken.

## What is actually true

`/hero-v2` draws its blueprint frame, circle, ticks and footer, but the monogram never appears.
Ruled out: GLB load failure (returns 200), JavaScript errors (none), missing GPU (reproduced on a
real GPU in Chrome), and screenshotting too early (waited 9s, past all animation timings). Both
`?pose=1` and the natural animation behave the same.

Most likely a silent failure in `MonogramV2.tsx`'s `onBeforeCompile` shader injection. It does
several `.replace()` calls against three.js shader chunk names, and a name that no longer matches
in three 0.185.1 fails **silently**, leaving uniforms undeclared and geometry unshaded. That fits
the symptoms exactly: no error, no mark.

Related: DAILY.md carries an unresolved Codex review of this same file that ran out of rounds
without agreement, including a question about whether `vNormal` is correct in the Fresnel
injection. Possibly the same defect.

## Impact

Low. It blocks nothing that matters. The live hero works, and social post images are now shot
from `/` instead. Worth fixing only if the v2 treatment is still wanted.
