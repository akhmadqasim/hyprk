#pragma once
// Pure layout of the macOS title bar, bar-local logical px (unit tested).

#include <hyprutils/math/Box.hpp>

#include <array>

namespace lg {
    using Hyprutils::Math::CBox;

    struct STitlebarLayout {
        std::array<CBox, 3> buttons; // close, minimise, zoom
        CBox                title;   // area of the left-aligned title (starts where the Mac draws it)
    };

    // title x after the zoom light's right edge, pt: proxy icon 13 pt after it, 16 pt wide, then 2 pt (Q-windows-11)
    constexpr double TITLE_AFTER_LIGHTS = 31;

    STitlebarLayout titlebarLayout(double width, double height, double button, double gap, double inset);

    // which button contains the point (bar-local), -1 if none; half a gap of slack around each light
    int buttonAt(const STitlebarLayout& l, double x, double y, double gap);

    // the lights group plus slack: hovering it shows the glyphs on all three (macOS behaviour)
    CBox lightsArea(const STitlebarLayout& l, double gap);
}
