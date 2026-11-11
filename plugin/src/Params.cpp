// Pure parts of the config (unit tested without Hyprland).
#include "Config.hpp"

#include <algorithm>
#include <charconv>

#include <hyprutils/string/String.hpp>
#include <hyprutils/string/VarList.hpp>

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
        return p.reduceMotion || it == p.spacing.end() ? 0.0 : std::max(it->second, 0.0);
    }

    double underlayFor(const SParams& p, const std::string& ns) {
        const auto it = p.underlay.find(ns);
        return it == p.underlay.end() ? 0.0 : std::max(it->second, 0.0);
    }

    double fillFor(const SParams& p, const std::string& ns) {
        const auto it = p.fillLayers.find(ns);
        return it == p.fillLayers.end() ? 0.0 : it->second;
    }

    double cutFillFor(const SParams& p, const std::string& ns) {
        const auto& map = p.appearance == 2 ? p.cutFillsDark : p.cutFills;
        const auto  it  = map.find(ns);
        return it == map.end() ? 0.0 : it->second;
    }

    std::unordered_map<std::string, double> parseFillMap(std::string_view s) {
        std::unordered_map<std::string, double> out;
        for (const auto& item : splitList(s)) {
            const auto f = Hyprutils::String::CVarList{item, 0, ':'};
            if (f.size() < 2 || f.size() > 3 || f[0].empty())
                continue;
            const auto mode = Hyprutils::String::trim(f[1]);
            const int  sign = mode == "lighter" ? 1 : mode == "darker" ? -1 : 0;
            if (sign == 0)
                continue;
            double amount = sign > 0 ? FILL_LIGHTER : FILL_DARKER;
            if (f.size() == 3) {
                const auto num     = Hyprutils::String::trim(f[2]);
                double     v       = 0;
                const auto [p, ec] = std::from_chars(num.data(), num.data() + num.size(), v);
                if (ec != std::errc{} || p != num.data() + num.size() || !(v > 0 && v <= 255))
                    continue;
                amount = v / 255.0;
            }
            out[Hyprutils::String::trim(f[0])] = sign * amount;
        }
        return out;
    }

    std::unordered_map<std::string, SParams::SSdf> parseSdfMap(std::string_view s) {
        std::unordered_map<std::string, SParams::SSdf> out;
        for (const auto& item : splitList(s)) {
            const auto f = Hyprutils::String::CVarList{item, 0, ':'};
            if ((f.size() != 1 && f.size() != 4) || f[0].empty())
                continue;
            SParams::SSdf sdf;
            if (f.size() == 4) {
                double v[3] = {};
                bool   ok   = true;
                for (int i = 0; i < 3 && ok; ++i) {
                    const auto num     = Hyprutils::String::trim(f[i + 1]);
                    const auto [p, ec] = std::from_chars(num.data(), num.data() + num.size(), v[i]);
                    ok                 = ec == std::errc{} && p == num.data() + num.size();
                }
                // one value distance > 0, padding >= 0, the shape left between the paddings
                if (!ok || !(v[0] > 0) || v[1] < 0 || !(v[2] > 2 * v[1]))
                    continue;
                sdf = {v[0] / v[2], (v[2] - 2 * v[1]) / v[2]};
            }
            out[Hyprutils::String::trim(f[0])] = sdf;
        }
        return out;
    }

    double panelBlurFor(const SParams& p, const std::string& ns) {
        const auto it = p.panelBlur.find(ns);
        return it == p.panelBlur.end() ? 0.0 : std::max(it->second, 0.0);
    }

    const std::string& materialFor(const SParams& p, const std::string& ns) {
        const auto it = p.materials.find(ns);
        return it != p.materials.end() ? it->second : p.defaultMaterial;
    }
}
