import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs
import qs.components
import qs.services

// Pull-down menu of the menu bar, macOS 26 style: rounded glass, inset
// rounded selection, shortcut column on the right.
Item {
    id: root

    property var items: []
    property real originX: 0       // screen position of this item, for the glass backdrop
    property real originY: 0

    readonly property real contentWidth: Math.max(Theme.menu.minWidth, maxTextWidth + Theme.menu.itemHPadding * 2 + Theme.menu.itemInset * 2 + 40)
    width: contentWidth
    height: list.height + Theme.menu.padding * 2

    signal triggered()

    function trigger(action) {
        Panels.close();
        triggered();
        switch (action) {
        case "settings": Apps.openSettings(); break;
        case "forcequit": Hyprland.dispatch("hl.dsp.window.kill()"); break;
        case "close": Hyprland.dispatch("hl.dsp.window.close()"); break;
        case "fullscreen": Hyprland.dispatch("hl.dsp.window.fullscreen()"); break;
        case "zoom": Hyprland.dispatch("hl.dsp.window.fullscreen({ mode = \"maximized\" })"); break;
        case "spotlight": Panels.open = "spotlight"; break;
        case "launchpad": Panels.open = "launchpad"; break;
        case "sleep": Power.sleep(); break;
        case "restart": Power.restart(); break;
        case "shutdown": Power.shutdown(); break;
        case "lock": Power.lock(); break;
        case "logout": Power.logout(); break;
        case "trash-open": Quickshell.execDetached(["gio", "open", "trash:///"]); break;
        case "trash-empty": Quickshell.execDetached(["sh", "-c", `gio trash --empty && "${Sounds.script}" trash-empty`]); break;
        }
    }

    // width of the widest label + shortcut
    FontMetrics { id: metrics; font.family: Theme.fontText; font.pixelSize: Theme.font.menu }
    readonly property real maxTextWidth: {
        let w = 0;
        for (const it of items)
            if (!it.sep) w = Math.max(w, metrics.advanceWidth(it.label) + (it.shortcut ? metrics.advanceWidth(it.shortcut) + 30 : 0));
        return w;
    }

    Glass {
        anchors.fill: parent
        radius: Theme.menu.radius
        sx: root.originX
        sy: root.originY
        tint: Theme.glass.tintStrong
    }

    Column {
        id: list
        y: Theme.menu.padding
        width: parent.width

        Repeater {
            model: root.items
            delegate: Item {
                id: row
                required property var modelData
                readonly property bool enabled: !modelData.sep && !modelData.disabled
                width: list.width
                height: modelData.sep ? Theme.menu.separatorHeight : Theme.menu.itemHeight

                Rectangle {
                    visible: row.modelData.sep === true
                    anchors.centerIn: parent
                    width: parent.width - Theme.menu.itemInset * 2 - Theme.menu.itemHPadding
                    height: 1
                    color: Theme.color.separator
                }
                Rectangle {
                    visible: !row.modelData.sep
                    anchors.fill: parent
                    anchors.leftMargin: Theme.menu.itemInset
                    anchors.rightMargin: Theme.menu.itemInset
                    radius: Theme.menu.itemRadius
                    color: Theme.color.menuSelection
                    opacity: ma.containsMouse && row.enabled ? 1 : 0
                }
                Text {
                    visible: !row.modelData.sep
                    anchors.verticalCenter: parent.verticalCenter
                    x: Theme.menu.itemInset + Theme.menu.itemHPadding
                    text: row.modelData.label || ""
                    font.family: Theme.fontText
                    font.pixelSize: Theme.font.menu
                    color: !row.enabled ? Theme.color.tertiaryLabel : ma.containsMouse ? Theme.color.menuSelectionText : Theme.color.label
                }
                Text {
                    visible: !row.modelData.sep && (row.modelData.shortcut !== undefined)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.menu.itemInset + Theme.menu.itemHPadding
                    text: row.modelData.shortcut || ""
                    font.family: Theme.fontText
                    font.pixelSize: Theme.font.menu
                    color: ma.containsMouse && row.enabled ? Theme.color.menuSelectionText : Theme.color.tertiaryLabel
                }
                Symbol {
                    visible: row.modelData.submenu === true
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.menu.itemInset + Theme.menu.itemHPadding - 4
                    name: "chevron.right"
                    size: 11
                    color: ma.containsMouse && row.enabled ? Theme.color.menuSelectionText : Theme.color.secondaryLabel
                }
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: if (row.enabled) root.trigger(row.modelData.action)
                }
            }
        }
    }
}
