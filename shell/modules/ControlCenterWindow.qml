import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.HyprK
import qs.services
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
    // both run withAnimation(Spring(duration: 0.25, bounce: -0.027)) = response 0.25 s, critically damped (SwiftUI clamps
    // the ratio 1.028 to 1, lib/spring.js fromBounce), on
    // a transition progress that sets bentoBoxOpacity = progress and bentoBoxScale = 1.01 - 0.01 x progress
    // (hidden: opacity 0, scale 1.01). Here `fade` is that opacity, on one exact spring (components/SpringCurve.qml)
    // in both directions; the window goes when it settles (0.4 s). Glass and content take the same value in the
    // same frame: the plugin glass as glassOpacity, the content as opacity. The scale anchor is not read: the
    // panel's centre (SwiftUI's default). Reduce motion: no scale (Theme.travel), at most 0.15 s (Theme.ms).
    property real fade: 0
    readonly property var fadeSpring: SpringLib.fromBounce(0.25, -0.027)
    // settlesGlass: the glass follows the 1 % scale, re-measured in the frame that draws the value
    SpringCurve { id: fadeAnim; target: ccw; property: "fade"; spring: ccw.fadeSpring; settlesGlass: true }
    onShownChanged: {
        if (shown) { morphAnim.stop(); module = ""; morph = 0; }
        fadeAnim.go(shown ? 1 : 0);
    }
    // A module opened from the grid (the Sound row's output button) takes the grid's place (MAC-ANSWERS.md
    // Q-panels-12: "a morph of about 0.35 s", curve not measured; not a shape morph here): the grid's glass
    // materializes out and the panel's in, contents cross-fade, on the panel's own open spring (REA section 2,
    // response 0.25 s, settles in about 0.35 s). Esc goes back to the grid, a second Esc closes; a click outside closes.
    property string module: ""
    property real morph: 0
    SpringCurve { id: morphAnim; target: ccw; property: "morph"; spring: ccw.fadeSpring; settlesGlass: true }
    onModuleChanged: morphAnim.go(module !== "" ? 1 : 0)
    glassMaterialize: 1
    glassOpacity: fade
    // while fading out the layer takes no input, so it never eats the click
    // that opened the next panel
    acceptsInput: shown
    MouseArea { anchors.fill: parent; enabled: ccw.shown; onPressed: Panels.close() }
    Item { anchors.fill: parent; focus: true; Keys.onEscapePressed: if (ccw.module !== "") ccw.module = ""; else Panels.close() }

    ControlCenter {
        id: cc
        anchors.right: parent.right
        anchors.rightMargin: Theme.cc.right
        y: Theme.cc.top
        originX: ccw.width - width - Theme.cc.right
        originY: y + Theme.menuBar.height
        opacity: ccw.fade * (1 - ccw.morph)
        visible: ccw.morph < 1
        gridShown: 1 - ccw.morph
        scale: 1 + Theme.travel(0.01) * (1 - ccw.fade)
        onModuleRequested: name => ccw.module = name
        MouseArea { anchors.fill: parent; z: -1 }   // swallow clicks so they don't close
    }

    CcSoundPanel {
        anchors.right: parent.right
        anchors.rightMargin: Theme.cc.modulePanelRight
        y: Theme.cc.modulePanelTop
        originX: ccw.width - width - Theme.cc.modulePanelRight
        originY: y + Theme.menuBar.height
        visible: ccw.module === "sound" || (ccw.morph > 0 && morphAnim.running)
        materialize: ccw.morph
        opacity: ccw.fade * ccw.morph
        scale: 1 + Theme.travel(0.01) * (1 - ccw.fade)
        onSettingsRequested: { Panels.close(); Apps.runHyprkApp("org.hyprk.Settings", { HYPRK_SETTINGS_PANE: "sound" }); }
        MouseArea { anchors.fill: parent; z: -1 }
    }

    // The panel's dim (Theme.cc.dim) on the layer below, so the tiles' glass samples it as on the Mac. Same
    // namespace (no layer animation, the fade is ours), no glass region, no input.
    PanelWindow {
        screen: ccw.modelData
        visible: ccw.visible
        anchors { top: true; right: true }
        margins.top: Theme.menuBar.height
        implicitWidth: cc.width + Theme.cc.right + Theme.cc.dimFeather * 1.5
        implicitHeight: cc.y + cc.height + Theme.cc.dimFeather * 1.5
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "hyprk-controlcenter"
        WlrLayershell.layer: WlrLayer.Top
        color: "transparent"
        mask: Region {}
        // the same spring on this window's own frames: a value stepped in the panel's frame reaches this window
        // one frame late or not, by turns
        id: dimWin
        property real fade: 0
        SpringCurve { id: dimAnim; target: dimWin; property: "fade"; spring: ccw.fadeSpring }
        Connections {
            target: ccw
            function onShownChanged() { dimAnim.go(ccw.shown ? 1 : 0); }
        }
        // full inside the tiles' box (and past the screen and menu bar edges), about 75 % at 12 pt outside; dithered
        // (shaders/dimfeather.frag: an 8 bit alpha ramp of 26 levels over the feather showed as rings, user report)
        ShaderEffect {
            anchors.fill: parent
            property color color: Theme.cc.dim
            property vector4d rect: Qt.vector4d(width - cc.width - Theme.cc.right - 30, -Theme.cc.dimFeather,
                                                cc.width + Theme.cc.right + 30 + Theme.cc.dimFeather, cc.y + cc.height + 30 + Theme.cc.dimFeather)
            property size sizePt: Qt.size(width, height)
            property real sigma: Theme.cc.dimFeather * 0.27
            opacity: dimWin.fade
            fragmentShader: Qt.resolvedUrl("../shaders/dimfeather.frag.qsb")
        }
    }

}
