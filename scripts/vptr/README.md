vptr drives the pointer of a nested test session through zwlr_virtual_pointer_v1 (real motion, enter and click events; `hyprctl dispatch hl.dsp.cursor.move` only sends the first enter).
Build: `scripts/vptr/build.sh` (prints the binary path). Run it with the TEST session's WAYLAND_DISPLAY: `vptr <layout width> <layout height>`, then stdin lines `x y delay_ms` (global logical position), `b` click, `d` / `u` press / release.
Keep it open on a FIFO for scripted runs: `mkfifo p; tail -f /dev/null > p & vptr 3840 1440 < p &` then `echo "3000 15 0" > p`.
