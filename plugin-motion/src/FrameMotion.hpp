#pragma once
// Unzoom and full screen enter/exit motion (Frame.hpp) on Hyprland's own position/size animations: when the
// fullscreen state of a window changes, its two animated variables get a private "linear" config whose speed is
// set every tick so the shown share follows the Mac's progress (holds included). Zoom keeps windowsMove.
// The Mac's Space slide (desktop out to the left, black Space in from the right) is not drawn: a black Space
// sliding over a still desktop measured worse against the Mac series than the window alone (MOTION-PLUGIN.md).
#include <hyprland/src/plugins/PluginAPI.hpp>

namespace motion::frame {
    void init(HANDLE handle);
    void exit();
    void tick();
}
