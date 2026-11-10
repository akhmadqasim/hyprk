#include "TitlebarLayout.hpp"

#include <algorithm>

namespace lg {
    STitlebarLayout titlebarLayout(double width, double height, double button, double gap, double inset) {
        STitlebarLayout l;
        const double    y = (height - button) / 2;
        for (int i = 0; i < 3; ++i)
            l.buttons[i] = CBox{inset + i * (button + gap), y, button, button};
        // left-aligned title (MAC-ANSWERS.md Q-windows-11, TextEdit): zoom disc ends at 69, the 16 pt proxy icon
        // sits at 82 and the title starts at 100, so 31 pt after the last light; the right margin mirrors the inset
        const double x = l.buttons[2].x + button + TITLE_AFTER_LIGHTS;
        l.title        = CBox{x, 0, std::max(0.0, width - inset - x), height};
        return l;
    }

    int buttonAt(const STitlebarLayout& l, double x, double y, double gap) {
        for (int i = 0; i < 3; ++i) {
            const auto& b = l.buttons[i];
            if (x >= b.x - gap / 2 && x < b.x + b.w + gap / 2 && y >= b.y - gap / 2 && y < b.y + b.h + gap / 2)
                return i;
        }
        return -1;
    }

    CBox lightsArea(const STitlebarLayout& l, double gap) {
        const auto& a = l.buttons[0];
        const auto& c = l.buttons[2];
        return CBox{a.x - gap, a.y - gap, c.x + c.w - a.x + 2 * gap, a.h + 2 * gap};
    }
}
