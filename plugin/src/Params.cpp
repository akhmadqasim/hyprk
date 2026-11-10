// Pure parts of the config (unit tested without Hyprland).
#include "Config.hpp"

#include <algorithm>

namespace lg {
    int parseAppearance(const std::string& s) {
        if (s == "light")
            return 1;
        if (s == "dark")
            return 2;
        return 0;
    }

    double radiusFor(const SParams& p, const std::string& ns, double inferred) {
        if (const auto it = p.radii.find(ns); it != p.radii.end())
            return std::max(it->second, 0.0);
        if (p.defaultRadius >= 0)
            return p.defaultRadius;
        return std::max(inferred, 0.0);
    }

    bool namespaceMatches(const SParams& p, const std::string& ns) {
        return std::ranges::any_of(p.namespaces, [&](const std::string& n) { return n == "*" || n == ns; });
    }
}

namespace lg {
    SRgba rgbaFromHex(long long rgba) {
        const auto c = static_cast<unsigned long long>(rgba) & 0xFFFFFFFFull;
        return {((c >> 24) & 0xFF) / 255.f, ((c >> 16) & 0xFF) / 255.f, ((c >> 8) & 0xFF) / 255.f, (c & 0xFF) / 255.f};
    }

    int parseTitlebarMode(const std::string& s) {
        if (s == "off")
            return 0;
        if (s == "classes")
            return 2;
        return 1;
    }

    double smoothKFor(const SParams& p, const std::string& ns) {
        const auto it = p.spacing.find(ns);
        return p.reduceMotion || it == p.spacing.end() ? 0.0 : 2.0 * std::max(it->second, 0.0);
    }

    bool pointerLightFor(const SParams& p, const std::string& ns) {
        return !p.reduceMotion && p.pointerLight > 0 && std::ranges::find(p.pointerLightNamespaces, ns) != p.pointerLightNamespaces.end();
    }

    const std::string& materialFor(const SParams& p, const std::string& ns) {
        const auto it = p.materials.find(ns);
        return it != p.materials.end() ? it->second : p.defaultMaterial;
    }
}
