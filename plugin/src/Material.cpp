#include "Material.hpp"

#include <algorithm>

namespace lg {

    namespace {
        // Rim (every recipe), from the 27.2.1 probe (reference/re/27.2.1/live/glass-params-*.json) and the HUD
        // pixels (reference/screens/27.2.1/hud-*.png): a thin dark line where the edge faces sideways (the glass
        // filter's key highlight with a negative colourBias, keyed horizontally) and a bright key/fill highlight
        // top and bottom (a CASDFKeyFillHighlightEffect layer under a vibrantColorMatrix). SFace holds the
        // per-recipe numbers; the shape of the bands is in shaders/liquidglass.frag.
        constexpr SRgba WHITE12 = {1, 1, 1, 0.12f};

        // Clear-family edge bleed colour (SPEC 9.3)
        constexpr SYcc CLEAR_BLEED = {0.75f, 1.f, 1.2f};
        // key/fill highlight target of Clear and Control Center: matrix rows (1.3192, -0.0478, -0.0047 | 0.2)
        constexpr SYcc CLEAR_KEY = {0.2f, 1.4666f, 1.3334f};

        // SPEC 9.2 RegularBase, V2. Used by menus, notifications, sidebars. Light saturation 1.2 -> 1.0:
        // the decoded value read too cyan over the Tahoe wallpapers (JUDGE.md).
        // Regular over a white window read as opaque white (JUDGE-r2): white point 1.03 -> 0.92, fill
        // 0.2 -> 0.12, blur-fill lighten 0.9 -> 0.4, at least 2 extra blur, and the variable blur keeps
        // full strength until 1 pt from the edge (alpha 0.15 / 0.85 instead of 0.5 / 0.5).
        // Drop shadow = the SRecipe defaults, measured on macOS 27.2.1 (LIVE-27.2.1.md): opacity 0.04 -> 0.4
        // (dark 0.6) and radius 4 -> 24 over D 64 -> 160, y 8. Ring shadow V2 (8, 4, 5, 0.06).
        // Rim (probe): dark specular -0.25, spread 96 deg light / 75 deg dark; highlight target from the matrix
        // rows (1.1202, -0.1894, -0.019 | 0.1471), the SFace default.
        constexpr SRecipe REGULAR = {
            .name         = "regular",
            .light        = {.ycc = {0.4f, 0.92f, 1.0f}, .fill = WHITE12, .bleed = {0.9f, 1.f, 1.2f}, .blurFill = {0.4f, 0, 0.5f}},
            .dark         = {.ycc = {0.125f, 1.125f, 1.3f}, .fill = {}, .bleed = {0.125f, 0.5f, 1.f}, .blurFill = {0, 0.9f, 0.5f}, .darkSpread = 75},
            .outerHeightN = 0.2f,
            .outerAmountN = 0.25f,
            .outerOpacity = 0.6f,
            .blurD0 = 48, .blurD1 = 160, .blurLo = 2, .blurHi = 4,
            .blurAlpha = {1, 0.15f, 0.85f},
            .ringOffsetY = 8, .ringStroke = 4, .ringRadius = 5, .ringOpacity = 0.06f,
        };

        // no drop shadow and no edge bleed: both measured 0 for Clear, Dock and Control Center on macOS 27.2.1
        // (LIVE-27.2.1.md; inputBleedOpacity 0 at every D in glass-params-*.json)
#define LG_NO_SHADOW .bleedOpacityLo = 0, .bleedOpacityHi = 0, .shadowOpacityLo = 0, .shadowOpacityHi = 0, .shadowOpacityHiDark = 0

        // Clear as resolved on 27.2.1 (probe `clear`; SPEC 9.3's base + the ClearSpec.Modifier branch whose
        // condition was not identified): face (0.125, 1.08, 1.06), no fill, blur 0.75, inner refraction
        // 0.36 D max 20 / -0.65 D min -60, no outer layer, rim -0.25 at 75 deg.
        constexpr SRecipe CLEAR = {
            .name              = "clear",
            .light             = {.ycc = {0.125f, 1.08f, 1.06f}, .fill = {}, .bleed = CLEAR_BLEED, .keyYcc = CLEAR_KEY, .darkSpread = 75},
            .dark              = {.ycc = {0.125f, 1.08f, 1.06f}, .fill = {}, .bleed = CLEAR_BLEED, .keyYcc = CLEAR_KEY, .darkSpread = 75},
            .refractionHeightN = 0.36f,
            .refractionAmountN = -0.65f,
            .blurLo = 0.75f, .blurHi = 0.75f, // constant
            LG_NO_SHADOW,
        };

