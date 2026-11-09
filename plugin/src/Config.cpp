#include "Config.hpp"

#include <hyprland/src/config/ConfigValue.hpp>
#include <hyprland/src/config/values/ConfigValues.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>

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
            {K("blur_lod"), &SParams::blurLod},
            {K("blur_lod_scale"), &SParams::blurLodScale},
            {K("refraction_scale"), &SParams::refractionScale},
            {K("aberration"), &SParams::aberration},
            {K("adapt_low"), &SParams::adaptLow},
            {K("adapt_high"), &SParams::adaptHigh},
            {K("light_angle"), &SParams::lightAngle},
            {K("highlight"), &SParams::highlight},
            {K("highlight_width"), &SParams::highlightWidth},
            {K("highlight_spread"), &SParams::highlightSpread},
            {K("highlight_curve"), &SParams::highlightCurve},
            {K("rim"), &SParams::rim},
            {K("lift"), &SParams::lift},
            {K("inner_shadow"), &SParams::innerShadow},
            {K("inner_shadow_size"), &SParams::innerShadowSize},
            {K("shadow_scale"), &SParams::shadowScale},
            {K("shadow_tint"), &SParams::shadowTint},
            {K("ring_scale"), &SParams::ringScale},
            {K("window_radius"), &SParams::windowRadius},
            {K("titlebar_height"), &SParams::titlebarHeight},
            {K("titlebar_button"), &SParams::titlebarButton},
            {K("titlebar_gap"), &SParams::titlebarGap},
            {K("titlebar_inset"), &SParams::titlebarInset},
            {K("titlebar_font_size"), &SParams::titlebarFontSize},
        };

        const SIntKey INTS[] = {
            {K("enabled"), 1, [](SParams& p, long long v) { p.enabled = v != 0; }},
            {K("full_damage"), 0, [](SParams& p, long long v) { p.fullDamage = v != 0; }},
            {K("debug_copy_per_element"), 0, [](SParams& p, long long v) { p.copyPerElement = v != 0; }},
            {K("linear"), 0, [](SParams& p, long long v) { p.linearLight = v != 0; }},
            {K("titlebar_glass"), 0, [](SParams& p, long long v) { p.titlebarGlass = v != 0; }},
            {K("titlebar_color"), 0xF3F1EFFF, [](SParams& p, long long v) { p.titlebarColor = rgbaFromHex(v); }},
            {K("titlebar_color_inactive"), 0xF6F5F4FF, [](SParams& p, long long v) { p.titlebarColorInactive = rgbaFromHex(v); }},
            {K("titlebar_text"), 0x333333D9, [](SParams& p, long long v) { p.titlebarText = rgbaFromHex(v); }},
            {K("titlebar_text_inactive"), 0x33333359, [](SParams& p, long long v) { p.titlebarTextInactive = rgbaFromHex(v); }},
            {K("stats"), 0, [](SParams& p, long long v) { p.stats = v != 0; }},
            {K("require_region"), 1, [](SParams& p, long long v) { p.requireRegion = v != 0; }},
        };

        // shell namespaces (shell/modules/*.qml); launchpad, mission control and wallpaper stay plain.
        // hyprk-controlcenter is reserved for the shell splitting Control Center out of hyprk-overlay.
        const SStringKey STRINGS[] = {
            {K("namespaces"), "hyprk-menubar,hyprk-dock,hyprk-overlay,hyprk-controlcenter,hyprk-notifications,hyprk-spotlight,hyprk-switcher",
             [](SParams& p, const std::string& v) { p.namespaces = splitList(v); }},
            {K("radii"), "", [](SParams& p, const std::string& v) { p.radii = parseNumberMap(v); }},
            {K("materials"), "hyprk-dock:dock,hyprk-controlcenter:controlcenter,hyprk-overlay:menu,hyprk-menubar:menu",
             [](SParams& p, const std::string& v) { p.materials = parseStringMap(v); }},
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
        const char* const LEGACY_FLOATS[] = {K("saturation"), K("brightness_light"), K("brightness_dark"), K("blur_edge_distance"), K("edge_blur_lod"),
                                             K("refraction"), K("refraction_height"), K("adapt_threshold"), K("adapt_softness"), K("shadow_opacity"),
                                             K("shadow_radius"), K("shadow_offset_y"), K("ring_opacity"), K("ring_width")};
        const char* const LEGACY_INTS[]   = {K("tint_light"), K("tint_dark")};
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
        p->roundingPower = std::max(p->roundingPower, 1.f);
        auto compile = [](const std::string& pattern) -> std::optional<std::regex> {
            if (pattern.empty())
                return std::nullopt;
            try {
                return std::regex(pattern);
            } catch (const std::regex_error&) { return std::nullopt; }
        };
        p->windowRegex          = compile(p->windowClasses);
        p->titlebarClassesRegex = compile(p->titlebarClasses);
        p->titlebarExcludeRegex = compile(p->titlebarExclude);
        if (p->adaptLow > p->adaptHigh) // an inverted band would flip every readback
            std::swap(p->adaptLow, p->adaptHigh);

        lastRaw = std::move(raw);
        last    = std::move(p);
        return last;
    }
}
