#include "Config.hpp"

#include <hyprland/src/config/ConfigValue.hpp>
#include <hyprland/src/config/values/ConfigValues.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>

#include <algorithm>
#include <array>
#include <cmath>
#include <memory>

namespace lg {
    namespace {
        using namespace Config::Values;

        const SParams DEFAULTS{};

        struct SFloatKey {
            const char* name;
            float SParams::*member;
        };
        struct SIntKey {
            const char* name;
            long long   def;
            void (*apply)(SParams&, long long);
        };
        struct SStringKey {
            const char* name;
            const char* def;
            void (*apply)(SParams&, const std::string&);
        };

#define K(key) "plugin:liquidglass:" key
        const SFloatKey FLOATS[] = {
            {K("default_radius"), &SParams::defaultRadius},
            {K("rounding_power"), &SParams::roundingPower},
            {K("refraction_scale"), &SParams::refractionScale},
            {K("aberration"), &SParams::aberration},
            {K("adapt_low"), &SParams::adaptLow},
            {K("adapt_high"), &SParams::adaptHigh},
            {K("highlight"), &SParams::highlight},
            {K("tint_amount"), &SParams::tintAmount},
            {K("appearance_fade"), &SParams::appearanceFade},
            {K("appearance_hold"), &SParams::appearanceHold},
            {K("shadow_scale"), &SParams::shadowScale},
            {K("shadow_tint"), &SParams::shadowTint},
            {K("ring_scale"), &SParams::ringScale},
            {K("window_radius"), &SParams::windowRadius},
            {K("popup_radius"), &SParams::popupRadius},
            {K("titlebar_height"), &SParams::titlebarHeight},
            {K("titlebar_button"), &SParams::titlebarButton},
            {K("titlebar_gap"), &SParams::titlebarGap},
            {K("titlebar_inset"), &SParams::titlebarInset},
            {K("titlebar_font_size"), &SParams::titlebarFontSize},
        };

        const SIntKey INTS[] = {
            {K("enabled"), 1, [](SParams& p, long long v) { p.enabled = v != 0; }},
            {K("full_damage"), 0, [](SParams& p, long long v) { p.fullDamage = v != 0; }},
            {K("linear"), 0, [](SParams& p, long long v) { p.linearLight = v != 0; }},
            {K("titlebar_auto_color"), 1, [](SParams& p, long long v) { p.titlebarAutoColor = v != 0; }},
            {K("titlebar_glass"), 0, [](SParams& p, long long v) { p.titlebarGlass = v != 0; }},
            {K("titlebar_color"), 0xF3F1EFFF, [](SParams& p, long long v) { p.titlebarColor = rgbaFromHex(v); }},
            {K("titlebar_color_inactive"), 0xF6F5F4FF, [](SParams& p, long long v) { p.titlebarColorInactive = rgbaFromHex(v); }},
            {K("titlebar_text"), 0x000000B3, [](SParams& p, long long v) { p.titlebarText = rgbaFromHex(v); }},
            {K("titlebar_text_inactive"), 0x00000040, [](SParams& p, long long v) { p.titlebarTextInactive = rgbaFromHex(v); }},
            {K("stats"), 0, [](SParams& p, long long v) { p.stats = v != 0; }},
            {K("window_shadow"), 0, [](SParams& p, long long v) { p.windowShadow = v != 0; }},
            {K("window_rim"), 0, [](SParams& p, long long v) { p.windowRim = v != 0; }},
            {K("reduce_motion"), 0, [](SParams& p, long long v) { p.reduceMotion = v != 0; }},
            {K("require_region"), 1, [](SParams& p, long long v) { p.requireRegion = v != 0; }},
        };

