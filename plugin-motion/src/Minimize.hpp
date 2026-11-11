#pragma once
// Client minimize requests (the yellow light a client draws itself: GTK header bars, Xwayland windows).
// Hyprland 0.57.2 drops xdg_toplevel.set_minimized and the X11 iconify request (CWindow::onUpdateState only reads
// fullscreen and maximized), and it does not list MINIMIZE in xdg_toplevel.wm_capabilities, so GTK 4 greys its minimize
// button out. This sends the capability again with MINIMIZE (and a configure, which applies it) when a window maps, and
// turns a minimize request into the move to special:minimized that the hyprk title bars, Finder and Settings use, so
// the genie (main.cpp) plays the same way. `plugin:hyprkmotion:client_minimize = 0` turns both off.

namespace motion::minimize {
    void init(void* handle);
    void exit();
}
