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

        struct SFloatKey {
            const char*   name;
            float SParams::*member;
            float         def;
        };

        const SParams DEFAULTS{};

        // name, field, default. Defaults are tuned by eye against reference/screens
        // (Apple's per-material numbers are not recovered, SPEC section 4).
#define F(key, field) SFloatKey{"plugin:liquidglass:" key, &SParams::field, DEFAULTS.field}
        const SFloatKey FLOATS[] = {
            F("default_radius", defaultRadius),
            F("rounding_power", roundingPower),
            F("blur_lod", blurLod),
            F("edge_blur_lod", edgeBlurLod),
            F("blur_edge_distance", blurEdgeDistance),
            F("refraction", refraction),
            F("refraction_height", refractionHeight),
            F("aberration", aberration),
            F("saturation", saturation),
            F("brightness_light", brightnessLight),
            F("brightness_dark", brightnessDark),
            F("adapt_threshold", adaptThreshold),
            F("adapt_softness", adaptSoftness),
            F("light_angle", lightAngle),
            F("highlight", highlight),
            F("highlight_width", highlightWidth),
            F("highlight_spread", highlightSpread),
            F("rim", rim),
            F("inner_shadow", innerShadow),
            F("inner_shadow_size", innerShadowSize),
            F("shadow_opacity", shadowOpacity),
            F("shadow_radius", shadowRadius),
            F("shadow_offset_y", shadowOffsetY),
            F("ring_opacity", ringOpacity),
            F("ring_width", ringWidth),
            F("window_radius", windowRadius),
        };
