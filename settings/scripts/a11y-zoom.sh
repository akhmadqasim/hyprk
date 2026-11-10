#!/usr/bin/env bash
# Accessibility > Zoom: step Hyprland's cursor zoom like macOS Option-Cmd-8 / = / -.
# Usage: a11y-zoom.sh toggle|in|out|off
# x1.25 per step, 1..10, toggle 1 <-> 2, off = 1.
set -u
# `hyprctl getoption` prints "float: 2.000000"; awk reads it and computes the step (no jq:
# the scroll gesture runs this on every wheel tick)
next=$(hyprctl getoption cursor:zoom_factor 2>/dev/null | awk -v d="${1:-toggle}" '
    /^float:/ { z = $2; found = 1 }
    END {
    if (!found) exit 3
    if (z < 1) z = 1
    if (d == "toggle") n = (z > 1) ? 1 : 2
    else if (d == "in") n = z * 1.25
    else if (d == "out") n = z / 1.25
    else n = 1
    if (n < 1) n = 1; if (n > 10) n = 10
    printf "%.2f", n }') || exit 3
exec hyprctl eval "hl.config({ cursor = { zoom_factor = $next } })" >/dev/null