        // shell namespaces (shell/modules/*.qml); launchpad, mission control and wallpaper stay plain.
        // No hyprk-menubar: the 27.2.1 menu bar has no glass (SkyLight SolariumMenuBarContext, title and
        // status pills are a blurred, colour-matrixed backdrop; reference/re/MENUBAR-REA-27.2.1.md).
        // hyprk-controlcenter is reserved for the shell splitting Control Center out of hyprk-overlay,
        // hyprk-notificationcenter for Notification Center leaving hyprk-overlay (its cards are not menu glass).
        const SStringKey STRINGS[] = {
            {K("namespaces"), "hyprk-dock,hyprk-overlay,hyprk-controlcenter,hyprk-notifications,hyprk-notificationcenter,hyprk-spotlight,hyprk-switcher",
             [](SParams& p, const std::string& v) { p.namespaces = splitList(v); }},
            {K("radii"), "", [](SParams& p, const std::string& v) { p.radii = parseNumberMap(v); }},
            {K("materials"),
             "hyprk-dock:dock,hyprk-controlcenter:controlcenter,hyprk-overlay:menu,hyprk-spotlight:spotlight,"
             "hyprk-notifications:notificationcenter,hyprk-notificationcenter:notificationcenter",
             [](SParams& p, const std::string& v) { p.materials = parseStringMap(v); }},
            // SwiftUI's default spacing 8 (Spacing.defaultValue): CC tiles 12 apart stay separate at rest,
            // Spotlight's mode buttons fuse with the field only while they emerge from it
            {K("spacing"), "hyprk-controlcenter:8,hyprk-dock:8,hyprk-overlay:8,hyprk-spotlight:8",
             [](SParams& p, const std::string& v) { p.spacing = parseNumberMap(v); }},
            // a blur the Mac has under that glass, composed into the glass's own reads (no pass of its own); unused since the
            // Control Center panel blur is drawn (panel_blur)
            {K("underlay_blur"), "", [](SParams& p, const std::string& v) { p.underlay = parseNumberMap(v); }},
            // the Control Center panel blur, drawn behind the tiles, which then sample it as on the Mac: Apple's pyramid at radius
            // 1.79 pt fits the Mac's gap between tiles over 4 pt stripes (rms 0.47 levels, 400 px; REFRACTION.md "Panel blur")
            {K("panel_blur"), "hyprk-controlcenter:1.79", [](SParams& p, const std::string& v) { p.panelBlur = parseNumberMap(v); }},
            // plus-lighter / plus-darker fill layers (none by default; the shell's surfaces opt in by namespace)
            {K("fill_layers"), "", [](SParams& p, const std::string& v) { p.fillLayers = parseFillMap(v); }},
            {K("popup_classes"), "^hyprk-finder$", [](SParams& p, const std::string& v) { p.popupClasses = v; }},
            {K("popup_material"), "menu", [](SParams& p, const std::string& v) { p.popupMaterial = v; }},
            {K("material"), "regular", [](SParams& p, const std::string& v) { p.defaultMaterial = v; }},
            {K("window_material"), "regular", [](SParams& p, const std::string& v) { p.windowMaterial = v; }},
            {K("appearance"), "auto", [](SParams& p, const std::string& v) { p.appearance = parseAppearance(v); }},
            {K("shader_path"), "", [](SParams& p, const std::string& v) { p.shaderPath = v; }},
            {K("titlebar"), "auto", [](SParams& p, const std::string& v) { p.titlebar = parseTitlebarMode(v); }},
            {K("titlebar_classes"), "", [](SParams& p, const std::string& v) { p.titlebarClasses = v; }},
            {K("titlebar_exclude"), TITLEBAR_EXCLUDE, [](SParams& p, const std::string& v) { p.titlebarExclude = v; }},
            {K("titlebar_font"), "SF Pro Text", [](SParams& p, const std::string& v) { p.titlebarFont = v; }},
            {K("window_classes"), "", [](SParams& p, const std::string& v) { p.windowClasses = v; }},
        };
        // keys of the first iteration, still accepted so existing configs load; they do nothing now
        // (the recipes in Material.cpp set face colour, tint and saturation)
        const char* const LEGACY_FLOATS[] = {K("blur_lod"), K("blur_lod_scale"), K("saturation"), K("brightness_light"), K("brightness_dark"), K("blur_edge_distance"), K("edge_blur_lod"),
                                             K("refraction"), K("refraction_height"), K("adapt_threshold"), K("adapt_softness"), K("shadow_opacity"),
                                             K("shadow_radius"), K("shadow_offset_y"), K("ring_opacity"), K("ring_width"),
                                             // by-eye rim of the second iteration, replaced by the 27.2.1 rim (Material.cpp)
                                             K("light_angle"), K("highlight_width"), K("highlight_spread"), K("highlight_curve"), K("rim"),
                                             K("lift"), K("inner_shadow"), K("inner_shadow_size"),
                                             // pointer light of the third iteration: the 27.2.1 light is fixed in layer space (MAC-ANSWERS PC #67 B 4)
                                             K("pointer_light"), K("pointer_light_radius")};
        const char* const LEGACY_STRINGS[] = {K("pointer_light_namespaces")};
        const char* const LEGACY_INTS[]   = {K("tint_light"), K("tint_dark"), K("debug_copy_per_element")};
#undef K

