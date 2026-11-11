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
        float                                        roundingPower   = 0.f;  // 0 = Apple's continuous corner (supercircle_sdf); >= 1 = Lp superellipse

        float                                        refractionScale = 1, aberration = 0; // Apple: no aberration on background glass

        int                                          appearance = 0;                   // 0 auto, 1 light, 2 dark
        float                                        adaptLow = 0.1f, adaptHigh = 0.3f; // V2 light range (SPEC 9.6)

        float                                        highlight = 1; // scales the key/fill highlight (1 = Apple)
        float                                        appearanceFade = 0.5f; // s, the snapshot's fade after an appearance switch (0 = off)
        float                                        appearanceHold = 0.15f; // s at full opacity before it (ours: there is no client acknowledgement here)
        float                                        dither = 1; // noise of half a level where the glass draws a slow gradient (0 = off)
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
        // ns -> Apple blur radius (pt) of a panel blur drawn behind the layer's glass, over the box of its shapes: the Control
        // Center panel blurs the desktop between and under its tiles (MAC-ANSWERS C2 3, REFRACTION.md "Panel blur")
        std::unordered_map<std::string, double>      panelBlur;

        // ns -> signed fill amount (0..1, > 0 plus-lighter, < 0 plus-darker): every shape of that layer is a compositing
        // fill over what lies under it, drawn before the layer's own content (Shape.hpp SGlassShape::fill)
        std::unordered_map<std::string, double>      fillLayers;

        // glass behind the xdg_popups of windows whose class matches (PopupGlass.cpp): a client's context menu
        std::string                                  popupClasses = "^hyprk-finder$";
        std::string                                  popupMaterial = "menu";
        float                                        popupRadius   = 12; // Q-menubar-13: menu glass corner radius 12

        bool                                         fullDamage    = false; // true: redraw the whole output while glass is visible
        bool                                         stats         = false; // GPU timestamp queries, `hyprctl liquidglass`
        bool                                         windowShadow  = false; // AppKit's window shadow (WindowShadow.hpp) instead of Hyprland's
        bool                                         windowRim     = false; // the 1 pt white rim inside every window (Q-windows-03)
        bool                                         linearLight   = false; // 1: shader in linear light (recipes are tuned for 0, see README)
        bool                                         requireRegion = true;  // no blur region -> no glass
        std::string                                  shaderPath;
        std::string                                  windowClasses;     // regex; empty = no window glass
        float                                        windowRadius = -1; // < 0: the window's rounding

        // macOS title bar for windows without their own (Titlebar.cpp)
        int                                          titlebar = 1; // 0 off, 1 auto (client asked for server-side decorations), 2 classes only
        std::string                                  titlebarClasses;  // regex: always get a bar
        std::string                                  titlebarExclude = TITLEBAR_EXCLUDE; // regex: never (they draw their own)
        float                                        titlebarHeight = 32, titlebarButton = 14, titlebarGap = 9, titlebarInset = 9, titlebarFontSize = 13;
        // colours are set from the hex defaults in Config.cpp's key table
        SRgba                                        titlebarColor, titlebarColorInactive, titlebarText, titlebarTextInactive;
        std::string                                  titlebarFont = "SF Pro Text";
        bool                                         titlebarGlass = false; // light glass (Hyprland blur + translucent fill)
        bool                                         titlebarAutoColor = true; // take the colour of the client's top rows

        // compiled once per snapshot from the regex strings above (nullopt: empty or invalid)
        std::optional<std::regex>                    popupRegex, windowRegex, titlebarClassesRegex, titlebarExcludeRegex;
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

    // `fill_layers` entry of a namespace: the signed fill amount (> 0 lighter, < 0 darker), 0 none
    double fillFor(const SParams& p, const std::string& ns);
    // "ns:lighter, ns2:darker, ns3:lighter:125" -> {{ns, 65/255}, {ns2, -57/255}, {ns3, 125/255}}: an optional third field
    // is the amount in 1/255 (0 < a <= 255; the default amounts are the Cmd-Tab tile's); other items are skipped
    std::unordered_map<std::string, double> parseFillMap(std::string_view s);

    // Apple blur radius (pt) of the panel blur behind a namespace's glass (`panel_blur`), 0 = none
    double panelBlurFor(const SParams& p, const std::string& ns);

    // Hyprland side (Config.cpp, needs the compositor)
    void registerConfig(void* handle);
    // shared snapshot, rebuilt only when a config value changed
    std::shared_ptr<const SParams> readConfig();
    void                           unregisterConfig();
}
