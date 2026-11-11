#include "Material.hpp"

#include <algorithm>
#include <cmath>

namespace lg {

    namespace {
        // key/fill highlight target of Clear and Control Center: matrix rows (1.3192, -0.0478, -0.0047 | 0.2)
        constexpr SYcc CLEAR_KEY = {0.2f, 1.4666f, 1.3334f};

        // Regular (RegularBase.Base 0x195f20248, filter dumps live/verify/C, C2): light face (0.4, 1.03, 1.2) + white
        // 0.2, max luma 1 but maxLumaSDR 0.94; dark face (0.125, 1.125, 1.3), no fill, max luma lerp(0.6, 0.35) over
        // D 64 -> 104. Blur fill radius 8: lighten 0.9 (light) / darken 0.9 (dark), normal 0.5. Edge bleed opacity
        // 0.5 (light) / 0.8 (dark) x q, colour (0.9, 1, 1.2) lighten-weighted / (0.125, 0.5, 1). Refraction inner
        // min(0.25 D, 20) / max(-0.5 D, -60), outer max(0.2 D, 16) / max(0.25 D, 16) at 0.6. Dark specular -0.25 at
        // 75 deg (dark) / 106 deg (light, SpreadSDR). Ring shadow (8, 4, 5, 0.06).
        constexpr SRecipe REGULAR = {
            .name         = "regular",
            .family       = eFamily::REGULAR,
            .light        = {.ycc = {0.4f, 1.03f, 1.2f}, .fill = {1, 1, 1, 0.2f}, .bleed = {0.9f, 1.f, 1.2f}, .blurFill = {0.9f, 0, 0.5f}, .darkSpread = 106},
            .dark         = {.ycc = {0.125f, 1.125f, 1.3f}, .fill = {}, .bleed = {0.125f, 0.5f, 1.f}, .blurFill = {0, 0.9f, 0.5f}, .darkSpread = 75},
            .outerHeightN = 0.2f,
            .outerAmountN = 0.25f,
            .outerMin     = 16,
            .outerOpacity = 0.6f,
            .blurD0 = 48, .blurD1 = 160, .blurLo = 2, .blurHi = 4,
            .blurAlpha = {0.8f, 0.4f, 0.5f},
            .blurAlphaD0 = 64, .blurAlphaD1 = 160,
            .ringOffsetY = 8, .ringStroke = 4, .ringRadius = 5, .ringOpacity = 0.06f,
        };

#define LG_NO_SHADOW .shadowOpacityLo = 0, .shadowOpacityHi = 0, .shadowOpacityHiDark = 0

        // Clear (ClearSpec): face (0.125, 1.08, 1.06), no fill, blur 0.75, inner min(0.36 D, 20) / max(-0.65 D, -60),
        // outer 0.125 D / 0.2 D at opacity 0, no shadow, no bleed, rim -0.25 at 75 deg.
        constexpr SRecipe CLEAR = {
            .name              = "clear",
            .family            = eFamily::CLEAR,
            .light             = {.ycc = {0.125f, 1.08f, 1.06f}, .keyYcc = CLEAR_KEY},
            .dark              = {.ycc = {0.125f, 1.08f, 1.06f}, .keyYcc = CLEAR_KEY},
            .refractionHeightN = 0.36f,
            .refractionAmountN = -0.65f,
            .outerHeightN      = 0.125f,
            .outerAmountN      = 0.2f,
            .blurLo = 0.75f, .blurHi = 0.75f, // constant
            LG_NO_SHADOW,
        };

