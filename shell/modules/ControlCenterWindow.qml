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

    // modelData, not screen: mapping the window re-emits screenChanged, which made
    // this binding loop on every open
    readonly property bool shown: Panels.open === "cc" && Panels.activeScreen === modelData
    visible: shown || cc.opacity > 0

    anchors { top: true; left: true; right: true; bottom: true }
    margins.top: Theme.menuBar.height
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-controlcenter"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // while fading out the layer takes no input, so it never eats the click
    // that opened the next panel
    glassOpacity: cc.opacity
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
        opacity: 0
        scale: 0.96
        transformOrigin: Item.TopRight
        MouseArea { anchors.fill: parent; z: -1 }   // swallow clicks so they don't close
    }

    // open on the SwiftUI spring, close fast; each starts from wherever the other left off
    onShownChanged: {
        openAnim.stop();
        closeAnim.stop();
        (shown ? openAnim : closeAnim).start();
    }
    ParallelAnimation {
        id: openAnim
        NumberAnimation { target: cc; property: "opacity"; to: 1; duration: Theme.anim.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.spring }
        NumberAnimation { target: cc; property: "scale"; to: 1; duration: Theme.anim.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.spring }
    }
    ParallelAnimation {
        id: closeAnim
        NumberAnimation { target: cc; property: "opacity"; to: 0; duration: Theme.anim.close; easing.type: Theme.anim.easing }
        NumberAnimation { target: cc; property: "scale"; to: 0.96; duration: Theme.anim.close; easing.type: Theme.anim.easing }
    }
}
