#pragma once
// Pure layout of the macOS title bar, bar-local logical px (unit tested).

#include <hyprutils/math/Box.hpp>

#include <array>

namespace lg {
    using Hyprutils::Math::CBox;

    struct STitlebarLayout {
        std::array<CBox, 3> buttons; // close, minimise, zoom
        CBox                title;   // area the centred title may use (symmetric, clear of the lights)
    };

    STitlebarLayout titlebarLayout(double width, double height, double button, double gap, double inset);

    // which button contains the point (bar-local), -1 if none; half a gap of slack around each light
    int buttonAt(const STitlebarLayout& l, double x, double y, double gap);

    // the lights group plus slack: hovering it shows the glyphs on all three (macOS behaviour)
    CBox lightsArea(const STitlebarLayout& l, double gap);
}
