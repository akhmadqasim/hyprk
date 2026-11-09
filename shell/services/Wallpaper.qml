pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs

// Provides the wallpaper and a pre-blurred copy used as the glass backdrop.
// All panels sample the blurred copy at their own screen position, so the
// material looks like frosted glass over the desktop without per-frame blur.
Singleton {
    id: root

    property string wallpaper: ""
    property string blurred: ""
    property int width: Quickshell.screens.length > 0 ? Quickshell.screens[0].width : 1920
    property int height: Quickshell.screens.length > 0 ? Quickshell.screens[0].height : 1080

    function refresh() {
        proc.running = false;
        proc.running = true;
    }

    onWidthChanged: refresh()
    onHeightChanged: refresh()
    Component.onCompleted: refresh()
    Connections {
        target: Theme
        function onDarkChanged() { root.refresh(); }
    }

    Process {
        id: proc
        command: [Theme.root + "/scripts/wallpaper.sh", String(root.width), String(root.height), String(Theme.glass.blurRadius), Theme.dark ? "dark" : "light"]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.split("\n")) {
                    if (line.startsWith("WALL=")) root.wallpaper = line.slice(5);
                    else if (line.startsWith("BLUR=")) root.blurred = line.slice(5);
                }
                Theme.blurAvailable = root.blurred !== "";
            }
        }
    }
}
