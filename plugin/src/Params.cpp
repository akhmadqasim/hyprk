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
    const std::string& materialFor(const SParams& p, const std::string& ns) {
        const auto it = p.materials.find(ns);
        return it != p.materials.end() ? it->second : p.defaultMaterial;
    }
}
