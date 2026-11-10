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

    namespace {
        // union-find with path halving
        struct SDisjointSet {
            std::vector<size_t> parent;
            explicit SDisjointSet(size_t n) : parent(n) {
                std::iota(parent.begin(), parent.end(), 0);
            }
            size_t find(size_t i) {
                while (parent[i] != i)
                    i = parent[i] = parent[parent[i]];
                return i;
            }
        };

        // grows `a` to also cover `b`
        void unite(SRect& a, const SRect& b) {
            const double x2 = std::max(a.right(), b.right()), y2 = std::max(a.bottom(), b.bottom());
            a.x             = std::min(a.x, b.x);
            a.y             = std::min(a.y, b.y);
            a.w             = x2 - a.x;
            a.h             = y2 - a.y;
        }
    }

    std::vector<SGlassShape> clusterRegion(const std::vector<SRect>& rects) {
        const size_t n = rects.size();
        SDisjointSet set(n);
        auto         find = [&](size_t i) { return set.find(i); };

        for (size_t i = 0; i < n; ++i)
            for (size_t j = i + 1; j < n; ++j)
                if (touches(rects[i], rects[j]))
                    set.parent[find(i)] = find(j);

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
            unite(out[slot[root]].box, rects[i]);
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
        // materialize holes: two 1 px tall rects of one cluster with exactly 1 px between them
        for (size_t i = 0; i < n; ++i) {
            const auto& a = rects[i];
            if (a.h != 1 || a.w <= 0)
                continue;
            for (size_t j = 0; j < n; ++j) {
                const auto& b = rects[j];
                if (j == i || b.h != 1 || b.y != a.y || b.x != a.right() + 1 || find(i) != find(j) || slot[find(i)] < 0)
                    continue;
                auto& shape = out[slot[find(i)]];
                if (shape.box.w > 3)
                    shape.materialize = std::clamp((a.right() - shape.box.x - 1) / (shape.box.w - 3), 0.0, 1.0);
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

    std::vector<SGlassGroup> groupShapes(const std::vector<SGlassShape>& shapes, double smoothK) {
        const size_t        n = shapes.size();
        SDisjointSet        set(n);
        auto                find = [&](size_t i) { return set.find(i); };
        std::vector<size_t> count(n, 1);
        if (smoothK > 0) {
            for (size_t i = 0; i < n; ++i)
                for (size_t j = i + 1; j < n; ++j) {
                    const auto& a = shapes[i].box;
                    const auto& b = shapes[j].box;
                    // gap between the boxes (0 when they overlap); the smooth union reaches k
                    const double dx = std::max({0.0, b.x - a.right(), a.x - b.right()});
                    const double dy = std::max({0.0, b.y - a.bottom(), a.y - b.bottom()});
                    const size_t ri = find(i), rj = find(j);
                    if (ri == rj || std::hypot(dx, dy) >= smoothK || count[ri] + count[rj] > MAX_GROUP)
                        continue;
                    set.parent[ri] = rj;
                    count[rj] += count[ri];
                }
        }

        std::vector<SGlassGroup> out;
        std::vector<long>        slot(n, -1);
        for (size_t i = 0; i < n; ++i) {
            const size_t root = find(i);
            const auto&  b    = shapes[i].box;
            if (slot[root] < 0) {
                slot[root] = long(out.size());
                out.push_back({{i}, b, i});
                continue;
            }
            auto& g = out[slot[root]];
            g.members.push_back(i);
            unite(g.box, b);
            const auto& lead = shapes[g.lead].box;
            if (b.w * b.h > lead.w * lead.h)
                g.lead = i;
        }
        return out;
    }

    double takeOpacityMarker(std::vector<SRect>& rects, double surfaceW, double surfaceH) {
        if (surfaceW <= 1 || surfaceH <= 0)
            return 1;
        const auto it = std::ranges::find_if(rects, [&](const SRect& r) { return r.w <= 1 && r.h <= 1 && r.bottom() >= surfaceH - 0.5; });
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

    SRect mipFootprint(const SRect& r, int level, double w, double h) {
        const double t  = std::ldexp(1.0, std::max(level, 0)); // texel size at `level`
        const double x1 = std::max(0.0, (std::floor(r.x / t) - 1) * t), y1 = std::max(0.0, (std::floor(r.y / t) - 1) * t);
        const double x2 = std::min(w, (std::floor(r.right() / t) + 2) * t), y2 = std::min(h, (std::floor(r.bottom() / t) + 2) * t);
        return {x1, y1, std::max(0.0, x2 - x1), std::max(0.0, y2 - y1)};
    }
}
