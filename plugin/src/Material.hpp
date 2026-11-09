#pragma once
// macOS 27.2 glass material recipes (DesignLibrary GlassRecipes, glass version v2), recovered in
// /mnt/code/liquid-glass-re/SPEC.md section 9 and glass-defaults.json. Pure code, unit tested.
//
// Apple's numbers are size-relative: most lengths are "normalized x D" where D is the smallest
// extent of the glass shape in points. resolveMaterial() turns a recipe + D into concrete values.

#include <string>
#include <string_view>

namespace lg {

    // YCC face effect: luminance remapped to [black, white], chroma scaled by saturation
    struct SYcc {
        float black = 0, white = 1, saturation = 1;
    };

    struct SRgba {
        float r = 0, g = 0, b = 0, a = 0;
    };

    // one side (light or dark) of a recipe
    struct SFace {
        SYcc  ycc;
        SRgba fill;              // "normalFill": mixed over the face by its alpha
        float highlightBias = 0; // key highlight colour bias (dark specular is negative)
    };

    struct SRecipe {
        const char* name = "regular";
        SFace       light, dark;

        // refraction: height = clamp(heightN * D, 0, heightMax); amount = max(amountN * D, amountMin)
        float refractionHeightN = 0.25f, refractionHeightMax = 20.f;
        float refractionAmountN = -0.5f, refractionAmountMin = -60.f;

        // extra mip blur on top of Hyprland's blur: lerp(blurLo, blurHi) over D in [blurD0, blurD1]
        float blurD0 = 64, blurD1 = 160, blurLo = 0, blurHi = 4;

        // drop shadow: opacity lerp over D, Gaussian radius, offset, backdrop saturation (tint)
        float shadowD0 = 64, shadowD1 = 160, shadowOpacityLo = 0.25f, shadowOpacityHi = 0.75f;
        float shadowRadius = 24, shadowOffsetY = 8, shadowSaturation = 1.2f;

        // ring shadow: offset y, stroke, blur radius, opacity (0 = off)
        float ringOffsetY = 0, ringStroke = 0, ringRadius = 0, ringOpacity = 0;
    };

    // "regular", "clear", "dock", "controlcenter", "menu"; unknown names give regular
    const SRecipe& recipeByName(std::string_view name);

    struct SResolved {
        float refractionHeight = 0, refractionAmount = 0; // pt
        float blurRadius       = 0;                       // Apple blur radius (backdrop texels at 1/4 scale)
        float shadowOpacity    = 0;
    };

    SResolved resolveMaterial(const SRecipe& r, double D);

    // clampedLinear(in0, in1, out0, out1) on x, Apple's ParameterScale
    double clampedLinear(double x, double in0, double in1, double out0, double out1);

    // Adaptive light/dark with a dead band: switch to dark below `low`, back to light above `high`.
    bool hysteresisDark(bool wasDark, double luminance, double low, double high);
}
