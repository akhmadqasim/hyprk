#pragma once
#include <string>

namespace lg {
    void  setHandle(void* handle);
    void* handle(); // the plugin HANDLE from PLUGIN_INIT
    void logInfo(const std::string& msg);
    // logs + one desktop notification, then stays quiet until resetLogOnce()
    void logOnce(const std::string& msg);
    void resetLogOnce();
}
