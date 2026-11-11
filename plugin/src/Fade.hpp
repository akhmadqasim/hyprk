#pragma once

namespace lg {
    // y of the CSS / CoreAnimation cubic bezier (x1, y1, x2, y2) at time x in 0..1
    double cubicBezier(double x1, double y1, double x2, double y2, double x);

    // Opacity of the old appearance's snapshot t seconds after an appearance switch: 1 while `hold` lasts (the clients
    // repaint under it), then AppKit's NSGlobalPreferenceTransitionOverlay fade: opacity 1 -> 0 as an implicit
    // CoreAnimation animation of `duration` (NSGlobalPreferenceTransitionDuration, 0.5 s) on CA's default timing
    // function (0.25, 0.1, 0.25, 1). 0 from hold + duration on.
    double appearanceSnapshotAlpha(double t, double hold, double duration);
}
