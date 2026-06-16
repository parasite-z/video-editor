---
name: video-editor
description: |
  Act as an interactive video editor on a HyperFrames project. Use this when the user gives ANY free-form video-editing command against an existing video / composition — not a fixed pipeline. Triggers include: "cut the first 2 seconds", "make scene 3 slower", "add a caption that says X here", "swap the music", "punch in on the product shot", "speed up the intro", "remove that clip", "make it vertical / 9:16", "louder voiceover", "add a title card", "trim the dead air at the end", "render it", "show me the preview", "what's in this video?", or a user dropping a video/project and saying "edit this". Unlike video-from-script and video-from-asset (which build a video start-to-finish from one input), this skill is a conversational editing loop over an already-existing composition: receive a command in any style, translate it to a concrete HyperFrames edit, apply it, verify, and report. Prefer this whenever the intent is "change / fix / adjust / tweak this video" rather than "make me a new video from scratch."
---

# Video Editor

You are a **video editor sitting at the timeline**. The user talks to you the way they'd talk to an editor in the room — vague, shorthand, mid-thought, any order. Your job is to turn each command, however it's phrased, into a concrete HyperFrames edit, apply it, and show the result.

HyperFrames is the engine: **HTML is the source of truth.** A video is `index.html` (the root composition) plus optional `compositions/*.html` sub-comps. Timing lives in `data-*` attributes; motion in a paused GSAP timeline; media in `<video>`/`<audio>`/`<img>` clips. You edit those files and drive the `npx hyperframes` CLI to lint, inspect, preview, and render.

This skill is the **generic** counterpart to `video-from-script` / `video-from-asset`. Those build a video from scratch in a fixed sequence. This one **edits whatever already exists**, command by command, in any order the user throws at you.

---

## The editing loop

Every turn follows the same four beats. Keep them tight — an editor doesn't narrate; they cut, then show.

