# Command map — any phrasing → concrete operation

The user will phrase edits in any register: terse ("tighter"), emotional ("make it pop"), technical ("set data-duration to 2.4"), or vague ("the middle bit drags"). This file is the lookup from intent to a concrete HyperFrames operation. Match on **meaning**, not exact words.

Notation: `clip` = an HTML element with `class="clip"` and timing `data-*` attributes. "Re-flow" = recompute downstream `data-start` values so the track stays gapless/non-overlapping (see [timeline-editing.md](timeline-editing.md)).

---

## Trimming & length

| Intent (examples) | Operation |
| --- | --- |
| "cut the first 2 seconds", "lose the dead air at the start" | Increase the opening clip's `data-media-start` (trim into source) or push `data-start`; re-flow the track so the video starts at 0. |
| "trim the end", "it runs long", "cut the last scene" | Shorten/remove the final clip(s); the root `data-duration` follows the last clip's end. |
| "make the intro shorter / tighter" | Reduce intro `data-duration` (and its GSAP tween durations proportionally); re-flow everything after it earlier by the same delta. |
| "let scene 3 breathe", "hold longer on the product" | Increase that clip's `data-duration`; push downstream clips later. |
| "make the whole thing 15 seconds" | Scale all `data-start`/`data-duration` by `15 / current-total`, or trim/drop scenes to hit the target — ask which if it's a big cut. |

## Speed & pacing

| Intent | Operation |
| --- | --- |
| "speed up the intro", "make it snappier/punchier" | Shorten `data-duration` and the GSAP tween durations on that scene; re-flow. Punchy also = tighter eases (`power3/power4.out`) and less overlap. |
| "slow it down", "too frantic" | Lengthen durations; soften eases; add small holds between beats. |
| "the logo animates too fast" | Increase that element's tween `duration` in the GSAP timeline (not the clip duration unless it's the whole scene). |
| "speed up the video clip itself" | For a `<video>`, trim with `data-media-start` + `data-duration`; true time-remap is an FFmpeg preprocess step, not a data-attr — flag that. |

## Captions & text

| Intent | Operation |
| --- | --- |
| "add subtitles", "add subs synced to the voice" | Ensure a word-level transcript exists (`npx hyperframes transcribe audio.wav` → `transcript.json`); add caption clips driven by it. See `hyperframes` skill for the caption pattern. |
| "put text here that says X" | Add a text clip at the current/named timestamp with `data-start`/`data-duration`/`data-track-index`; style per `design.md`. |
| "fix that typo", "change the caption to Y" | Edit the text content of the clip; if it's transcript-driven, edit `transcript.json` or the override. |
| "make the text bigger / move it up / different color" | CSS edit on that element (respect `design.md` brand values). |
| "highlight that word", "marker sweep / circle it" | Add a text-highlight effect — defer to the `hyperframes` skill's highlight patterns. |

## Audio & voiceover

| Intent | Operation |
| --- | --- |
| "add a voiceover saying X", "have it narrate this" | `npx hyperframes tts "X" --voice <match content> --output narration.wav`; add an `<audio>` clip; optionally `transcribe` for captions. Voice table is in the `hyperframes-media` skill. |
| "swap the music", "different track" | User supplies the file → drop into project, repoint the music `<audio>` `src`, re-check duration vs. video length. |
| "louder / quieter / mute the voice" | Set `data-volume` (0–1) on the audio/video clip. Video with a separate audio track should be `muted`. |
| "duck the music under the voice" | Lower music `data-volume`; if dynamic ducking is needed, that's an FFmpeg preprocess — flag it. |
| "fade the music out at the end" | GSAP-tween a gain, or fade via the audio clip's volume envelope per the `hyperframes` skill; simplest: shorten + crossfade. |

## Media swaps

| Intent | Operation |
| --- | --- |
| "replace the background", "use this image instead" | Place the asset in the project; repoint the clip `src`; for video, recheck duration and trim. |
| "remove the background from this clip" | `npx hyperframes remove-background in.mp4 --output cutout.webm` (u2net); use as a transparent overlay clip. |
| "add a B-roll clip here" | Insert a new `<video>` clip at the timestamp on a free track; re-flow if it's inline rather than overlay. |

## Structure & layout

| Intent | Operation |
| --- | --- |
| "delete / kill scene 2", "remove that clip" | Remove the clip element; close the gap on its track (pull later clips earlier). |
| "move scene 3 before scene 2", "reorder" | Recompute `data-start` for the affected clips in the new order; keep durations. |
| "add a title card / end card / lower-third" | Add a clip (often a `data-composition-src` sub-comp) at the right time; build end-state layout first, then animate (see `hyperframes` skill). |
| "make it vertical / 9:16 / for TikTok / Reels" | Set root `data-width="1080" data-height="1920"`; re-fit layouts (padding-based `.scene-content`, not fixed px). Common: 1920×1080 (16:9), 1080×1920 (9:16), 1080×1080 (1:1). |
| "punch in / zoom on X", "ken burns" | GSAP scale + position tween on that clip over its duration. |

## Workflow / output

| Intent | Operation |
| --- | --- |
| "show me", "preview", "play it" | `npx hyperframes preview` (background) → return `http://localhost:<port>/#project/<name>`. |
| "render", "export", "ship it", "give me the mp4" | `npx hyperframes render` → report output path. |
| "lint", "is it valid?", "check it" | `npx hyperframes lint` (and `inspect`); report findings. |
| "what's in this?", "how long is it?", "list the scenes" | Read the comp(s); summarize timeline (scenes, durations, tracks, total). No edit. |
| "undo that" | Revert the specific change you just made (you know the prior values — restore them). If unsure of prior state, say so. |

---

## When nothing matches cleanly

1. Restate the command as an editing intent in one line ("You want the product to stay on screen longer — extending its hold").
2. Pick the operation that achieves it, apply, state the assumption.
3. If it truly can't be expressed in the HyperFrames model (e.g. variable-speed time-remap, audio ducking automation), say what's possible in-engine and what needs an FFmpeg/preprocess step — don't silently approximate.