        // Dock (DockRecipe.Other): face light (0.15, 0.9, 1.25), dark (0.05, 0.92, 1.25) + black 2 % with max luma 0.75;
        // blur 1.5; outer layer opacity 0.2 without displacement; rim -0.25 at 75 deg (SDR; 120 only with HDR
        // headroom), highlight target light (0.2, 1.2, 1.333), dark (0.25, 0.95, 1.2). Inner refraction 0.08 D / -0.18 D
        // at size class medium (Dock.app GlassMaterialProvider.Configuration.dock .size = .medium, MAC-ANSWERS PC #67 B2
        // 3): 13.28 pt / -29.88 pt at every Dock size (real Dock rms 0.4-1.1 pt). Light face = the real Dock (white 229,
        // black 38, grey 127 -> 134), dark 176 / 107 / 12 (MAC-ANSWERS "Glass checks (#53)").
        constexpr SRecipe DOCK = {
            .name                = "dock",
            .family              = eFamily::CLEAR,
            .light               = {.ycc = {0.15f, 0.9f, 1.25f}, .keyYcc = {0.2f, 1.2f, 1.3334f}},
            .dark                = {.ycc = {0.05f, 0.92f, 1.25f}, .fill = {0, 0, 0, 0.02f}, .keyYcc = {0.25f, 0.95f, 1.2f}, .maxLuma = 0.75f},
            .refractionHeightN   = 0.08f,
            .refractionHeightMax = 1e6f,
            .refractionAmountN   = -0.18f,
            .refractionAmountMin = -1e6f,
            .outerOpacity        = 0.2f,
            .blurLo = 1.5f, .blurHi = 1.5f, // constant
            LG_NO_SHADOW,
            .sizeD = SIZE_MEDIUM,
        };

        // Control Center (= the volume/brightness HUD, SystemBannerUI _Glass.controlCenter), light and dark alike:
        // face (0.125, 0.8, 1.2), no fill; inner min(0.225 D, 25) / max(-2 D, -80); outer 0.0357 D / 0.0714 D at
        // 0.1525; rim -0.3 at 75 deg. Over the Electric Blue wallpaper (69, 83, 206) the HUD gives (68, 85, 232) on the
        // Mac. Blur: Apple's radius 4 with opacities 1 / 0.1 / 0.5 over distances -100 / -1 / 0 rides on the CC panel's
        // own blur, which hyprk does not have (its CC panel is a dim only); Hyprland's blur stands in for both (JUDGE-r4),
        // the variable blur softens toward the middle.
        constexpr SFace   CONTROLCENTER_FACE = {.ycc = {0.125f, 0.8f, 1.2f}, .keyYcc = CLEAR_KEY, .darkBias = -0.3f};
        constexpr SRecipe CONTROLCENTER      = {
                 .name                = "controlcenter",
                 .family              = eFamily::CLEAR,
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
                 .blurAlpha = {1, 0.1f, 0.5f},
                 LG_NO_SHADOW,
        };

        // Spotlight = SiriRecipe.SiriModifier branch A (reference/re/NOTES.md); not in the Mac's verified model, so the
        // slider is not applied (eFamily::FIXED)
        constexpr SRecipe SPOTLIGHT = {
            .name                = "spotlight",
            .family              = eFamily::FIXED,
            .light               = {.ycc = {0.1f, 1.0f, 1.25f}, .blurFill = {0.4f, 0.75f, 0.5f}},
            .dark                = {.ycc = {0.1f, 1.0f, 1.25f}, .blurFill = {0, 0.75f, 0.5f}},
            .refractionHeightN   = 0.4f,
            .refractionHeightMax = 1e6f,
            .refractionAmountN   = -0.72f,
            .refractionAmountMin = -1e6f,
            .outerHeightN        = 0.4f,
            .outerAmountN        = 0.4f,
            .outerOpacity        = 1.0f,
            .blurLo = 6, .blurHi = 6, // constant: Apple 8 x 0.75
            .blurDist0N = 0, .blurDist0Fixed = -60, .blurDist1 = -1,
            .blurAlpha = {1, 0, 1},
            LG_NO_SHADOW,
        };
#undef LG_NO_SHADOW

        // regular.menu: Regular + the glass menu shadow, the same at every size. Mac dumps: opacity 0.7 light / 0.8 dark,
        // radius 24, y 10; through this shader (erfc edge, shadow_tint 0.35) those inputs give twice the Mac's ink, so the
        // opacity is fitted to the Mac's pixels over white (Q-menubar-28, below and beside at 2..40 pt): radius 24 and y
        // 10 come out of the free fit unchanged, opacity 0.32 light (rms 0.3 level) / 0.36 dark (rms 0.2): below at
        // 2/10/20 pt 219/228/240 light, 214/225/238 dark (Mac the same). The shell draws alerts in the same layer
        // (hyprk-overlay:menu), so they get this one too.
        constexpr SRecipe MENU = [] {
            SRecipe r         = REGULAR;
            r.name            = "menu";
            r.shadowD0        = r.shadowD1 = 0;
            r.shadowOpacityLo = r.shadowOpacityHi = 0.32f;
            r.shadowOpacityHiDark                 = 0.36f;
            r.shadowRadiusLo                      = r.shadowRadius;
            r.shadowOffsetY                       = 10;
            return r;
        }();

