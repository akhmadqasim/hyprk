#pragma once
// macOS Dock "genie" minimize, recovered from Dock.app (macOS 27.2):
// WAGenieAnimation::perform 0x10006933c (see liquid-glass-re/SPEC.md 11.3).
// Pure math: no compositor types, so it can be unit tested.
#include <vector>

namespace motion {
    struct Rect {
        double x = 0, y = 0, w = 0, h = 0;
    };

    // One horizontal mesh row: screen y, left and right edge, and the texture v (0 = window top).
    struct Row {
        double y, left, right, v;
    };

    // The two eased phases of the genie at linear progress p (0..1):
    // bend (edges pull toward the icon) and slide (content travels into the icon).
    struct GeniePhases {
        double bend  = 0;
        double slide = 0;
    };

    double      cosEase(double x);
    GeniePhases geniePhases(const Rect& window, const Rect& target, double p);

    // Rows of the warped window for a Dock at the bottom of the screen. Rows below the
    // target's bottom edge are already inside the icon and are left out.
    std::vector<Row> genieRows(const Rect& window, const Rect& target, double p, int rows);

    // Union of window and target: everything the genie can touch.
    Rect genieExtents(const Rect& window, const Rect& target);
}
