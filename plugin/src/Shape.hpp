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
        // shadow marker (hyprk Glass.qml `shadow: false`): a 1x1 hole in the row below the middle one, at the
        // centre column. The shape then takes Regular's drop shadow for its size (probe: 0.04, radius 4 pt at
        // D <= 64) instead of its layer recipe's (hyprk-overlay = menu: 0.7, radius 24 at every size)
        bool regularShadow = false;
        // pointer marker (the Dock label's pointer): a plain rect with a 1x1 hole in its top row at x = left + 1, hanging
        // 1 pt below the pill (its top = pill bottom + 1; touching, the region union would merge the two). The shape is
        // then Apple's cartouche pointer (MAC-ANSWERS "REA 27.2.1" 3, Dock ECCartoucheGlassLayerController): a square of side
        // POINTER_SIDE turned 45 deg, corner radius POINTER_RADIUS, centred on the rect's centre column POINTER_OFFSET above
        // the pill's bottom edge; its box becomes the square's bounds, and its group unions with smoothness POINTER_SMOOTH.
        bool pointer = false;
        // a compositing fill instead of glass (`fill_layers`, every shape of such a layer): the signed amount per channel
        // (0..1) inside the rounded rect, over what lies there: > 0 plus-lighter (dst + fill), < 0 plus-darker
        // (dst - |fill|), 0 = glass. Qt cannot blend with what the compositor drew (the Cmd-Tab selection tile, the Dock's
        // running dots).
        double fill = 0;
    };
    inline constexpr double FILL_LIGHTER = 65.0 / 255.0, FILL_DARKER = 57.0 / 255.0;
    inline constexpr double POINTER_SIDE = 16, POINTER_RADIUS = 2.5, POINTER_OFFSET = 4, POINTER_SMOOTH = 25;

    // Shapes drawn as one smooth-union SDF (GlassEffectContainer-like): indices into the shape list.
    // `lead` is the shape with the largest area; its size picks the size-relative recipe values,
    // like Apple's minimumDistanceOfLargestArea.
    struct SGlassGroup {
        std::vector<size_t> members;
        SRect               box; // bounding box of the members
        size_t              lead = 0;
        double              smoothK = 0; // the union's smoothness: the layer's, POINTER_SMOOTH with a pointer
    };
    inline constexpr size_t MAX_GROUP = 8; // must match MAX_SHAPES in shaders/liquidglass.frag

    // Groups touching/overlapping rects (a rasterised rounded region arrives as a
    // staircase of rects) into one box each, and infers the corner radius from the
    // height of the staircase at the left edge.
    // A materialize hole (hyprk Glass.qml) is a 1x1 gap in the shape's middle row: x = left + 1 +
    // round(m * (w - 3)). It arrives as two 1 px tall rects of the same cluster 1 px apart and sets
    // SGlassShape::materialize = m; shapes without one stay at 1. The same kind of gap one row lower
    // (y = top + floor(h / 2) + 1, x = left + floor(w / 2)) sets SGlassShape::regularShadow.
    std::vector<SGlassShape> clusterRegion(const std::vector<SRect>& rects);

    // A pointer shape has no materialize hole (its marker is a hole of its own): it takes the materialize of the largest
    // other shape of its group (the label pill), so pill and pointer come and go as one shape. Alone it keeps its own.
    void pointerFollowsGroup(std::vector<SGlassShape>& shapes, const std::vector<SGlassGroup>& groups);

    // Groups shapes whose boxes are closer than `smoothK` (the smooth union's reach, px; 0 = every
    // shape alone) into one group each, at most MAX_GROUP shapes per group. A pair with a pointer shape reaches
    // POINTER_SMOOTH x pxPerUnit instead (`smoothK` is in the boxes' units, which are pxPerUnit per pt).
    std::vector<SGlassGroup> groupShapes(const std::vector<SGlassShape>& shapes, double smoothK, double pxPerUnit = 1);

    // The texture area (px) to copy or blur so that a read anywhere in `r` at mip `level` or below
    // (bilinear, plus the half-texel tent of fetchSharp) touches only texels rebuilt from fresh pixels:
    // `r` grown to whole level-`level` texels plus one texel each side, clipped to w x h.
    // Outside it the texture keeps whatever an earlier frame or element left there.
    SRect mipFootprint(const SRect& r, int level, double w, double h);

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
