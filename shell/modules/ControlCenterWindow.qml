import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.services
import qs.HyprK

// Control Center on its own layer namespace (hyprk-controlcenter) so the
// liquidglass plugin gives its tiles the controlcenter recipe, not the menu one.
// Full-screen below the menu bar so a click outside the tiles closes it.
ShellWindow {
    id: ccw

    required property var modelData
    screen: modelData

    // modelData, not screen: mapping the window re-emits screenChanged, which made
    // this binding loop on every open
    readonly property bool shown: Panels.open === "cc" && Panels.activeScreen === modelData
    visible: shown || fadeAnim.running

    anchors { top: true; left: true; right: true; bottom: true }
    margins.top: Theme.menuBar.height
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-controlcenter"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // MAC-ANSWERS.md R2 (27.2.1): Control Center fades in, no scale and no slide (the tiles are in
    // their final place from the first frame), the tile glass filling in during the same fade: share of
    // the change 0.16, 0.29, 0.40, 0.51, 0.61, 0.71 ... at 17 ms steps, 1.0 at about 0.3 s. OutCubic over
    // 320 ms fits it within 0.03 (least squares over OutQuad..OutQuint and springs). It fades out in
    // about 0.17 to 0.2 s (curve not measured: ease-out like the menus). Glass and content take the same
    // value in the same frame: the plugin glass as glassOpacity, the content as opacity.
    // Reduce motion: the same fade, at most 0.15 s (Theme.ms).
    property real fade: 0
    NumberAnimation { id: fadeAnim; target: ccw; property: "fade"; easing.type: Easing.OutCubic }
    onShownChanged: {
        fadeAnim.stop();
        fadeAnim.to = shown ? 1 : 0;
        fadeAnim.duration = Theme.ms(shown ? 320 : 200);
        fadeAnim.start();
    }
    glassMaterialize: 1
    glassOpacity: fade
    // while fading out the layer takes no input, so it never eats the click
    // that opened the next panel
    acceptsInput: shown
    MouseArea { anchors.fill: parent; enabled: ccw.shown; onPressed: Panels.close() }
    Item { anchors.fill: parent; focus: true; Keys.onEscapePressed: Panels.close() }

    ControlCenter {
        id: cc
        anchors.right: parent.right
        anchors.rightMargin: Theme.cc.marginRight
        y: Theme.cc.marginTop
        originX: ccw.width - width - Theme.cc.marginRight
        originY: y + Theme.menuBar.height
        opacity: ccw.fade
        MouseArea { anchors.fill: parent; z: -1 }   // swallow clicks so they don't close
    }

}
