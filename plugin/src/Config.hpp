#pragma once
// Plugin config: every key lives under plugin:liquidglass:<name>
// (Lua: hl.config({ plugin = { liquidglass = { ... } } })).

#include "Shape.hpp"

#include <string>
#include <unordered_map>
#include <vector>

namespace lg {

    // Snapshot of all values, read once per frame. Lengths are logical px.
    struct SParams {
        bool                                    enabled = true;
        std::vector<std::string>                namespaces;
        std::unordered_map<std::string, double> radii;
        float                                   defaultRadius = -1; // < 0: infer from the client's blur region
        float                                   roundingPower = 2.6f;

        float                                   blurLod = 0.5f, edgeBlurLod = 0.0f, blurEdgeDistance = 14;
        float                                   refraction = 18, refractionHeight = 18, aberration = 1.5f;

        float                                   saturation = 1.4f, brightnessLight = 1.04f, brightnessDark = 0.9f;
        SColor                                  tintLight, tintDark;
        int                                     appearance     = 0; // 0 auto, 1 light, 2 dark
        float                                   adaptThreshold = 0.22f, adaptSoftness = 0.08f;

        float                                   lightAngle = -50, highlight = 0.6f, highlightWidth = 2.0f, highlightSpread = 0.0f, rim = 0.3f;
        float                                   innerShadow = 0.10f, innerShadowSize = 8;

        float                                   shadowOpacity = 0.22f, shadowRadius = 14, shadowOffsetY = 4;
        float                                   ringOpacity = 0.10f, ringWidth = 0.8f;

        bool                                    fullDamage = true;
        bool                                    requireRegion = true; // no blur region -> no glass
        std::string                             shaderPath;
        std::string                             windowClasses; // regex; empty = no window glass
        float                                   windowRadius = -1;  // < 0: decoration:rounding
    };

    // "auto" / "light" / "dark" -> 0/1/2, unknown -> 0
    int parseAppearance(const std::string& s);

    // corner radius for a namespace: explicit map entry, else default, else inferred
    double radiusFor(const SParams& p, const std::string& ns, double inferred);

    bool namespaceMatches(const SParams& p, const std::string& ns);

    // Hyprland side (Config.cpp, needs the compositor)
    void    registerConfig(void* handle);
    SParams readConfig();
    void    unregisterConfig();
}
