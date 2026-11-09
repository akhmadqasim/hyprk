#include "TitlebarLayout.hpp"

#include <algorithm>

namespace lg {
    STitlebarLayout titlebarLayout(double width, double height, double button, double gap, double inset) {
        STitlebarLayout l;
        const double    y = (height - button) / 2;
        for (int i = 0; i < 3; ++i)
            l.buttons[i] = CBox{inset + i * (button + gap), y, button, button};
        const double side = l.buttons[2].x + button + gap * 2; // keep the title centred on the bar
        l.title           = CBox{side, 0, std::max(0.0, width - 2 * side), height};
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
