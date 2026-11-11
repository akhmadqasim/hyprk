#include <cstdint>
#include <map>
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

    // a rasterised quarter circle reaches the edge sqrt(r) rows early (inset < 0.5px):
    // stair = r - sqrt(r)  =>  r = ((1 + sqrt(1 + 4 stair)) / 2)^2
    static double stairRadius(double stair) {
        const double root = (1.0 + std::sqrt(1.0 + 4.0 * std::max(stair, 0.0))) / 2.0;
        return stair > 0 ? root * root : stair;
    }

    // Quickshell builds a rounded Region from Qt's ellipse regions with a whole radius (core/region.cpp: the box minus
    // (corner box - QRegion::Ellipse)), and Qt flattens the ellipse to a polygon: the staircase is not a circle's, and
    // the stair formula above read 12 as 13.7, 31 as 37.1 and 32 as 38.2 (24 as 23.9). Per radius 1..128: the rows until
    // the top left corner reaches the left edge, and the cells it leaves out (Qt 6.10.2; a tool that builds the same
    // regions printed it). The cells grow strictly with the radius from 4 on, so a corner that matches a row is that
    // radius exactly; any other staircase (another toolkit, a true circle) keeps the formula.
    static constexpr uint16_t QT_CORNER[][2] = {
        {0, 0}, // r 0
        {0, 0}, {2, 3}, {3, 5}, {2, 3}, {3, 5}, {4, 10}, {7, 18}, {8, 22}, {9, 27}, {10, 33}, {11, 37}, {10, 40},
        {10, 46}, {11, 52}, {12, 56}, {13, 65}, {14, 67}, {14, 75}, {15, 84}, {16, 96}, {17, 110}, {18, 118}, {18, 125}, {19, 139},
        {25, 157}, {26, 172}, {27, 190}, {28, 196}, {29, 210}, {30, 219}, {31, 237}, {32, 255}, {33, 284}, {34, 292}, {35, 298}, {36, 321},
        {37, 333}, {38, 345}, {39, 369}, {40, 392}, {37, 396}, {38, 416}, {39, 425}, {40, 455}, {40, 483}, {41, 493}, {42, 528}, {43, 530},
        {44, 546}, {45, 593}, {46, 601}, {47, 625}, {48, 636}, {48, 666}, {49, 684}, {50, 718}, {51, 753}, {52, 767}, {53, 781}, {54, 814},
        {55, 838}, {56, 870}, {57, 896}, {57, 921}, {58, 959}, {59, 971}, {60, 996}, {61, 1046}, {62, 1052}, {63, 1101}, {64, 1129}, {65, 1153},
        {66, 1185}, {66, 1244}, {67, 1262}, {68, 1294}, {69, 1327}, {70, 1365}, {71, 1409}, {72, 1443}, {73, 1472}, {74, 1518}, {75, 1554}, {75, 1587},
        {76, 1617}, {77, 1667}, {78, 1705}, {79, 1740}, {80, 1758}, {81, 1814}, {82, 1863}, {83, 1877}, {83, 1917}, {84, 1940}, {85, 2004}, {86, 2050},
        {97, 2126}, {98, 2169}, {99, 2217}, {100, 2235}, {101, 2314}, {102, 2324}, {103, 2382}, {104, 2442}, {105, 2481}, {106, 2521}, {107, 2547}, {108, 2616},
        {109, 2690}, {110, 2710}, {111, 2757}, {112, 2829}, {113, 2855}, {114, 2885}, {115, 2954}, {116, 2990}, {117, 3046}, {118, 3091}, {119, 3119}, {120, 3167},
        {121, 3275}, {122, 3332}, {123, 3380}, {124, 3454}, {125, 3495}, {126, 3591}, {127, 3609}, {128, 3649}};

    double cornerRadius(double stair, double cells) {
        const double formula = stairRadius(stair);
        double       best    = -1;
        for (size_t r = 1; r < std::size(QT_CORNER); ++r)
            if (QT_CORNER[r][0] == stair && QT_CORNER[r][1] == cells && (best < 0 || std::abs(double(r) - formula) < std::abs(best - formula)))
                best = double(r); // 2 and 4, 3 and 5 make the same region: the one nearer the formula
        return best > 0 ? best : formula;
    }

    int fractionLevels(double w) {
        return std::clamp(int(std::floor(std::sqrt(std::max(w - 3, 0.0)))), 0, FRACTION_MAX_LEVELS);
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
        // the cells the top left corner leaves out: per band above that row, its leftmost rect
        std::vector<double> cells(out.size(), 0);
        {
            std::vector<std::map<double, std::pair<double, double>>> bands(out.size()); // y -> (min x, height)
            for (size_t i = 0; i < n; ++i) {
                const size_t root = find(i);
                if (rects[i].w <= 0 || rects[i].h <= 0 || slot[root] < 0)
                    continue;
                const auto& shape = out[slot[root]];
                if (shape.radius <= 0 || rects[i].y >= shape.box.y + shape.radius)
                    continue;
                auto [it, fresh] = bands[slot[root]].try_emplace(rects[i].y, rects[i].x, rects[i].h);
                if (!fresh)
                    it->second.first = std::min(it->second.first, rects[i].x);
            }
            for (size_t s = 0; s < out.size(); ++s)
                for (const auto& [y, band] : bands[s])
                    cells[s] += (band.first - out[s].box.x) * std::min(band.second, out[s].box.y + out[s].radius - y);
        }
        // materialize (middle row) and shadow (row below, centre column) holes: two 1 px tall rects of one cluster with
        // exactly 1 px between them. The shell places the holes from the item geometry it measured, Quickshell builds the
        // shape from the geometry at commit; while the shape scales these can differ by a row (HUD appear: the shadow
        // hole landed on the box's middle row and read as materialize 0.5 for one frame, a soft rimless capsule). So the
        // holes are told apart by their structure, not by the exact row: of two hole rows the upper one is materialize;
        // a lone hole at the centre column is the shadow marker (that column does not move while the shape scales about
        // its centre; a materialize hole passes it only around m = 0.5), anywhere else it is materialize.
        // A region arrives as bands of equal rows (pixman), so when the materialize hole passes the shadow hole's column (m
        // about 0.5) the two rows are one band, 2 px tall, split by a 1 x 2 gap: that is both holes, one row each (read as no
        // hole it gave one frame of full material in the middle of the Dock label's fade).
        std::vector<std::vector<SRect>> holes(out.size()); // per shape: the left part of each hole row
        for (size_t i = 0; i < n; ++i) {
            const auto& a = rects[i];
            if ((a.h != 1 && a.h != 2) || a.w <= 0)
                continue;
            for (size_t j = 0; j < n; ++j) {
                const auto& b = rects[j];
                if (j == i || b.h != a.h || b.y != a.y || b.x != a.right() + 1 || find(i) != find(j) || slot[find(i)] < 0)
                    continue;
                for (double y = a.y; y < a.bottom(); ++y)
                    holes[slot[find(i)]].push_back({a.x, y, a.w, 1});
            }
        }
        std::vector<char> roundEnds(out.size(), 0); // a capsule or circle with sub-point edges: radius = half its true size
        for (size_t s = 0; s < out.size(); ++s) {
            auto& found = holes[s];
            if (found.empty())
                continue;
            std::ranges::sort(found, {}, &SRect::y);
            auto& shape = out[s];
            // the pointer marker: a hole at left + 1 in the top row of a plain rect
            if (std::erase_if(found, [&](const SRect& a) { return a.y == shape.box.y && a.x == shape.box.x && a.w == 1; }) > 0) {
                // the marker box hangs 1 pt below the pill (a region is a union: touching, it would merge with it); the
                // square's centre is POINTER_OFFSET above the pill's bottom edge, the box becomes the square's bounds
                shape.pointer    = true;
                const double cx  = shape.box.x + shape.box.w / 2, cy = shape.box.y - 1 - POINTER_OFFSET;
                const double h   = POINTER_SIDE * M_SQRT1_2;
                shape.box        = {cx - h, cy - h, 2 * h, 2 * h};
                shape.radius     = POINTER_RADIUS;
                continue;
            }
            if (found.empty())
                continue;
            const double mid    = shape.box.y + std::floor(shape.box.h / 2);
            const double centre = shape.box.x + std::floor(shape.box.w / 2);
            // sub-point edges (Shape.hpp FRACTION_*): read and taken out before the marker holes, applied after them
            const int    n      = fractionLevels(shape.box.w);
            double       edge[4] = {0, 0, 0, 0}; // left, right, top, bottom: true edge - region edge
            int          edges   = 0;
            if (n >= 2 && shape.box.h >= FRACTION_MIN_H) {
                const double base = centre - std::floor(n * n / 2.0);
                std::erase_if(found, [&](const SRect& a) {
                    const int axis = a.y == mid - FRACTION_ROW_X ? 0 : a.y == mid - FRACTION_ROW_Y ? 1 : -1;
                    const int code = int(a.right() - base);
                    if (axis < 0 || code < 0 || code >= n * n)
                        return false;
                    edge[2 * axis]     = double(code / n) / (n - 1) - 0.5;
                    edge[2 * axis + 1] = double(code % n) / (n - 1) - 0.5;
                    edges |= 1 << axis;
                    return true;
                });
            }
            const auto applyEdges = [&] {
                if (edges != 3)
                    return;
                roundEnds[s] = shape.radius >= 0 && cornerRadius(shape.radius, cells[s]) >= std::min(shape.box.w, shape.box.h) / 2 - 0.5;
                shape.box = {shape.box.x + edge[0], shape.box.y + edge[2], shape.box.w + edge[1] - edge[0], shape.box.h + edge[3] - edge[2]};
            };
            const auto   setMaterialize = [&shape](const SRect& a) {
                if (shape.box.w > 3)
                    shape.materialize = std::clamp((a.right() - shape.box.x - 1) / (shape.box.w - 3), 0.0, 1.0);
            };
            // rows within 2 of where the shell meant them (a row of scale motion per frame at most)
            std::erase_if(found, [&](const SRect& a) { return std::abs(a.y - mid) > 2 && std::abs(a.y - (mid + 1)) > 2; });
            if (found.size() >= 2) {
                for (size_t k = 0; k + 1 < found.size(); ++k)
                    if (found[k + 1].y == found[k].y + 1) {
                        setMaterialize(found[k]);
                        shape.regularShadow = true;
                        break;
                    }
            } else if (found.size() == 1) {
                if (std::abs(found[0].right() - centre) <= 2)
                    shape.regularShadow = true;
                else
                    setMaterialize(found[0]);
            }
            applyEdges();
        }

        for (size_t i = 0; i < out.size(); ++i) {
            auto& s = out[i];
            if (s.pointer)
                continue; // its radius is Apple's, not read from the region
            if (s.radius > 0)
                s.radius = cornerRadius(s.radius, cells[i]);
            s.radius = roundEnds[i] ? std::min(s.box.w, s.box.h) / 2.0 : std::clamp(s.radius, 0.0, std::min(s.box.w, s.box.h) / 2.0);
        }

        return out;
    }

    std::vector<SGlassGroup> groupShapes(const std::vector<SGlassShape>& shapes, double smoothK, double pxPerUnit) {
        const size_t        n = shapes.size();
        SDisjointSet        set(n);
        auto                find = [&](size_t i) { return set.find(i); };
        std::vector<size_t> count(n, 1);
        const double        pointerK = POINTER_SMOOTH / std::max(pxPerUnit, 1e-6);
        const bool          anyPointer = std::ranges::any_of(shapes, &SGlassShape::pointer);
        if (smoothK > 0 || anyPointer) {
            for (size_t i = 0; i < n; ++i)
                for (size_t j = i + 1; j < n; ++j) {
                    const double k = shapes[i].pointer || shapes[j].pointer ? std::max(smoothK, pointerK) : smoothK;
                    const auto& a = shapes[i].box;
                    const auto& b = shapes[j].box;
                    // gap between the boxes (0 when they overlap); the smooth union reaches k
                    const double dx = std::max({0.0, b.x - a.right(), a.x - b.right()});
                    const double dy = std::max({0.0, b.y - a.bottom(), a.y - b.bottom()});
                    const size_t ri = find(i), rj = find(j);
                    if (ri == rj || std::hypot(dx, dy) >= k || count[ri] + count[rj] > MAX_GROUP)
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
                out.push_back({{i}, b, i, smoothK});
                continue;
            }
            auto& g = out[slot[root]];
            g.members.push_back(i);
            unite(g.box, b);
            const auto& lead = shapes[g.lead].box;
            if (b.w * b.h > lead.w * lead.h)
                g.lead = i;
        }
        for (auto& g : out)
            if (g.members.size() > 1 && std::ranges::any_of(g.members, [&](size_t i) { return shapes[i].pointer; }))
                g.smoothK = std::max(smoothK, pointerK);
        return out;
    }

    void pointerFollowsGroup(std::vector<SGlassShape>& shapes, const std::vector<SGlassGroup>& groups) {
        for (const auto& g : groups) {
            const SGlassShape* body = nullptr;
            for (const size_t i : g.members)
                if (!shapes[i].pointer && (!body || shapes[i].box.w * shapes[i].box.h > body->box.w * body->box.h))
                    body = &shapes[i];
            if (!body)
                continue;
            for (const size_t i : g.members)
                if (shapes[i].pointer)
                    shapes[i].materialize = body->materialize;
        }
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
        radius = std::clamp(radius, 0.0, std::min(halfW, halfH));
        if (power <= 0 && radius > 1e-3) {
            // CA::OGL::Metal::ShaderUtils::supercircle_sdf (QuartzCore 27.2.1), as sdBoxN in the shader
            constexpr double K   = 1.528665;
            const double     ax = std::abs(px), ay = std::abs(py), E = radius * K;
            const double     capX = std::clamp((K - halfW / radius) / (K - 1), 0.0, 1.0), capY = std::clamp((K - halfH / radius) / (K - 1), 0.0, 1.0);
            const double     m  = std::lerp(E, radius, std::max(capX, capY));
            const double     qx = ax - halfW + m, qy = ay - halfH + m;
            const double     tx = std::max((ax - halfW + E) / E, 0.0), ty = std::max((ay - halfH + E) / E, 0.0);
            const double     len = std::hypot(tx, ty), mx = std::max(tx, ty);
            const double     x   = mx > 0 ? std::clamp(std::min(tx, ty) / mx, 0.0, 1.0) : 0.0;
            const double     pol = 0.268531 + x * (1.26803 + x * (-3.64122 + x * (3.15601 - 0.926054 * x)));
            const double     fc  = len + 1 - 1 / (1 - x * x * std::clamp(len, 0.0, 1.0) * pol);
            const double     fr  = std::hypot(std::max(tx * K - (K - 1), 0.0), std::max(ty * K - (K - 1), 0.0)) / K + (1 - 1 / K);
            const double     sg  = ty > tx ? 1.0 : -1.0;
            const double     f   = std::lerp(std::lerp(fc, fr, capX), std::lerp(fc, fr, capY), std::clamp(0.5 - sg + sg * x, 0.0, 1.0));
            return std::min(std::max(qx, qy), 0.0) + E * (f - 1);
        }
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
