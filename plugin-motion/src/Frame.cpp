#include "Frame.hpp"

#include <algorithm>
#include <array>
#include <cmath>
#include <span>

namespace motion::frame {
    namespace {
        constexpr double FRAME = 1.0 / 60.0;

        // MAC-ANSWERS.md R2 (27.2.1) per-frame series, frame 1 first; frame 0 (the trigger) is 0
        constexpr std::array<double, 19> UNZOOM_SERIES = {0.01, 0.05, 0.11, 0.18, 0.28, 0.38, 0.48, 0.56, 0.65, 0.71,
                                                          0.77, 0.83, 0.88, 0.92, 0.94, 0.96, 0.98, 0.99, 1.0};
        constexpr std::array<double, 24> ENTER_SERIES  = {0.01, 0.03, 0.07, 0.14, 0.24, 0.33, 0.45, 0.59, 0.67, 0.72, 0.77, 0.81,
                                                          0.84, 0.87, 0.89, 0.91, 0.93, 0.94, 0.95, 0.96, 0.97, 0.98, 0.99, 1.0};

        // exit: AppKit's window frame curve over the Dock's 0.5 s (Frame.hpp)
        constexpr double EXIT_DURATION = 0.5;

        double series(std::span<const double> s, double t) {
            if (t <= 0)
                return 0;
            const double k = t / FRAME; // frame index, frame 0 = 0
            const size_t i = size_t(std::floor(k));
            if (i >= s.size())
                return 1;
            const double a = i == 0 ? 0.0 : s[i - 1];
            return a + (s[i] - a) * (k - double(i));
        }
    }

    double cubicBezier(double x1, double y1, double x2, double y2, double x) {
        x = std::clamp(x, 0.0, 1.0);
        const auto bez = [](double p1, double p2, double t) {
            const double u = 1 - t;
            return 3 * u * u * t * p1 + 3 * u * t * t * p2 + t * t * t;
        };
        double lo = 0, hi = 1, t = x;
        for (int i = 0; i < 40; ++i) { // x(t) is monotonic for x1, x2 in [0, 1]
            t = (lo + hi) / 2;
            (bez(x1, x2, t) < x ? lo : hi) = t;
        }
        return bez(y1, y2, (lo + hi) / 2);
    }

    double duration(eKind kind) {
        switch (kind) {
            case eKind::UNZOOM: return UNZOOM_SERIES.size() * FRAME;
            case eKind::FULLSCREEN_ENTER: return ENTER_SERIES.size() * FRAME;
            case eKind::FULLSCREEN_EXIT: return EXIT_DURATION;
        }
        return 0;
    }

    double progress(eKind kind, double t) {
        switch (kind) {
            case eKind::UNZOOM: return series(UNZOOM_SERIES, t);
            case eKind::FULLSCREEN_ENTER: return series(ENTER_SERIES, t);
            case eKind::FULLSCREEN_EXIT: return t <= 0 ? 0 : cubicBezier(0.25, 0, 0, 1, t / EXIT_DURATION);
        }
        return 1;
    }

    double hyprSpeed(double elapsedMs, double p) {
        if (p >= 1)
            return std::max(elapsedMs, 1.0) / 100.0 / 2.0; // percent 2: done
        if (p <= 1e-4 || elapsedMs <= 0)
            return 1e6; // percent ~0
        return elapsedMs / 100.0 / p;
    }
}
