#pragma once
// Pure geometry helpers (no Hyprland includes) so they can be unit tested.

#include <string>
#include <string_view>
#include <unordered_map>
#include <vector>

namespace lg {

    struct SRect {
        double x = 0, y = 0, w = 0, h = 0;
        double right() const { return x + w; }
        double bottom() const { return y + h; }
    };

    struct SGlassShape {
        SRect  box;
        double radius = 0; // inferred corner radius in the same units as box
    };

    // Groups touching/overlapping rects (a rasterised rounded region arrives as a
    // staircase of rects) into one box each, and infers the corner radius from the
    // height of the staircase at the left edge.
    std::vector<SGlassShape> clusterRegion(const std::vector<SRect>& rects);

    // Signed distance to a rounded rect whose corners are Lp superellipses
    // (power 2 = circle). p is relative to the box centre, half = half size.
    // Negative inside. Mirrors sdShape() in shaders/liquidglass.frag.
    double sdRoundedBox(double px, double py, double halfW, double halfH, double radius, double power);

    // Apple's quarter-circle bevel profile, 1 at the edge, 0 at depth >= height.
    double bevel(double depth, double height);

    // "a,b , c" -> {"a","b","c"}; empty items dropped.
    std::vector<std::string> splitList(std::string_view s);

    // "hyprk-dock:26, hyprk-menubar:0" -> {{"hyprk-dock",26},{"hyprk-menubar",0}}.
    // Items without a valid number are skipped.
    std::unordered_map<std::string, double> parseNumberMap(std::string_view s);

    // "hyprk-dock:dock, x:regular" -> {{"hyprk-dock","dock"},{"x","regular"}}
    std::unordered_map<std::string, std::string> parseStringMap(std::string_view s);

}
