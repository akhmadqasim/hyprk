#pragma once
// macOS 27.2.1 glass material recipes (DesignLibrary GlassRecipes, glass version v2) and the Liquid Glass slider,
// as verified on the Mac against the binaries and the screen (reference/re/MAC-ANSWERS.md "Verification of motion and
// glass claims (PC #67)" B and C, "C2. Remaining glass items"; code in reference/re/27.2.1/decomp/
// DesignLibrary-diffusion-amount.c and QuartzCore-glassBackground-shader.c). Pure code, unit tested, and checked
// against Apple's model by plugin/tools/check_model.py.
//
// Apple's numbers are size-relative: D is the smallest extent of the glass shape in points. resolveMaterial() turns a
// recipe + D + light/dark + slider value into the inputs the shader takes.

#include <array>
#include <string_view>

namespace lg {

    // YCC colour effect (CA::ColorMatrix::set_ycc_composite):
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

    // which DesignLibrary base the recipe has, and with it the slider response
    enum class eFamily {
        REGULAR, // RegularBase + RegularDiffusionAmount: Regular, Menu, Notification Center
        CLEAR,   // ClearSpec + ClearDiffusionAmount: Clear, Dock, Control Center
        FIXED,   // not decoded (Spotlight / Siri): the slider changes nothing
    };

    // one side (light or dark) of a recipe, as at slider 0.5
    struct SFace {
        SYcc      ycc;
        SRgba     fill;     // normalFill (straight alpha)
        SYcc      bleed;    // edge bleed colour matrix (Regular family)
        SBlurFill blurFill;
        // key/fill highlight layer target = its vibrantColorMatrix as YCC (the matrix is a*I - k*luma plus an
        // offset: black = offset, white = offset + a - k, saturation = a). Regular: R row 1.1202 -0.1894 -0.019 | 0.1471
        SYcc  keyYcc = {0.1471f, 1.0588f, 1.1765f};
        float darkBias   = -0.25f; // dark specular colourBias
        float darkSpread = 75;     // its spread on SDR (KeyFillHighlightSpreadSDR), degrees
        // max luma of the CLEAR / FIXED families (Dock dark 0.75); the REGULAR family computes it (resolveMaterial)
        float maxLuma = 1;
    };

    constexpr float SIZE_MINIMUM = 48.f, SIZE_MEDIUM = 166.f, SIZE_MAXIMUM = 201.3f;

    struct SRecipe {
        const char* name   = "regular";
        eFamily     family = eFamily::REGULAR;
        SFace       light, dark;

        // inner refraction: height = clamp(heightN * D, 0, heightMax); amount = max(amountN * D, amountMin)
        float refractionHeightN = 0.25f, refractionHeightMax = 20.f;
        float refractionAmountN = -0.5f, refractionAmountMin = -60.f;

        // outer refraction (a second sample outside the shape, mixed into the outermost 1 pt):
        // height = max(outerHeightN * D, outerMin), amount = max(outerAmountN * D, outerMin)
        float outerHeightN = 0, outerAmountN = 0, outerMin = 0, outerOpacity = 0;

        // blur of the face: hyprk's own kernel (Hyprland's blur + mips of a sharp copy, see README "Blur"), not
        // Apple's mip-of-a-scaled-backdrop. radius lerp(blurLo, blurHi) over D in [blurD0, blurD1] feeds the mip level.
        float blurD0 = 64, blurD1 = 160, blurLo = 0, blurHi = 4;
        // variable blur: radius x (alpha0 - alpha1 ramp(d, dist0, dist1) - alpha2 ramp(d, dist1, 0)),
        // d < 0 inside. dist0 = dist0N * D + dist0Fixed
        float                blurDist0N = -0.5f, blurDist0Fixed = 0, blurDist1 = -1;
        std::array<float, 3> blurAlpha  = {1, 0.5f, 0.5f};
        // alpha0 and alpha1 x lerp(0, 1) over D in [blurAlphaD0, blurAlphaD1] (equal: always full)
        float blurAlphaD0 = 0, blurAlphaD1 = 0;
        // Apple's BlurRadius, only for the backdrop scale estimator (Regular family)
        float appleBlurRadius = 5;

