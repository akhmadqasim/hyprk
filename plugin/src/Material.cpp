#include "Material.hpp"

#include <algorithm>
#include <array>

namespace lg {

    namespace {
        // Dark sides use a +0.3 rim bias. Apple's darkSpecular has colorBias -0.3, but that is an
        // extra darkening layer on top of the key highlight, which is not decoded; a plain -0.3 made
        // the dark rim disappear (by eye vs reference/screens).
        constexpr SRgba WHITE20 = {1, 1, 1, 0.2f};

        // SPEC 9.2 RegularBase, V2. Used by menus, notifications, sidebars.
        // Shadow for Regular was not traced (SPEC: "assume Clear's"), ring shadow V2 (8, 4, 5, 0.06).
        constexpr SRecipe REGULAR = {
            .name  = "regular",
            .light = {.ycc = {0.4f, 1.03f, 1.2f}, .fill = WHITE20, .highlightBias = 0.5f},
            .dark  = {.ycc = {0.125f, 1.125f, 1.3f}, .fill = {}, .highlightBias = 0.3f},
            .ringOffsetY = 8, .ringStroke = 4, .ringRadius = 5, .ringOpacity = 0.06f,
        };

        // SPEC 9.3 Clear (base + ClearSpec.Modifier, V2): no fill, refraction -0.8 D,
        // blur D 48->120 : 3->8, Clear shadow.
        constexpr SRecipe CLEAR = {
            .name              = "clear",
            .light             = {.ycc = {0.125f, 1.08f, 1.06f}, .fill = {}, .highlightBias = 0.5f},
            .dark              = {.ycc = {0.125f, 1.08f, 1.06f}, .fill = {}, .highlightBias = 0.3f},
            .refractionAmountN = -0.8f,
            .blurD0 = 48, .blurD1 = 120, .blurLo = 3, .blurHi = 8,
        };

        // SPEC 9.5 DockRecipe.Other V2 on top of Clear: blur 1.5, inner 0.08 D / -0.18 D.
        constexpr SRecipe DOCK = {
            .name              = "dock",
            .light             = {.ycc = {0.15f, 0.9f, 1.25f}, .fill = {}, .highlightBias = 0.5f},
            .dark              = {.ycc = {0.05f, 0.92f, 1.25f}, .fill = {}, .highlightBias = 0.3f},
            .refractionHeightN = 0.08f,
            .refractionAmountN = -0.18f,
            .blurLo = 1.5f, .blurHi = 1.5f, // constant
        };

        // SPEC 9.5 Control Center, Mac, V2 on top of Clear: blur 4, inner 0.225 D clamp 25,
        // amount -2.0 D clamp -80, face (0.125, 0.8, 1.2).
        constexpr SRecipe CONTROLCENTER = {
            .name                = "controlcenter",
            .light               = {.ycc = {0.125f, 0.8f, 1.2f}, .fill = {}, .highlightBias = 0.5f},
            .dark                = {.ycc = {0.125f, 0.8f, 1.2f}, .fill = {}, .highlightBias = 0.3f},
            .refractionHeightN   = 0.225f,
            .refractionHeightMax = 25,
            .refractionAmountN   = -2.0f,
            .refractionAmountMin = -80,
            .blurLo = 4, .blurHi = 4, // constant
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
            .blurRadius       = float(clampedLinear(D, r.blurD0, r.blurD1, r.blurLo, r.blurHi)),
            .shadowOpacity    = float(clampedLinear(D, r.shadowD0, r.shadowD1, r.shadowOpacityLo, r.shadowOpacityHi)),
        };
    }

    bool hysteresisDark(bool wasDark, double luminance, double low, double high) {
        if (wasDark)
            return luminance <= high;
        return luminance < low;
    }
}
