---
found: 2026-07-20
severity: blocks the "render posts from the real hero" path; may also affect the live site
---

# hero-v2 renders the blueprint but not the monogram

Found while trying to shoot post images from the real hero (Will's chosen path, because the
flat cards were not good enough and the cutout PNG fringes white at large sizes).

## What happens

`http://localhost:3001/hero-v2` (and `?pose=1`) renders the blueprint construction frame
beautifully: guides, circle, ticks, corner brackets, the BOWKER BUSINESS SERVICES footer. The
**monogram itself never appears.** The canvas stays empty.

## What was ruled out

| Suspect | Verdict |
|---|---|
| GLB failed to load | NO. `GET /models/bbs-monogram-meshy.glb` returns **200**. |
| JavaScript error | NO. Zero console errors or exceptions on the page. |
| No GPU / software renderer | NO. Reproduced in Will's **real Chrome with a real GPU**, same result. |
| Screenshot fired too early | NO. Waited 9 seconds, well past SWEEP 2.6s + IGNITE_DELAY 1.5s + IGNITE 1.6s. |
| `?pose` value out of range | Unlikely. Reproduced both with `?pose=1` and with no pose at all. |

So: the model loads, nothing throws, the GPU is real, and the mark still does not draw.

## Where to look next

`app/MonogramV2.tsx` is heavily customised: `onBeforeCompile` shader injection with object-space
varyings (`vObjN`, `vObjP`), a two-tone split by depth plane, a Fresnel rim injected after
`<tonemapping_fragment>`, plus a generated micro-relief normal map. A silent failure in the shader
injection would produce exactly this: no exception, no console error, geometry present but not
visibly shaded. Worth checking whether the injected chunks still match three 0.185.1's shader
source, since a `.replace()` against a chunk name that no longer matches fails **silently** and
leaves the uniforms undeclared.

Note the DAILY.md backlog already carries an unresolved Codex review of this exact file, including
a question about whether `vNormal` is correct in the Fresnel injection. That review never reached
agreement (it ran out of rounds). This may be the same defect, now visible.

## Impact

- Blocks rendering social post images from the real hero.
- **Check the live site.** If this reproduces in production, the BBS homepage is currently showing
  a blueprint frame with no logo in it.
