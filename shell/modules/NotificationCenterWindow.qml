import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.services

// Notification Center on its own layer namespace (hyprk-notificationcenter), so the liquidglass plugin gives its cards
// the notificationCenter recipe and not the menu one (hyprk-overlay). Full-screen below the menu bar so a click
// outside the column closes it. Mapped only while the panel shows or slides.
ShellWindow {
    id: ncw

    required property var modelData
    screen: modelData

    // modelData, not screen: mapping the window re-emits screenChanged (binding loop)
    readonly property bool shown: nc.shown
    visible: shown || nc.animating || nc.progress > 0
    acceptsInput: shown
    glassOpacity: A11y.reduceMotion ? Math.max(0, Math.min(1, nc.progress)) : 1   // Reduce motion: a crossfade

    anchors { top: true; left: true; right: true; bottom: true }
    margins.top: Theme.menuBar.height
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-notificationcenter"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    MouseArea { anchors.fill: parent; enabled: ncw.shown; onPressed: Panels.close() }
    Item { anchors.fill: parent; focus: true; Keys.onEscapePressed: Panels.close() }

    NotificationCenter {
        id: nc
        anchors.right: parent.right
        anchors.rightMargin: Theme.nc.marginRight
        y: Theme.nc.marginTop
        maxHeight: ncw.height - y - 20
        onThisScreen: Panels.activeScreen === ncw.modelData
        originX: ncw.width - width - Theme.nc.marginRight
        originY: y + Theme.menuBar.height
        buttonHost: buttons
        MouseArea { anchors.fill: parent; z: -1 }   // swallow clicks so they don't close
    }

    // The buttons' glass ("Show less", a stack's x, "Show", "Edit Widgets" and its x: _Glass.regular, PC #62 Static RE)
    // on hyprk-overlay, which the plugin gives the regular (menu) face; on the cards' layer they would get the
    // notificationCenter recipe (about 121 over white instead of 179). Same geometry as this window so the shapes
    // land in place; below the cards' layer so the text drawn here stays on top. Glass only: no content, no input.
    ShellWindow {
        id: buttons
        screen: ncw.modelData
        visible: ncw.visible
        anchors { top: true; left: true; right: true; bottom: true }
        margins.top: Theme.menuBar.height
        exclusionMode: ExclusionMode.Ignore
        namespace: "hyprk-overlay"   // regular glass; no-anim like the other shell layers
        WlrLayershell.layer: WlrLayer.Top
        acceptsInput: false
        glassOpacity: ncw.glassOpacity
    }

    // The column backdrop (Theme.nc.backdropDim, plugin hand-off): a Top-layer surface below the cards and the buttons, so
    // their glass samples it as on the Mac: one feathered shadow under the column, riding with the slide (no fade of
    // its own). Its visibility follows the buttons' window, which makes Hyprland list it below that one (checked with
    // hyprctl layers; bound to ncw.visible directly it landed on top and darkened the buttons). Same namespace as the
    // cards (no layer animation), no glass, no input. The column blur (sigma about 3 pt) is not done.
    PanelWindow {
        id: dim
        screen: ncw.modelData
        visible: buttons.visible
        anchors { top: true; right: true }
        margins.top: Theme.menuBar.height
        implicitWidth: Theme.nc.width + Theme.nc.marginRight + Theme.nc.backdropOutset + Theme.nc.backdropBlur * 2
        implicitHeight: nc.y + nc.height + Theme.nc.backdropOutset + Theme.nc.backdropBlur * 2
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "hyprk-notificationcenter"
        WlrLayershell.layer: WlrLayer.Top
        color: "transparent"
        mask: Region {}
        RectangularShadow {
            // the 376 pt column frame: 16 pt either side of the cards, its right edge on the screen edge, from the
            // menu bar to 16 pt below the last widget. The feather is there on the right too: the Mac's dim over white
            // above the cards (nc/overview-redacted-dark-white.png row 5) is 207 until 62 pt from the screen edge, then
            // 210 213 217 220 at 42 32 23 17 pt (a Gaussian edge of sigma 26.5 pt, 1 pt inside the screen edge; the
            // left side's is 27.3), and the pixels outside a card are the same left and right (stack-dark-grey.png
            // 99.5 / 99.5, white 200 / 200). The frame used to run 50 pt past the screen edge: flat to the edge, the
            // card's right outside 96 against 102 on the left over grey 127, 192 / 206 over white
            x: parent.width - Theme.nc.width - Theme.nc.marginRight - Theme.nc.backdropOutset
            y: 0
            width: Theme.nc.width + Theme.nc.marginRight + Theme.nc.backdropOutset
            // to 16 pt below the last widget: it fades out over about 55 pt there (Mac about 85) and 20 pt below
            // "Edit Widgets" the Mac's backdrop is back to 1
            height: nc.y + nc.height - Theme.nc.editGap - Theme.nc.pillHeight + Theme.nc.backdropOutset
            blur: Theme.nc.backdropBlur
            radius: Theme.nc.backdropRadius
            color: Theme.nc.backdropDim
            transform: Translate { x: nc.slideX }
        }
    }
}
