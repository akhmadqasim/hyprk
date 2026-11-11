#pragma once
// Frame transitions Hyprland's single windowsMove leaf cannot express: unzoom (its own curve), full screen enter
// (0.4 s) and full screen exit (AppKit's window curve, 0.5 s). Pure maths, unit tested.
//
// Mac data (MAC-ANSWERS.md R2, 27.2.1, share of the total pixel change per 60 Hz frame):
//   unzoom            0.01 0.05 0.11 0.18 0.28 0.38 0.48 0.56 0.65 0.71 0.77 0.83 0.88 0.92 0.94 0.96 0.98 0.99 1.0
//   full screen enter 0.01 0.03 0.07 0.14 0.24 0.33 0.45 0.59 0.67 0.72 0.77 0.81 0.84 0.87 0.89 0.91 0.93 0.94 0.95
//                     0.96 0.97 0.98 0.99 (then 1)
//   full screen exit  about 0.5 s "in two steps" by eye (no per-frame series).
// REA of 27.2.1 (MOTION-PLUGIN.md "Full screen REA"): Dock answers AppKit's enter/exit request with 0.5 s
// (FUN_100130044 / FUN_10011fa54; NSFullScreenTransitionDuration, default 0.5, is only the NaN fallback), and
// _NSFullScreenTransitionOverlayWindow moves the window frame on functionWithControlPoints(0.25, 0, 0, 1) over that
// duration, the same for enter and exit (0x18a7a4f0c, 0x18a7a54a8). The Space slide beside it is a 0.5 s cosine
// (Dock FUN_1000c60f8) that hyprk does not draw. No hold exists in either path; the recorded "two steps" is the
// front-loaded window curve plus the slide. Exit plays the decoded window curve; enter keeps the recorded series,
// which that curve reproduces within 1-2 frames.
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
