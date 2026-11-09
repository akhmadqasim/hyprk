#include "Log.hpp"

#include <hyprland/src/debug/log/Logger.hpp>
#include <hyprland/src/helpers/Color.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>

namespace lg {
    static HANDLE s_handle = nullptr;
    static bool   s_noticeShown = false;

    void setHandle(void* handle) {
        s_handle = handle;
    }

    void logInfo(const std::string& msg) {
        LOG(Log::INFO, "[liquidglass] {}", msg);
    }

    void logOnce(const std::string& msg) {
        if (s_noticeShown)
            return;
        s_noticeShown = true;
        LOG(Log::ERR, "[liquidglass] {}", msg);
        if (s_handle)
            HyprlandAPI::addNotification(s_handle, "[liquidglass] " + msg, CHyprColor{1.0, 0.6, 0.2, 1.0}, 6000);
    }

    void resetLogOnce() {
        s_noticeShown = false;
    }
}