        // Notification Center cards and banners: _Glass.notificationCenter (reference/re/27.2.1/decomp/
        // NotificationCenter-glass.c) = Regular at size class medium (D 166, MAC-ANSWERS PC #67 B2 notes): max luma
        // 0.35 dark (the real NC, PC #62: banner 33 / 114 over black / grey 127, card 128 / 104 / 32), bleed and
        // refraction of a 166 pt panel on every card. Shadow: Regular's at D 166 is 0.6 dark / 0.4 light, r 24, y 8; like
        // the menu's, those inputs give too much ink through this shader, so radius and offset stay and the opacity is
        // fitted to the gap between two cards over white (with the shell's list shadow, black 0.2): Mac 181 dark / 189
        // light (PC #62); 0.21 / 0.135 give 181 / 189 (Regular's 0.6 / 0.4 gave 155 / 172, the own-size 0.10 gave 199).
        // Rim: the real NC card's top / bottom line (outer px -> inner px -> body, dark: 68 -> 53 -> 35 over black)
        // is the 1 pt key band alone at 1.23 x Regular's (mask 1.0 and 0.54 in the two px): not decoded, Mac pixels.
        constexpr SRecipe NOTIFICATIONCENTER = [] {
            SRecipe r       = REGULAR;
            r.name          = "notificationcenter";
            r.sizeD         = SIZE_MEDIUM;
            r.shadowD0 = r.shadowD1 = 0;
            r.shadowOpacityLo = r.shadowOpacityHi = 0.135f;
            r.shadowOpacityHiDark                 = 0.21f;
            r.shadowRadiusLo                      = r.shadowRadius;
            r.keyScale      = 1.23f;
            r.diffuseAmount = 0;
            return r;
        }();

        constexpr std::array RECIPES = {REGULAR, CLEAR, DOCK, CONTROLCENTER, MENU, SPOTLIGHT, NOTIFICATIONCENTER};
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

    float backdropScale(double r, double rf, double N, double F) {
        constexpr double PI2 = M_PI * M_PI;
        for (const double s : {0.125, 0.25, 0.5}) {
            const double alias = (1 - F) * (N * std::exp(-PI2 * rf * rf * s * s / 4) + (1 - N) * std::exp(-PI2 * r * r * s * s / 4));
            if (alias <= 0.05)
                return float(s);
        }
        return 0.5f;
    }