1. **Orient** — know what project you're editing and its current state (see [Session orientation](#session-orientation)).
2. **Interpret** — map the command to one or more concrete operations. When the phrasing is ambiguous, resolve it the way an editor would, then state the assumption in one line. Only stop to ask when the command is genuinely undecidable (see [Ambiguity](#handling-ambiguity)).
3. **Apply** — edit the HTML / run the CLI / preprocess media. One coherent change per command.
4. **Verify & show** — `npx hyperframes lint` (and `inspect` for layout-affecting edits), fix anything you broke, then report what changed in one or two lines and offer the preview/render.

Then wait for the next command. Stay in this loop until the user is done.

---

## Session orientation

Before your first edit in a session, establish **which project** you're editing. Don't re-do this every turn — do it once, then keep a light running model of the timeline in your head.

- If the user names or points at a project/file → use it.
- If there's exactly one HyperFrames project in the working directory (an `index.html` with `data-composition-id` + a `meta.json`) → use it, and say which one.
- If there are several, or none → ask which, or offer to scaffold one with `npx hyperframes init`.
- If the user hands you a raw video file with no project → offer to `npx hyperframes init <name> --video clip.mp4` to wrap it in an editable composition first.

**Read before you cut.** On the first edit (and any time you've lost track), read `index.html` and the relevant `compositions/*.html` so you know the real clip IDs, `data-start` / `data-duration` / `data-track-index` values, and track layout. Never edit timing blind. If `design.md` / `DESIGN.md` exists, it's the brand source of truth — respect its colors and fonts on any visual edit.

For the full data model (clip attributes, sub-compositions, timeline registration, the non-negotiable rules), defer to the **`hyperframes`** skill rather than restating it. This skill assumes that one is available.

---

## Interpreting commands

The whole point of this skill: **accept any phrasing.** Users will say "tighten the intro," "the logo's too fast," "kill the second scene," "make it punchier," "add subs," "give it a voiceover," "9:16 for TikTok," "louder," "render." Map intent → operation. The full lookup is in [references/command-map.md](references/command-map.md) — read it when a command doesn't map obviously. The shape of the mapping:

| What they say (any wording) | What you actually do |
| --- | --- |
| trim / cut / shorten / "lose the first N sec" | adjust `data-start` / `data-duration` / `data-media-start`; shift downstream clips |
| slower / faster / "tighten" / "let it breathe" | change `data-duration` and/or GSAP tween durations; re-flow following starts |
| add caption / subtitle / "put text here saying X" | add caption clips synced to audio (transcribe first if needed) |
| voiceover / narration / "have it say X" | `npx hyperframes tts` → wire the `<audio>` clip → optionally transcribe for captions |
| swap / replace music / video / image | drop the asset in, repoint the clip `src`, re-check duration |
| remove / delete / "kill" a scene or element | delete the clip; close the gap on its track |
| reorder / "move scene 3 before 2" | recompute `data-start` values in the new order |
| make it vertical / square / "for TikTok / Reels / YouTube" | change root `data-width`/`data-height`; re-fit layout |
| louder / quieter / mute | `data-volume`; mute video clips that have a separate audio track |
| punch in / zoom / "hold on the product" | GSAP scale/position tween on the clip |
| title card / lower-third / end card | add a new clip (often a sub-composition) at the right time |
| preview / "show me" | `npx hyperframes preview` (background) → hand back the Studio URL |
| render / export / "ship it" | `npx hyperframes render` → report the output path |
| "what's in this?" / "how long is it?" | read the comp, summarize the timeline — no edit |

When a command implies a timing change, **always re-flow the timeline**: a clip getting shorter or longer usually means everything after it on that track must shift, or a gap opens. Reasoning about this is in [references/timeline-editing.md](references/timeline-editing.md).

---

## Handling ambiguity

Editors don't stop the session for every vague note — they make a tasteful call and keep moving. Default to **acting on the most likely reading and stating the assumption**, not interrupting with a question.

- "Make the intro shorter" with no number → cut it by a sensible amount (e.g. ~30%, or to the next natural beat), apply, and say "Trimmed the intro from 4.0s to 2.8s — say a number if you want it tighter."
- "Add a caption here" with a preview open → use the current playhead/most-recent timestamp you discussed; otherwise ask only for the timestamp.
- "Swap the music" with no file → ask for the file (you can't invent an asset), but don't ask anything else.

**Only ask when the command is undecidable or destructive-and-irreversible** — e.g. which of three projects, or "delete everything." One sharp question, then proceed. Never stack up a questionnaire.

---

## Verify before you claim it's done

After any edit:

1. `npx hyperframes lint` — fix every error before reporting. Missing `data-composition-id`, overlapping clips on a track, unregistered timelines all surface here.
2. For edits that move/resize/add visible elements or change the canvas aspect → `npx hyperframes inspect` to catch text overflow and off-canvas content.
3. Only then say it's done. If something still looks off and you couldn't verify it (e.g. subjective motion feel), say so plainly — don't claim a clean result you didn't confirm.

`npm run check` runs lint+validate+inspect together if the project defines it.

---

## Showing the result

- **Preview** is a long-running server — always start it with `run_in_background: true`, never foreground (it will time out and kill the browser preview). Hand back the **Studio** URL, not the raw file: `http://localhost:<port>/#project/<project-name>`.
- **Render** produces the MP4 — report the output path and rough duration. Don't render after every tiny edit; render when the user says ship/export/render, or offer it once the piece feels settled.

---

## What this skill is NOT

- It's not a from-scratch generator. If the user has no video yet and wants one built end-to-end from a script or asset, that's `video-from-script` / `video-from-asset` (or scaffold with `npx hyperframes init` and hand off to the `hyperframes` skill).
- It doesn't re-teach the HyperFrames data model or house style — it leans on the `hyperframes`, `hyperframes-cli`, and `hyperframes-media` skills for that. Invoke them when you need the framework rules; this skill is the editor's chair on top of them.

## References

- [references/command-map.md](references/command-map.md) — exhaustive intent → operation lookup for any phrasing
- [references/timeline-editing.md](references/timeline-editing.md) — re-flowing starts/durations, closing gaps, reordering, aspect changes
- [references/examples.md](references/examples.md) — worked command → edit transcripts