#undef F

        constexpr auto K_ENABLED = "plugin:liquidglass:enabled", K_NAMESPACES = "plugin:liquidglass:namespaces", K_RADII = "plugin:liquidglass:radii",
                       K_TINT_LIGHT = "plugin:liquidglass:tint_light", K_TINT_DARK = "plugin:liquidglass:tint_dark", K_APPEARANCE = "plugin:liquidglass:appearance",
                       K_FULL_DAMAGE = "plugin:liquidglass:full_damage", K_REQUIRE_REGION = "plugin:liquidglass:require_region", K_SHADER = "plugin:liquidglass:shader_path", K_WINDOWS = "plugin:liquidglass:window_classes";

        // shell namespaces (shell/modules/*.qml); launchpad and wallpaper stay plain
        constexpr auto DEF_NAMESPACES = "hyprk-menubar,hyprk-dock,hyprk-overlay,hyprk-notifications,hyprk-spotlight,hyprk-switcher";
        constexpr auto DEF_RADII      = "hyprk-menubar:0";
        constexpr long long DEF_TINT_LIGHT = 0xFFFFFF33, DEF_TINT_DARK = 0x1C1C1E38;

        struct SCache {
            std::vector<CConfigValue<Config::FLOAT>> floats;
            CConfigValue<Config::INTEGER>            enabled, fullDamage, requireRegion, tintLight, tintDark;
            CConfigValue<Config::STRING>             namespaces, radii, appearance, shader, windows;
        };
        std::unique_ptr<SCache> g_cache;
    }

    void registerConfig(void* handle) {
        for (const auto& f : FLOATS)
            HyprlandAPI::addConfigValueV2(handle, makeShared<CFloatValue>(f.name, "", f.def));
        HyprlandAPI::addConfigValueV2(handle, makeShared<CIntValue>(K_ENABLED, "draw liquid glass (0 = plain Hyprland blur)", 1));
        HyprlandAPI::addConfigValueV2(handle, makeShared<CIntValue>(K_FULL_DAMAGE, "redraw the whole output when glass is visible", 1));
        HyprlandAPI::addConfigValueV2(handle, makeShared<CIntValue>(K_REQUIRE_REGION, "only glass layers that set a blur region", 1));
        HyprlandAPI::addConfigValueV2(handle, makeShared<CIntValue>(K_TINT_LIGHT, "0xRRGGBBAA light tint, AA = amount", DEF_TINT_LIGHT));
        HyprlandAPI::addConfigValueV2(handle, makeShared<CIntValue>(K_TINT_DARK, "0xRRGGBBAA dark tint, AA = amount", DEF_TINT_DARK));
        HyprlandAPI::addConfigValueV2(handle, makeShared<CStringValue>(K_NAMESPACES, "comma list of layer namespaces, * = all", Config::STRING{DEF_NAMESPACES}));
        HyprlandAPI::addConfigValueV2(handle, makeShared<CStringValue>(K_RADII, "ns:radius list", Config::STRING{DEF_RADII}));
        HyprlandAPI::addConfigValueV2(handle, makeShared<CStringValue>(K_APPEARANCE, "auto | light | dark", Config::STRING{"auto"}));
        HyprlandAPI::addConfigValueV2(handle, makeShared<CStringValue>(K_SHADER, "override fragment shader file", Config::STRING{""}));
        HyprlandAPI::addConfigValueV2(handle, makeShared<CStringValue>(K_WINDOWS, "regex of window classes that get glass", Config::STRING{""}));

        g_cache = std::make_unique<SCache>();
        for (const auto& f : FLOATS)
            g_cache->floats.emplace_back(f.name);
        g_cache->enabled.bind(K_ENABLED);
        g_cache->fullDamage.bind(K_FULL_DAMAGE);
        g_cache->requireRegion.bind(K_REQUIRE_REGION);
        g_cache->tintLight.bind(K_TINT_LIGHT);
        g_cache->tintDark.bind(K_TINT_DARK);
        g_cache->namespaces.bind(K_NAMESPACES);
        g_cache->radii.bind(K_RADII);
        g_cache->appearance.bind(K_APPEARANCE);
        g_cache->shader.bind(K_SHADER);
        g_cache->windows.bind(K_WINDOWS);
    }

    void unregisterConfig() {
        g_cache.reset();
    }

    std::shared_ptr<const SParams> readConfig() {
        static std::shared_ptr<const SParams> last = std::make_shared<SParams>();
        if (!g_cache)
            return last;

        // raw values first: cheap to compare, parsed only when something differs
        struct SRaw {
            std::vector<float>       floats;
            std::array<long long, 5> ints;
            std::array<std::string, 5> strings;
            bool operator==(const SRaw&) const = default;
        };
        static SRaw lastRaw;
        SRaw        raw;
        raw.floats.reserve(std::size(FLOATS));
        for (const auto& v : g_cache->floats)
            raw.floats.push_back(*v);
        raw.ints    = {*g_cache->enabled, *g_cache->fullDamage, *g_cache->requireRegion, *g_cache->tintLight, *g_cache->tintDark};
        raw.strings = {*g_cache->namespaces, *g_cache->radii, *g_cache->appearance, *g_cache->shader, *g_cache->windows};
        if (raw == lastRaw)
            return last;

        auto p = std::make_shared<SParams>();
        for (size_t i = 0; i < std::size(FLOATS); ++i)
            if (std::isfinite(raw.floats[i]))
                (*p).*(FLOATS[i].member) = raw.floats[i];
        p->enabled       = raw.ints[0] != 0;
        p->fullDamage    = raw.ints[1] != 0;
        p->requireRegion = raw.ints[2] != 0;
        p->tintLight     = colorFromRGBA(raw.ints[3]);
        p->tintDark      = colorFromRGBA(raw.ints[4]);
        p->namespaces    = splitList(raw.strings[0]);
        p->radii         = parseNumberMap(raw.strings[1]);
        p->appearance    = parseAppearance(raw.strings[2]);
        p->shaderPath    = raw.strings[3];
        p->windowClasses = raw.strings[4];
        p->roundingPower = std::max(p->roundingPower, 1.f);

        lastRaw = std::move(raw);
        last    = std::move(p);
        return last;
    }
}
