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
        // dark Dock max luma 0.75 (probe), every other face 1 (MAC-ANSWERS "Glass checks (#53)")
        CHECK(near(resolveMaterial(recipeByName("dock"), 84).maxLumaDark, 0.75, 1e-6) && near(resolveMaterial(recipeByName("dock"), 84).maxLumaLight, 1) &&
              near(resolveMaterial(recipeByName("controlcenter"), 300).maxLumaDark, 1));
        // Regular / menu = the 27.2.1 probe `regular`: face, fill, max luma and blur opacities by D
        {
            const auto& mn = recipeByName("menu");
            CHECK(near(mn.light.ycc.white, 1.03, 1e-6) && near(mn.light.fill.a, 0.2, 1e-6) && near(mn.light.blurFill.lighten, 0.9, 1e-6));
            CHECK(near(resolveMaterial(mn, 24).maxLumaDark, 0.6, 1e-6) && near(resolveMaterial(mn, 96).maxLumaDark, 0.4, 1e-6) &&
                  near(resolveMaterial(mn, 112).maxLumaDark, 0.375, 1e-6) && near(resolveMaterial(mn, 400).maxLumaDark, 0.35, 1e-6));
            const auto a96 = resolveMaterial(mn, 96).blurAlpha, a24 = resolveMaterial(mn, 24).blurAlpha, a240 = resolveMaterial(mn, 240).blurAlpha;
            CHECK(near(a96[0], 0.26667, 1e-4) && near(a96[1], 0.13333, 1e-4) && near(a96[2], 0.5, 1e-6) && near(a24[0], 0) && near(a240[0], 0.8, 1e-6));
            CHECK(near(resolveMaterial(recipeByName("controlcenter"), 30).blurAlpha[0], 1, 1e-6));
        }
        CHECK(near(resolveMaterial(recipeByName("controlcenter"), 60).refractionAmount, -80, 1e-4));
        CHECK(std::string{recipeByName("nope").name} == "regular");
        // 27.2.1 probe (reference/re/27.2.1/live/glass-params-*.json): Control Center (also the HUD) is the
        // same face light and dark, no bleed; Clear and Dock as resolved there; key spread 80 -> 90 over D 96 -> 192
        const auto& cc = recipeByName("controlcenter");
        for (const auto* f : {&cc.light, &cc.dark})
            CHECK(near(f->ycc.black, 0.125, 1e-6) && near(f->ycc.white, 0.8, 1e-6) && near(f->ycc.saturation, 1.2, 1e-6) && near(f->fill.a, 0) &&
                  near(f->darkBias, -0.3, 1e-6) && near(f->darkSpread, 75) && near(f->keyYcc.white, 1.4666, 1e-4));
        CHECK(near(cc.blurAlpha[1], 0.1, 1e-6) && near(resolveMaterial(cc, 96).bleedOpacity, 0) && near(resolveMaterial(cc, 160).keySpread, 86.6667, 1e-3));
        r = resolveMaterial(recipeByName("clear"), 64);
        CHECK(near(r.refractionHeight, 20, 1e-4) && near(r.refractionAmount, -41.6, 1e-4) && near(r.blurRadius, 0.75, 1e-6) && near(r.bleedOpacity, 0));
        r = resolveMaterial(recipeByName("dock"), 64);
        CHECK(near(r.refractionHeight, 5.12, 1e-4) && near(r.refractionAmount, -11.52, 1e-4) && near(r.outerAmount, 0) && near(r.bleedOpacity, 0));
        CHECK(near(recipeByName("dock").light.ycc.saturation, 1.25, 1e-6) && near(recipeByName("dock").dark.fill.a, 0.02, 1e-6));
        // drop shadows as measured on macOS 27.2.1 (reference/re/LIVE-27.2.1.md)
        r = resolveMaterial(reg, 24);
        CHECK(near(r.shadowOpacity, 0.04, 1e-6) && near(r.shadowOpacityDark, 0.04, 1e-6) && near(r.shadowRadius, 4, 1e-5));
        r = resolveMaterial(reg, 96);
        CHECK(near(r.shadowOpacity, 0.16, 1e-5) && near(r.shadowOpacityDark, 0.22667, 1e-5) && near(r.shadowRadius, 10.66667, 1e-4));
        r = resolveMaterial(reg, 400);
        CHECK(near(r.shadowOpacity, 0.4, 1e-6) && near(r.shadowOpacityDark, 0.6, 1e-6) && near(r.shadowRadius, 24, 1e-5));
        r = resolveMaterial(recipeByName("menu"), 24);
        CHECK(near(r.shadowOpacity, 0.7, 1e-6) && near(r.shadowOpacityDark, 0.8, 1e-6) && near(r.shadowRadius, 24, 1e-5));
        CHECK(near(recipeByName("menu").shadowOffsetY, 10, 1e-6));
        for (const char* n : {"clear", "dock", "controlcenter"})
            CHECK(!hasShadow(recipeByName(n)) && near(resolveMaterial(recipeByName(n), 200).shadowOpacityDark, 0, 1e-6));
        CHECK(hasShadow(reg));
        // Spotlight = SiriRecipe.SiriModifier branch A (reference/re/NOTES.md): no shadow, no edge bleed, no ring,
        // unclamped refraction 0.4 D / -0.72 D, outer 0.4 D / 0.4 D at 1.0, blur from 60 pt inside the edge
        const auto& sp = recipeByName("spotlight");
        CHECK(std::string{sp.name} == "spotlight" && !hasShadow(sp) && near(sp.ringOpacity, 0));
        r = resolveMaterial(sp, 60);
        CHECK(near(r.refractionHeight, 24, 1e-4) && near(r.refractionAmount, -43.2, 1e-4));
        CHECK(near(r.outerHeight, 24, 1e-4) && near(r.outerAmount, 24, 1e-4) && near(sp.outerOpacity, 1));
        CHECK(near(r.bleedOpacity, 0) && near(r.shadowOpacity, 0) && near(r.shadowOpacityDark, 0));
        CHECK(near(r.blurDist0, -60, 1e-4) && near(sp.blurDist1, -1) && near(sp.blurAlpha[0], 1) && near(sp.blurAlpha[1], 0) && near(sp.blurAlpha[2], 1));
        r = resolveMaterial(sp, 400); // no regular caps, constant blur
        CHECK(near(r.refractionHeight, 160, 1e-3) && near(r.refractionAmount, -288, 1e-3) && near(r.blurRadius, resolveMaterial(sp, 30).blurRadius));
        for (const auto* f : {&sp.light, &sp.dark})
            CHECK(near(f->ycc.black, 0.1, 1e-6) && near(f->ycc.white, 1) && near(f->ycc.saturation, 1.25, 1e-6) && near(f->fill.a, 0) &&
                  near(f->blurFill.darken, 0.75, 1e-6) && near(f->blurFill.normal, 0.5, 1e-6));
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
    p.pointerLightNamespaces = {"hyprk-dock"};
    CHECK(near(smoothKFor(p, "hyprk-dock"), 12) && near(smoothKFor(p, "x"), 0) && pointerLightFor(p, "hyprk-dock") && !pointerLightFor(p, "x"));
    p.reduceMotion = true;
    CHECK(near(smoothKFor(p, "hyprk-dock"), 0) && !pointerLightFor(p, "hyprk-dock"));
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
        auto& mid = rows[20];                        // y 70, full width 100..203
        const double hx = 100 + 1 + 25;              // m = 25 / 100
        rows.push_back({hx + 1, mid.y, mid.right() - hx - 1, 1});
        mid.w = hx - mid.x;
        auto shapes = clusterRegion(rows);
        CHECK(shapes.size() == 1 && near(shapes[0].materialize, 0.25) && near(shapes[0].box.w, 103));
        CHECK(std::abs(shapes[0].radius - 12) <= 3);
        // two separate shapes 1 px apart in one row are not a hole
        auto two = clusterRegion({{0, 0, 10, 1}, {11, 0, 10, 1}});
        CHECK(two.size() == 2 && near(two[0].materialize, 1) && near(two[1].materialize, 1));
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

    std::printf(g_fail ? "%d failures\n" : "all tests passed\n", g_fail);
    return g_fail ? 1 : 0;
}
