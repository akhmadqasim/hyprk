import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.services

// Control Center on its own layer namespace (hyprk-controlcenter) so the
// liquidglass plugin gives its tiles the controlcenter recipe, not the menu one.
// Full-screen below the menu bar so a click outside the tiles closes it.
ShellWindow {
    id: ccw

    required property var modelData
    screen: modelData

    readonly property bool shown: Panels.open === "cc" && Panels.activeScreen === screen
    visible: shown || cc.opacity > 0

    anchors { top: true; left: true; right: true; bottom: true }
    margins.top: Theme.menuBar.height
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-controlcenter"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // while fading out the layer takes no input, so it never eats the click
    // that opened the next panel
    mask: shown ? null : noInput
    Region { id: noInput }
    MouseArea { anchors.fill: parent; enabled: ccw.shown; onPressed: Panels.close() }
    Item { anchors.fill: parent; focus: true; Keys.onEscapePressed: Panels.close() }

    ControlCenter {
        id: cc
        anchors.right: parent.right
        anchors.rightMargin: Theme.cc.marginRight
        y: Theme.cc.marginTop
        originX: ccw.width - width - Theme.cc.marginRight
        originY: y + Theme.menuBar.height
        opacity: ccw.shown ? 1 : 0
        scale: ccw.shown ? 1 : 0.96
        transformOrigin: Item.TopRight
        readonly property int dur: ccw.shown ? Theme.anim.normal : Theme.anim.close
        Behavior on opacity { NumberAnimation { duration: cc.dur; easing.type: Theme.anim.easing } }
        Behavior on scale { NumberAnimation { duration: cc.dur; easing.type: Theme.anim.easing } }
        MouseArea { anchors.fill: parent; z: -1 }   // swallow clicks so they don't close
    }
}
