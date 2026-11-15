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
        // Dark bias -0.278: a fit, not the dump's -0.25 (GLASS-HIG.md rounds 9 and 11): over grey 127 the Mac's dark
        // alert and menus read their side line 47 over 112-113 (alert-shown-grey-dark.png, menu-probe-popup-over-grey-dark
        // .png), -0.25 drew 53, -0.278 46; the NC card line 67 -> 63 (Mac 54), the banner 82 -> 78 (Mac 67)
        constexpr SRecipe REGULAR = {
            .name         = "regular",
            .family       = eFamily::REGULAR,
            .light        = {.ycc = {0.4f, 1.03f, 1.2f}, .fill = {1, 1, 1, 0.2f}, .bleed = {0.9f, 1.f, 1.2f}, .blurFill = {0.9f, 0, 0.5f}, .darkSpread = 106},
            .dark         = {.ycc = {0.125f, 1.125f, 1.3f}, .fill = {}, .bleed = {0.125f, 0.5f, 1.f}, .blurFill = {0, 0.9f, 0.5f}, .darkBias = -0.278f, .darkSpread = 75},
            .outerHeightN = 0.2f,
            .outerAmountN = 0.25f,
            .outerMin     = 16,
            .outerOpacity = 0.6f,
            .blurRadius = 5,
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
            .blurRadius        = 0.75f,
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
            .blurRadius          = 1.5f,
            LG_NO_SHADOW,
            // Dock.app's glass is not ovalized (MAC-ANSWERS-8.md R8.1 is SwiftUI / AppKit glass): the Mac's Dock top rim
            // over black reads 104 from 25 pt (its corner's end) to 229 pt from its left end (glass53/dock-dark-black.png
            // row 10; at 0.5 it would fall to about 70 near the end), Cmd-Tab's top rim is as bright over the wallpaper
            // 100 pt from its end as mid-way (cmdtab-dark.png: +54 / +48); GLASS-HIG.md 20
            .ovalize = false,
            .sizeD   = SIZE_MEDIUM,
        };

        // Control Center (= the volume/brightness HUD, SystemBannerUI _Glass.controlCenter), light and dark alike:
        // face (0.125, 0.8, 1.2), no fill; inner min(0.225 D, 25) / max(-2 D, -80); outer 0.0357 D / 0.0714 D at
        // 0.1525; rim -0.3 at 75 deg. Over the Electric Blue wallpaper (69, 83, 206) the HUD gives (68, 85, 232) on the
        // Mac. Blur: Apple's radius 4 with opacities 1 / 0.1 / 0.5 over distances -100 / -1 / 0 (about 0.9 pt at 15 pt
        // deep, 1.5 at the middle of a 64 pt tile). On the Mac the CC tiles sample the panel's own blur under them; hyprk's
        // panel is a dim only, so the `underlay_blur` key adds that blur to the tiles' reads (REFRACTION.md).
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
                 .blurRadius          = 4,
                 .blurDist0N = 0, .blurDist0Fixed = -100,
                 .blurAlpha = {1, 0.1f, 0.5f},
                 LG_NO_SHADOW,
                 // the modules' glass is not ovalized: the Mac's Now Playing tile (130 pt) keeps its bottom rim flat over
                 // the straight part, 231 / 179 over grey, 123 / 84 over black (glass53/cc-*-{grey127,black}.png rows 129 /
                 // 128, 0-20 pt from the middle); at 0.5 ours read 224 / 175 there 15 pt out
                 .ovalize = false,
        };

        // Spotlight = SiriRecipe.SiriModifier branch A (reference/re/NOTES.md); not in the Mac's verified model, so the
        // slider is not applied (eFamily::FIXED).
        // Fill: black 0.205, the shell's old bottom veil (Theme.spotlight.panelBottomVeil) moved in front of the key/fill
        // highlight, on a face clamped to 1 first (clampBeforeFill): over white the face is about 1.11, so the highlight
        // was clamped away and the list's bottom rim read 203 flat (Mac 220 / 231 on its last two rows); the shell's veils
        // on the plugin path are the rest, 1 - (1 - v) / 0.795 (SPOTLIGHT-27.2.1.md "Judge #20"). The key (top) lobe
        // went on the face before the clamp and the fill (judge #21); since round 17 it is not drawn here at all
        // (keyTop 0): the top line lies over the shell's veil and the shell draws it (SPOTLIGHT-27.2.1.md "Round 17")
        constexpr SRecipe SPOTLIGHT = {
            .name                = "spotlight",
            .family              = eFamily::FIXED,
            .light               = {.ycc = {0.1f, 1.0f, 1.25f}, .fill = {0, 0, 0, 0.205f}, .blurFill = {0.4f, 0.75f, 0.5f}},
            .dark                = {.ycc = {0.1f, 1.0f, 1.25f}, .fill = {0, 0, 0, 0.205f}, .blurFill = {0, 0.75f, 0.5f}},
            .refractionHeightN   = 0.4f,
            .refractionHeightMax = 1e6f,
            .refractionAmountN   = -0.72f,
            .refractionAmountMin = -1e6f,
            .outerHeightN        = 0.4f,
            .outerAmountN        = 0.4f,
            .outerOpacity        = 1.0f,
            .blurRadius          = 6, // 8 x 0.75 (NOTES.md); full from 1 pt inside, sharp at the edge
            .blurDist0N = 0, .blurDist0Fixed = -60, .blurDist1 = -1,
            .blurAlpha = {1, 1, 0},
            // the Spotlight panel is a window with AppKit's active window shadow: fitted to the Mac's empty bar
            // (panels/spotlight-empty-*.png, below and above at mid-width) as density x 0.5 erfc((d -+ y) / (sigma sqrt 2)):
            // light 0.404 / y 18 / sigma 20 (rms 0.002), dark 0.71 / 19 / 19 (rms 0.011), i.e. shadowParameters active
            // (0.40 / 0.70, y 18, blur 20, SHADOW.md); black. The shader's edge is 0.5 erfc(d / radius): radius 20 sqrt 2
            .shadowD0 = 1, .shadowD1 = 1, .shadowOpacityLo = 0.4f, .shadowOpacityHi = 0.4f, .shadowOpacityHiDark = 0.7f,
            .shadowRadiusLo = 28.284f, .shadowRadius = 28.284f, .shadowOffsetY = 18, .shadowBlack = true, .clampBeforeFill = true,
            // R17.5 (spotlight-list-top-edge-step-*.png, the r17 stills): the list's first rows are the outer sample
            // (weights .75 / .25 at 2x, as decoded) of the backdrop with the bar in it, plus the shell's light line
            .outerSeesPrior = true, .priorVeil = {0.975f, 0.754f, 0.517f}, .keyTop = 0,
        };
