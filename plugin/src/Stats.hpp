#pragma once
// Optional GPU timing (plugin:liquidglass:stats = 1): GL timestamp queries around each
// monitor frame and around the plugin's own drawing, read back without stalling.
// `hyprctl liquidglass` prints the averages.

#include <string>

namespace lg::stats {
    enum eKind { FRAME = 0, GLASS = 1, SHADOW = 2 };

    bool        enabled();
    void        setEnabled(bool on);
    // opens/closes one measured interval; no-ops when disabled or unsupported
    void        begin(eKind kind);
    void        end(eKind kind);
    void        poll(); // collect finished queries
    std::string report();
    void        reset();
    void        release(); // GL objects, PLUGIN_EXIT
}
