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
        MouseArea { anchors.fill: parent; z: -1 }   // swallow clicks so they don't close
    }

    // The column backdrop (Theme.nc.backdropDim) on the layer below, so the cards' glass samples it as on the Mac: one
    // feathered shadow under the column, riding with the slide. Same namespace (no layer animation), no glass, no input.
    PanelWindow {
        screen: ncw.modelData
        visible: ncw.visible
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
            // the 376 pt column frame: 16 pt either side of the cards (its right edge on the screen edge), from the
            // menu bar to 16 pt below the last item
            x: parent.width - Theme.nc.width - Theme.nc.marginRight - Theme.nc.backdropOutset
            y: 0
            width: Theme.nc.width + Theme.nc.marginRight + Theme.nc.backdropOutset + Theme.nc.backdropBlur
            height: nc.y + nc.height + Theme.nc.backdropOutset
            blur: Theme.nc.backdropBlur
            color: Theme.nc.backdropDim
            transform: Translate { x: nc.slideX }
        }
    }
}
