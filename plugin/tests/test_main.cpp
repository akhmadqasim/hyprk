// Unit tests for the pure logic (region clustering, SDF, parsing). No framework.
#include "Config.hpp"
#include "Shape.hpp"

#include <cmath>
#include <cstdio>

static int g_fail = 0;
#define CHECK(cond)                                                                                                                                                                \
    do {                                                                                                                                                                           \
        if (!(cond)) {                                                                                                                                                             \
            std::printf("FAIL %s:%d  %s\n", __FILE__, __LINE__, #cond);                                                                                                            \
            ++g_fail;                                                                                                                                                              \
        }                                                                                                                                                                          \
    } while (0)
static bool near(double a, double b, double eps = 1e-6) {
    return std::abs(a - b) <= eps;
}

// rasterise a rounded rect into per-row rects, like a wl_region from Quickshell
static std::vector<lg::SRect> roundedRows(double x, double y, double w, double h, double r) {
    std::vector<lg::SRect> out;
    for (int row = 0; row < h; ++row) {
        const double cy    = row + 0.5;
        double       inset = 0;
        const double dy    = cy < r ? r - cy : (cy > h - r ? cy - (h - r) : 0);
        if (dy > 0)
            inset = r - std::sqrt(std::max(r * r - dy * dy, 0.0));
        inset = std::round(inset);
        out.push_back({x + inset, y + row, w - 2 * inset, 1});
    }
    return out;
}

int main() {
    using namespace lg;

    // one rounded rect -> one shape, radius close to the real one
    {
        auto shapes = clusterRegion(roundedRows(100, 50, 400, 70, 20));
        CHECK(shapes.size() == 1);
        CHECK(near(shapes[0].box.x, 100) && near(shapes[0].box.y, 50) && near(shapes[0].box.w, 400) && near(shapes[0].box.h, 70));
        CHECK(std::abs(shapes[0].radius - 20) <= 3);
    }
    // two separate cards -> two shapes; plain rect -> radius 0
    {
        auto rects = roundedRows(0, 0, 300, 80, 16);
        rects.push_back({0, 100, 300, 60});
        auto shapes = clusterRegion(rects);
        CHECK(shapes.size() == 2);
        CHECK(near(shapes[1].box.y, 100) && near(shapes[1].radius, 0));
    }
    // corner-only contact does not merge; empty rects ignored
    {
        auto shapes = clusterRegion({{0, 0, 10, 10}, {10, 10, 10, 10}, {50, 50, 0, 5}});
        CHECK(shapes.size() == 2);
    }
    // pill: radius clamps to half height
    {
        auto shapes = clusterRegion(roundedRows(0, 0, 200, 40, 30));
        CHECK(shapes.size() == 1 && shapes[0].radius <= 20);
    }

    // SDF: centre is -half of the short side, edge 0, outside positive, corner circle
    CHECK(near(sdRoundedBox(0, 0, 50, 20, 10, 2), -20));
    CHECK(near(sdRoundedBox(50, 0, 50, 20, 10, 2), 0));
    CHECK(near(sdRoundedBox(60, 0, 50, 20, 10, 2), 10));
    CHECK(near(sdRoundedBox(40 + 10 / std::sqrt(2.0), 10 + 10 / std::sqrt(2.0), 50, 20, 10, 2), 0, 1e-9));
    // higher power pushes the corner outward (squircle): corner diagonal point is inside
    CHECK(sdRoundedBox(40 + 10 / std::sqrt(2.0), 10 + 10 / std::sqrt(2.0), 50, 20, 10, 4) < 0);

    // bevel: 1 at the edge, 0 at full depth, monotonic
    CHECK(near(bevel(0, 10), 1));
    CHECK(near(bevel(10, 10), 0));
    CHECK(near(bevel(20, 10), 0));
    CHECK(bevel(2, 10) > bevel(5, 10));
    CHECK(near(bevel(3, 0), 0));

    // parsing
    CHECK((splitList(" a, b ,,c ") == std::vector<std::string>{"a", "b", "c"}));
    {
        auto m = parseNumberMap("hyprk-dock:26, hyprk-menubar:0, bad, x:y, q:1.5");
        CHECK(m.size() == 3 && near(m["hyprk-dock"], 26) && near(m["q"], 1.5));
    }
    {
        auto c = colorFromRGBA(0xFF800040);
        CHECK(near(c.r, 1) && near(c.g, 128 / 255.0, 1e-6) && near(c.b, 0) && near(c.a, 64 / 255.0, 1e-6));
    }
    CHECK(parseAppearance("dark") == 2 && parseAppearance("light") == 1 && parseAppearance("x") == 0);

    SParams p;
    p.namespaces = {"hyprk-dock"};
    p.radii      = {{"hyprk-menubar", 0}};
    CHECK(namespaceMatches(p, "hyprk-dock") && !namespaceMatches(p, "other"));
    p.namespaces = {"*"};
    CHECK(namespaceMatches(p, "other"));
    CHECK(near(radiusFor(p, "hyprk-menubar", 12), 0));
    CHECK(near(radiusFor(p, "hyprk-dock", 12), 12));
    p.defaultRadius = 8;
    CHECK(near(radiusFor(p, "hyprk-dock", 12), 8));

    std::printf(g_fail ? "%d failures\n" : "all tests passed\n", g_fail);
    return g_fail ? 1 : 0;
}
