# Timeline editing — re-flow, gaps, reorder, aspect

Most edits to *one* clip ripple to *others*. The cardinal rule: **after changing any clip's start or duration, fix the rest of its track.** Same-track clips cannot overlap (lint errors), and unintended gaps read as dead air.

## The timing model (recap)

- `data-start` — when the clip begins (seconds, or a clip-ID reference like `"intro + 0.5"`).
- `data-duration` — how long it lasts (required for img/div/composition clips; video/audio default to media length).
- `data-media-start` — trim offset into the *source* media (seconds). Trimming the *start* of a video means raising this, not just moving `data-start`.
- `data-track-index` — integer lane. Clips on the same lane must not overlap. Visual layering is CSS `z-index`, not track index.
- The root composition's total length follows the end of its last clip (or an explicit root `data-duration`).

**Prefer relative references where they already exist.** If clips are chained as `data-start="prevId + 0"`, editing one duration auto-reflows the chain. If they use absolute seconds, you must recompute downstream values yourself.

## Re-flowing after a duration change

Clip B's duration changes by `Δ` (positive = longer). Every clip that starts at or after B's old end, **on the same track**, shifts by `Δ`:

```
newStart = oldStart + Δ   (for each clip starting >= B.oldEnd on B's track)
```

If clips on *other* tracks are meant to stay synced to B (e.g. a caption tied to a scene), shift them too. If they're independent (background music spanning the whole video), leave them.

## Closing a gap (after delete / trim)

Removing clip B (length `L`) leaves an `L`-second hole. Pull every later same-track clip earlier by `L`:

```
newStart = oldStart - L   (for each clip starting >= B.start on B's track)
```

Then confirm the root total shrank by `L`.

## Inserting a clip

Inserting clip X (length `L`) at time `t` on a track that's already full from `t` onward: push everything at/after `t` later by `L` first, then place X at `t`. If X is an **overlay** on a free track, no push needed — just give it a free `data-track-index` and the right `z-index`.

## Reordering scenes

Reordering is just recomputing `data-start` in the new sequence, keeping each clip's duration:

```
cursor = firstStart
for clip in newOrder:
    clip.data-start = cursor
    cursor += clip.data-duration   # (+ any intended gap/transition overlap)
```

Keep transitions consistent — if scenes crossfade by 0.3s, subtract that overlap as you advance the cursor.

## Aspect-ratio / canvas changes

Changing `data-width`/`data-height` on the root (e.g. 1920×1080 → 1080×1920) does **not** auto-fix layouts. After the change:

1. Make sure `.scene-content` fills the canvas with `width:100%; height:100%; padding:…; box-sizing:border-box` — not fixed px. Padding-based layouts survive aspect changes; fixed `top/left/width` do not.
2. Re-check font sizes — a 120px headline that fit 16:9 width may wrap badly at 9:16.
3. Run `npx hyperframes inspect` to catch off-canvas and overflow after re-fit.

Common targets: **16:9** 1920×1080 (YouTube/landscape), **9:16** 1080×1920 (TikTok/Reels/Shorts), **1:1** 1080×1080 (feed square).

## After every reflow

- `npx hyperframes lint` — catches overlaps and unregistered timelines you may have introduced.
- Sanity-check the new total duration against intent.
- If you shifted GSAP-driven elements, make sure tween positions on the timeline still line up with the new `data-start` values.