    SResolved resolveMaterial(const SRecipe& r, double D, bool dark, double tint) {
        if (r.sizeD > 0) // size class: a fixed D for every size-dependent input
            D = r.sizeD;
        const SFace& f    = dark ? r.dark : r.light;
        const double a    = std::clamp(std::isfinite(tint) ? tint : 0.5, 0.0, 1.0);
        const double u    = std::clamp(2 * a, 0.0, 1.0), t = std::clamp(2 * a - 1, 0.0, 1.0);
        const double q    = clampedLinear(D, 64, 160, 0, 1);
        const float  ramp = float(clampedLinear(D, r.blurAlphaD0, r.blurAlphaD1, 0, 1));

        SResolved res{
            .refractionHeight = float(std::clamp(r.refractionHeightN * D, 0.0, double(r.refractionHeightMax))),
            .refractionAmount = float(std::max(r.refractionAmountN * D, double(r.refractionAmountMin))),
            .outerHeight      = float(std::max(r.outerHeightN * D, double(r.outerMin))),
            .outerAmount      = float(std::max(r.outerAmountN * D, double(r.outerMin))),
            .outerOpacity     = r.outerOpacity,
            .blurRadius       = float(clampedLinear(D, r.blurD0, r.blurD1, r.blurLo, r.blurHi)),
            // never shallower than dist1, or the first ramp would run backwards
            .blurDist0     = float(std::min(r.blurDist0N * D + r.blurDist0Fixed, double(r.blurDist1) - 0.5)),
            .blurAlpha     = {r.blurAlpha[0] * ramp, r.blurAlpha[1] * ramp, r.blurAlpha[2]},
            .ycc           = f.ycc,
            .fill          = f.fill,
            .blurFill      = f.blurFill,
            .maxLuma       = f.maxLuma,
            .bleed         = f.bleed,
            .bleedLighten  = !dark,
            .shadowOpacity = float(clampedLinear(D, r.shadowD0, r.shadowD1, r.shadowOpacityLo, dark ? r.shadowOpacityHiDark : r.shadowOpacityHi)),
            .shadowRadius  = float(clampedLinear(D, r.shadowD0, r.shadowD1, r.shadowRadiusLo, r.shadowRadius)),
            .shadowOffsetY = r.shadowOffsetY,
            .keySpread     = float(clampedLinear(D, 96, 191, 80, 90)),
            .keyYcc        = f.keyYcc,
            .keyAmount     = r.keyAmount,
            .diffuseAmount = r.diffuseAmount,
            .keyScale      = r.keyScale,
            .darkBias      = f.darkBias,
            .darkSpread    = f.darkSpread,
        };

        if (r.family == eFamily::REGULAR) {
            // edge bleed (a step of the same shader, Regular family only)
            res.bleedOpacity = float((dark ? 0.8 : 0.5) * q);
            res.bleedAmount = res.bleedHeight = float(0.35 * D);
            // max luma: dark lerp(0.6, 0.35) over D 64 -> 104, light maxLumaSDR 0.94
            const double s = clampedLinear(D, 64, 104, 0, 1);
            res.maxLuma    = dark ? float(0.6 + (0.35 - 0.6) * s) : 0.94f;

            // RegularDiffusionAmount (0x195f22ea0); 0.5 is the recipe as is
            if (std::abs(a - 0.5) >= 0.00034526698) {
                auto&       bf = res.blurFill;
                const float k  = dark ? f.ycc.black : 1.f; // grey of the face black level, or white
                const auto  mixFill = [&](SRgba to, double w) { // fill (1 - w) + to w, straight alpha
                    auto& c = res.fill;
                    c       = {float(c.r + (to.r - c.r) * w), float(c.g + (to.g - c.g) * w), float(c.b + (to.b - c.b) * w), float(c.a + (to.a - c.a) * w)};
                };
                if (a >= 0.5) {
                    bf.normal  = float(bf.normal * (1 - t) + t);
                    bf.lighten = float(bf.lighten * (1 - t) + (bf.lighten > 0 ? 0.9 : 0) * t);
                    bf.darken  = float(bf.darken * (1 - t) + (bf.darken > 0 ? 0.9 : 0) * t);
                    mixFill({k, k, k, 0.5f}, t);
                } else {
                    bf.normal  = float(bf.normal * u);
                    bf.lighten = float(bf.lighten * (0.75 + 0.25 * u));
                    bf.darken  = float(bf.darken * (0.75 + 0.25 * u));
                    mixFill({k, k, k, 0}, 1 - u);
                    if (dark)
                        res.maxLuma = float((0.6 + (0.45 - 0.6) * s) * (1 - u) + res.maxLuma * u);
                }
            }
            const auto& bf    = res.blurFill;
            const bool  fills = bf.lighten > 0 || bf.darken > 0 || bf.normal > 0;
            res.backdropScale = backdropScale(r.appleBlurRadius * res.blurAlpha[0], fills ? 8 : 0, bf.normal, res.fill.a);
        } else if (r.family == eFamily::CLEAR) {
            // ClearDiffusionAmount (0x195efeb9c): below 0.5 the blur radius x 2a (sharp at 0), above a blur fill of
            // radius 8 with normal opacity 2a - 1
            if (a < 0.5) {
                const float b = float(2 * a);
                res.blurRadius *= b;
                for (auto& x : res.blurAlpha)
                    x *= b;
            } else if (a > 0.5)
                res.blurFill = {0, 0, float(2 * a - 1)};
        }
        return res;
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
