@echo off
REM Video Editor skill - Windows installer. Double-click to run.
REM Installs the "video-editor" Claude Code skill + its HyperFrames dependencies.
setlocal enabledelayedexpansion
cd /d "%~dp0"
cls

echo ========================================
echo   Video Editor - Team Installer (Windows)
echo ========================================
echo.

set OK=1

REM --- 1. Check Node.js ---
echo 1/4  Checking Node.js...
where node >nul 2>&1
if %errorlevel%==0 (
  for /f "delims=" %%v in ('node -v') do echo      OK - Node %%v
) else (
  set OK=0
  echo      MISSING - Node.js is not installed.
  echo      Opening the download page. Install it, then run this again.
  start "" "https://nodejs.org/en/download"
)

REM --- 2. Check FFmpeg ---
echo 2/4  Checking FFmpeg...
where ffmpeg >nul 2>&1
if %errorlevel%==0 (
  echo      OK - FFmpeg found
) else (
  echo      NOT FOUND - needed to preview/render video.
  echo      Easiest fix: open PowerShell and run:  winget install Gyan.FFmpeg
  echo      ^(You can finish this install now and add FFmpeg later.^)
)

REM --- 3. Install the video-editor skill ---
echo 3/4  Installing the video-editor skill...
set "DEST=%USERPROFILE%\.claude\skills"
if not exist "%DEST%" mkdir "%DEST%"
if exist "%~dp0skill\video-editor\SKILL.md" (
  if exist "%DEST%\video-editor" rmdir /s /q "%DEST%\video-editor"
  xcopy "%~dp0skill\video-editor" "%DEST%\video-editor\" /e /i /q >nul
  echo      OK - copied to %%USERPROFILE%%\.claude\skills\video-editor
) else (
  set OK=0
  echo      ERROR - could not find the skill files next to this installer.
  echo      Make sure you unzipped the whole folder before running.
)

REM --- 4. Install HyperFrames skills ---
echo 4/4  Installing HyperFrames skills ^(downloads once^)...
where node >nul 2>&1
if %errorlevel%==0 (
  call npx --yes skills add heygen-com/hyperframes -g --all -y >nul 2>&1
  if !errorlevel!==0 (
    echo      OK - HyperFrames skills installed globally.
  ) else (
    echo      COULD NOT AUTO-INSTALL - check internet, then later run:
    echo        npx skills add heygen-com/hyperframes -g --all -y
  )
) else (
  echo      SKIPPED - install Node.js first ^(step 1^), then run this again.
)

echo.
if "%OK%"=="1" (
  echo Done! The video editor is installed.
) else (
  echo Almost there. Fix the items marked above, then run this again.
)
echo.
echo How to use it:
echo   1. Open Claude Code.
echo   2. Make a new video to edit ^(one time^):
echo        npx hyperframes init my-video --example blank --non-interactive
echo   3. Go into that folder and start editing in plain English:
echo        /video-editor
echo        "add a title that says Hello"
echo        "make it vertical for TikTok"
echo        "show me the preview"
echo.
pause