        // drop shadow: opacity and Gaussian radius lerp over D (shadowD0 == shadowD1: always the high end),
        // the dark side has its own top opacity. Regular: 0.04 + 0.56 q dark (Mac dumps by size), light 0.04 -> 0.4
        // (LIVE-27.2.1.md), radius 4 + 20 q, q = clamp((D - 64) / 96), y 8.
        float shadowD0 = 64, shadowD1 = 160, shadowOpacityLo = 0.04f, shadowOpacityHi = 0.4f, shadowOpacityHiDark = 0.6f;
        float shadowRadiusLo = 4, shadowRadius = 24, shadowOffsetY = 8, shadowSaturation = 1.f;

        // key/fill highlight (CASDFKeyFillHighlightEffect): key amount, diffuse band amount (Apple 0.5 and 0.5 x 0.15)
        // and a scale of the whole mask (1 = Apple; Notification Center 1.23, its measured rim)
        float keyAmount = 0.5f, diffuseAmount = 0.075f, keyScale = 1;

        // size class (GlassMaterialProvider.Size, SwiftUI _Glass.SurfaceSize, MAC-ANSWERS PC #67 B2 3 and notes): every
        // size-dependent input reads this fixed D instead of the shape's shortest side. 0 = automatic (the shape's own,
        // AppKit NSGlassEffectView), SIZE_MINIMUM / SIZE_MEDIUM / SIZE_MAXIMUM = 48 / 166 / 201.3 pt
        float sizeD = 0;

        // ring shadow: offset y, stroke, blur radius, opacity (0 = off)
        float ringOffsetY = 0, ringStroke = 0, ringRadius = 0, ringOpacity = 0;
    };

    // "regular", "clear", "dock", "controlcenter", "menu", "spotlight", "notificationcenter"; unknown names give regular
    const SRecipe& recipeByName(std::string_view name);

    struct SResolved { // pt unless noted
        float refractionHeight = 0, refractionAmount = 0;
        float outerHeight = 0, outerAmount = 0, outerOpacity = 0;
        float blurRadius   = 0; // hyprk blur units (mip level input)
        float blurDist0    = 0;
        std::array<float, 3> blurAlpha = {1, 0.5f, 0.5f};
        SYcc      ycc;
        SRgba     fill;
        SBlurFill blurFill;
        float     maxLuma = 1;
        // edge bleed: out = mix(face, bleed(s), g^4 opacity), g = Y(face) if bleedLighten else 1 - Y(face)
        float bleedOpacity = 0, bleedAmount = 0, bleedHeight = 0;
        SYcc  bleed;
        bool  bleedLighten = false;
        float backdropScale = 0.5f; // Apple's backdrop texture scale (perceptual estimator), the bleed sample's mip
        float shadowOpacity = 0, shadowRadius = 0, shadowOffsetY = 0;
        float keySpread = 80; // degrees, key/fill highlight lobe: 80 up to D 96, 90 from D 191
        SYcc  keyYcc;
        float keyAmount = 0.5f, diffuseAmount = 0.075f, keyScale = 1;
        float darkBias = -0.25f, darkSpread = 75;
    };

    // false when the recipe never draws a drop shadow (Clear, Dock, Control Center)
    bool hasShadow(const SRecipe& r);

    // tint = Liquid Glass slider (NSGlassTintAmount) 0..1, 0.5 = the recipe as is
    SResolved resolveMaterial(const SRecipe& r, double D, bool dark, double tint = 0.5);

    // DesignLibrary GlassMaterialProvider.BackdropScalePerceptualEstimator: first of 0.125 / 0.25 / 0.5 whose
    // visible alias is <= 0.05 (r = blur radius x opacity0, rf = blur-fill radius, N = normal opacity, F = fill alpha)
    float backdropScale(double r, double rf, double N, double F);

    // clampedLinear(in0, in1, out0, out1) on x, Apple's ParameterScale
    double clampedLinear(double x, double in0, double in1, double out0, double out1);

    // Adaptive light/dark with a dead band: switch to dark below `low`, back to light above `high`.
    bool hysteresisDark(bool wasDark, double luminance, double low, double high);
}
