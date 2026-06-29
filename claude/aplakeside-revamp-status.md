# APLakeside Revamp — Claude's Pass Complete

**Date:** 2026-06-29
**Status:** HTML + CSS + animations.js scaffold done. Codex: pick up your brief.

## What Claude built

### index.html (full rewrite)
- New emblem PNG (`brand-mark-cohesion-without-admin.png`) in nav, hero, footer
- Hero: `lake-tour-boats.jpg` full-bleed with parallax + water canvas
- Value strip (3-col: Defensible spend / Minimal effort / Lasting impact)
- Place section: `autumn-lakeside-trees.jpg` side panel
- Three movements with real photos:
  - Morning → `lake-tour-boats.jpg`
  - Midday → `candlelit-dining-table.jpg`
  - Afternoon → `conference-table-setting.jpg`
- Photo break panel: `lakeside-event-dining.jpg`
- Close/CTA: `waterfront-venue-exterior.jpg`
- 3D package cards (Foundation / Elevate / Transform) with photo thumbnails
- Anime.js CDN loaded, inline script removed → `animations.js`

### styles.css (full rewrite)
- CSS custom properties updated (--ink, --navy, --gold, --gold-light, --ivory)
- Custom cursor styles (.cursor-dot / .cursor-ring)
- 3D package card system (perspective, rotateX/Y on hover)
- Visual timeline (.day-timeline, .tl-track, .tl-line, .tl-node)
- Photo break section
- Value strip
- Full responsive breakpoints

### animations.js (new)
- Custom cursor with lerp ring
- Parallax (hero photo + mouse drift)
- Anime.js scroll reveals
- Visual timeline draw + node activation
- 3D card mouse-tracking tilt
- Water sine-wave canvas on hero
- Counter animation for reality section

## What Codex should do
Read your brief: `tasks/aplakeside-revamp-codex.md`

The `animations.js` scaffold is in place — Codex should EXTEND it, not replace it.
Specific additions Codex should layer in:
1. GodMode smooth scrolling (lerp-based scroll position)
2. More sophisticated Anime.js timeline sequences for section entrances
3. Enhance the water canvas (add more wave depth, foam edge)
4. Scroll-scrubbed progress indicator
5. Mobile touch parallax

## File locations
- Site: `C:\Users\bowke\OneDrive\Documents\Claude\Projects\C.T business\site\`
- Photos: `C:\Users\bowke\OneDrive\Documents\Claude\Projects\C.T business\site\photos\`
- All 6 new photos + emblem PNG already copied to site\photos\
