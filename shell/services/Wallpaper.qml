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
    property real topLuma: 0.3                  // brightness behind the menu bar
    readonly property string url: wallpaper ? "file://" + wallpaper : ""
    readonly property string blurredUrl: blurred ? "file://" + blurred : ""
    readonly property int thumbWidth: 320       // one decode size shared by all wallpaper thumbnails
    property int width: Panels.screen ? Panels.screen.width : 1920
    property int height: Panels.screen ? Panels.screen.height : 1080

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

    // state/wallpaper.json path (Settings > Wallpaper) wins over the default pick
    readonly property string chosen: Prefs.wallpaper.path || ""
    // later: the Process `environment` binding reads `chosen` too and may not have updated yet, so the
    // script ran with the previous wallpaper (bar text colour one wallpaper behind)
    onChosenChanged: Qt.callLater(refresh)

    Process {
        id: proc
        environment: ({ HYPRK_WALLPAPER: root.chosen })
        command: [Quickshell.shellDir + "/scripts/wallpaper.sh", String(root.width), String(root.height), String(Theme.glass.blurRadius), Theme.dark ? "dark" : "light"]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.split("\n")) {
                    if (line.startsWith("WALL=")) root.wallpaper = line.slice(5);
                    else if (line.startsWith("BLUR=")) root.blurred = line.slice(5);
                    else if (line.startsWith("LUMA=")) root.topLuma = parseFloat(line.slice(5)) || 0.3;
                }
                Theme.menuBarOnLight = root.topLuma > Theme.menuBarLumaThreshold;
                Theme.blurAvailable = root.blurred !== "";
            }
        }
    }
}