        // Dock as resolved on 27.2.1 (probe `dock`, = SPEC 9.5 DockRecipe.Other V2): face light (0.15, 0.9, 1.25),
        // dark (0.05, 0.92, 1.25) + black 2 %; blur 1.5; inner 0.08 D / -0.18 D; outer layer opacity 0.2 with no
        // displacement (outer height and amount 0); rim -0.25 at 120 deg, highlight target light (0.2, 1.2, 1.333),
        // dark (0.25, 0.95, 1.2). The light face matches the real Dock (MAC-ANSWERS Q-dock-01: white 229, black 38,
        // grey 127 -> 134). Dark: max luma 0.75 (probe) bends the face to the Mac's 176 / 107 / 12 over white / grey
        // 127 / black (MAC-ANSWERS "Glass checks (#53)"); the 0.92 white alone gave 228 / 119 / 12.
        constexpr SRecipe DOCK = {
            .name              = "dock",
            .light             = {.ycc = {0.15f, 0.9f, 1.25f}, .fill = {}, .bleed = CLEAR_BLEED, .keyYcc = {0.2f, 1.2f, 1.3334f}, .darkSpread = 120},
            .dark              = {.ycc = {0.05f, 0.92f, 1.25f}, .fill = {0, 0, 0, 0.02f}, .bleed = CLEAR_BLEED, .keyYcc = {0.25f, 0.95f, 1.2f}, .darkSpread = 120, .maxLuma = 0.75f},
            .refractionHeightN = 0.08f,
            .refractionAmountN = -0.18f,
            .outerOpacity      = 0.2f,
            .blurLo = 1.5f, .blurHi = 1.5f, // constant
            LG_NO_SHADOW,
        };

        // SPEC 9.5 Control Center, Mac, V2 = the 27.2.1 probe `controlCenter`, light and dark alike: face
        // (0.125, 0.8, 1.2), no fill; blur distances (-100, -1, 0, 0) with opacities (1, 0.1, 0.5, 1);
        // inner 0.225 D max 25 / -2.0 D min -80; outer 0.0357 D / 0.0714 D at 0.1525; rim -0.3 at 75 deg.
        // Also the volume/brightness HUD (SystemBannerUI _Glass.controlCenter): over the Electric Blue
        // wallpaper (69, 83, 206) this face gives (68, 85, 232), the Mac's reading (MAC-ANSWERS "HUD").
        // Apple's blur 4 rides on Hyprland's already strong blur here and wiped out the wallpaper
        // shapes the reference shows through the tiles (JUDGE-r4): no extra blur, the variable
        // blur (from 100 pt inside the edge) still softens the middle
        constexpr SFace CONTROLCENTER_FACE = {.ycc = {0.125f, 0.8f, 1.2f}, .fill = {}, .bleed = CLEAR_BLEED, .keyYcc = CLEAR_KEY, .darkBias = -0.3f, .darkSpread = 75};
        constexpr SRecipe CONTROLCENTER = {
            .name                = "controlcenter",
            .light               = CONTROLCENTER_FACE,
            .dark                = CONTROLCENTER_FACE,
            .refractionHeightN   = 0.225f,
            .refractionHeightMax = 25,
            .refractionAmountN   = -2.0f,
            .refractionAmountMin = -80,
            .outerHeightN        = 0.0357f,
            .outerAmountN        = 0.0714f,
            .outerOpacity        = 0.1525f,
            .blurLo = 0, .blurHi = 0,
            .blurDist0N = 0, .blurDist0Fixed = -100,
            .blurAlpha      = {1, 0.1f, 0.5f},
            LG_NO_SHADOW,
        };
        constexpr SRecipe SPOTLIGHT = {
            .name                = "spotlight",
            .light               = {.ycc = {0.1f, 1.0f, 1.25f}, .fill = {}, .bleed = {0.9f, 1.f, 1.2f}, .blurFill = {0.4f, 0.75f, 0.5f}, .darkSpread = 75},
            .dark                = {.ycc = {0.1f, 1.0f, 1.25f}, .fill = {}, .bleed = {0.125f, 0.5f, 1.f}, .blurFill = {0, 0.75f, 0.5f}, .darkSpread = 75},
            .refractionHeightN   = 0.4f,
            .refractionHeightMax = 1e6f,
            .refractionAmountN   = -0.72f,
            .refractionAmountMin = -1e6f,
            .outerHeightN        = 0.4f,
            .outerAmountN        = 0.4f,
            .outerOpacity        = 1.0f,
            .blurLo = 6, .blurHi = 6, // constant: Apple 8 x 0.75 (see above)
            .blurDist0N = 0, .blurDist0Fixed = -60, .blurDist1 = -1,
            .blurAlpha      = {1, 0, 1},
            LG_NO_SHADOW,
        };
#undef LG_NO_SHADOW

