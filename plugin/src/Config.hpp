#pragma once
// Plugin config: every key lives under plugin:liquidglass:<name>
// (Lua: hl.config({ plugin = { liquidglass = { ... } } })).

#include "Shape.hpp"

#include <memory>
#include <string>
#include <unordered_map>
#include <vector>

namespace lg {

    // Snapshot of all values. Lengths are logical px (pt).
    // Material numbers (face YCC, refraction, blur, shadow, ring) come from the recipes in
    // Material.hpp; the keys here pick a recipe per namespace and scale the result.
    struct SParams {
        bool                                         enabled = true;
        std::vector<std::string>                     namespaces;
        std::unordered_map<std::string, double>      radii;
        std::unordered_map<std::string, std::string> materials;              // ns -> recipe
        std::string                                  defaultMaterial = "regular";
        std::string                                  windowMaterial  = "regular";
        float                                        defaultRadius   = -1;   // < 0: infer from the client's blur region
        float                                        roundingPower   = 2.6f; // Apple's continuous corner is close to 2.6-3

        float                                        blurLod = 0, blurLodScale = 0.6f; // extra mip blur: blurLod + scale*log2(1 + recipe radius)
        float                                        refractionScale = 1, aberration = 1.5f;

        int                                          appearance = 0;                   // 0 auto, 1 light, 2 dark
        float                                        adaptLow = 0.1f, adaptHigh = 0.3f; // V2 light range (SPEC 9.6)

        float                                        lightAngle = -50, highlight = 1, highlightWidth = 1.5f, highlightSpread = 0.09f, highlightCurve = 0.5f, rim = 0.5f;
        float                                        lift = 1; // scales each recipe's light-side lift (0 = none)
        float                                        innerShadow = 0.06f, innerShadowSize = 8;
        float                                        shadowScale = 1, shadowTint = 0.35f, ringScale = 1;

        bool                                         fullDamage    = false; // true: redraw the whole output while glass is visible
        bool                                         requireRegion = true;  // no blur region -> no glass
        std::string                                  shaderPath;
        std::string                                  windowClasses;     // regex; empty = no window glass
        float                                        windowRadius = -1; // < 0: the window's rounding
    };

    // "auto" / "light" / "dark" -> 0/1/2, unknown -> 0
    int parseAppearance(const std::string& s);

    // corner radius for a namespace: explicit map entry, else default, else inferred
    double radiusFor(const SParams& p, const std::string& ns, double inferred);

    bool namespaceMatches(const SParams& p, const std::string& ns);

    const std::string& materialFor(const SParams& p, const std::string& ns);

    // Hyprland side (Config.cpp, needs the compositor)
    void registerConfig(void* handle);
    // shared snapshot, rebuilt only when a config value changed
    std::shared_ptr<const SParams> readConfig();
    void                           unregisterConfig();
}
