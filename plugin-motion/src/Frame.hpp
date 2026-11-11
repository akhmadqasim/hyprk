#pragma once
// Frame transitions Hyprland's single windowsMove leaf cannot express: unzoom (its own curve), full screen enter
// (0.4 s) and full screen exit (two steps with a hold). Pure maths, unit tested.
//
// Mac data (MAC-ANSWERS.md R2, 27.2.1, share of the total pixel change per 60 Hz frame):
//   unzoom            0.01 0.05 0.11 0.18 0.28 0.38 0.48 0.56 0.65 0.71 0.77 0.83 0.88 0.92 0.94 0.96 0.98 0.99 1.0
//   full screen enter 0.01 0.03 0.07 0.14 0.24 0.33 0.45 0.59 0.67 0.72 0.77 0.81 0.84 0.87 0.89 0.91 0.93 0.94 0.95
//                     0.96 0.97 0.98 0.99 (then 1)
//   full screen exit  about 0.5 s in two steps: 0.15 s to 0.47, a 0.15 s hold, the rest over 0.3 s (no per-frame
//                     series; the shape inside each step is not in the data: ease-in-out (0.42, 0, 0.58, 1), the
//                     NSAnimation default, is used for both steps)
// The series are played back as measured (piecewise linear between the frames, frame k at k / 60 s).

namespace motion::frame {
    enum class eKind {
        UNZOOM,
        FULLSCREEN_ENTER,
        FULLSCREEN_EXIT,
    };

    // seconds until progress() reaches 1
    double duration(eKind kind);

    // share of the way from the old frame to the new one at t seconds, 0..1, monotonic
    double progress(eKind kind, double t);

    // Hyprland speed (units of 100 ms) for a "linear" curve so that an animation started elapsedMs ago shows p:
    // percent = (elapsed / 100) / speed = p. A hold is a speed that grows with time.
    double hyprSpeed(double elapsedMs, double p);

    // cubic-bezier(x1, y1, x2, y2) at x (CSS timing function)
    double cubicBezier(double x1, double y1, double x2, double y2, double x);
}
