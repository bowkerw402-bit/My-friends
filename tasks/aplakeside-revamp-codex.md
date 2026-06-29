# Codex Task — APLakeside Website Animation Layer

**Project:** APLakeside Services website revamp
**Site:** `C:\Users\bowke\OneDrive\Documents\Claude\Projects\C.T business\site\index.html`
**Your job:** Add the full animation and 3D interaction layer using Anime.js

Claude is handling the HTML/CSS restructure in parallel. Once Claude's changes land, layer these on top. Work in a new `animations.js` file — do not touch index.html structure or styles.css variables.

---

## Stack to use
- **Anime.js** (CDN: `https://cdnjs.cloudflare.com/ajax/libs/animejs/3.2.1/anime.min.js`)
- **GodMode / GSAP ScrollTrigger** for scroll-driven sequences if needed
- Vanilla JS — no frameworks

---

## Animations to build

### 1. Hero entrance (`.scene-arrival`)
- Emblem drops in with a subtle 3D rotate + fade (rotateY 15deg → 0, opacity 0→1, 800ms ease)
- Headline words stagger up with Anime.js timeline (already have `.w` spans)
- Water ripples: canvas-based sine wave overlay on the hero, very subtle, 2–3 wave layers

### 2. Scroll-reveal (replace current IntersectionObserver)
- Replace the existing `.reveal` / `.in` pattern with Anime.js scroll-triggered animations
- Elements translate Y(40px)→0 + opacity 0→1 on enter, staggered by `.d1`, `.d2`, `.d3` delay classes
- Easing: `easeOutExpo`

### 3. Visual timeline (`.scene-day` — Three Movements)
- Horizontal progress line that draws left→right as user scrolls through the section
- Each movement node pulses gold when it enters viewport
- Movement cards tilt slightly on hover (CSS perspective + JS mouse tracking)

### 4. Package cards (`.tier`)
- 3D card flip or lift effect on hover — translateZ(20px) + subtle shadow bloom
- Gold border animates in (stroke-dashoffset or border-width) on scroll entry
- "Most chosen" badge pulses softly

### 5. Parallax
- Replace existing `requestAnimationFrame` parallax with Anime.js `.scroll()` or manual lerp
- Sky layer: 0.12x scroll rate
- Hills layer: 0.08x scroll rate
- Smooth lerp (0.08 factor) so it feels weighted

### 6. Cursor (GodMode style)
- Custom cursor dot (8px gold) + ring (32px, 1px gold border)
- Ring lerps behind cursor with ~0.12 factor
- Ring scales up to 1.4x on hover over CTAs/links
- Disable on touch devices

### 7. Nav
- On scroll past hero: nav slides in from top with Anime.js (translateY -60→0, 400ms)
- Logo mark rotates 360deg on hover (360deg, 600ms, easeInOutSine)

---

## Photo assignments (Claude will have set these in HTML)
```
Hero bg:           lake-tour-boats.jpg
Morning movement:  lake-tour-boats.jpg
Dining movement:   candlelit-dining-table.jpg
Session movement:  conference-table-setting.jpg
Place section:     autumn-lakeside-trees.jpg
Venue section:     lakeside-event-dining.jpg / waterfront-venue-exterior.jpg
```

---

## Design tokens (match Claude's CSS variables)
```css
--navy: #0D1B2A
--gold: #B79B61
--gold-light: #D4B97E
--cream: #F8F6F1
--mid: #14263D
```

---

## Output
- `C:\Users\bowke\OneDrive\Documents\Claude\Projects\C.T business\site\animations.js`
- Add one script tag at the bottom of index.html: `<script src="animations.js"></script>`
- Remove the old inline `<script>` block from index.html (Claude may have already done this)

---

**Check `My-friends/context/` for any notes Claude left after finishing the HTML pass.**