#undef LG_NO_SHADOW

        // regular.menu: Regular + the glass menu shadow, the same at every size. Mac dumps: opacity 0.7 light / 0.8 dark,
        // radius 24, y 10, black fill 0.3, no vibrancy: the filter darkens by 0.3 x 0.7 = 0.21 / 0.24 x edge. The earlier
        // fit to the Mac's pixels over white (Q-menubar-28, below and beside at 2..40 pt; radius 24 and y 10 unchanged by the
        // free fit) found 0.32 / 0.36 through the old shadow (ink x 0.65): 0.208 / 0.234, the decoded ink within 3 %.
        // The shell draws alerts in the same layer (hyprk-overlay:menu), so they get this one too.
        constexpr SRecipe MENU = [] {
            SRecipe r         = REGULAR;
            r.name            = "menu";
            r.shadowD0        = r.shadowD1 = 0;
            r.shadowOpacityLo = r.shadowOpacityHi = 0.7f;
            r.shadowOpacityHiDark                 = 0.8f;
            r.shadowRadiusLo                      = r.shadowRadius;
            r.shadowOffsetY                       = 10;
            return r;
        }();

        // Notification Center cards and banners: _Glass.notificationCenter (reference/re/27.2.1/decomp/
        // NotificationCenter-glass.c) = Regular at size class medium (D 166, MAC-ANSWERS PC #67 B2 notes): max luma
        // 0.35 dark (the real NC, PC #62: banner 33 / 114 over black / grey 127, card 128 / 104 / 32), bleed and
        // refraction of a 166 pt panel on every card. Shadow: Regular's at D 166 is 0.6 dark / 0.4 light, r 24, y 8, with
        // ShadowVibrancyContribution 1 (the notificationCenter dumps from D 96: tinted by the backdrop); radius and offset
        // stay, the opacity is fitted to the gap between two cards over white (with the shell's list shadow, black 0.2): Mac
        // 181 dark / 189 light (PC #62): darkening 0.1365 / 0.0878 = 0.3 x 0.455 / 0.2925 (the decoded 0.6 / 0.4 give
        // 0.18 / 0.12, too dark: the cards' D is not decoded).
        // Rim: the real NC card's top / bottom line (outer px -> inner px -> body, dark: 68 -> 53 -> 35 over black)
        // is the 1 pt key band alone at 1.23 x Regular's (mask 1.0 and 0.54 in the two px): not decoded, Mac pixels.
        // Dark side line (the dark specular at full strength, straight rows of a 3-line card / the banner; line pixel
        // against the pixel outside it): the Mac's card 99.5 -> 44.5 over grey 127 and 200 -> 70.4 over white
        // (nc/stack-dark-{grey,white}.png), the banner 116.5 -> 50 and 233.5 -> 71.5 (panels/shadow-banner-{grey,white}
        // -dark.png), 0 over black, (57,65,156) -> (20,24,86) over blue; MAC-ANSWERS-18.md R18.2 (live/r18, a two-line
        // card: the middle row, strength 0.93): banner 233 -> 79 over white and (0,0,224) -> (0,0,159) over pure blue,
        // card 203 -> 78 and (0,0,193) -> (0,0,126). The blues are the DECODED tone with the dump's own bias -0.25,
        // c (1 + bias (3 - 2 c)) per channel: (20.6, 24.5, 86.8), 158.8, 125.9, the same as the light appearance draws
        // (banner 240 -> 176, (0,0,231) -> (0,0,166)); so is grey 99.5 (44.3). Only a light backdrop is darker than
        // that tone (white: 165 decoded, 71.5 on the Mac): the toned luma saturates near 0.28. So: the decoded tone,
        // then its luma Y limited through a soft knee, x (1 + (Y / 0.278)^4)^(-1/4), fitted on the six grey-axis
        // points (residuals -1.8 -1.1 1.4 -1.2 2.3 0.5 levels). The limiter is Mac pixels, not decoded. (Until round 18
        // a luma curve Y (0.5493 - 0.2602 Y) with chroma x 0.62: 4 off over white on a two-line card, 16 over pure
        // blue.) Alert and menus keep the fitted -0.278 without the limiter: their Mac line is known over grey 127 only
        // (GLASS-HIG.md 18)
        constexpr SRecipe NOTIFICATIONCENTER = [] {
            SRecipe r       = REGULAR;
            r.name          = "notificationcenter";
            r.sizeD         = SIZE_MEDIUM;
            r.shadowD0 = r.shadowD1 = 0;
            r.shadowOpacityLo = r.shadowOpacityHi = 0.2925f;
            r.shadowOpacityHiDark                 = 0.455f;
            r.shadowVibrancy                      = 1;
            r.shadowRadiusLo                      = r.shadowRadius;
            r.keyScale      = 1.23f;
            r.diffuseAmount = 0;
            r.dark.darkBias = -0.25f;
            r.darkToneCap   = 0.278f;
            r.darkToneKnee  = 4;
            return r;
        }();

        // banners (hyprk-notifications): _Glass.notificationCenter with Regular's decoded shadow at D 166, 0.4 light /
        // 0.6 dark (r 24, y 8, vibrancy 1): Mac R5.2 shadow-banner-{grey,white}-*.png solved over grey 127 and white,
        // darkening .124 / .185, sigma 16.9 pt, y 7.6 pt (GLASS-HIG.md 15); the cards keep the gap fit above
        constexpr SRecipe NOTIFICATIONBANNER = [] {
            SRecipe r             = NOTIFICATIONCENTER;
            r.name                = "notificationbanner";
            r.shadowOpacityLo     = r.shadowOpacityHi = 0.4f;
            r.shadowOpacityHiDark = 0.6f;
            return r;
        }();

        constexpr std::array RECIPES = {REGULAR, CLEAR, DOCK, CONTROLCENTER, MENU, SPOTLIGHT, NOTIFICATIONCENTER, NOTIFICATIONBANNER};
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
            .blurRadius       = r.blurRadius,
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
            .shadowFill    = r.shadowFill,
            .shadowVibrancy = r.shadowVibrancy,
            .keySpread     = float(clampedLinear(D, 96, 191, 80, 90)),
            .keyYcc        = f.keyYcc,
            .keyAmount     = r.keyAmount,
            .diffuseAmount = r.diffuseAmount,
            .keyScale      = r.keyScale,
            .darkBias      = f.darkBias,
            .darkSpread    = f.darkSpread,
            .darkToneCap   = dark ? r.darkToneCap : 0,
            .darkToneKnee  = r.darkToneKnee,
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
            res.backdropScale = backdropScale(r.blurRadius * res.blurAlpha[0], fills ? 8 : 0, bf.normal, res.fill.a);
        } else if (r.family == eFamily::CLEAR) {
            // ClearDiffusionAmount (0x195efeb9c): below 0.5 the blur radius x 2a (sharp at 0; the opacities stay), above a
            // blur fill of radius 8 with normal opacity 2a - 1
            if (a < 0.5)
                res.blurRadius *= float(2 * a);
            else if (a > 0.5)
                res.blurFill = {0, 0, float(2 * a - 1)};
        }
        return res;
    }

    bool hasShadow(const SRecipe& r) {
        return r.shadowOpacityLo > 0 || r.shadowOpacityHi > 0 || r.shadowOpacityHiDark > 0;
    }

    float gradientOvalization(double w, double h) {
        return std::min(w, h) > OVALIZATION_MIN_SIDE ? float(OVALIZATION) : 0.f;
    }

    bool hysteresisDark(bool wasDark, double luminance, double low, double high) {
        if (wasDark)
            return luminance <= high;
        return luminance < low;
    }
}
