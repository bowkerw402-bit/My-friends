# 15 improvements — speed / quality / idea-execution / planning

From the 2026-07-18 council (design critic + process retrospective + realism research) on the
APLakeside lake hero build. Ranked within each category by impact. The ones marked ✅ ADOPTED are
already wired into `web-design-3d/references/immersive-3d-scene-recipe.md` or the gate.

## PLANNING (where the time actually leaked)
1. **Write a 6-line spec before any scene code** — shot, frame budget (where each element lives on
   screen), palette+lighting target, signature object, motion budget, reveal order. Every one of
   Will's v2 notes (logo→corner, boat class, reveal choreography, local water colour) was a
   *specification* gap decidable before the first render, not a craft miss. ✅ ADOPTED
2. **Add a mobile line to the spec.** Building centre-composition and discovering the logo wanted a
   corner is a re-do. Decide the portrait reflow up front. ✅ ADOPTED
3. **Gather reference AND anti-reference images before organic/photoreal work.** The stylised lake
   got away without a ground-truth target; a tree/realism piece can't — "plausible but wrong"
   branching is invisible to the gate. ✅ ADOPTED (in the recipe's tree note)
4. **Commit per pass; stop full-file rewrites.** The whole build (file, snapshots, brand/, design/)
   is still untracked — no diff, no bisect, which is *why* the scroll bug could recur invisibly
   across three passes. Anchored edits + a commit per pass. (Git commit is Will's call.)

## SPEED
5. **Batch QA into ONE contact sheet** using the `?pose=`/`?scroll=` determinism that's already
   built — snap all key states in one pass and read them together. The lake's first-frame defects
   dribbled out over 5 fix passes; one contact sheet surfaces them in one look. ✅ ADOPTED
6. **Self-host every external asset up front, as a class** (textures, HDRI, three.js) — not
   per-failure. Kills CORS/offline/CDN-down at once; the CDN-texture CORS fail was knowable at write
   time. ✅ ADOPTED (recipe); still TODO on the live lake page (three.js + HDRI remain CDN).
7. **Reuse the approved rig atomically, not cherry-picked.** Reading the approved medallion then
   writing a *different* HDRI cost two cycles rediscovering env-map=material / mood=sky+lights. Port
   the whole lighting rig as a unit. ✅ ADOPTED
8. **Longer `--wait` on WebGL snaps (7–11s)** so the env-gated loop has started — a short wait
   catches a pre-loop frame (the "giant centred emblem" artifact). ✅ ADOPTED

## QUALITY
9. **Every animated object gets an explicit resting transform at creation** (often `scale 0`,
   revealing in). The armillary rendered at default scale 1 on the pre-loop frame = a giant centred
   ring. ✅ ADOPTED (recipe + fixed on the page).
10. **Contact shadow under anything on a surface** — the single biggest realism-per-line cue; a
    floating object with a reflection still reads pasted-on. ✅ ADOPTED (on the page + recipe).
11. **Raycast the cursor to the real surface plane**, don't linearly map screen→world — correct
    optics on every aspect ratio. ✅ ADOPTED (on the page + recipe).
12. **Legibility scrim behind hero type over a bright band**; and compose asymmetrically (emblem
    one corner, subject the diagonal) instead of stacking everything dead-centre. ✅ ADOPTED (on the
    page — the scrim + the top-left emblem gave the composition its diagonal).
13. **Paint water teal, let fresnel reflect the sky for blue**; calm-lake levers (low distortion,
    fine ripple, slow time). Sky-blue water with a scrolling normal but no fresnel is the plastic
    tell. ✅ ADOPTED (on the page + recipe).

## IDEA-EXECUTION / REVIEW
14. **Don't trust the gate's heuristics blindly on novel work — feed it the declared behaviour.**
    It false-fired twice on the lake (reveal-settle timing vs contract-legal 420ms; "6fps" across
    intentional hold frames). If a FAIL contradicts a known-good frame, suspect the check. Both
    fixed; the gate should read declared durations and be versioned WITH the project. ✅ PARTLY
    (both false-fires fixed; gate still lives outside any repo).
15. **Name the renderer fork explicitly instead of drifting into it.** Photoreal realism wants
    ACES+sRGB+physical lights, which shifts the locked brand gold. You can't keep verbatim brand
    reuse AND chase photoreal on one renderer. Decide per piece: cinematic-stylised at r128 (keep
    the gold recipe) or photoreal on a modern path (re-approve the gold once). Chasing photoreal
    frozen at r128 is the uncanny-valley trap. ✅ ADOPTED as a decision point (recipe); Will's call.

## The single biggest risk going forward (council, unanimous)
Chasing photoreal realism while pinned to r128 + NoToneMapping (tuned to protect the approved gold)
is the uncanny-valley trap. The realism frontier (the tree) will force the renderer/tone-mapping
decision. Build the tree on ACES from the start — it has no approved-gold constraint — and treat it
as the sandbox for the modern-renderer look before touching the locked pieces.
