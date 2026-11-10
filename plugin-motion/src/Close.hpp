#pragma once
// macOS window close (AppKit ScaleDownAndOut, SPEC.md 11.2): Hyprland's windowsOut/fadeOut do the
// scale 1 -> 0.98 and alpha 1 -> 0; this adds the 0 -> 5 pt content blur, and fixes the empty
// close snapshot of clients that unmap by committing a null buffer.
namespace motion::close {
    // installs the hooks; returns false if a symbol was not found (the plugin still loads)
    bool init(void* handle);
    void exit();
}
