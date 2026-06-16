#!/bin/bash
# Video Editor skill — Mac installer. Double-click to run.
# Installs the "video-editor" Claude Code skill + its HyperFrames dependencies.

set -u
clear

# Always work from the folder this script lives in (so it finds ./skill).
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; RED=$'\033[0;31m'; BOLD=$'\033[1m'; NC=$'\033[0m'

echo "${BOLD}========================================${NC}"
echo "${BOLD}  Video Editor — Team Installer (Mac)${NC}"
echo "${BOLD}========================================${NC}"
echo

ok=1

# --- 1. Check Node.js ---
echo "1/4  Checking Node.js..."
if command -v node >/dev/null 2>&1; then
  echo "     ${GREEN}OK${NC} — Node $(node -v)"
else
  ok=0
  echo "     ${RED}MISSING${NC} — Node.js is not installed."
  echo "     Opening the download page. Install it, then run this again."
  open "https://nodejs.org/en/download" >/dev/null 2>&1
fi

# --- 2. Check FFmpeg (needed to preview/render video) ---
echo "2/4  Checking FFmpeg..."
if command -v ffmpeg >/dev/null 2>&1; then
  echo "     ${GREEN}OK${NC} — $(ffmpeg -version 2>/dev/null | head -1 | cut -d' ' -f1-3)"
else
  echo "     ${YELLOW}NOT FOUND${NC} — needed to preview/render video."
  echo "     Easiest fix: install Homebrew (brew.sh), then run:  brew install ffmpeg"
  echo "     (You can finish this install now and add FFmpeg later.)"
fi

# --- 3. Install the video-editor skill (from this folder) ---
echo "3/4  Installing the video-editor skill..."
DEST="$HOME/.claude/skills"
mkdir -p "$DEST"
if [ -d "$HERE/skill/video-editor" ]; then
  rm -rf "$DEST/video-editor"
  cp -R "$HERE/skill/video-editor" "$DEST/video-editor"
  echo "     ${GREEN}OK${NC} — copied to ~/.claude/skills/video-editor"
else
  ok=0
  echo "     ${RED}ERROR${NC} — could not find the skill files next to this installer."
  echo "     Make sure you unzipped the whole folder before running."
fi

# --- 4. Install HyperFrames skills (the engine it drives) ---
echo "4/4  Installing HyperFrames skills (downloads once)..."
if command -v node >/dev/null 2>&1; then
  if npx --yes skills add heygen-com/hyperframes -g --all -y >/dev/null 2>&1; then
    echo "     ${GREEN}OK${NC} — HyperFrames skills installed globally."
  else
    echo "     ${YELLOW}COULD NOT AUTO-INSTALL${NC} — check your internet, then later run:"
    echo "       npx skills add heygen-com/hyperframes -g --all -y"
  fi
else
  echo "     ${YELLOW}SKIPPED${NC} — install Node.js first (step 1), then run this again."
fi

echo
if [ "$ok" -eq 1 ]; then
  echo "${GREEN}${BOLD}Done!${NC} The video editor is installed."
else
  echo "${YELLOW}${BOLD}Almost there.${NC} Fix the items marked above, then run this again."
fi
echo
echo "${BOLD}How to use it:${NC}"
echo "  1. Open Claude Code."
echo "  2. Make a new video to edit (one time):"
echo "       npx hyperframes init my-video --example blank --non-interactive"
echo "  3. Go into that folder and start editing in plain English:"
echo "       /video-editor"
echo "       \"add a title that says Hello\""
echo "       \"make it vertical for TikTok\""
echo "       \"show me the preview\""
echo
echo "Press Return to close this window."
read -r _
