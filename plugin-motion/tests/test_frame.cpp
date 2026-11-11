#include "Frame.hpp"

#include <cmath>
#include <cstdio>
#include <initializer_list>

static int fails = 0;
#define CHECK(c)                                                                                                                                                                   \
    do {                                                                                                                                                                           \
        if (!(c)) {                                                                                                                                                                \
            std::printf("FAIL %s:%d %s\n", __FILE__, __LINE__, #c);                                                                                                               \
            ++fails;                                                                                                                                                               \
        }                                                                                                                                                                          \
    } while (0)

static bool near(double a, double b, double e = 1e-6) {
    return std::abs(a - b) <= e;
}

int main() {
    using namespace motion::frame;
    constexpr double F = 1.0 / 60.0;

    // the Mac's frames come back exactly at frame times (R2 series)
    CHECK(near(progress(eKind::UNZOOM, 0), 0));
    CHECK(near(progress(eKind::UNZOOM, 1 * F), 0.01));
    CHECK(near(progress(eKind::UNZOOM, 7 * F), 0.48));
    CHECK(near(progress(eKind::UNZOOM, 19 * F), 1));
    CHECK(near(progress(eKind::UNZOOM, 7.5 * F), (0.48 + 0.56) / 2));
    CHECK(near(progress(eKind::FULLSCREEN_ENTER, 8 * F), 0.59));
    CHECK(near(progress(eKind::FULLSCREEN_ENTER, 23 * F), 0.99));
    CHECK(near(progress(eKind::FULLSCREEN_ENTER, 24 * F), 1));
    CHECK(near(duration(eKind::FULLSCREEN_ENTER), 0.4) && near(duration(eKind::UNZOOM), 19 * F));

    // exit: cubic-bezier(0.25, 0, 0, 1) over 0.5 s (AppKit overlay window, Dock duration); 60 Hz samples per REA
    CHECK(near(duration(eKind::FULLSCREEN_EXIT), 0.5));
    CHECK(near(progress(eKind::FULLSCREEN_EXIT, 0.25), cubicBezier(0.25, 0, 0, 1, 0.5)));
    CHECK(near(progress(eKind::FULLSCREEN_EXIT, 5 * F), 0.33, 0.01) && near(progress(eKind::FULLSCREEN_EXIT, 10 * F), 0.72, 0.01));
    CHECK(near(progress(eKind::FULLSCREEN_EXIT, 0.5), 1, 1e-6));

    // every kind is monotonic
    for (auto k : {eKind::UNZOOM, eKind::FULLSCREEN_ENTER, eKind::FULLSCREEN_EXIT}) {
        double last = 0;
        bool   mono = true;
        for (double t = 0; t <= 0.7; t += 0.001) {
            const double p = progress(k, t);
            mono           = mono && p >= last - 1e-12 && p <= 1;
            last           = p;
        }
        CHECK(mono && near(last, 1));
    }

    // speed: Hyprland's percent (elapsed / 100 / speed) equals the progress asked for
    CHECK(near(120.0 / 100.0 / hyprSpeed(120, 0.3), 0.3));
    CHECK(120.0 / 100.0 / hyprSpeed(120, 1) >= 1);
    CHECK(0.0 / 100.0 / hyprSpeed(0, 0) < 1e-6 && 50.0 / 100.0 / hyprSpeed(50, 0) < 1e-4);

    CHECK(near(cubicBezier(0.42, 0, 0.58, 1, 0.5), 0.5, 1e-6) && near(cubicBezier(0, 0, 1, 1, 0.3), 0.3, 1e-6));

    if (fails)
        std::printf("%d failures\n", fails);
    return fails ? 1 : 0;
}
