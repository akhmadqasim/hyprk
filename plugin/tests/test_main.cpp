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

    // recipes resolved against D (smallest extent, pt), light/dark and the Liquid Glass slider; the full grid is checked
    // against Apple's model by tools/check_model.py (ctest apple_model), these pin the numbers the shell relies on
    {
        const auto& reg = recipeByName("regular");
        auto        r   = resolveMaterial(reg, 40, true);
        CHECK(near(r.refractionHeight, 10, 1e-4) && near(r.refractionAmount, -20, 1e-4) && near(r.blurRadius, 5) &&
              near(r.blurAlpha[0], 0) && near(r.blurAlpha[2], 0.5, 1e-6) && near(r.blurDist0, -20, 1e-4)); // Apple BlurRadius 5, BlurOpacity0 0.8 q
        CHECK(near(r.outerHeight, 16, 1e-5) && near(r.outerAmount, 16, 1e-5) && near(r.outerOpacity, 0.6, 1e-6)); // outer max(0.2 D, 16) / max(0.25 D, 16)
        r = resolveMaterial(reg, 200, true); // clamps: height 20, amount -60; blur 5 x opacity 0.8 / 0.4 / 0.5 over -100 / -1 / 0
        CHECK(near(r.refractionHeight, 20, 1e-4) && near(r.refractionAmount, -60, 1e-4) && near(r.blurRadius, 5, 1e-4) && near(r.blurAlpha[0], 0.8, 1e-6) &&
              near(r.blurAlpha[1], 0.4, 1e-6) && near(r.blurDist0, -100, 1e-4) && near(r.outerHeight, 40, 1e-4) &&
              near(r.outerAmount, 50, 1e-4));
        // face: dark max luma lerp(0.6, 0.35) over D 64 -> 104, light maxLumaSDR 0.94; edge bleed 0.8 / 0.5 x q
        CHECK(near(resolveMaterial(reg, 24, true).maxLuma, 0.6, 1e-6) && near(resolveMaterial(reg, 96, true).maxLuma, 0.4, 1e-6) &&
              near(resolveMaterial(reg, 400, true).maxLuma, 0.35, 1e-6) && near(resolveMaterial(reg, 64, false).maxLuma, 0.94, 1e-6));
        CHECK(near(resolveMaterial(reg, 96, true).bleedOpacity, 0.26667, 1e-4) && near(resolveMaterial(reg, 96, false).bleedOpacity, 0.16667, 1e-4) &&
              near(resolveMaterial(reg, 64, true).bleedOpacity, 0) && near(resolveMaterial(reg, 200, true).bleedAmount, 70, 1e-4));
        CHECK(resolveMaterial(reg, 200, false).bleedLighten && !resolveMaterial(reg, 200, true).bleedLighten);
        // the slider (RegularDiffusionAmount): blur fill, fill, dark max luma; 0.5 = the recipe
        r = resolveMaterial(reg, 64, true, 0);
        CHECK(near(r.blurFill.darken, 0.675, 1e-6) && near(r.blurFill.normal, 0) && near(r.fill.a, 0) && near(r.maxLuma, 0.6, 1e-6));
        r = resolveMaterial(reg, 64, true, 1);
        CHECK(near(r.blurFill.darken, 0.9, 1e-6) && near(r.blurFill.normal, 1) && near(r.fill.r, 0.125, 1e-6) && near(r.fill.a, 0.5, 1e-6));
        CHECK(near(resolveMaterial(reg, 64, false, 0.75).fill.a, 0.35, 1e-6) && near(resolveMaterial(reg, 64, false, 0.25).fill.a, 0.1, 1e-6));
        CHECK(near(resolveMaterial(reg, 200, true, 0).maxLuma, 0.45, 1e-6) && near(resolveMaterial(reg, 200, true, 0.25).maxLuma, 0.4, 1e-6));
        // backdrop scale estimator: 0.5 at D <= 64 below a = 1, 0.25 for panels from a = 0.5, 0.125 at a = 1 (Mac C2 4)
        CHECK(near(resolveMaterial(reg, 64, true, 0.75).backdropScale, 0.5) && near(resolveMaterial(reg, 64, true, 1).backdropScale, 0.125) &&
              near(resolveMaterial(reg, 200, true, 0.5).backdropScale, 0.25) && near(resolveMaterial(reg, 200, false, 0.25).backdropScale, 0.5));
        // rim: dark specular 75 deg dark / 106 light, key spread 80 -> 90 over D 96 -> 191, key amount 0.5, diffuse 0.075
        CHECK(near(resolveMaterial(reg, 64, true).darkSpread, 75) && near(resolveMaterial(reg, 64, false).darkSpread, 106) &&
              near(resolveMaterial(reg, 191, true).keySpread, 90, 1e-4) && near(resolveMaterial(reg, 64, true).diffuseAmount, 0.075, 1e-6));
        // shadow by size: 0.04 + 0.56 q dark, light to 0.4, radius 4 + 20 q, y 8
        r = resolveMaterial(reg, 24, true);
        CHECK(near(r.shadowOpacity, 0.04, 1e-6) && near(r.shadowRadius, 4, 1e-5) && near(r.shadowOffsetY, 8));
        CHECK(near(resolveMaterial(reg, 96, false).shadowOpacity, 0.16, 1e-5) && near(resolveMaterial(reg, 96, true).shadowOpacity, 0.22667, 1e-5) &&
              near(resolveMaterial(reg, 400, true).shadowOpacity, 0.6, 1e-6) && near(resolveMaterial(reg, 400, false).shadowRadius, 24, 1e-5));
        CHECK(hasShadow(reg) && near(resolveMaterial(reg, 400, true, 0).shadowOpacity, 0.6, 1e-6)); // the slider leaves the shadow

        const auto& mn = recipeByName("menu");
        r              = resolveMaterial(mn, 24, false);
        CHECK(near(r.ycc.white, 1.03, 1e-6) && near(r.fill.a, 0.2, 1e-6) && near(r.blurFill.lighten, 0.9, 1e-6) && near(r.shadowOpacity, 0.32, 1e-6) &&
              near(r.shadowRadius, 24, 1e-5) && near(r.shadowOffsetY, 10));
        CHECK(near(resolveMaterial(mn, 24, true).shadowOpacity, 0.36, 1e-6)); // fitted to Q-menubar-28 (Material.cpp)

        // Notification Center: Regular at size class medium (D 166 at any card size), rim = 1.23 x the key band, no diffuse
        const auto& nc = recipeByName("notificationcenter");
        CHECK(std::string{nc.name} == "notificationcenter" && hasShadow(nc) && near(resolveMaterial(nc, 75, true).maxLuma, 0.35, 1e-6) &&
              near(resolveMaterial(nc, 75, false).maxLuma, 0.94, 1e-6) && near(resolveMaterial(nc, 75, true).keyScale, 1.23, 1e-6) &&
              near(resolveMaterial(nc, 75, true).diffuseAmount, 0) && near(resolveMaterial(nc, 75, true).shadowOpacity, 0.21, 1e-6) && near(resolveMaterial(nc, 75, false).shadowOpacity, 0.135, 1e-6) &&
              near(resolveMaterial(nc, 75, true).shadowRadius, 24, 1e-6) &&
              near(resolveMaterial(nc, 75, true).bleedAmount, 0.35 * 166, 1e-4));
        CHECK(std::string{recipeByName("nope").name} == "regular");

        // Clear family: no bleed, no shadow, colours fixed; the slider scales the blur (x 2a) or adds a blur fill (2a - 1)
        const auto& cc = recipeByName("controlcenter");
        for (const bool dark : {false, true}) {
            r = resolveMaterial(cc, 64, dark);
            CHECK(near(r.ycc.black, 0.125, 1e-6) && near(r.ycc.white, 0.8, 1e-6) && near(r.ycc.saturation, 1.2, 1e-6) && near(r.fill.a, 0) &&
                  near(r.darkBias, -0.3, 1e-6) && near(r.darkSpread, 75) && near(r.keyYcc.white, 1.4666, 1e-4) && near(r.maxLuma, 1) && near(r.bleedOpacity, 0));
        }
        CHECK(near(resolveMaterial(cc, 60, true).refractionAmount, -80, 1e-4) && near(resolveMaterial(cc, 30, true).blurAlpha[0], 1, 1e-6) &&
              near(resolveMaterial(cc, 30, true, 0.25).blurRadius, 2, 1e-6) &&
              near(resolveMaterial(cc, 30, true, 0.25).blurAlpha[0], 1, 1e-6) && near(resolveMaterial(cc, 30, true).blurDist0, -100, 1e-4) && near(resolveMaterial(cc, 30, true, 0.75).blurFill.normal, 0.5, 1e-6) &&
              near(resolveMaterial(cc, 30, true, 0.75).ycc.white, 0.8, 1e-6));
        r = resolveMaterial(recipeByName("clear"), 64, false, 0);
        CHECK(near(r.refractionHeight, 20, 1e-4) && near(r.refractionAmount, -41.6, 1e-4) && near(r.blurRadius, 0) && near(r.outerOpacity, 0) && !hasShadow(recipeByName("clear")));
        CHECK(near(resolveMaterial(recipeByName("clear"), 64, false, 1).blurRadius, 0.75, 1e-6) && near(resolveMaterial(recipeByName("clear"), 64, false, 1).blurFill.normal, 1));
        const auto& dock = recipeByName("dock");
        r                = resolveMaterial(dock, 64, true);
        CHECK(near(r.maxLuma, 0.75, 1e-6) && near(r.fill.a, 0.02, 1e-6) && near(r.ycc.saturation, 1.25, 1e-6) && near(r.darkSpread, 75) && near(r.outerOpacity, 0.2, 1e-6) &&
              near(r.outerAmount, 0) && near(r.refractionAmount, -29.88, 1e-4) && near(r.refractionHeight, 13.28, 1e-4) &&
              near(resolveMaterial(dock, 120, true).refractionAmount, -29.88, 1e-4) && near(resolveMaterial(dock, 64, false).ycc.white, 0.9, 1e-6) && !hasShadow(dock));

        // Spotlight (SiriRecipe, not in the verified model): unclamped refraction 0.4 D / -0.72 D, outer 0.4 D at 1.0,
        // blur from 60 pt inside the edge; the slider changes nothing
        const auto& sp = recipeByName("spotlight");
        CHECK(std::string{sp.name} == "spotlight" && !hasShadow(sp) && near(sp.ringOpacity, 0));
        r = resolveMaterial(sp, 60, false);
        CHECK(near(r.refractionHeight, 24, 1e-4) && near(r.refractionAmount, -43.2, 1e-4) && near(r.outerHeight, 24, 1e-4) && near(r.outerAmount, 24, 1e-4) &&
              near(r.outerOpacity, 1) && near(r.bleedOpacity, 0) && near(r.shadowOpacity, 0) && near(r.blurDist0, -60, 1e-4));
        CHECK(near(resolveMaterial(sp, 60, true, 0).blurFill.darken, 0.75, 1e-6) && near(resolveMaterial(sp, 60, true, 1).blurAlpha[0], 1) &&
              near(resolveMaterial(sp, 400, false).refractionAmount, -288, 1e-3));
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
    p.spacing = {{"hyprk-dock", 12}};
    CHECK(near(smoothKFor(p, "hyprk-dock"), 12) && near(smoothKFor(p, "x"), 0));
    p.reduceMotion = true;
    CHECK(near(smoothKFor(p, "hyprk-dock"), 0));
    p.reduceMotion = false;
    p.defaultRadius = 8;
    CHECK(near(radiusFor(p, "hyprk-dock", 12), 8));

    // title bar layout: three 14 pt lights, 7 pt apart, 15 pt in, centred vertically in 32 pt
    {
        auto l = titlebarLayout(600, 32, 14, 7, 15);
        CHECK(near(l.buttons[0].x, 15) && near(l.buttons[1].x, 36) && near(l.buttons[2].x, 57) && near(l.buttons[0].y, 9));
        CHECK(near(l.title.x, 15 + 2 * 21 + 14 + 31) && near(l.title.w, 600 - 15 - 102)); // left-aligned, 31 pt after the lights
        CHECK(near(titlebarLayout(700, 32, 14, 9, 9).title.x, 100)); // Mac TextEdit: lights at 9 / 32 / 55, title at 100
        CHECK(buttonAt(l, 22, 16, 7) == 0 && buttonAt(l, 64, 16, 7) == 2 && buttonAt(l, 300, 16, 7) == -1);
        CHECK(lightsArea(l, 7).containsPoint({40, 16}) && !lightsArea(l, 7).containsPoint({200, 16}));
        CHECK(near(titlebarLayout(100, 32, 14, 7, 15).title.w, 0)); // narrow window: no room for a title
    }
    CHECK(near(rgbaFromHex(0xFF800040).g, 128 / 255.0, 1e-6) && parseTitlebarMode("off") == 0 && parseTitlebarMode("classes") == 2 && parseTitlebarMode("x") == 1);

    // opacity marker: 1x1 in the bottom row, x / (W - 1); removed, other rects kept
    {
        std::vector<SRect> rects = roundedRows(10, 10, 100, 60, 12);
        const size_t       n     = rects.size();
        rects.push_back({639, 719, 1, 1}); // W 1279+1 = 1280 -> x 639 = 0.5
        CHECK(near(takeOpacityMarker(rects, 1280, 720), 639.0 / 1279.0));
        CHECK(rects.size() == n);
        CHECK(near(takeOpacityMarker(rects, 1280, 720), 1)); // none left
        CHECK(rects.size() == n);
        std::vector<SRect> zero = {{0, 719, 1, 1}};
        CHECK(near(takeOpacityMarker(zero, 1280, 720), 0) && zero.empty());
        // a glass shape touching the bottom edge is not a marker
        std::vector<SRect> wide = {{0, 700, 200, 20}};
        CHECK(near(takeOpacityMarker(wide, 1280, 720), 1) && wide.size() == 1);
    }

    // materialize hole: 1x1 gap in the middle row, x = left + 1 + round(m (w - 3))
    {
        auto rows = roundedRows(100, 50, 103, 40, 12);
        CHECK(near(clusterRegion(rows)[0].materialize, 1));
        const SRect  mid = rows[20];                 // y 70, full width 100..203
        const double hx  = 100 + 1 + 25;             // m = 25 / 100
        rows[20].w       = hx - mid.x;
        rows.push_back({hx + 1, mid.y, mid.right() - hx - 1, 1});
        auto shapes = clusterRegion(rows);
        CHECK(shapes.size() == 1 && near(shapes[0].materialize, 0.25) && near(shapes[0].box.w, 103));
        CHECK(std::abs(shapes[0].radius - 12) <= 3);
        // two separate shapes 1 px apart in one row are not a hole
        auto two = clusterRegion({{0, 0, 10, 1}, {11, 0, 10, 1}});
        CHECK(two.size() == 2 && near(two[0].materialize, 1) && near(two[1].materialize, 1));
        CHECK(!shapes[0].regularShadow);
    }

    // shadow marker: 1x1 gap in the row below the middle one (y = top + floor(h / 2) + 1), centre column;
    // with a materialize hole in the middle row both are read, without it materialize stays 1
    {
        auto rows = roundedRows(300, 500, 120, 24, 12); // a 120 x 24 capsule
        CHECK(!clusterRegion(rows)[0].regularShadow);
        auto split = [&](size_t row, double hx) {
            const SRect r = rows[row]; // push_back may move the rows
            rows[row].w   = hx - r.x;
            rows.push_back({hx + 1, r.y, r.right() - hx - 1, 1});
        };
        split(13, 360); // y 513
        auto marked = clusterRegion(rows);
        CHECK(marked.size() == 1 && marked[0].regularShadow && near(marked[0].materialize, 1) && near(marked[0].box.h, 24));
        split(12, 300 + 1 + 39); // y 512: materialize hole at m = 39 / 117
        marked = clusterRegion(rows);
        CHECK(marked.size() == 1 && marked[0].regularShadow && near(marked[0].materialize, 39.0 / 117.0));
    }

    // holes a row off (the shell measured the scaling shape a frame apart from Quickshell's commit): a lone hole at the
    // centre column is the shadow marker even on the middle row (HUD appear read it as materialize 0.5), two hole rows
    // are materialize above shadow wherever they sit, a lone hole elsewhere is materialize
    {
        auto base  = roundedRows(300, 500, 120, 24, 12); // mid = 512, centre column 360
        auto split = [](std::vector<SRect>& rows, size_t row, double hx) {
            const SRect r = rows[row]; // push_back may move the rows
            rows[row].w   = hx - r.x;
            rows.push_back({hx + 1, r.y, r.right() - hx - 1, 1});
        };
        auto rows = base;
        split(rows, 12, 360); // shadow hole on the middle row
        auto s = clusterRegion(rows);
        CHECK(s.size() == 1 && s[0].regularShadow && near(s[0].materialize, 1));
        rows = base;
        split(rows, 14, 361); // one row and one column further
        s = clusterRegion(rows);
        CHECK(s.size() == 1 && s[0].regularShadow && near(s[0].materialize, 1));
        rows = base;
        split(rows, 11, 300 + 1 + 39); // both one row up
        split(rows, 12, 360);
        s = clusterRegion(rows);
        CHECK(s.size() == 1 && s[0].regularShadow && near(s[0].materialize, 39.0 / 117.0));
        rows = base;
        split(rows, 13, 300 + 1 + 90); // lone materialize hole one row down
        s = clusterRegion(rows);
        CHECK(s.size() == 1 && !s[0].regularShadow && near(s[0].materialize, 90.0 / 117.0));
    }

    // groups: shapes closer than k share one smooth-union group, lead = largest area
    {
        std::vector<SGlassShape> s = {{{0, 0, 64, 64}, 16}, {{76, 0, 64, 64}, 16}, {{0, 76, 140, 64}, 16}, {{400, 0, 20, 20}, 4}};
        CHECK(groupShapes(s, 12).size() == 4);        // gap 12 is not < 12: all alone (CC at rest)
        auto g = groupShapes(s, 13);
        CHECK(g.size() == 2 && g[0].members.size() == 3 && g[0].lead == 2 && near(g[0].box.w, 140) && near(g[0].box.h, 140));
        CHECK(groupShapes(s, 0).size() == 4);
        std::vector<SGlassShape> many(10, SGlassShape{{0, 0, 10, 10}, 2});
        CHECK(groupShapes(many, 5).size() == 2);      // capped at MAX_GROUP
    }

    // pointer marker (Dock label): a rect 1 pt below the pill with a 1x1 hole in its top row at left + 1
    {
        std::vector<SRect> rows = {{92, 47, 1, 1}, {94, 47, 14, 1}, {92, 48, 16, 6}};
        auto               s    = clusterRegion(rows);
        const double       h    = POINTER_SIDE * M_SQRT1_2;
        // centre x 100, y = 47 - 1 - 4 = 42: the pill (bottom 46) holds the square's top half
        CHECK(s.size() == 1 && s[0].pointer && !s[0].regularShadow && near(s[0].materialize, 1) && near(s[0].box.x, 100 - h, 1e-9) &&
              near(s[0].box.y, 42 - h, 1e-9) && near(s[0].box.w, 2 * h, 1e-9) && near(s[0].radius, POINTER_RADIUS));
        CHECK(!clusterRegion({{100, 50, 23, 23}})[0].pointer);
        const auto fm = parseFillMap("a:lighter, b:darker, c:other");
        CHECK(fm.size() == 2 && fm.at("a") == 1 && fm.at("b") == -1);
        // pill 26 pt tall above, the pointer's box 3 pt below it: alone at the layer's k 0, one group at 25
        std::vector<SGlassShape> lab = {{{90, 0, 60, 26}, 13}, s[0]};
        lab[1].box = {88, 29, 23, 23};
        CHECK(groupShapes(lab, 0).size() == 1 && near(groupShapes(lab, 0)[0].smoothK, POINTER_SMOOTH) && groupShapes(lab, 0)[0].lead == 0);
        lab[1].pointer = false;
        CHECK(groupShapes(lab, 0).size() == 2 && near(groupShapes(lab, 8)[0].smoothK, 8));
    }

    // mipFootprint: every texel a read in the box touches at that level (bilinear + tent) is refreshed.
    // A read box starting at x 1724 (not a multiple of 128): box + 128 px left part of the level-7
    // texels on its left edge to an older frame
    {
        const auto f = mipFootprint({1724, 0, 836, 310}, 7, 2560, 1664);
        CHECK(near(f.x, 1536) && near(f.y, 0) && near(f.right(), 2560) && near(f.bottom(), 512));
        // brute force: the texels a read at the level touches lie inside the footprint
        for (int level : {0, 3, 5, 7}) {
            const SRect  r{301.5, 77, 223, 95};
            const auto   g = mipFootprint(r, level, 4096, 4096);
            const double t = std::ldexp(1.0, level);
            bool inside = std::fmod(g.x, t) == 0 && std::fmod(g.y, t) == 0; // whole texels at this level
            for (double u : {r.x, r.right(), r.x + 17.25})
                for (double o : {-t / 2, t / 2}) {                      // fetchSharp's tent taps
                    const double k = std::floor((u + o) / t - 0.5); // bilinear: texels k and k + 1
                    inside = inside && k * t >= g.x && (k + 2) * t <= g.right();
                }
            CHECK(inside);
        }
        const auto edge = mipFootprint({0, 0, 50, 50}, 7, 100, 80); // clipped to the texture
        CHECK(near(edge.x, 0) && near(edge.w, 100) && near(edge.h, 80));
    }

    std::printf(g_fail ? "%d failures\n" : "all tests passed\n", g_fail);
    return g_fail ? 1 : 0;
}
