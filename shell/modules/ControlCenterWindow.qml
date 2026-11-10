import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.services
import qs.HyprK
import "../lib/spring.js" as SpringLib

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

    // MAC-ANSWERS.md "REA 27.2.1" section 2 (ControlCenter FUN_1002dc74c / FUN_1002dce40): open and close
    // both run withAnimation(Spring(duration: 0.25, bounce: -0.027)) = response 0.25 s, damping ratio 1.028, on
    // a transition progress that sets bentoBoxOpacity = progress and bentoBoxScale = 1.01 - 0.01 x progress
    // (hidden: opacity 0, scale 1.01). Here `fade` is that opacity, on one exact spring (components/SpringCurve.qml)
    // in both directions; the window goes when it settles (0.4 s). Glass and content take the same value in the
    // same frame: the plugin glass as glassOpacity, the content as opacity. The scale anchor is not read: the
    // panel's centre (SwiftUI's default). Reduce motion: no scale (Theme.travel), at most 0.15 s (Theme.ms).
    property real fade: 0
    SpringCurve { id: fadeAnim; target: ccw; property: "fade"; spring: SpringLib.fromBounce(0.25, -0.027) }
    onShownChanged: {
        fadeAnim.go(shown ? 1 : 0);
        settleGlass(fadeAnim.duration + 50);      // the glass follows the 1 % scale
    }
    onVisibleChanged: if (visible) settleGlass(fadeAnim.duration + 50)
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
        scale: 1 + Theme.travel(0.01) * (1 - ccw.fade)
        MouseArea { anchors.fill: parent; z: -1 }   // swallow clicks so they don't close
    }

}
