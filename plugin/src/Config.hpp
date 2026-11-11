#pragma once
// Plugin config: every key lives under plugin:liquidglass:<name>
// (Lua: hl.config({ plugin = { liquidglass = { ... } } })).

#include "Material.hpp"
#include "Shape.hpp"

#include <memory>
#include <optional>
#include <regex>
#include <string>
#include <unordered_map>
#include <vector>

namespace lg {

    inline constexpr const char* TITLEBAR_EXCLUDE = R"(^(org\.hyprk\..*|hyprk-.*)$)"; // the hyprk apps draw their own

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

        float                                        refractionScale = 1, aberration = 0; // Apple: no aberration on background glass

        int                                          appearance = 0;                   // 0 auto, 1 light, 2 dark
        float                                        adaptLow = 0.1f, adaptHigh = 0.3f; // V2 light range (SPEC 9.6)

        float                                        highlight = 1; // scales the key/fill highlight (1 = Apple)
        float                                        tintAmount = 0.5f; // Liquid Glass slider (NSGlassTintAmount) 0..1, 0.5 = the recipes as is
        float                                        shadowScale = 1, shadowTint = 0.35f, ringScale = 1;

        // Liquid Glass motion. spacing: ns -> pt, the smoothness k of the union of a layer's shapes
        // (SwiftUI passes GlassEffectContainer(spacing:) straight to CASDFLayer.smoothness, default 8):
        // shapes fuse when the gap is below k / 2 and reach toward each other below k.
        std::unordered_map<std::string, double>      spacing;
        bool                                         reduceMotion = false; // no merging
        // ns -> Apple blur radius (pt) of a layer that sits between the backdrop and the glass on the Mac but not here: the
        // Control Center panel blurs the desktop under its tiles (MAC-ANSWERS C2 3), hyprk's panel is a dim only
        std::unordered_map<std::string, double>      underlay;

        bool                                         fullDamage    = false; // true: redraw the whole output while glass is visible
        bool                                         stats         = false; // GPU timestamp queries, `hyprctl liquidglass`
        bool                                         linearLight   = false; // 1: shader in linear light (recipes are tuned for 0, see README)
        bool                                         requireRegion = true;  // no blur region -> no glass
        std::string                                  shaderPath;
        std::string                                  windowClasses;     // regex; empty = no window glass
        float                                        windowRadius = -1; // < 0: the window's rounding

        // macOS title bar for windows without their own (Titlebar.cpp)
        int                                          titlebar = 1; // 0 off, 1 auto (client asked for server-side decorations), 2 classes only
        std::string                                  titlebarClasses;  // regex: always get a bar
        std::string                                  titlebarExclude = TITLEBAR_EXCLUDE; // regex: never (they draw their own)
        float                                        titlebarHeight = 32, titlebarButton = 14, titlebarGap = 9, titlebarInset = 15, titlebarFontSize = 13;
        // colours are set from the hex defaults in Config.cpp's key table
        SRgba                                        titlebarColor, titlebarColorInactive, titlebarText, titlebarTextInactive;
        std::string                                  titlebarFont = "SF Pro Text";
        bool                                         titlebarGlass = false; // light glass (Hyprland blur + translucent fill)
        bool                                         titlebarAutoColor = true; // take the colour of the client's top rows

        // compiled once per snapshot from the regex strings above (nullopt: empty or invalid)
        std::optional<std::regex>                    windowRegex, titlebarClassesRegex, titlebarExcludeRegex;
    };

    // 0xRRGGBBAA -> rgba 0..1
    SRgba rgbaFromHex(long long rgba);
    int   parseTitlebarMode(const std::string& s); // "off" | "auto" | "classes"


    // "auto" / "light" / "dark" -> 0/1/2, unknown -> 0
    int parseAppearance(const std::string& s);

    // corner radius for a namespace: explicit map entry, else default, else inferred
    double radiusFor(const SParams& p, const std::string& ns, double inferred);

    bool namespaceMatches(const SParams& p, const std::string& ns);

    const std::string& materialFor(const SParams& p, const std::string& ns);

    // smooth-union smoothness k (logical px) for a namespace: its spacing, 0 with reduce_motion
    double smoothKFor(const SParams& p, const std::string& ns);

    // Apple blur radius (pt) of the layer under the glass of a namespace (`underlay_blur`), 0 = none
    double underlayFor(const SParams& p, const std::string& ns);

    // Hyprland side (Config.cpp, needs the compositor)
    void registerConfig(void* handle);
    // shared snapshot, rebuilt only when a config value changed
    std::shared_ptr<const SParams> readConfig();
    void                           unregisterConfig();
}
