# Contributing

## Before you start

- Open an issue first for anything bigger than a small fix.
- One change per pull request.
- You must understand every line you submit and be able to explain it.

## Build and run

Needs Hyprland 0.57+, Quickshell 0.3+, Qt 6.8+, CMake and Ninja.

    cmake -S plugin -B plugin/build -G Ninja && cmake --build plugin/build
    dist/try-nested.sh          # hyprk in a window on your current desktop

## Tests

Run these before you open a pull request:

    node shell/tests/run.mjs
    node --test settings/tests/*.test.js
    QT_QPA_PLATFORM=offscreen qmltestrunner -import ui -input ui/tests   # shared HyprK controls
    ctest --test-dir plugin/build

If you change something visual, add a before/after screenshot to the pull request.

## Matching macOS

Numbers like sizes, radii, colours and timings must come from somewhere.
Name the source in a comment or in the pull request: a reference screenshot, a measurement
on a real Mac, or a value from `SPEC.md`. If you guessed, say so.

Every feature needs a fallback when it isn't supported (no plugin, Reduce Transparency,
Reduce Motion, missing service). Check the `FALLBACKS.md` next to the code you change.

## Commits

Short subject that starts with the area, for example `dock: fix separator height`.
Areas: `shell`, `settings`, `finder`, `ui`, `plugin`, `config`, `themes`, `dist`, `packaging`, `re`.

## Assets

This repo is private because it holds Apple fonts, icons, cursors, wallpapers and sounds.
Never make it public and never copy those files into a public repo or package.
