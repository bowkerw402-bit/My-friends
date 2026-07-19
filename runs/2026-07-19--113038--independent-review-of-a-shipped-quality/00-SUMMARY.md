# 2026-07-19--113038--independent-review-of-a-shipped-quality

**Task:** Independent review of a shipped-quality WebGL hero implementation. Be critical and specific.

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

Be blunt. Do not restate my own reasoning back to me. If something I did is wrong, say so.

- **Mode:** two-agent  (two-agent=True, degraded=False)
- **Rounds:** 1  -  **Done:** rounds exhausted
- **Codex:** ok
- **Review verdict:** FAIL
- **Tools (verified, Claude):** Read
- **PII:** none

See transcript.md for the full exchange, tools.md for the ledger.
