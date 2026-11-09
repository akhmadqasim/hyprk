#pragma once
// macOS 27.2 glass material recipes (DesignLibrary GlassRecipes, glass version v2), recovered in
// /mnt/code/liquid-glass-re/SPEC.md section 9 and glass-defaults.json. Pure code, unit tested.
//
// Apple's numbers are size-relative: most lengths are "normalized x D" where D is the smallest
// extent of the glass shape in points. resolveMaterial() turns a recipe + D into concrete values.

#include <array>
#include <string_view>

namespace lg {

    // YCC colour effect (CA::ColorMatrix::set_ycc_composite, SPEC 9.7):
    // Y' = black + (white - black) Y, chroma x saturation, then the fill over it
    struct SYcc {
        float black = 0, white = 1, saturation = 1;
    };

    struct SRgba {
        float r = 0, g = 0, b = 0, a = 0;
    };

    // blur fill: wider-blur sample combined by lighten (max), darken (min) and normal mix
    struct SBlurFill {
        float lighten = 0, darken = 0, normal = 0;
    };

    // one side (light or dark) of a recipe
    struct SFace {
        SYcc      ycc;
        SRgba     fill;              // "normalFill"
        float     highlightBias = 0; // key highlight colour bias
        SYcc      bleed;             // edge bleed colour effect
        SBlurFill blurFill;
        float     lift = 0; // extra white mixed over the face (by eye, not from the RE)
        // face luminance kept inside [lumaMin, lumaMax] (gamma), so tiles keep their tone and label
        // contrast over any backdrop (by eye: Control Center over white windows went near black/white)
        float     lumaMin = 0, lumaMax = 1;
    };

    struct SRecipe {
        const char* name = "regular";
        SFace       light, dark;

        // inner refraction: height = clamp(heightN * D, 0, heightMax); amount = max(amountN * D, amountMin)
        float refractionHeightN = 0.25f, refractionHeightMax = 20.f;
        float refractionAmountN = -0.5f, refractionAmountMin = -60.f;

        // outer refraction layer: height/amount x D, mixed in over the rim band by outerOpacity
        float outerHeightN = 0, outerAmountN = 0, outerOpacity = 0;

        // Apple blur radius: lerp(blurLo, blurHi) over D in [blurD0, blurD1]
        float blurD0 = 64, blurD1 = 160, blurLo = 0, blurHi = 4;
        // variable blur: radius x (alpha0 - alpha1 ramp(d, dist0, dist1) - alpha2 ramp(d, dist1, 0)),
        // d < 0 inside. dist0 = dist0N * D + dist0Fixed (Apple's "inset 0.5" read as half of D, a guess)
        float                blurDist0N = -0.5f, blurDist0Fixed = 0, blurDist1 = -1;
        std::array<float, 3> blurAlpha  = {1, 0.5f, 0.5f};

        // edge bleed: opacity lerp over D, height/amount/blur x D (blur max 160)
        float bleedD0 = 64, bleedD1 = 160, bleedOpacityLo = 0, bleedOpacityHi = 0.5f;
        float bleedHeightN = 0.35f, bleedAmountN = 0.35f, bleedBlurN = 0.35f;

        // drop shadow: opacity lerp over D, Gaussian radius, offset, backdrop saturation (tint)
        float shadowD0 = 64, shadowD1 = 160, shadowOpacityLo = 0.25f, shadowOpacityHi = 0.75f;
        float shadowRadius = 24, shadowOffsetY = 8, shadowSaturation = 1.2f;

        // ring shadow: offset y, stroke, blur radius, opacity (0 = off)
        float ringOffsetY = 0, ringStroke = 0, ringRadius = 0, ringOpacity = 0;
    };

    // "regular", "clear", "dock", "controlcenter", "menu", "spotlight"; unknown names give regular
    const SRecipe& recipeByName(std::string_view name);

    struct SResolved { // pt unless noted
        float refractionHeight = 0, refractionAmount = 0;
        float outerHeight = 0, outerAmount = 0;
        float blurRadius   = 0; // Apple units (backdrop texels at 1/4 scale)
        float blurDist0    = 0;
        float bleedOpacity = 0, bleedHeight = 0, bleedAmount = 0, bleedBlur = 0;
        float shadowOpacity = 0;
    };

    SResolved resolveMaterial(const SRecipe& r, double D);

    // clampedLinear(in0, in1, out0, out1) on x, Apple's ParameterScale
    double clampedLinear(double x, double in0, double in1, double out0, double out1);

    // Adaptive light/dark with a dead band: switch to dark below `low`, back to light above `high`.
    bool hysteresisDark(bool wasDark, double luminance, double low, double high);
}