        struct SCache {
            std::array<CConfigValue<Config::FLOAT>, std::size(FLOATS)>   floats;
            std::array<CConfigValue<Config::INTEGER>, std::size(INTS)>   ints;
            std::array<CConfigValue<Config::STRING>, std::size(STRINGS)> strings;
        };
        std::unique_ptr<SCache> g_cache;

        // raw values: cheap to compare, parsed only when something differs
        struct SRaw {
            std::array<float, std::size(FLOATS)>        floats{};
            std::array<long long, std::size(INTS)>      ints{};
            std::array<std::string, std::size(STRINGS)> strings;
            bool                                        operator==(const SRaw&) const = default;
        };
    }

    void registerConfig(void* handle) {
        for (const auto& f : FLOATS)
            HyprlandAPI::addConfigValueV2(handle, makeShared<CFloatValue>(f.name, "", DEFAULTS.*(f.member)));
        for (const auto& i : INTS)
            HyprlandAPI::addConfigValueV2(handle, makeShared<CIntValue>(i.name, "", i.def));
        for (const auto& s : STRINGS)
            HyprlandAPI::addConfigValueV2(handle, makeShared<CStringValue>(s.name, "", Config::STRING{s.def}));

        for (const auto* name : LEGACY_FLOATS)
            HyprlandAPI::addConfigValueV2(handle, makeShared<CFloatValue>(name, "deprecated, ignored", 0.F));
        for (const auto* name : LEGACY_INTS)
            HyprlandAPI::addConfigValueV2(handle, makeShared<CIntValue>(name, "deprecated, ignored", 0));
        for (const auto* name : LEGACY_STRINGS)
            HyprlandAPI::addConfigValueV2(handle, makeShared<CStringValue>(name, "deprecated, ignored", Config::STRING{""}));

        g_cache = std::make_unique<SCache>();
        for (size_t i = 0; i < std::size(FLOATS); ++i)
            g_cache->floats[i].bind(FLOATS[i].name);
        for (size_t i = 0; i < std::size(INTS); ++i)
            g_cache->ints[i].bind(INTS[i].name);
        for (size_t i = 0; i < std::size(STRINGS); ++i)
            g_cache->strings[i].bind(STRINGS[i].name);
    }

    void unregisterConfig() {
        g_cache.reset();
    }

    std::shared_ptr<const SParams> readConfig() {
        static std::shared_ptr<const SParams> last = std::make_shared<SParams>();
        static SRaw                           lastRaw;
        if (!g_cache)
            return last;

        SRaw raw;
        for (size_t i = 0; i < std::size(FLOATS); ++i) {
            const float v = *g_cache->floats[i];
            raw.floats[i] = std::isfinite(v) ? v : DEFAULTS.*(FLOATS[i].member); // NaN never compares equal
        }
        for (size_t i = 0; i < std::size(INTS); ++i)
            raw.ints[i] = *g_cache->ints[i];
        for (size_t i = 0; i < std::size(STRINGS); ++i)
            raw.strings[i] = *g_cache->strings[i];
        if (raw == lastRaw)
            return last;

        auto p = std::make_shared<SParams>();
        for (size_t i = 0; i < std::size(FLOATS); ++i)
            (*p).*(FLOATS[i].member) = raw.floats[i];
        for (size_t i = 0; i < std::size(INTS); ++i)
            INTS[i].apply(*p, raw.ints[i]);
        for (size_t i = 0; i < std::size(STRINGS); ++i)
            STRINGS[i].apply(*p, raw.strings[i]);
        p->roundingPower = p->roundingPower <= 0.f ? 0.f : std::max(p->roundingPower, 1.f);
        p->tintAmount    = std::clamp(p->tintAmount, 0.f, 1.f);
        auto compile = [](const std::string& pattern) -> std::optional<std::regex> {
            if (pattern.empty())
                return std::nullopt;
            try {
                return std::regex(pattern);
            } catch (const std::regex_error&) { return std::nullopt; }
        };
        p->windowRegex          = compile(p->windowClasses);
        p->popupRegex           = compile(p->popupClasses);
        p->titlebarClassesRegex = compile(p->titlebarClasses);
        p->titlebarExcludeRegex = compile(p->titlebarExclude);
        if (p->adaptLow > p->adaptHigh) // an inverted band would flip every readback
            std::swap(p->adaptLow, p->adaptHigh);

        lastRaw = std::move(raw);
        last    = std::move(p);
        return last;
    }
}
