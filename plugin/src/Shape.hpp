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
        // materialize progress 0..1 (Liquid Glass appear/disappear ramp), from a materialize hole
        double materialize = 1;
    };

    // Shapes drawn as one smooth-union SDF (GlassEffectContainer-like): indices into the shape list.
    // `lead` is the shape with the largest area; its size picks the size-relative recipe values,
    // like Apple's minimumDistanceOfLargestArea.
    struct SGlassGroup {
        std::vector<size_t> members;
        SRect               box; // bounding box of the members
        size_t              lead = 0;
    };
    inline constexpr size_t MAX_GROUP = 8; // must match MAX_SHAPES in shaders/liquidglass.frag

    // Groups touching/overlapping rects (a rasterised rounded region arrives as a
    // staircase of rects) into one box each, and infers the corner radius from the
    // height of the staircase at the left edge.
    // A materialize hole (hyprk Glass.qml) is a 1x1 gap in the shape's middle row: x = left + 1 +
    // round(m * (w - 3)). It arrives as two 1 px tall rects of the same cluster 1 px apart and sets
    // SGlassShape::materialize = m; shapes without one stay at 1.
    std::vector<SGlassShape> clusterRegion(const std::vector<SRect>& rects);

    // Groups shapes whose boxes are closer than `smoothK` (the smooth union's reach, px; 0 = every
    // shape alone) into one group each, at most MAX_GROUP shapes per group.
    std::vector<SGlassGroup> groupShapes(const std::vector<SGlassShape>& shapes, double smoothK);

    // Polynomial smooth minimum (iq), as smin() in the shader: equals min(a, b) when |a - b| >= k.
    double smoothMin(double a, double b, double k);

    // Glass opacity marker (hyprk ShellWindow.glassOpacity): a 1x1 rect in the bottom row
    // edge of the surface, opacity = x / (surfaceW - 1). It lets the shell fade the compositor glass with
    // its content, in the same commit. Removes the marker from rects; returns 1 when there is none.
    double takeOpacityMarker(std::vector<SRect>& rects, double surfaceW, double surfaceH);

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
