# The Design Funnel

The repeatable method for building high-quality visual/3D web work for Will — and, more usefully,
the record of everything that went **wrong** getting there and what the actual root cause turned out
to be each time.

Written 2026-07-18, out of the APLakeside lake-hero build (six rounds of feedback, several of them
brutal). Will: *"I would say just save this entire funnel — all the troubleshooting that just
happened, all the stuff that we did to get to this point. I want this to be something you can refer
to consistently."*

---

## Read in this order

| File | What it is | When you need it |
|---|---|---|
| **[the-funnel.md](the-funnel.md)** | The pipeline: spec → build → verify → gate → close the loop. The craft playbook (realism, grade, materials, motion). | Before you write any scene code. |
| **[calibration.md](calibration.md)** | Will's taste, **measured** from work he already approved. Chroma bands, ground lightness, where gold is allowed. | Before you pick any colour. Non-negotiable. |
| **[case-study-lake-hero.md](case-study-lake-hero.md)** | All six rounds of the lake build: what he said, what I did, what the real cause was. | When something looks wrong and you're about to guess. |
| **[tools.md](tools.md)** | The QA tools and the exact commands. | Every build. |
| **`tools/predeliver.mjs`** | The show/no-show gate. Blocks on drift vs the last approved build. | **Before Will sees anything.** |
| **[../council/2026-07-19-retries-to-three.md](../council/2026-07-19-retries-to-three.md)** | Why 14 rounds happened and what makes the next one 3. | Before starting a project. |

---

## The rule that supersedes everything below

**Count SHOWINGS, not rounds.** Unlimited internal iteration; three contacts with Will. Of the 13
post-v1 rounds, only ~4 transferred information that could not have been obtained without showing
him something — the rest were the builder debugging in public, which is what he was objecting to
("yo slow down cause it looks kinda shit"). **Run `predeliver.mjs` before every showing.**

## The five-line version

1. **Spec before you build.** Every refinement round on the lake hero was a *specification* gap, not
   a craft miss. Six lines (shot, frame budget, palette, signature object, motion budget, reveal
   order) delete most of them.
2. **Check the calibration before choosing a colour.** `feel.json` holds bands measured from work
   he approved. Twice I invented a gold by eye and shipped one *more saturated than the one he
   personally calls "the gold that is too gold."* It was measurable the whole time.
3. **Reuse an approved rig atomically, never cherry-picked.** Porting half of one (a different env,
   one tone-mapping setting) cost a full fix cycle every single time it happened.
4. **Watch the motion, don't snap it.** A frozen frame cannot show what breaks *during* a move.
   `filmstrip.mjs` tiles the whole arc into one image. Every real fix came from reading one.
5. **Two failed fixes on the same symptom means the diagnosis is wrong.** Stop fixing. Go find the
   frame that discriminates between your hypotheses.

---

## The meta-lesson, and it is the expensive one

**Every root cause in this build was one layer below where the symptom appeared, and in every case
I fixed the symptom first.**

- "The logo reads as a broken U" → wasn't the ring's rotation (it was broken at *zero* rotation).
  It was a metallic surface mirroring a blown-out sky.
- "The gold looks matte and cheap" → wasn't the material. It was that I'd tied the metal's
  environment to the scene's mood, so at dusk it had nothing bright to reflect.
- "Everything looks oversaturated" → wasn't the grade alone. It was a high-noon key plus a
  desaturating tone-mapper plus CSS tint slabs, each added to compensate for the last.
- "I can see the pixels" → wasn't the geometry. `antialias:true` is **inert** once EffectComposer
  is active, and the water had no anisotropic filtering.

The tell is always the same: **a fix that doesn't work, applied twice.** That is the signal to stop
and go one layer down, not to try a third variant of the same fix.

---

## The other meta-lesson

I built a bench that measured his taste, then ran an entire multi-round build **without opening it
once**. He noticed: *"I don't know what you've done with all of the visual psychology stuff, but
that seems to have completely disappeared from the framework."*

A tool that must be remembered is already dead. `calibration.md` exists to make the check take
fifteen seconds, and `the-funnel.md` puts it in the pipeline as a step with the literal command.
