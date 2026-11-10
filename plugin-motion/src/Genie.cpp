#include "Genie.hpp"

#include <algorithm>
#include <cmath>
#include <numbers>

namespace motion {
    double cosEase(double x) {
        x = std::clamp(x, 0.0, 1.0);
        return 0.5 - 0.5 * std::cos(std::numbers::pi * x);
    }

    // Phase lengths are path lengths in points, quantised to 50 pt log steps like the Dock:
    //   bend  L1 = 50 * int(log(max(2*gap, (|dl|+|dr|)/8) / 2 + 1))
    //   slide L2 = 50 * int(log(travel / 2 + 1))
    // and the slide starts L2*acos(1-2q)/pi before the bend ends (q = window height / travel).
    GeniePhases geniePhases(const Rect& window, const Rect& target, double p) {
        const double travel = std::max(1.0, (target.y + target.h) - window.y);
        const double gap    = std::max(0.0, target.y - (window.y + window.h));
        const double dl     = target.x - window.x;
        const double dr     = (target.x + target.w) - (window.x + window.w);

        double       l1 = 50.0 * std::floor(std::log(std::max(2.0 * gap, (std::abs(dl) + std::abs(dr)) / 8.0) * 0.5 + 1.0));
        const double l2 = std::max(50.0, 50.0 * std::floor(std::log(travel * 0.5 + 1.0)));
        const double q  = std::clamp(window.h / travel, 0.0, 1.0);
        const double o  = l2 * std::acos(1.0 - 2.0 * q) / std::numbers::pi;

        double       start = l1 - o;
        if (start <= 0) {
            start = 0;
            l1    = std::max(o, 1.0);
        }
        l1             = std::max(l1, 1.0);
        const double d = (l2 + start) * std::clamp(p, 0.0, 1.0);
        return {.bend = cosEase(d / l1), .slide = cosEase((d - start) / l2)};
    }

    std::vector<Row> genieRows(const Rect& window, const Rect& target, double p, int rows) {
        std::vector<Row> out;
        if (window.w <= 0 || window.h <= 0 || rows < 2)
            return out;

        const auto   ph     = geniePhases(window, target, p);
        const double travel = (target.y + target.h) - window.y;
        const double top    = window.y + travel * ph.slide;               // where the window's top edge is now
        const double bottom = std::min(top + window.h, target.y + target.h);
        if (bottom <= top)
            return out;

        // funnel: 0 at the window's top edge, 1 at the target's top edge, half-cosine in between
        const double span = std::max(1.0, target.y - window.y);
        out.reserve(rows);
        for (int i = 0; i < rows; ++i) {
            const double y = top + (bottom - top) * i / (rows - 1);
            const double b = cosEase((y - window.y) / span) * ph.bend;
            out.push_back({
                .y     = y,
                .left  = window.x + (target.x - window.x) * b,
                .right = window.x + window.w + ((target.x + target.w) - (window.x + window.w)) * b,
                .v     = (y - top) / window.h,
            });
        }
        return out;
    }

    Rect genieExtents(const Rect& a, const Rect& b) {
        const double x0 = std::min(a.x, b.x), y0 = std::min(a.y, b.y);
        const double x1 = std::max(a.x + a.w, b.x + b.w), y1 = std::max(a.y + a.h, b.y + b.h);
        return {x0, y0, x1 - x0, y1 - y0};
    }
}
