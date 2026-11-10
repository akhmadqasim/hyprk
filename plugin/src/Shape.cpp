#include "Shape.hpp"

#include <algorithm>
#include <charconv>
#include <cmath>
#include <numeric>

#include <hyprutils/string/String.hpp>
#include <hyprutils/string/VarList.hpp>

namespace lg {

    static bool touches(const SRect& a, const SRect& b) {
        // overlapping or sharing an edge (a staircase band sits right on top of the next one)
        return a.x <= b.right() && b.x <= a.right() && a.y <= b.bottom() && b.y <= a.bottom() &&
            // a shared corner point alone does not join two shapes
            !((a.right() == b.x || b.right() == a.x) && (a.bottom() == b.y || b.bottom() == a.y));
    }

    std::vector<SGlassShape> clusterRegion(const std::vector<SRect>& rects) {
        const size_t        n = rects.size();
        std::vector<size_t> parent(n);
        std::iota(parent.begin(), parent.end(), 0);
        auto find = [&](size_t i) {
            while (parent[i] != i)
                i = parent[i] = parent[parent[i]];
            return i;
        };

        for (size_t i = 0; i < n; ++i)
            for (size_t j = i + 1; j < n; ++j)
                if (touches(rects[i], rects[j]))
                    parent[find(i)] = find(j);

        std::vector<SGlassShape> out;
        std::vector<long>        slot(n, -1);
        for (size_t i = 0; i < n; ++i) {
            if (rects[i].w <= 0 || rects[i].h <= 0)
                continue;
            const size_t root = find(i);
            if (slot[root] < 0) {
                slot[root] = static_cast<long>(out.size());
                out.push_back({rects[i], -1});
                continue;
            }
            auto&        b  = out[slot[root]].box;
            const double x2 = std::max(b.right(), rects[i].right()), y2 = std::max(b.bottom(), rects[i].bottom());
            b.x             = std::min(b.x, rects[i].x);
            b.y             = std::min(b.y, rects[i].y);
            b.w             = x2 - b.x;
            b.h             = y2 - b.y;
        }

        // radius: first y at which the cluster reaches its left edge, minus the top
        for (size_t i = 0; i < n; ++i) {
            const size_t root = find(i);
            if (rects[i].w <= 0 || rects[i].h <= 0 || slot[root] < 0)
                continue;
            auto& shape = out[slot[root]];
            if (rects[i].x <= shape.box.x) {
                const double stair = rects[i].y - shape.box.y;
                if (shape.radius < 0 || stair < shape.radius)
                    shape.radius = stair;
            }
        }
        for (auto& s : out) {
            // a rasterised quarter circle reaches the edge sqrt(r) rows early (inset < 0.5px):
            // stair = r - sqrt(r)  =>  r = ((1 + sqrt(1 + 4 stair)) / 2)^2
            if (s.radius > 0) {
                const double root = (1.0 + std::sqrt(1.0 + 4.0 * s.radius)) / 2.0;
                s.radius          = root * root;
            }
            s.radius = std::clamp(s.radius, 0.0, std::min(s.box.w, s.box.h) / 2.0);
        }

        return out;
    }

    double takeOpacityMarker(std::vector<SRect>& rects, double surfaceW, double surfaceH) {
        if (surfaceW <= 1 || surfaceH <= 0)
            return 1;
        const auto it = std::ranges::find_if(rects, [&](const SRect& r) { return r.w <= 3 && r.h <= 3 && r.bottom() >= surfaceH - 0.5; });
        if (it == rects.end())
            return 1;
        const double opacity = std::clamp(it->x / (surfaceW - 1), 0.0, 1.0);
        rects.erase(it);
        return opacity;
    }

    double sdRoundedBox(double px, double py, double halfW, double halfH, double radius, double power) {
        radius        = std::clamp(radius, 0.0, std::min(halfW, halfH));
        power         = std::max(power, 1.0);
        const double qx = std::abs(px) - halfW + radius, qy = std::abs(py) - halfH + radius;
        const double mx = std::max(qx, 0.0), my = std::max(qy, 0.0);
        const double c  = (mx > 0 || my > 0) ? std::pow(std::pow(mx, power) + std::pow(my, power), 1.0 / power) : 0.0;
        return c + std::min(std::max(qx, qy), 0.0) - radius;
    }

    double bevel(double depth, double height) {
        if (height <= 0)
            return 0;
        const double t = std::clamp(depth / height, 0.0, 1.0);
        return 1.0 - std::clamp(std::sqrt(std::max((2.0 - t) * t, 0.0)), 0.0, 1.0);
    }

    std::vector<std::string> splitList(std::string_view s) {
        std::vector<std::string> out;
        for (const auto& item : Hyprutils::String::CVarList{std::string{s}, 0, ','}) {
            if (auto t = Hyprutils::String::trim(item); !t.empty())
                out.push_back(std::move(t));
        }
        return out;
    }

    std::unordered_map<std::string, std::string> parseStringMap(std::string_view s) {
        std::unordered_map<std::string, std::string> out;
        for (const auto& item : splitList(s)) {
            const auto colon = item.rfind(':');
            if (colon == std::string::npos)
                continue;
            const auto key   = Hyprutils::String::trim(std::string_view{item}.substr(0, colon));
            const auto value = Hyprutils::String::trim(std::string_view{item}.substr(colon + 1));
            if (!key.empty() && !value.empty())
                out[std::string{key}] = std::string{value};
        }
        return out;
    }

    std::unordered_map<std::string, double> parseNumberMap(std::string_view s) {
        std::unordered_map<std::string, double> out;
        for (const auto& [key, num] : parseStringMap(s)) {
            double     value        = 0;
            const auto [ptr, ec]    = std::from_chars(num.data(), num.data() + num.size(), value);
            if (ec == std::errc{} && ptr == num.data() + num.size())
                out[key] = value;
        }
        return out;
    }
}
