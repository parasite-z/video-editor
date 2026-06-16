# Worked transcripts — command in, edit out

These show the editor's-chair rhythm: interpret → apply → verify → one-line report. They're illustrative, not scripts to recite.

---

### "the intro drags, tighten it up"

1. **Orient:** project `eye-plush-ad`, already known this session. Intro is `#scene1`, `data-start="0" data-duration="4.0"`.
2. **Interpret:** no number given → tighten ~30%, to 2.8s. Following scenes on track 0 start at ≥4.0.
3. **Apply:** set `#scene1` `data-duration="2.8"`; shift every later track-0 clip earlier by 1.2s; scale scene1's GSAP entrance/exit tweens to fit 2.8s.
4. **Verify:** `lint` clean.
5. **Report:** "Tightened the intro 4.0s → 2.8s and pulled everything up 1.2s — total now 18.4s. Want it tighter, or preview it?"

---

### "add a voiceover that says 'Here's what's new' over the first scene"

1. **Interpret:** generate TTS, lay it under scene 1.
2. **Apply:**
   - `npx hyperframes tts "Here's what's new" --voice af_nova --output vo-intro.wav`
   - Add `<audio class="clip" src="vo-intro.wav" data-start="0" data-track-index="3">` (audio track lane).
   - Offer captions: `npx hyperframes transcribe vo-intro.wav` → caption clips.
3. **Verify:** `lint`; confirm VO length ≤ scene 1 duration (extend the hold if it overruns — ask if that changes pacing much).
4. **Report:** "Added an `af_nova` voiceover over scene 1 (1.6s). Want subtitles synced to it?"

---

### "make it vertical for tiktok"

1. **Interpret:** root canvas → 1080×1920; re-fit layouts.
2. **Apply:** set root `data-width="1080" data-height="1920"`; convert any fixed-px `.scene-content` to padding-based full-bleed; bump/reflow headline sizes that now wrap.
3. **Verify:** `npx hyperframes inspect` — fix off-canvas / overflow it reports; then `lint`.
4. **Report:** "Switched to 9:16 (1080×1920) and re-fit all four scenes — inspect is clean. Preview?"

---

### "kill scene 2, it's redundant"

1. **Interpret:** delete `#scene2`, close the gap.
2. **Apply:** remove the clip (and its sub-comp reference if inline-only); pull later track-0 clips earlier by scene2's duration; remove captions/VO tied only to scene 2.
3. **Verify:** `lint`; confirm total dropped by that duration; `inspect` if the surrounding scenes shifted layout.
4. **Report:** "Removed scene 2 (3.1s) and closed the gap — total 15.3s. Transitions into scene 3 still land; preview to confirm the feel?"

---

### "what's even in this video?"

No edit. Read `index.html` + `compositions/*`, then:

> "18.4s, 9:16. Track 0: scene1 hook (0–2.8), scene2 product (2.8–6.0), scene3 demo (6.0–12.0), endcard (12.0–18.4). Track 3: music bed full-length. No voiceover, no captions yet. What do you want to change?"

---

### "set scene 3 to exactly 2.4 seconds" (technical phrasing)

Direct: set `#scene3` `data-duration="2.4"`; reflow downstream; scale its tweens; `lint`. "Done — scene 3 is 2.4s, everything after shifted accordingly."