        // Regular + the Mac glass menu shadow, the same at every size. Measured on macOS 27.2.1
        // (LIVE-27.2.1.md): 0.7 light, 0.8 dark, radius 24, y 10. A real alert has 0.6 / 0.7 (SPEC 9.5), but
        // the shell draws alerts in the same layer as menus (hyprk-overlay:menu), so they get this one too
        constexpr SRecipe MENU = [] {
            SRecipe r   = REGULAR;
            r.name      = "menu";
            r.shadowD0  = r.shadowD1 = 0;
            r.shadowOpacityLo = r.shadowOpacityHi = 0.7f;
            r.shadowOpacityHiDark                 = 0.8f;
            r.shadowRadiusLo                      = r.shadowRadius;
            r.shadowOffsetY                       = 10;
            return r;
        }();

        constexpr std::array RECIPES = {REGULAR, CLEAR, DOCK, CONTROLCENTER, MENU, SPOTLIGHT};
    }

    const SRecipe& recipeByName(std::string_view name) {
        for (const auto& r : RECIPES)
            if (name == r.name)
                return r;
        return RECIPES[0];
    }

    double clampedLinear(double x, double in0, double in1, double out0, double out1) {
        if (in1 <= in0)
            return x < in0 ? out0 : out1;
        const double t = std::clamp((x - in0) / (in1 - in0), 0.0, 1.0);
        return out0 + (out1 - out0) * t;
    }

    SResolved resolveMaterial(const SRecipe& r, double D) {
        return {
            .refractionHeight = float(std::clamp(r.refractionHeightN * D, 0.0, double(r.refractionHeightMax))),
            .refractionAmount = float(std::max(r.refractionAmountN * D, double(r.refractionAmountMin))),
            .outerHeight      = float(r.outerHeightN * D),
            .outerAmount      = float(r.outerAmountN * D),
            .blurRadius       = float(clampedLinear(D, r.blurD0, r.blurD1, r.blurLo, r.blurHi)),
            // never shallower than dist1, or the first ramp would run backwards
            .blurDist0     = float(std::min(r.blurDist0N * D + r.blurDist0Fixed, double(r.blurDist1) - 0.5)),
            .bleedOpacity  = float(clampedLinear(D, r.bleedD0, r.bleedD1, r.bleedOpacityLo, r.bleedOpacityHi)),
            .bleedHeight   = float(r.bleedHeightN * D),
            .bleedAmount   = float(r.bleedAmountN * D),
            .bleedBlur     = float(std::min(r.bleedBlurN * D, 160.0)),
            .shadowOpacity     = float(clampedLinear(D, r.shadowD0, r.shadowD1, r.shadowOpacityLo, r.shadowOpacityHi)),
            .shadowOpacityDark = float(clampedLinear(D, r.shadowD0, r.shadowD1, r.shadowOpacityLo, r.shadowOpacityHiDark)),
            .shadowRadius      = float(clampedLinear(D, r.shadowD0, r.shadowD1, r.shadowRadiusLo, r.shadowRadius)),
            .keySpread         = float(clampedLinear(D, 96, 192, 80, 90)),
        };
    }

    bool hasShadow(const SRecipe& r) {
        return r.shadowOpacityLo > 0 || r.shadowOpacityHi > 0 || r.shadowOpacityHiDark > 0;
    }

    bool hysteresisDark(bool wasDark, double luminance, double low, double high) {
        if (wasDark)
            return luminance <= high;
        return luminance < low;
    }
}
