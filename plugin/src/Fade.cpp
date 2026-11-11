#include "Fade.hpp"

#include <algorithm>
#include <cmath>

namespace lg {
    double cubicBezier(double x1, double y1, double x2, double y2, double x) {
        x = std::clamp(x, 0.0, 1.0);
        const auto at = [](double a, double b, double s) { return ((1 - 3 * b + 3 * a) * s + (3 * b - 6 * a)) * s * s + 3 * a * s; };
        double     lo = 0, hi = 1, s = x;
        for (int i = 0; i < 40; ++i) { // bisection: x(s) is monotonic for x1, x2 in 0..1
            s = (lo + hi) / 2;
            (at(x1, x2, s) < x ? lo : hi) = s;
        }
        return at(y1, y2, s);
    }

    double appearanceSnapshotAlpha(double t, double hold, double duration) {
        if (t <= hold)
            return 1;
        if (duration <= 0 || t >= hold + duration)
            return 0;
        return 1 - cubicBezier(0.25, 0.1, 0.25, 1, (t - hold) / duration);
    }
}
