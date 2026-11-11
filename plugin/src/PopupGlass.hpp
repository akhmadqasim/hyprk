#pragma once
// Glass behind the xdg_popups of windows whose class matches popup_classes (PopupGlass.cpp)

#include "Config.hpp"

#include <memory>

namespace lg {
    void initPopupGlass(void* handle, std::shared_ptr<const SParams> (*params)());
    void exitPopupGlass(void* handle);
}
