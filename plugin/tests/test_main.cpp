// Unit tests for the pure logic (region clustering, SDF, parsing). No framework.
#include "Config.hpp"
#include "Material.hpp"
#include "Shape.hpp"
#include "TitlebarLayout.hpp"

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
    CHECK((splitList("a, ,b, ") == std::vector<std::string>{"a", "b"}));
    {
        auto m = parseNumberMap("hyprk-dock:26, hyprk-menubar:0, bad, x:y, q:1.5");
        CHECK(m.size() == 3 && near(m["hyprk-dock"], 26) && near(m["q"], 1.5));
    }
    {
        auto m = parseStringMap("hyprk-dock:dock, bad, :x, y: ");
        CHECK(m.size() == 1 && m["hyprk-dock"] == "dock");
    }

    // recipes: SPEC 9 values resolved against D (smallest extent, pt)
    {
        const auto& reg = recipeByName("regular");
        auto        r   = resolveMaterial(reg, 40);
        CHECK(near(r.refractionHeight, 10, 1e-4) && near(r.refractionAmount, -20, 1e-4) && near(r.blurRadius, 2)); // blur floor 2 (JUDGE-r2)
        r = resolveMaterial(reg, 200); // clamps: height 20, amount -60, blur 4
        CHECK(near(r.refractionHeight, 20, 1e-4) && near(r.refractionAmount, -60, 1e-4) && near(r.blurRadius, 4, 1e-4));
        CHECK(near(resolveMaterial(reg, 104).blurRadius, 3, 1e-4));
        CHECK(near(recipeByName("dock").light.ycc.white, 0.9, 1e-6));
        CHECK(near(resolveMaterial(recipeByName("controlcenter"), 60).refractionAmount, -80, 1e-4));
        CHECK(std::string{recipeByName("nope").name} == "regular");
        CHECK(near(recipeByName("menu").shadowOpacityHi, 0.6, 1e-6));
    }
    CHECK(near(clampedLinear(48, 48, 160, 0.25, 0.75), 0.25) && near(clampedLinear(104, 48, 160, 0.25, 0.75), 0.5) && near(clampedLinear(500, 48, 160, 0.25, 0.75), 0.75));

    // hysteresis: dark below low, stays dark inside the band, light again above high
    CHECK(!hysteresisDark(false, 0.2, 0.1, 0.3));
    CHECK(hysteresisDark(false, 0.05, 0.1, 0.3));
    CHECK(hysteresisDark(true, 0.2, 0.1, 0.3));
    CHECK(!hysteresisDark(true, 0.35, 0.1, 0.3));

    CHECK(parseAppearance("dark") == 2 && parseAppearance("light") == 1 && parseAppearance("x") == 0);

    SParams p;
    p.materials  = {{"hyprk-dock", "dock"}};
    CHECK(materialFor(p, "hyprk-dock") == "dock" && materialFor(p, "x") == "regular");
    p.namespaces = {"hyprk-dock"};
    p.radii      = {{"hyprk-menubar", 0}};
    CHECK(namespaceMatches(p, "hyprk-dock") && !namespaceMatches(p, "other"));
    p.namespaces = {"*"};
    CHECK(namespaceMatches(p, "other"));
    CHECK(near(radiusFor(p, "hyprk-menubar", 12), 0));
    CHECK(near(radiusFor(p, "hyprk-dock", 12), 12));
    p.defaultRadius = 8;
    CHECK(near(radiusFor(p, "hyprk-dock", 12), 8));

    // title bar layout: three 14 pt lights, 7 pt apart, 15 pt in, centred vertically in 32 pt
    {
        auto l = titlebarLayout(600, 32, 14, 7, 15);
        CHECK(near(l.buttons[0].x, 15) && near(l.buttons[1].x, 36) && near(l.buttons[2].x, 57) && near(l.buttons[0].y, 9));
        CHECK(near(l.title.x, 85) && near(l.title.w, 600 - 170)); // symmetric around the centre
        CHECK(buttonAt(l, 22, 16, 7) == 0 && buttonAt(l, 64, 16, 7) == 2 && buttonAt(l, 300, 16, 7) == -1);
        CHECK(lightsArea(l, 7).containsPoint({40, 16}) && !lightsArea(l, 7).containsPoint({200, 16}));
        CHECK(near(titlebarLayout(100, 32, 14, 7, 15).title.w, 0)); // narrow window: no room for a title
    }
    CHECK(near(rgbaFromHex(0xFF800040).g, 128 / 255.0, 1e-6) && parseTitlebarMode("off") == 0 && parseTitlebarMode("classes") == 2 && parseTitlebarMode("x") == 1);

    std::printf(g_fail ? "%d failures\n" : "all tests passed\n", g_fail);
    return g_fail ? 1 : 0;
}
