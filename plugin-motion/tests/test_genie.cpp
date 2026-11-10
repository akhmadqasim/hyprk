#include "Genie.hpp"

#include <cmath>
#include <cstdio>

static int fails = 0;
#define CHECK(c)                                                                                                                                                                   \
    do {                                                                                                                                                                           \
        if (!(c)) {                                                                                                                                                                \
            std::printf("FAIL %s:%d %s\n", __FILE__, __LINE__, #c);                                                                                                               \
            ++fails;                                                                                                                                                               \
        }                                                                                                                                                                          \
    } while (0)

int main() {
    using namespace motion;
    const Rect win{290, 120, 700, 500};
    const Rect icon{900, 770, 48, 48};

    // start: untouched window
    auto r0 = genieRows(win, icon, 0.0, 16);
    CHECK(r0.size() == 16);
    CHECK(std::abs(r0.front().y - win.y) < 1e-6 && std::abs(r0.back().y - (win.y + win.h)) < 1e-6);
    CHECK(std::abs(r0.front().left - win.x) < 1e-6 && std::abs(r0.back().right - (win.x + win.w)) < 1e-6);

    // end: everything inside the icon (no rows left, or rows collapsed onto the icon bottom)
    auto r1 = genieRows(win, icon, 1.0, 16);
    CHECK(r1.empty());

    // phases are monotonic and reach 1
    double lastB = -1, lastS = -1;
    for (int i = 0; i <= 100; ++i) {
        auto ph = geniePhases(win, icon, i / 100.0);
        CHECK(ph.bend >= lastB - 1e-9 && ph.slide >= lastS - 1e-9);
        lastB = ph.bend;
        lastS = ph.slide;
    }
    CHECK(std::abs(lastB - 1) < 1e-9 && std::abs(lastS - 1) < 1e-9);
    // the bend leads the slide
    auto mid = geniePhases(win, icon, 0.3);
    CHECK(mid.bend > mid.slide);

    // half way: rows near the icon are narrower than the window
    auto rh = genieRows(win, icon, 0.5, 32);
    CHECK(!rh.empty());
    CHECK(rh.back().right - rh.back().left < win.w);
    for (auto& r : rh)
        CHECK(r.v >= -1e-9 && r.v <= 1 + 1e-9 && r.right >= r.left);

    auto e = genieExtents(win, icon);
    CHECK(e.x == 290 && e.y == 120 && std::abs(e.x + e.w - 990) < 1e-9 && std::abs(e.y + e.h - 818) < 1e-9);

    std::printf("%s\n", fails ? "FAILED" : "ok");
    return fails ? 1 : 0;
}
