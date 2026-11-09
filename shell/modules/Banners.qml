import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.services

// Notification banners, top-right below the menu bar. They slide in from
// the right and expire after Theme.notif.timeout unless hovered.
PanelWindow {
    id: win

    required property var modelData
    screen: modelData

    visible: Notifs.banners.length > 0 && Panels.open !== "nc"
    anchors { top: true; right: true }
    margins.top: Theme.notif.marginTop
    margins.right: Theme.notif.marginRight - 24
    implicitWidth: Theme.notif.width + 24 * 2        // room for shadow and close button
    implicitHeight: Math.max(1, col.height + 40)
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.namespace: "hyprk-notifications"
    WlrLayershell.layer: WlrLayer.Overlay

    Column {
        id: col
        x: 24
        y: 8
        spacing: Theme.notif.spacing

        Repeater {
            model: Notifs.banners
            delegate: NotifCard {
                id: card
                required property var modelData
                width: Theme.notif.width
                nid: modelData.id
                appName: modelData.appName || "Notification"
                appIcon: modelData.appIcon || modelData.desktopEntry || ""
                summary: modelData.summary
                body: modelData.body
                // banner window origin: right-aligned below the menu bar
                sx: win.screen.width - win.width - (Theme.notif.marginRight - 24) + x + col.x
                sy: Theme.menuBar.height + Theme.notif.marginTop + y + col.y
                onClicked: { Notifs.invokeDefault(nid); Notifs.hideBanner(nid); }
                onClosed: Notifs.dismiss(nid)

                transform: Translate { id: slide; x: 0 }
                Component.onCompleted: slideIn.start()
                NumberAnimation {
                    id: slideIn
                    target: slide
                    property: "x"
                    from: Theme.notif.width
                    to: 0
                    duration: Theme.anim.bannerIn
                    easing.type: Easing.OutCubic
                }
                Timer {
                    interval: card.modelData.expireTimeout > 0 ? card.modelData.expireTimeout : Theme.notif.timeout
                    running: !hoverCatcher.hovered && card.modelData.urgency !== 2
                    onTriggered: Notifs.hideBanner(card.nid)
                }
                HoverHandler { id: hoverCatcher }
            }
        }
    }
}
