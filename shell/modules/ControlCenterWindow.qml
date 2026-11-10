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
    visible: shown || appear.moving    // the spring overshoots below 0 on close: not its value

    anchors { top: true; left: true; right: true; bottom: true }
    margins.top: Theme.menuBar.height
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-controlcenter"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // Liquid Glass: each module's glass materializes (lensing, blur and rim ramp in, shrinking from
    // its hidden scale, ControlCenter.qml Module) on the SwiftUI transition spring while the content
    // fades in; Reduce motion: a short crossfade of glass and content, no scale
    glassMaterialize: A11y.reduceMotion ? 1 : appear.value
    glassOpacity: A11y.reduceMotion ? cc.opacity : 1
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
        opacity: Math.max(0, Math.min(1, appear.value))
        MouseArea { anchors.fill: parent; z: -1 }   // swallow clicks so they don't close
    }

    // retargets from wherever it is (Glass items re-measure themselves as materialize changes)
    Spring {
        id: appear
        target: ccw.shown ? 1 : 0
        response: A11y.reduceMotion ? Tokens.motion.crossfade : Tokens.motion.materializeResponse
        damping: A11y.reduceMotion ? 1 : Tokens.motion.materializeDamping
    }
}
