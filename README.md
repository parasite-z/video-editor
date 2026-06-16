# video-editor

A **generic, conversational video-editing skill** for HeyGen [HyperFrames](https://hyperframes.heygen.com). Where `/video-from-script` and `/video-from-asset` build a video start-to-finish from one input, `/video-editor` puts Claude in the **editor's chair** over a video that already exists: you give any free-form command, in any style, and it translates that to a concrete HyperFrames edit, applies it, verifies, and shows the result.

## Install (one-time, per machine)

**Prerequisites:** [Claude Code](https://claude.com/claude-code), [Node.js 22+](https://nodejs.org), and FFmpeg.

Then run these two lines in a terminal:

```bash
npx skills add heygen-com/hyperframes -g --all -y   # the HyperFrames engine + skills
npx skills add parasite-z/video-editor -g --all -y  # this editor skill
```

That's it — `/video-editor` is now available in every Claude Code session. To update later, re-run the second line.

> 🇹🇭 ดูคู่มือภาษาไทยที่ [README.th.md](README.th.md). For non-technical teammates who'd rather double-click than use a terminal, see [`team-installer/`](team-installer/).

## Use it

In a Claude Code session inside a HyperFrames project (or a folder with one):

```
/video-editor
```

Then just talk to it like an editor:

- "cut the first 2 seconds"
- "make scene 3 slower"
- "add a caption here that says 'New drop'"
- "swap the music for this file"
- "punch in on the product shot"
- "make it vertical for TikTok"
- "louder voiceover"
- "what's in this video?"
- "render it"

It stays in an editing loop — command, edit, show, repeat — until you're done.

## How it works

It's a thin editor layer on top of the existing HyperFrames skills:

- **`hyperframes`** — the data model, house style, caption/TTS/transition patterns
- **`hyperframes-cli`** — `init` / `lint` / `inspect` / `preview` / `render`
- **`hyperframes-media`** — `tts` / `transcribe` / `remove-background`

This skill adds: free-form command interpretation, timeline re-flow logic, and the verify-before-claiming loop. The framework rules stay in the skills above; this one decides *what edit a command means* and *how it ripples through the timeline*.

## Layout

```
.claude/skills/video-editor/
  SKILL.md                      # the editor loop + command interpretation
  references/
    command-map.md              # any phrasing → concrete operation
    timeline-editing.md         # re-flow, gaps, reorder, aspect changes
    examples.md                 # worked command → edit transcripts
```

## Install in another project

The skill lives under `.claude/skills/`, so it's available in any session opened in this folder. To use it elsewhere, copy or symlink `.claude/skills/video-editor` into that project's `.claude/skills/`, or into `~/.claude/skills/` to make it global.

> Requires the `hyperframes` family of skills to be installed (`npx hyperframes skills`), Node ≥ 22, and FFmpeg.
