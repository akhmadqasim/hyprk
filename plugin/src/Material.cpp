#include "Material.hpp"

#include <algorithm>

namespace lg {

    namespace {
        // Dark sides use a +0.3 rim bias. Apple's darkSpecular has colorBias -0.3, but that is an
        // extra darkening layer on top of the key highlight, which is not decoded; a plain -0.3 made
        // the dark rim disappear (by eye vs reference/screens).
        constexpr SRgba WHITE20 = {1, 1, 1, 0.2f};

        // Clear-family edge bleed colour (SPEC 9.3)
        constexpr SYcc CLEAR_BLEED = {0.75f, 1.f, 1.2f};

        // SPEC 9.2 RegularBase, V2. Used by menus, notifications, sidebars. Light saturation 1.2 -> 1.0
        // and dock 1.25 -> 1.1: the decoded values read too cyan over the Tahoe wallpapers (JUDGE.md).
        // Shadow for Regular was not traced (SPEC: "assume Clear's"), ring shadow V2 (8, 4, 5, 0.06).
        constexpr SRecipe REGULAR = {
            .name         = "regular",
            .light        = {.ycc = {0.4f, 1.03f, 1.0f}, .fill = WHITE20, .highlightBias = 0.5f, .bleed = {0.9f, 1.f, 1.2f}, .blurFill = {0.9f, 0, 0.5f}, .lift = 0.05f},
            .dark         = {.ycc = {0.125f, 1.125f, 1.3f}, .fill = {}, .highlightBias = 0.3f, .bleed = {0.125f, 0.5f, 1.f}, .blurFill = {0, 0.9f, 0.5f}},
            .outerHeightN = 0.2f,
            .outerAmountN = 0.25f,
            .outerOpacity = 0.6f,
            .ringOffsetY = 8, .ringStroke = 4, .ringRadius = 5, .ringOpacity = 0.06f,
        };

        // SPEC 9.3 Clear (base + ClearSpec.Modifier, V2): no fill, refraction -0.8 D, no outer layer,
        // blur D 48->120 : 3->8, Clear shadow.
        constexpr SRecipe CLEAR = {
            .name              = "clear",
            .light             = {.ycc = {0.125f, 1.08f, 1.06f}, .fill = {}, .highlightBias = 0.5f, .bleed = CLEAR_BLEED},
            .dark              = {.ycc = {0.125f, 1.08f, 1.06f}, .fill = {}, .highlightBias = 0.3f, .bleed = CLEAR_BLEED},
            .refractionAmountN = -0.8f,
            .blurD0 = 48, .blurD1 = 120, .blurLo = 3, .blurHi = 8,
        };

        // SPEC 9.5 DockRecipe.Other V2 on top of Clear: blur 1.5, inner 0.08 D / -0.18 D,
        // outer 0.13 D / 0.42 D at 0.2.
        constexpr SRecipe DOCK = {
            .name              = "dock",
            .light             = {.ycc = {0.15f, 0.9f, 1.1f}, .fill = {}, .highlightBias = 0.5f, .bleed = CLEAR_BLEED, .lift = 0.05f},
            .dark              = {.ycc = {0.05f, 0.92f, 1.25f}, .fill = {}, .highlightBias = 0.3f, .bleed = CLEAR_BLEED},
            .refractionHeightN = 0.08f,
            .refractionAmountN = -0.18f,
            .outerHeightN      = 0.13f,
            .outerAmountN      = 0.42f,
            .outerOpacity      = 0.2f,
            .blurLo = 1.5f, .blurHi = 1.5f, // constant
        };

        // Face: SPEC 9.5 gives (0.125, 0.8, 1.2), but in our gamma-space shader that measured ~1.4:1
        // against the white tile labels (JUDGE.md). (0.1, 0.5, 0.7) keeps labels >= 4.5:1 and matches
        // the neutral grey-brown of reference/screens/macos27-control-center.png.
        // SPEC 9.5 Control Center, Mac, V2 on top of Clear: blur 4 with distances (-100, -1, 0, 0),
        // inner 0.225 D clamp 25 / -2.0 D clamp -80, outer 0.0357 D / 0.0714 D at 0.1525.
        constexpr SRecipe CONTROLCENTER = {
            .name                = "controlcenter",
            .light               = {.ycc = {0.1f, 0.5f, 0.7f}, .fill = {}, .highlightBias = 0.5f, .bleed = CLEAR_BLEED},
            .dark                = {.ycc = {0.1f, 0.5f, 0.7f}, .fill = {}, .highlightBias = 0.3f, .bleed = CLEAR_BLEED},
            .refractionHeightN   = 0.225f,
            .refractionHeightMax = 25,
            .refractionAmountN   = -2.0f,
            .refractionAmountMin = -80,
            .outerHeightN        = 0.0357f,
            .outerAmountN        = 0.0714f,
            .outerOpacity        = 0.1525f,
            .blurLo = 4, .blurHi = 4, // constant
            .blurDist0N = 0, .blurDist0Fixed = -100,
        };

        // Regular + the Mac glass window/menu active shadow (SPEC 9.5: 0.6 light, radius 24, y 10)
        constexpr SRecipe MENU = [] {
            SRecipe r         = REGULAR;
            r.name            = "menu";
            r.shadowOpacityLo = r.shadowOpacityHi = 0.6f;
            r.shadowOffsetY   = 10;
            return r;
        }();

        constexpr std::array RECIPES = {REGULAR, CLEAR, DOCK, CONTROLCENTER, MENU};
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
            .shadowOpacity = float(clampedLinear(D, r.shadowD0, r.shadowD1, r.shadowOpacityLo, r.shadowOpacityHi)),
        };
    }

    bool hysteresisDark(bool wasDark, double luminance, double low, double high) {
        if (wasDark)
            return luminance <= high;
        return luminance < low;
    }
}
